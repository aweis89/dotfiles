function gcloud-foreach-project
    if test (count $argv) -eq 0
        echo "Usage: gcloud-foreach-project <gcloud-command-args>"
        return 1
    end

    set projects (gcloud projects list --format="value(projectId)" 2>/dev/null)

    if test -z "$projects"
        echo "No projects found"
        return 1
    end

    # Use parallel for concurrent execution - each project on a new line
    # Prepend 'gcloud' to the arguments
    printf "%s\n" $projects | parallel -j 0 \
        "echo '=== Project: {} ==='; gcloud $argv --project={} 2>/dev/null; or true"
end

# Completion for gcloud-foreach-project - use the same completion as gcloud
complete -c gcloud-foreach-project -f -a '(__fish_argcomplete_complete gcloud)'
