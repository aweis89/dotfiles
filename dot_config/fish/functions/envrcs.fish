function __envrcs_item
    if set -q ENVRCS_RBW_ITEM; and test -n "$ENVRCS_RBW_ITEM"
        printf '%s\n' "$ENVRCS_RBW_ITEM"
    else
        printf '%s\n' '~/.local/share/chezmoi/envrcs.yaml'
    end
end

function __envrcs_source_dir
    set -l source_dir (chezmoi source-path 2>/dev/null)
    if test $status -ne 0 -o -z "$source_dir"
        echo "✗ Failed to find chezmoi source dir" >&2
        return 1
    end

    printf '%s\n' "$source_dir"
end

function __envrcs_source_file
    set -l source_dir (__envrcs_source_dir); or return 1
    printf '%s\n' "$source_dir/envrcs.yaml.age"
end

function __envrcs_plain_source_file
    set -l source_dir (__envrcs_source_dir); or return 1
    printf '%s\n' "$source_dir/envrcs.yaml"
end

function __envrcs_require
    for required_command in chezmoi jq mktemp rbw
        if not command -q "$required_command"
            echo "✗ Missing required command: $required_command" >&2
            return 1
        end
    end
end

function __envrcs_hash
    set -l file $argv[1]

    if command -q shasum
        shasum -a 256 "$file" | awk '{print $1}'
    else if command -q sha256sum
        sha256sum "$file" | awk '{print $1}'
    else
        wc -c <"$file"
    end
end

function __envrcs_tmp_file
    set -l suffix $argv[1]
    set -l tmpdir /tmp

    if set -q TMPDIR; and test -n "$TMPDIR"
        set tmpdir "$TMPDIR"
    end

    mktemp "$tmpdir/envrcs.XXXXXX$suffix"
end

function __envrcs_validate
    set -l file $argv[1]

    if not test -s "$file"
        echo "✗ Refusing empty envrcs.yaml" >&2
        return 1
    end

    if command -q ruby
        ruby -e '
require "yaml"
path = ARGV.fetch(0)
data = YAML.load_file(path)
unless data.is_a?(Hash)
  warn "envrcs.yaml must be a YAML map: path => content"
  exit 1
end
data.each do |key, value|
  unless key.is_a?(String)
    warn "envrcs.yaml key must be a string: #{key.inspect}"
    exit 1
  end
  unless value.is_a?(String)
    warn "envrcs.yaml value for #{key.inspect} must be a string block"
    exit 1
  end
end
' "$file"
        return $status
    end

    echo "⚠ ruby missing; skipping YAML shape validation" >&2
end

function __envrcs_encrypt_cache
    set -l plain_file $argv[1]
    set -l encrypted_file (__envrcs_source_file); or return 1
    set -l encrypted_dir (dirname "$encrypted_file")
    set -l tmp_encrypted (mktemp "$encrypted_dir/.envrcs.yaml.age.XXXXXX")

    if not chezmoi encrypt "$plain_file" >"$tmp_encrypted"
        rm -f "$tmp_encrypted"
        echo "✗ chezmoi encryption failed" >&2
        echo "  Configure chezmoi encryption first, then retry" >&2
        return 1
    end

    chmod 600 "$tmp_encrypted"
    mv "$tmp_encrypted" "$encrypted_file"
end

function __envrcs_decrypt_cache
    set -l plain_file $argv[1]
    set -l encrypted_file (__envrcs_source_file); or return 1

    if not test -f "$encrypted_file"
        echo "✗ Missing encrypted cache: $encrypted_file" >&2
        echo "  Run: envrcs sync" >&2
        return 1
    end

    if not chezmoi decrypt "$encrypted_file" >"$plain_file"
        echo "✗ chezmoi decryption failed" >&2
        return 1
    end

    chmod 600 "$plain_file"
end

function __envrcs_pull
    set -l run_apply $argv[1]
    set -l item (__envrcs_item)
    set -l encrypted_file (__envrcs_source_file); or return 1
    set -l plain_file (__envrcs_tmp_file .yaml)

    echo "Syncing rbw..."
    if not rbw sync
        rm -f "$plain_file"
        echo "✗ rbw sync failed" >&2
        return 1
    end

    echo "Pulling $item -> $encrypted_file"
    if not rbw get --raw "$item" | jq -er '.notes // empty' >"$plain_file"
        rm -f "$plain_file"
        echo "✗ Failed to read rbw note: $item" >&2
        return 1
    end
    chmod 600 "$plain_file"

    if not __envrcs_validate "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    if not __envrcs_encrypt_cache "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    rm -f "$plain_file"
    echo "✓ Pulled encrypted envrc source"

    if test "$run_apply" = 1
        chezmoi apply
    end
end

function __envrcs_push
    set -l item (__envrcs_item)
    set -l encrypted_file (__envrcs_source_file); or return 1
    set -l plain_file (__envrcs_tmp_file .yaml)

    if not test -f "$encrypted_file"
        rm -f "$plain_file"
        echo "✗ Missing $encrypted_file" >&2
        echo "  Run: envrcs sync" >&2
        return 1
    end

    if not __envrcs_decrypt_cache "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    if not __envrcs_validate "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    echo "Syncing rbw..."
    if not rbw sync
        rm -f "$plain_file"
        echo "✗ rbw sync failed" >&2
        return 1
    end

    if not rbw get --raw "$item" >/dev/null
        rm -f "$plain_file"
        echo "✗ rbw item not found: $item" >&2
        return 1
    end

    echo "Pushing $encrypted_file -> $item"
    if not rbw edit "$item" <"$plain_file"
        rm -f "$plain_file"
        echo "✗ Failed to update rbw note: $item" >&2
        return 1
    end

    rm -f "$plain_file"
    echo "✓ Pushed envrc source"
end

function __envrcs_edit
    __envrcs_pull 0; or return 1

    set -l plain_file (__envrcs_tmp_file .yaml)
    if not __envrcs_decrypt_cache "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    set -l before (__envrcs_hash "$plain_file")
    set -l editor

    if set -q EDITOR; and test -n "$EDITOR"
        set editor "$EDITOR"
    else
        set editor nvim
    end

    echo "Editing temporary decrypted envrcs.yaml"
    eval "$editor "(string escape -- "$plain_file")
    set -l edit_status $status
    if test $edit_status -ne 0
        rm -f "$plain_file"
        echo "✗ Editor exited with status $edit_status" >&2
        return $edit_status
    end

    if not __envrcs_validate "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    set -l after (__envrcs_hash "$plain_file")
    if test "$before" = "$after"
        rm -f "$plain_file"
        echo "No changes; skipping push"
        chezmoi apply
        return $status
    end

    if not __envrcs_encrypt_cache "$plain_file"
        rm -f "$plain_file"
        return 1
    end

    rm -f "$plain_file"
    __envrcs_push; or return 1
    chezmoi apply
end

function __envrcs_usage
    echo "Usage: envrcs <command> [options]"
    echo "Commands:"
    echo "  sync        Pull rbw note to encrypted envrcs.yaml.age, then chezmoi apply"
    echo "  edit        Pull latest, edit temp plaintext, push to rbw, apply"
    echo "  push        Push encrypted local cache to rbw note"
    echo "  path        Print encrypted local cache path"
    echo "  plain-path  Print old plaintext cache path"
    echo "  item        Print rbw item name"
    echo ""
    echo "sync options:"
    echo "  --pull-only Pull only; no apply"
    echo ""
    echo "Config: ENVRCS_RBW_ITEM overrides rbw item name"
end

function envrcs
    set -l command $argv[1]
    set -e argv[1]

    switch "$command"
        case -h --help help ''
            __envrcs_usage
            return 0
        case item
            __envrcs_item
            return 0
        case path
            if not command -q chezmoi
                echo "✗ Missing required command: chezmoi" >&2
                return 1
            end
            __envrcs_source_file
            return $status
        case plain-path
            if not command -q chezmoi
                echo "✗ Missing required command: chezmoi" >&2
                return 1
            end
            __envrcs_plain_source_file
            return $status
    end

    __envrcs_require; or return 1

    switch "$command"
        case sync pull
            switch "$argv[1]"
                case '' --pull
                    __envrcs_pull 1
                case --pull-only
                    __envrcs_pull 0
                case '*'
                    echo "✗ Unknown sync option: $argv[1]" >&2
                    __envrcs_usage >&2
                    return 1
            end
        case edit
            if test (count $argv) -ne 0
                echo "✗ edit takes no options" >&2
                __envrcs_usage >&2
                return 1
            end
            __envrcs_edit
        case push
            if test (count $argv) -ne 0
                echo "✗ push takes no options" >&2
                __envrcs_usage >&2
                return 1
            end
            __envrcs_push
        case '*'
            echo "✗ Unknown command: $command" >&2
            __envrcs_usage >&2
            return 1
    end
end
