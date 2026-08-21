function cache_tool_init
    set -l tool $argv[1]
    set -l init_cmd $argv[2]
    set -l should_install $argv[3]
    set -l cache_var __{$tool}_cache

    if not set -q $cache_var
        set -U $cache_var ~/.local/share/fish/$tool.fish
    end

    set -l cache_file $$cache_var
    set -l cache_tmp "$cache_file.tmp"

    if not test -s $cache_file
        if test "$should_install" = true
            if not type -q $tool
                brew install $tool
            end
        end

        if eval $init_cmd >$cache_tmp
            if test -s $cache_tmp
                command mv $cache_tmp $cache_file
            else
                command rm -f $cache_tmp
            end
        else
            command rm -f $cache_tmp
        end
    end

    if test -s $cache_file
        source $cache_file
    end
end
