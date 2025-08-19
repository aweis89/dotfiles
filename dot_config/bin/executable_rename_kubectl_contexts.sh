#!/bin/bash

# Array of context mappings in format "original_context:new_name"
contexts=(
    "gke_qzlt-stage-webapp_us-central1_staging:webapp-staging"
    "gke_qzlt-prod-webapp_us-central1_prod:webapp-prod"
    "gke_calbot3-staging_us-east1_calbot3-calbot:calbot3-stage"
    "gke_calbot4-staging_us-east1_calbot4-calbot:calbot4-stage"
    "gke_calbot5-staging_us-east1_calbot5-calbot:calbot5-stage"
    "gke_calbot6-staging_us-east1_calbot6-calbot:calbot6-stage"
    "gke_calbot7-production_us-east1_calbot7-calbot:calbot7-prod"
    "gke_calbot8-production_us-east1_calbot8-calbot:calbot8-prod"
    "gke_calendly-edw-production_us-east4_us-east4-data-platform-comp-9c50cb26-gke:cal-edw-prod"
    "gke_mi-recall-production_us-east1_mi-recall-transcription:cal-recall-trans-prod"
    "gke_mi-recall-staging_us-east1_mi-recall-apps:cal-mi-recall-stage"
    "gke_platform-287919_us-east4_us-east4-tf-gcp-platform-cluster:cal-platform"
    "gke_production-287919_us-east4_us-east4-tf-gcp-production-cluster:cal-prod"
    "gke_staging-287520_us-east4_us-east4-tf-gcp-staging-cluster:cal-stage"
)

echo "Renaming kubectl contexts..."

for mapping in "${contexts[@]}"; do
    # Split the mapping by colon
    original_context="${mapping%%:*}"
    new_name="${mapping##*:}"
    
    echo "Checking if context '$original_context' exists..."
    
    # Check if the original context exists
    if kubectl config get-contexts "$original_context" &>/dev/null; then
        echo "Renaming '$original_context' to '$new_name'..."
        kubectl config rename-context "$original_context" "$new_name"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully renamed to '$new_name'"
        else
            echo "✗ Failed to rename '$original_context'"
        fi
    else
        echo "⚠ Context '$original_context' not found, skipping..."
    fi
    echo ""
done

echo "Context renaming complete!"