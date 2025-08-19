function gcloud-account
    set account (gcloud auth list --format='table(account)' | grep -v ACCOUNT | fzf | string collect; or echo)
    gcloud config set account $account
end