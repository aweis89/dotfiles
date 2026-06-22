function __bw_file_run_with_timeout
    set -l seconds $argv[1]
    set -e argv[1]

    if command -q timeout
        command timeout -k 5 "$seconds" $argv
    else if command -q gtimeout
        command gtimeout -k 5 "$seconds" $argv
    else
        command $argv
    end
end

function __bw_file_home_name
    set -l path_name $argv[1]
    set -l home_regex (string escape --style=regex "$HOME")

    string replace -r "^$home_regex(?=/|\$)" '~' "$path_name"
end

function __bw_file_find_item
    set -l candidate_json (printf '%s\n' $argv | jq -R . | jq -s .)

    echo "  Loading Bitwarden item list..." >&2
    set -l item_match (bw list items 2>/dev/null | jq -er --argjson names "$candidate_json" '
        first(
            $names[] as $name
            | .[]
            | select(.name == $name)
            | [.id, .name]
            | @tsv
        )
    ' 2>/dev/null)

    if test $status -ne 0 -o -z "$item_match"
        return 1
    end

    set -l matched_item_parts (string split \t -- "$item_match")
    set -l item_id $matched_item_parts[1]
    set -l matched_name $matched_item_parts[2]

    for candidate in $argv
        echo "  Looking for Bitwarden item: $candidate" >&2

        if test "$candidate" = "$matched_name"
            printf '%s\n%s\n' "$item_id" "$candidate"
            return 0
        end
    end

    return 1
end

function bw-file
    set -l action $argv[1]
    set -l file_path $argv[2]
    set -l original_path $file_path
    set -l bw_timeout (set -q BW_FILE_TIMEOUT; and echo "$BW_FILE_TIMEOUT"; or echo 30)
    set -l bw_unlock_timeout (set -q BW_FILE_UNLOCK_TIMEOUT; and echo "$BW_FILE_UNLOCK_TIMEOUT"; or echo 180)

    if test -z "$action" -o -z "$file_path"
        echo "Usage: bw-file [backup|restore] <file-path>"
        echo "  backup  - Save file to Bitwarden"
        echo "  restore - Restore file from Bitwarden"
        echo ""
        echo "Examples:"
        echo "  bw-file backup ~/.aws/config"
        echo "  bw-file restore ~/.ssh/config"
        return 1
    end

    for required_command in bw jq mktemp
        if not command -q "$required_command"
            echo "Missing required command: $required_command"
            return 1
        end
    end

    # Expand ~ to home directory for file operations
    set file_path (string replace -r '^~(?=/|$)' "$HOME" "$file_path")

    if not string match -q '/*' "$file_path"
        set file_path (path resolve "$PWD/$file_path")
    else
        set file_path (path resolve "$file_path")
    end

    # Normalize path for item name (replace $HOME with ~ for portability).
    set -l item_name (__bw_file_home_name "$file_path")
    set -l candidate_names "$item_name"

    set -l expanded_original_path (string replace -r '^~(?=/|$)' "$HOME" "$original_path")
    set -l legacy_names (__bw_file_home_name "$expanded_original_path")
    if not string match -q '/*' "$expanded_original_path"
        set -a legacy_names "$expanded_original_path"
    end

    set -l pwd_path (path resolve "$PWD")
    set -l pwd_regex (string escape --style=regex "$pwd_path")
    set -l pwd_relative_path (string replace -r "^$pwd_regex/" '' "$file_path")
    if test "$pwd_relative_path" != "$file_path"
        set -a legacy_names "$pwd_relative_path" "./$pwd_relative_path"
    end

    for candidate in $legacy_names
        if test -n "$candidate"; and not contains -- "$candidate" $candidate_names
            set -a candidate_names "$candidate"
        end
    end

    set -l status_json (__bw_file_run_with_timeout "$bw_timeout" bw status 2>/dev/null)
    if test $status -ne 0
        echo "Failed to read Bitwarden status"
        return 1
    end

    set -l vault_status (printf '%s\n' $status_json | jq -r '.status // empty' 2>/dev/null)
    switch "$vault_status"
        case unauthenticated
            echo "Not logged in to Bitwarden. Please run: bw login"
            return 1
        case locked
            echo "Bitwarden vault is locked. Unlocking..."
            read --silent --local --prompt-str "Master password: " bw_master_password
            set -l read_status $status
            echo

            if test $read_status -ne 0 -o -z "$bw_master_password"
                echo "Failed to read master password"
                return 1
            end

            set -lx BW_FILE_MASTER_PASSWORD "$bw_master_password"
            set -e bw_master_password

            set -gx BW_SESSION (__bw_file_run_with_timeout "$bw_unlock_timeout" bw unlock --raw --passwordenv BW_FILE_MASTER_PASSWORD 2>/dev/null)
            set -l unlock_status $status
            set -e BW_FILE_MASTER_PASSWORD

            if test $unlock_status -ne 0 -o -z "$BW_SESSION"
                echo "Failed to unlock vault"
                return 1
            end
            # Ensure local cache is fresh to avoid stale cipher errors.
            bw sync >/dev/null 2>&1
        case unlocked
            # Already usable.
        case '*'
            echo "Unexpected Bitwarden status: $vault_status"
            return 1
    end

    switch $action
        case backup save
            if not test -f "$file_path"
                echo "✗ File not found: $file_path"
                return 1
            end

            echo "Backing up $file_path to Bitwarden..."

            # Check if item already exists
            set -l item_match (__bw_file_find_item $candidate_names)
            set -l item_id $item_match[1]
            set -l matched_item_name $item_match[2]

            if test -z "$item_id"
                echo "Creating new Bitwarden secure note..."
                # Create new secure note with file contents only
                # Use jq --rawfile to properly read and encode the file with newlines preserved
                set json_data (jq -cn \
                    --arg name "$item_name" \
                    --rawfile contents "$file_path" \
                    '{
                        type: 2,
                        secureNote: { type: 0 },
                        name: $name,
                        notes: $contents
                    }')

                if printf '%s\n' "$json_data" | bw encode | bw create item >/dev/null
                    bw sync >/dev/null 2>&1
                    echo "✓ File backed up successfully to Bitwarden"
                    echo "  Item: $item_name"
                else
                    echo "✗ Failed to create Bitwarden item"
                    return 1
                end
            else
                echo "Updating existing Bitwarden item..."
                # Get existing item and update its notes with file contents only
                # Use jq --rawfile to properly read and encode the file with newlines preserved
                set json_data (bw get item "$item_id" | jq -c \
                    --rawfile contents "$file_path" \
                    '.notes = $contents')

                if test $status -ne 0 -o -z "$json_data"
                    echo "✗ Failed to read existing Bitwarden item"
                    return 1
                end

                if printf '%s\n' "$json_data" | bw encode | bw edit item "$item_id" >/dev/null
                    bw sync >/dev/null 2>&1
                    echo "✓ File backed up successfully to Bitwarden"
                    echo "  Item: $matched_item_name"
                else
                    echo "✗ Failed to update Bitwarden item"
                    return 1
                end
            end

        case restore
            echo "Restoring $file_path from Bitwarden..."

            # Find the item
            set -l item_match (__bw_file_find_item $candidate_names)
            set -l item_id $item_match[1]
            set -l matched_item_name $item_match[2]

            if test -z "$item_id"
                echo "✗ No backup found for this file in Bitwarden"
                echo "Searched item names:"
                for candidate in $candidate_names
                    echo "  $candidate"
                end
                echo "Run 'bw-file backup $file_path' first"
                return 1
            end

            # Create directory if it doesn't exist
            set dir_path (dirname $file_path)
            if not test -d "$dir_path"
                echo "Creating directory: $dir_path"
                mkdir -p "$dir_path"
            end

            set -l item_json_path (mktemp "$dir_path/.bw-file-item.XXXXXX")
            set -l restore_path (mktemp "$dir_path/.bw-file-restore.XXXXXX")

            if not bw get item "$item_id" >"$item_json_path"
                rm -f "$item_json_path" "$restore_path"
                echo "✗ Failed to read Bitwarden item: $matched_item_name"
                return 1
            end

            if not jq -er 'if has("notes") and .notes != null then .notes else error("Bitwarden item has no notes") end' "$item_json_path" >"$restore_path"
                rm -f "$item_json_path" "$restore_path"
                echo "✗ Bitwarden item does not contain restorable file contents: $matched_item_name"
                return 1
            end

            # Backup existing file if it exists
            set -l backup_path
            if test -f "$file_path"
                set backup_path "$file_path.backup."(date +%Y%m%d_%H%M%S)
                echo "Creating backup of existing file: $backup_path"
                if not cp "$file_path" "$backup_path"
                    rm -f "$item_json_path" "$restore_path"
                    echo "✗ Failed to back up existing file"
                    return 1
                end

                set -l existing_mode (stat -f %Lp "$file_path" 2>/dev/null)
                if test -n "$existing_mode"
                    chmod "$existing_mode" "$restore_path" 2>/dev/null
                end
            end

            if mv "$restore_path" "$file_path"
                rm -f "$item_json_path"
                echo "✓ File restored successfully to $file_path"
                if test -f "$backup_path"
                    echo "  Previous file backed up to: $backup_path"
                end
                echo "  Item: $matched_item_name"
            else
                rm -f "$item_json_path" "$restore_path"
                echo "✗ Failed to write file"
                return 1
            end

        case '*'
            echo "Unknown action: $action"
            echo "Usage: bw-file [backup|restore] <file-path>"
            return 1
    end
end
