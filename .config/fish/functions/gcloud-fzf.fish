function gcloud-fzf
    set cmd (__gcloud_sel | string collect; or echo)
    test -n "$cmd" && eval "$cmd"
end