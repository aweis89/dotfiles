if status is-interactive
    # Inline Fisher initialization (previously in functions/load_fisher.fish)
    # Update this path if you relocate your Fisher plugin dir
    if not set --query _fisher_path_initialized
        set --global _fisher_path_initialized

        set -l fisher_path ~/.local/share/fish/fisher

        if test -d "$fisher_path"
            # Add Fisher paths (keep user overrides first)
            set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..]
            set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..]

            # Source Fisher-managed conf.d files unless overridden by user files
            for file in $fisher_path/conf.d/*.fish
                set -l user_file (string replace --regex "^.*/" $__fish_config_dir/conf.d/ -- $file)
                if not test -f $user_file; and test -f $file; and test -r $file
                    source $file
                end
            end
        end
    end
end
