
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
    yaml=$(cat /dev/stdin)
    echo $yaml > ~/tmp/fzf.yaml
    preview_cmd='cat ~/tmp/fzf.yaml | head -n $((10 + {n})) | tail -n 20 | bat --language=yaml --color=always --highlight-line=11 --theme OneHalfDark'
    echo $yaml | fzf --preview "$preview_cmd"
}

kcn() {
	if [[ "$1" = "" ]]; then
		kubens "$(kubens | fzf)"
	else
		kubens $1
	fi
}

kcu() {
	if [[ "$1" = "" ]]; then
		kubectx "$(kubectx | fzf)"
	else
		kubectx $1
	fi
}
