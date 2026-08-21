# Dynamic autocomplete for aws-profile
complete -c aws-profile -f -a "(grep -E '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/' && grep -E '^\[default\]' ~/.aws/config | sed 's/\[default\]/default/')"
complete -c aws-profile -s p -l persist -d "Persist profile across sessions"
complete -c aws-profile -s d -l delete -d "Remove persisted profile"
