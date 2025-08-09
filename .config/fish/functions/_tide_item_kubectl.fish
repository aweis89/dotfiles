function _tide_item_kubectl
    kubectl config view --minify --output 'jsonpath={.current-context}/{..namespace}' 2>/dev/null | read -l context
    
    # Cluster name alias mapping (matches against full context name)
    set -l cluster_aliases \
        "gke_qzlt-stage-webapp_us-central1_staging:webapp-staging" \
        "production-cluster:prod" \
        "staging-cluster:stage" \
        "development-cluster:dev" \
        "testing-cluster:test" \
        "sandbox-cluster:sandbox" \
        "monitoring-cluster:mon" \
        "analytics-cluster:analytics"
    
    set -l shortened_context $context
    
    # Apply alias if match found (check against original context)
    for alias_pair in $cluster_aliases
        echo $alias_pair | read -d ':' original_name alias_name
        if string match -q "*$original_name*" $context
            set shortened_context (echo $context | string replace $original_name $alias_name)
            break
        end
    end
    
    # If no alias matched, apply the default shortening rules
    if test "$shortened_context" = "$context"
        set shortened_context (echo $context | string replace -r 'gke_[^_]+_[^_]+_' '' | string replace -r 'us-east4-tf-gcp-' '' | string replace -r '/(|default)$' '')
    else
        # Remove default namespace from aliased context
        set shortened_context (echo $shortened_context | string replace -r '/(|default)$' '')
    end
    
    _tide_print_item kubectl $tide_kubectl_icon' ' $shortened_context
end
