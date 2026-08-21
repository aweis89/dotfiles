function aws-update-kubeconfig
    set clusters (aws eks list-clusters --query 'clusters[*]' --output text | tr '\t' '\n' | fzf | string collect; or echo)
    if test -n "$clusters"
        set cluster_name (echo "$clusters" | string collect; or echo)

        # Check if cluster already exists in kubeconfig
        set existing_context ""
        for context in (kubectl config get-contexts -o name 2>/dev/null)
            # Check if context name matches cluster name or contains cluster name in ARN format
            if test "$context" = "$cluster_name"
                set existing_context "$context"
                break
            else if string match -q "*$cluster_name" "$context"
                set existing_context "$context"
                break
            end
        end

        if test -n "$existing_context"
            # Cluster exists in kubeconfig
            if test "$existing_context" != "$cluster_name"
                # Context exists but needs renaming
                echo "Context '$existing_context' found, renaming to '$cluster_name'..."
                kubectl config rename-context "$existing_context" "$cluster_name"
            end
            # Switch to the cluster
            echo "Switching to cluster: $cluster_name"
            kubectl config use-context "$cluster_name"
        else
            # Cluster doesn't exist, add it
            echo "Adding cluster to kubeconfig: $cluster_name"
            if test -n "$argv"
                aws eks update-kubeconfig --name "$cluster_name" $argv
            else
                aws eks update-kubeconfig --name "$cluster_name"
            end
            # Rename the context to match the cluster name
            set current_context (kubectl config current-context)
            if test "$current_context" != "$cluster_name"
                kubectl config rename-context "$current_context" "$cluster_name"
            end
        end
    end
end
