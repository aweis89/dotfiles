alias kcn=kubens
alias kcu=kubectx

kf() {
    resource=${1:-pods}
    local name=$(kubectl get $resource --no-headers | fzf | awk '{print $1}')
    yaml=$(kubectl get $resource $name -o yaml)
    echo $yaml | fzf_stdin_preview
}

kfa() {
    resource=${1:-pods}
    local line=$(kubectl get $resource --no-headers -A | fzf -0)
    namespace=$(echo $line | awk '{print $1}')
    name=$(echo $line | awk '{print $2}')
    yaml=$(kubectl get $resource $name -n $namespace -o yaml)
    echo $yaml | fzf_stdin_preview
}

fzf_stdin_preview() {
    stdin=$(cat /dev/stdin)
    lang=${1:-yaml}
    tmpfile=$(mktemp $HOME/tmp/fzfstin.XXXX)
    echo "$stdin" > $tmpfile
    preview_cmd="cat $tmpfile | head -n \$((10 + {n})) | tail -n 20 | bat --language=$lang --color=always --highlight-line=11 --theme OneHalfDark"
    echo $stdin | fzf --preview "$preview_cmd"
    rm $tmpfile
}
