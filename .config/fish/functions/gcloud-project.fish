function gcloud-project
    set projects (gcloud projects list | string collect; or echo)
    set selected (echo "$projects" | grep -v PROJECT_ID | fzf | string collect; or echo)
    if test -n "$selected"
        set project_id (echo "$selected" | awk '{print $1}' | string collect; or echo)
        gcloud config set project "$project_id"
        gcloud config get project
    end
end