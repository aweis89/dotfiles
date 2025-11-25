function pr-msg
    # Retrieve PR data
    set pr (gh pr view --json url,title,number,isDraft,additions,deletions)
    # Extract repository name
    set repo (basename -s .git (git config --get remote.origin.url))
    # Parse PR attributes using jq
    set title (echo $pr | jq -r '.title')
    set number (echo $pr | jq -r '.number')
    set url (echo $pr | jq -r '.url')
    set isDraft (echo $pr | jq -r '.isDraft')
    set additions (echo $pr | jq -r '.additions')
    set deletions (echo $pr | jq -r '.deletions')

    # Calculate total lines changed
    set total_lines (math $additions + $deletions)

    # Determine size based on lines changed
    if test $total_lines -lt 10
        set size XS
    else if test $total_lines -lt 100
        set size S
    else if test $total_lines -lt 500
        set size M
    else
        set size L
    end

    # Construct the message
    # Replace square brackets in title with parentheses to avoid markdown conflicts
    set clean_title (string replace -a '[' '(' -- $title)
    set clean_title (string replace -a ']' ')' -- $clean_title)
    set msg "[$repo#$number: $clean_title]($url)"
    if test "$isDraft" = true
        set msg ":draft-pr: $msg"
    end
    # Output the message and copy to clipboard
    echo (set -q PR_EMOJI; and echo $PR_EMOJI; or echo ":pull-request:")" :shirt: ($size) $msg" | tee /dev/tty | pbcopy
end
