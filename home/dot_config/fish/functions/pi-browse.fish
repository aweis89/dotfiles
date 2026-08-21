function pi-browse --description 'Browse loaded Pi skills, prompt templates, and extension commands'
    argparse h/help e/edit -- $argv
    or return 2

    if set -q _flag_help
        echo 'Usage: pi-browse [--edit]'
        echo
        echo 'Lists loaded Pi extension commands, prompt templates, and skill commands via RPC,'
        echo 'opens the list in fzf, and previews the backing source file with bat.'
        echo
        echo 'Options:'
        echo '  -e, --edit    Open the selected source file in $EDITOR instead of viewing with bat'
        echo '  -h, --help    Show this help'
        return 0
    end

    for dependency in jq fzf
        if not command -q $dependency
            echo "pi-browse: missing required command: $dependency" >&2
            return 127
        end
    end

    set -l viewer
    if command -q bat
        set viewer bat
    else if command -q batcat
        set viewer batcat
    else
        echo 'pi-browse: bat was not found; previews will use sed instead' >&2
    end

    set -l stdout_file (mktemp -t pi-browse-commands.XXXXXX)
    set -l stderr_file (mktemp -t pi-browse-errors.XXXXXX)

    printf '%s\n' '{"id":"pi-browse-commands","type":"get_commands"}' \
        | env PI_CURSOR_SETTING_SOURCES=none PI_CURSOR_PI_TOOL_BRIDGE=0 PI_CURSOR_TOOL_MANIFEST=0 \
            command pi --mode rpc --no-session --no-tools --no-context-files >$stdout_file 2>$stderr_file
    set -l pi_status $pipestatus[2]

    if test $pi_status -ne 0
        echo "pi-browse: pi RPC get_commands failed with status $pi_status" >&2
        if test -s $stderr_file
            cat $stderr_file >&2
        end
        rm -f $stdout_file $stderr_file
        return $pi_status
    end

    set -l rows (jq -r '
        select(.id == "pi-browse-commands" and .success == true)
        | .data.commands[]
        | select(.source == "extension" or .source == "prompt" or .source == "skill")
        | [
            .source,
            ("/" + .name),
            ((.description // "") | gsub("[\t\r\n]+"; " ")),
            (.sourceInfo.scope // .location // ""),
            (.sourceInfo.source // ""),
            (.sourceInfo.path // .path // "")
        ]
        | @tsv
    ' $stdout_file)
    set -l jq_status $status

    rm -f $stdout_file $stderr_file

    if test $jq_status -ne 0
        echo 'pi-browse: failed to parse pi RPC output' >&2
        return $jq_status
    end

    if test (count $rows) -eq 0
        echo 'pi-browse: no Pi extension commands, prompt templates, or skills found' >&2
        return 1
    end

    set -l preview
    if test -n "$viewer"
        set preview "sh -c 'file=\$1; if [ -n \"\$file\" ] && [ -r \"\$file\" ]; then $viewer --color=always --style=numbers --line-range :500 \"\$file\"; else printf \"No readable source file for this command.\\n\"; fi' sh {6}"
    else
        set preview "sh -c 'file=\$1; if [ -n \"\$file\" ] && [ -r \"\$file\" ]; then sed -n \"1,240p\" \"\$file\"; else printf \"No readable source file for this command.\\n\"; fi' sh {6}"
    end

    set -l selected (printf '%s\n' $rows \
        | env SHELL=/bin/sh fzf \
            --height=80% \
            --reverse \
            --delimiter='\t' \
            --with-nth='2,1,3,4,5' \
            --header='Pi resources: Enter views source, --edit opens in $EDITOR, Esc cancels' \
            --preview-window='right:60%:wrap' \
            --preview=$preview)

    if test -z "$selected"
        return 0
    end

    set -l fields (string split \t -- $selected)
    set -l label $fields[2]
    set -l path $fields[6]

    if test -z "$path" -o ! -r "$path"
        echo "pi-browse: no readable source file for $label" >&2
        return 1
    end

    if set -q _flag_edit
        if test -n "$EDITOR"
            eval "$EDITOR "(string escape -- $path)
        else
            command vi "$path"
        end
    else if test -n "$viewer"
        command $viewer --paging=always --style=full --color=always "$path"
    else
        command less "$path"
    end
end
