function gcloud-update-kubeconfig
    set cluster (gcloud container clusters list | grep -v NAME | fzf | string collect; or echo)
    if test -n "$cluster"
        set zone (echo "$cluster" | awk '{print $2}' | string collect; or echo)
        set name (echo "$cluster" | awk '{print $1}' | string collect; or echo)
        if test -n "$argv"
            gcloud container clusters get-credentials "$name" --zone "$zone" $argv
        else
            gcloud container clusters get-credentials "$name" --zone "$zone"
        end
        # Rename the context to match the cluster name
        set current_context (kubectl config current-context)
        kubectl config rename-context "$current_context" "$name"
    end
end
