function cache_tool_init
    set -l tool $argv[1]
    set -l init_cmd $argv[2]
    set -l should_install $argv[3]
    set -l cache_var __{$tool}_cache

    if not set -q $cache_var
        set -U $cache_var ~/.local/share/fish/$tool.fish
        if not test -f $$cache_var
            if test "$should_install" = true
                brew install $tool
            end
            eval $init_cmd >$$cache_var
        end
    end
    source $$cache_var
end