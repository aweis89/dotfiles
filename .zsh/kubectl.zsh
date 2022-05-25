alias kcn=kubens
alias kcu=kubectx

kf() {
    local resource=${1:-pods}
    local name=$(kubectl get $resource --no-headers ${@:2} | fzf | awk '{print $1}')
    local yaml=$(kubectl get $resource $name -o yaml)
    echo $yaml | fzf_stdin_preview
}

kfa() {
    local resource=${1:-pods}
    local line=$(kubectl get $resource --no-headers -A ${@:2} | fzf)
    local namespace=$(echo $line | awk '{print $1}')
    local name=$(echo $line | awk '{print $2}')
    local yaml=$(kubectl get $resource $name -n $namespace -o yaml)
    echo $yaml | fzf_stdin_preview
}

BAT_THEME=${BAT_THEME:-'OneHalfDark'}

fzf_stdin_preview() {
    local lang=${1:-yaml}
    local surround=20
    if test -n "$TMUX"
    then
        local height=$(tmux display-message -p '#{pane_height}')
        surround=$((height - 15))
    fi
    local stdin=$(cat /dev/stdin)
    local tmpfile=$(mktemp $HOME/tmp/fzfstin.XXXX)
    trap "rm -f $tmpfile" EXIT
    echo "$stdin" > $tmpfile
    local preview_cmd="cat $tmpfile | head -n \$(($surround+{n})) | \
        tail -n \$(($surround*2)) | bat \
        --language=$lang --color=always --style=grid \
        --highlight-line=\$(($surround+1)) --theme $BAT_THEME"
    echo $stdin | fzf --preview "$preview_cmd"
}
