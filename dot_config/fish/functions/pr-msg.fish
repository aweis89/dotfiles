function pr-msg
    # Retrieve PR data
    set pr (gh pr view --json url,title,number,isDraft)
    # Extract repository name
    set repo (basename -s .git (git config --get remote.origin.url))
    # Parse PR attributes using jq
    set title (echo $pr | jq -r '.title')
    set number (echo $pr | jq -r '.number')
    set url (echo $pr | jq -r '.url')
    set isDraft (echo $pr | jq -r '.isDraft')
    # Construct the message
    set msg "[$repo#$number: $title]($url)"
    if test "$isDraft" = true
        set msg ":draft-pr: $msg"
    end
    # Output the message and copy to clipboard
    echo ":pull-request: $msg :pray:" | tee /dev/tty | pbcopy
end
