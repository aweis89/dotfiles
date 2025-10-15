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
    
    # Expand ~ to home directory
    set file_path (string replace -r '^~' $HOME $file_path)
    
    # Generate item name from file path
    set -l item_name "File Backup: "(basename $file_path)" - "(dirname $file_path)
    set -l file_name (basename $file_path)
    
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
                echo "Creating new Bitwarden item..."
                # Create new secure note with file path in notes
                set item_id (bw get template item | jq '.type = 2 | .secureNote.type = 0 | .name = "'"$item_name"'" | .notes = "Original path: '"$file_path"'"' | bw encode | bw create item | jq -r '.id')
                if test $status -ne 0
                    echo "Failed to create Bitwarden item"
                    return 1
                end
            else
                echo "Found existing item, will update..."
                # Delete old attachment if it exists
                set attachment_id (bw get item "$item_id" 2>/dev/null | jq -r '.attachments[]? | select(.fileName == "'"$file_name"'") | .id')
                if test -n "$attachment_id"
                    bw delete attachment "$attachment_id" >/dev/null 2>&1
                end
            end
            
            # Attach the file
            echo "Uploading file..."
            bw create attachment --file "$file_path" --itemid "$item_id" >/dev/null
            if test $status -eq 0
                bw sync >/dev/null 2>&1
                echo "✓ File backed up successfully to Bitwarden"
                echo "  Item: $item_name"
            else
                echo "✗ Failed to upload file"
                return 1
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
            
            # Check if attachment exists
            set attachment_exists (bw get item "$item_id" 2>/dev/null | jq -r '.attachments[]? | select(.fileName == "'"$file_name"'") | .fileName')
            
            if test -z "$attachment_exists"
                echo "✗ No file attachment found in Bitwarden item"
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
            
            # Download and restore
            echo "Downloading file from Bitwarden..."
            bw get attachment "$file_name" --itemid "$item_id" --output "$dir_path/" >/dev/null
            if test $status -eq 0
                echo "✓ File restored successfully to $file_path"
                if test -f "$backup_path"
                    echo "  Previous file backed up to: $backup_path"
                end
            else
                echo "✗ Failed to download file from Bitwarden"
                return 1
            end
            
        case '*'
            echo "Unknown action: $action"
            echo "Usage: bw-file [backup|restore] <file-path>"
            return 1
    end
end
