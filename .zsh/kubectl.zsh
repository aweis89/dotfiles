# kubectl helpers
kf() {
    resource=${1:-pods}
    local name=$(kubectl get $resource --no-headers | fzf | awk '{print $1}')
    kubectl get $resource $name -o yaml | fzf
}

kfa() {
    resource=${1:-pods}
    local line=$(kubectl get $resource --no-headers -A | fzf)
    namespace=$(echo $line | awk '{print $1}')
    name=$(echo $line | awk '{print $2}')
    kubectl get $resource $name -n $namespace -o yaml | fzf
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
