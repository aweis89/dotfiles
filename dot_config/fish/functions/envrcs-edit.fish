function envrcs-edit
    switch "$argv[1]"
        case -h --help help
            echo "Usage: envrcs-edit"
            echo "  Pull latest rbw note, edit local envrcs.yaml with EDITOR/nvim, push, apply"
            echo ""
            echo "Config: ENVRCS_RBW_ITEM overrides rbw item name"
            return 0
        case ''
        case '*'
            echo "✗ Unknown option: $argv[1]" >&2
            echo "Usage: envrcs-edit" >&2
            return 1
    end

    envrcs-sync --pull-only; or return 1

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
