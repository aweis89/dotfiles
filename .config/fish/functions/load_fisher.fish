function load_fisher --description "Initialize Fisher plugin manager" --argument-names fisher_path
    # Install Fisher if not present
    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher update
    end

    # Exit early if already initialized in this session
    set --query _fisher_path_initialized && return
    set --global _fisher_path_initialized

    # Validate fisher_path
    if test -z "$fisher_path" || test "$fisher_path" = "$__fish_config_dir"
        return
    end

    # Add Fisher paths
    set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..]
    set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..]

    # Source Fisher config files
    for file in $fisher_path/conf.d/*.fish
        if ! test -f (string replace --regex "^.*/" $__fish_config_dir/conf.d/ -- $file)
            and test -f $file && test -r $file
            source $file
        end
    end
end
