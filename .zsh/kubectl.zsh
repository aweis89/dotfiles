alias kcn=kubens
alias kcu=kubectx

kf() {
    resource=${1:-pods}
    local name=$(kubectl get $resource --no-headers ${@:2} | fzf | awk '{print $1}')
    yaml=$(kubectl get $resource $name -o yaml)
    echo $yaml | fzf_stdin_preview
}

kfa() {
    resource=${1:-pods}
    local line=$(kubectl get $resource --no-headers -A ${@:2} | fzf)
    namespace=$(echo $line | awk '{print $1}')
    name=$(echo $line | awk '{print $2}')
    yaml=$(kubectl get $resource $name -n $namespace -o yaml)
    echo $yaml | fzf_stdin_preview
}

BAT_THEME=${BAT_THEME:-'OneHalfDark'}

fzf_stdin_preview() {
    lang=${1:-yaml}
    surround=20
    if test -n "$TMUX"
    then
        height=$(tmux display-message -p '#{pane_height}')
        surround=$((height - 15))
    fi
    stdin=$(cat /dev/stdin)
    tmpfile=$(mktemp $HOME/tmp/fzfstin.XXXX)
    trap "rm -f $tmpfile" EXIT
    echo "$stdin" > $tmpfile
    preview_cmd="cat $tmpfile | head -n \$(($surround+{n})) | \
        tail -n \$(($surround*2)) | bat --language=$lang --color=always \
        --highlight-line=\$(($surround+1)) --theme $BAT_THEME"
    echo $stdin | fzf --preview "$preview_cmd"
}
