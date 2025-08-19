function gcloud-update-kubeconfig
    set cluster (gcloud container clusters list | grep -v NAME | fzf | string collect; or echo)
    if test -n "$cluster"
        set zone (echo "$cluster" | awk '{print $2}' | string collect; or echo)
        set name (echo "$cluster" | awk '{print $1}' | string collect; or echo)
        set -x
        gcloud container clusters get-credentials "$name" --zone "$zone" "$argv"
        set +x
    end
end