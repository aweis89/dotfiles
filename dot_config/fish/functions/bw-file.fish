function bw-file
    set -l action $argv[1]
    set -l file_path $argv[2]

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

    # Expand ~ to home directory for file operations
    set file_path (string replace -r '^~' $HOME $file_path)

    # Normalize path for item name (replace $HOME with ~ for portability)
    set -l item_name (string replace -r "^$HOME" '~' $file_path)

    # Check if logged in
    if not bw login --check &>/dev/null
        echo "Not logged in to Bitwarden. Please run: bw login"
        return 1
    end

    # Check if unlocked
    if test -z "$BW_SESSION"
        echo "Bitwarden vault is locked. Unlocking..."
        set -gx BW_SESSION (bw unlock --raw)
        if test $status -ne 0
            echo "Failed to unlock vault"
            return 1
        end
        # Ensure local cache is fresh to avoid stale cipher errors
        bw sync >/dev/null 2>&1
    end

    switch $action
        case backup save
            if not test -f "$file_path"
                echo "✗ File not found: $file_path"
                return 1
            end

            echo "Backing up $file_path to Bitwarden..."

            # Check if item already exists
            set item_id (bw list items --search "$item_name" 2>/dev/null | jq -r '.[0].id // empty')

            if test -z "$item_id"
                echo "Creating new Bitwarden secure note..."
                # Create new secure note with file contents only
                # Use jq --rawfile to properly read and encode the file with newlines preserved
                set json_data (jq -n \
                    --arg name "$item_name" \
                    --rawfile contents "$file_path" \
                    '{
                        type: 2,
                        secureNote: { type: 0 },
                        name: $name,
                        notes: $contents
                    }')

                echo "$json_data" | bw encode | bw create item >/dev/null
                if test $status -eq 0
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
                set json_data (bw get item "$item_id" | jq \
                    --rawfile contents "$file_path" \
                    '.notes = $contents')

                echo "$json_data" | bw encode | bw edit item "$item_id" >/dev/null
                if test $status -eq 0
                    bw sync >/dev/null 2>&1
                    echo "✓ File backed up successfully to Bitwarden"
                    echo "  Item: $item_name"
                else
                    echo "✗ Failed to update Bitwarden item"
                    return 1
                end
            end

        case restore
            echo "Restoring $file_path from Bitwarden..."

            # Find the item
            set item_id (bw list items --search "$item_name" 2>/dev/null | jq -r '.[0].id // empty')

            if test -z "$item_id"
                echo "✗ No backup found for this file in Bitwarden"
                echo "Run 'bw-file backup $file_path' first"
                return 1
            end

            # Create directory if it doesn't exist
            set dir_path (dirname $file_path)
            if not test -d "$dir_path"
                echo "Creating directory: $dir_path"
                mkdir -p "$dir_path"
            end

            # Backup existing file if it exists
            if test -f "$file_path"
                set backup_path "$file_path.backup."(date +%Y%m%d_%H%M%S)
                echo "Creating backup of existing file: $backup_path"
                cp "$file_path" "$backup_path"
            end

            # Write the file directly using jq -r to extract and preserve newlines
            bw get item "$item_id" | jq -r '.notes' >"$file_path"
            if test $status -eq 0
                echo "✓ File restored successfully to $file_path"
                if test -f "$backup_path"
                    echo "  Previous file backed up to: $backup_path"
                end
            else
                echo "✗ Failed to write file"
                return 1
            end

        case '*'
            echo "Unknown action: $action"
            echo "Usage: bw-file [backup|restore] <file-path>"
            return 1
    end
end
