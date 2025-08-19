# Fish completions for gclone command

# Complete repository names from GitHub organization using gh cli
function __gclone_repos
    if test -n "$GITHUB_ORG"
        set -l query (commandline -ct)
        if test -n "$query"
            gh repo list $GITHUB_ORG --limit 1000 --json name --jq ".[].name | select(startswith(\"$query\"))" 2>/dev/null
        else
            gh repo list $GITHUB_ORG --limit 100 --json name --jq '.[].name' 2>/dev/null
        end
    end
end

# Complete the first argument (repository name) with org repos
complete -c gclone -f -a '(__gclone_repos)' -d 'Repository to clone from organization'