complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "sync" -d "Pull Bitwarden note to encrypted cache and apply envrc files"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "edit" -d "Pull latest, edit temp plaintext, push, apply"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "push" -d "Push encrypted cache to Bitwarden note"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "path" -d "Print encrypted local cache path"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "plain-path" -d "Print old plaintext cache path"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "item" -d "Print Bitwarden item name"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path plain-path item help" -a "help" -d "Show help"

complete -c envrcs -f -n "__fish_seen_subcommand_from sync pull" -l pull -d "Pull Bitwarden note to encrypted cache and apply envrc files"
complete -c envrcs -f -n "__fish_seen_subcommand_from sync pull" -l pull-only -d "Pull Bitwarden note to encrypted cache without apply"

complete -c envrcs -f -s h -l help -d "Show help"
