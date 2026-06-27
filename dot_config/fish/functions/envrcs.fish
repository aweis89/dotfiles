function __envrcs_item
    if set -q ENVRCS_RBW_ITEM; and test -n "$ENVRCS_RBW_ITEM"
        printf '%s\n' "$ENVRCS_RBW_ITEM"
    else
        printf '%s\n' '~/.local/share/chezmoi/envrcs.yaml'
    end
end

function __envrcs_source_file
    set -l source_dir (chezmoi source-path 2>/dev/null)
    if test $status -ne 0 -o -z "$source_dir"
        echo "✗ Failed to find chezmoi source dir" >&2
        return 1
    end

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

function __envrcs_pull
    set -l run_apply $argv[1]
    set -l item (__envrcs_item)
    set -l file (__envrcs_source_file); or return 1
    set -l dir (dirname "$file")
    set -l tmp (mktemp "$dir/.envrcs.yaml.XXXXXX")

    echo "Syncing rbw..."
    if not rbw sync
        rm -f "$tmp"
        echo "✗ rbw sync failed" >&2
        return 1
    end

    echo "Pulling $item -> $file"
    if not rbw get --raw "$item" | jq -er '.notes // empty' >"$tmp"
        rm -f "$tmp"
        echo "✗ Failed to read rbw note: $item" >&2
        return 1
    end

    if not __envrcs_validate "$tmp"
        rm -f "$tmp"
        return 1
    end

    chmod 600 "$tmp"
    mv "$tmp" "$file"
    echo "✓ Pulled envrc source"

    if test "$run_apply" = 1
        chezmoi apply
    end
end

function __envrcs_push
    set -l item (__envrcs_item)
    set -l file (__envrcs_source_file); or return 1

    if not test -f "$file"
        echo "✗ Missing $file" >&2
        echo "  Run: envrcs sync" >&2
        return 1
    end

    if not __envrcs_validate "$file"
        return 1
    end

    echo "Syncing rbw..."
    if not rbw sync
        echo "✗ rbw sync failed" >&2
        return 1
    end

    if not rbw get --raw "$item" >/dev/null
        echo "✗ rbw item not found: $item" >&2
        return 1
    end

    echo "Pushing $file -> $item"
    if not rbw edit "$item" <"$file"
        echo "✗ Failed to update rbw note: $item" >&2
        return 1
    end

    echo "✓ Pushed envrc source"
end

function __envrcs_edit
    __envrcs_pull 0; or return 1

    set -l file (__envrcs_source_file); or return 1
    set -l before (__envrcs_hash "$file")
    set -l editor

    if set -q EDITOR; and test -n "$EDITOR"
        set editor "$EDITOR"
    else
        set editor nvim
    end

    echo "Editing $file"
    eval "$editor "(string escape -- "$file")
    set -l edit_status $status
    if test $edit_status -ne 0
        echo "✗ Editor exited with status $edit_status" >&2
        return $edit_status
    end

    if not __envrcs_validate "$file"
        return 1
    end

    set -l after (__envrcs_hash "$file")
    if test "$before" = "$after"
        echo "No changes; skipping push"
        chezmoi apply
        return $status
    end

    __envrcs_push; or return 1
    chezmoi apply
end

function __envrcs_usage
    echo "Usage: envrcs <command> [options]"
    echo "Commands:"
    echo "  sync        Pull rbw note to local envrcs.yaml, then chezmoi apply"
    echo "  edit        Pull latest, edit envrcs.yaml, push to rbw, apply"
    echo "  push        Push local envrcs.yaml to rbw note"
    echo "  path        Print local envrcs.yaml path"
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
