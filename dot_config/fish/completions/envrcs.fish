complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "sync" -d "Pull rbw note and apply envrc files"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "edit" -d "Pull latest, edit envrcs.yaml, push, apply"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "push" -d "Push local envrcs.yaml to rbw note"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "path" -d "Print local envrcs.yaml path"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "item" -d "Print rbw item name"
complete -c envrcs -f -n "not __fish_seen_subcommand_from sync pull edit push path item help" -a "help" -d "Show help"

complete -c envrcs -f -n "__fish_seen_subcommand_from sync pull" -l pull -d "Pull rbw note and apply envrc files"
complete -c envrcs -f -n "__fish_seen_subcommand_from sync pull" -l pull-only -d "Pull rbw note without apply"

complete -c envrcs -f -s h -l help -d "Show help"
