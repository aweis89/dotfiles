function _tide_item_kubectl
    kubectl config view --minify --output 'jsonpath={.current-context}/{..namespace}' 2>/dev/null | read -l context

    # Cluster name alias mapping (matches against full context name)
    set -l cluster_aliases \
        "gke_qzlt-stage-webapp_us-central1_staging:webapp-staging" \
        "gke_qzlt-prod-webapp_us-central1_prod:webapp-prod" \
        "gke_calbot3-staging_us-east1_calbot3-calbot:calbot3-stage" \
        "gke_calbot4-staging_us-east1_calbot4-calbot:calbot4-stage" \
        "gke_calbot5-staging_us-east1_calbot5-calbot:calbot5-stage" \
        "gke_calbot6-staging_us-east1_calbot6-calbot:calbot6-stage" \
        "gke_calbot7-production_us-east1_calbot7-calbot:calbot7-prod" \
        "gke_calbot8-production_us-east1_calbot8-calbot:calbot8-prod" \
        "gke_calendly-edw-production_us-east4_us-east4-data-platform-comp-9c50cb26-gke:cal-edw-prod" \
        "gke_mi-recall-production_us-east1_mi-recall-transcription:cal-recall-trans-prod" \
        "gke_mi-recall-staging_us-east1_mi-recall-apps:cal-mi-recall-stage" \
        "gke_platform-287919_us-east4_us-east4-tf-gcp-platform-cluster:cal-platform" \
        "gke_production-287919_us-east4_us-east4-tf-gcp-production-cluster:cal-prod" \
        "gke_staging-287520_us-east4_us-east4-tf-gcp-staging-cluster:cal-stage"

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
