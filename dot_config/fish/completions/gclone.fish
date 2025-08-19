# Fish completions for gclone command

# Complete repository names from GitHub organization using gh cli
function __gclone_repos
    if test -n "$GITHUB_ORG"
        gh repo list $GITHUB_ORG --limit 1000 --json name --jq '.[].name' 2>/dev/null
    end
end

# Complete the first argument (repository name) with org repos
complete -c gclone -f -a '(__gclone_repos)' -d 'Repository to clone from organization'