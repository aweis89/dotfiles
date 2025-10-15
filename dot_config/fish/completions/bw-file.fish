# Autocomplete for bw-file
complete -c bw-file -f -n "not __fish_seen_subcommand_from backup restore save" -a "backup" -d "Save file to Bitwarden"
complete -c bw-file -f -n "not __fish_seen_subcommand_from backup restore save" -a "restore" -d "Restore file from Bitwarden"

# File path completion for second argument
complete -c bw-file -n "__fish_seen_subcommand_from backup restore save" -a "(__fish_complete_path)"
