function aws-update-kubeconfig
    set clusters (aws eks list-clusters --query 'clusters[*]' --output text | tr '\t' '\n' | fzf | string collect; or echo)
    if test -n "$clusters"
        set cluster_name (echo "$clusters" | string collect; or echo)
        if test -n "$argv"
            aws eks update-kubeconfig --name "$cluster_name" $argv
        else
            aws eks update-kubeconfig --name "$cluster_name"
        end
        # Rename the context to match the cluster name
        set current_context (kubectl config current-context)
        kubectl config rename-context "$current_context" "$cluster_name"
    end
end
