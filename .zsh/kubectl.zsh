delete-finalizers() {
  kubectl get pods $@ -o json | jq -r \
    '.items[] | select(.metadata.deletionTimestamp!=null) | .metadata.name' |
    xargs -I {} kubectl patch pod $@ {} -p '{"metadata":{"finalizers":null}}'
}

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

# Kubernetes Functions
k-node-run() {
  local node_name=$1
  shift
  local command=("$@")
  local args_json=$(printf ', "%s"' "${command[@]}")
  args_json="[${args_json:2}]"

  kubectl run -it curl-pod --image=curlimages/curl --overrides="{
        \"apiVersion\": \"v1\",
        \"spec\": {
            \"nodeSelector\": {
                \"kubernetes.io/hostname\": \"${node_name}\"
            },
            \"containers\": [{
                \"name\": \"curl-pod\",
                \"image\": \"curlimages/curl\",
                \"args\": ${args_json}
            }]
        }
    }"
}
