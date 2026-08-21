function _pure_prompt_first_line \
    --description 'Print Kubernetes context above directory and Git information.'

    set --local prompt_ssh (_pure_prompt_ssh)
    set --local prompt_container (_pure_prompt_container)
    set --local prompt_k8s (_pure_prompt_k8s)
    set --local prompt_git (_pure_prompt_git)
    set --local prompt_command_duration (_pure_prompt_command_duration)

    # Only the Git and duration segments share space with the directory.
    set --local second_line_suffix (_pure_print_prompt \
        $prompt_git \
        $prompt_command_duration
    )
    set --local suffix_width (_pure_string_width $second_line_suffix)
    set --local current_folder (_pure_prompt_current_folder $suffix_width)

    set --local first_line (_pure_print_prompt \
        $prompt_ssh \
        $prompt_container \
        $prompt_k8s
    )
    set --local second_line (_pure_print_prompt \
        $current_folder \
        $prompt_git \
        $prompt_command_duration
    )

    if test -n "$first_line"
        # fish_prompt interprets this escape when rendering the prompt.
        string join '\n' "$first_line" "$second_line"
    else
        echo "$second_line"
    end
end
