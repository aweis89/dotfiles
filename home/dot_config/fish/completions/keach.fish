# Completions for keach function
# First argument: context keyword (complete with existing context names as hints)
# Remaining arguments: inherit kubectl completions

# Complete first argument with existing context names as suggestions
complete -c keach -n "test (count (commandline -opc)) -eq 1" -a "(kubectl config get-contexts -o name 2>/dev/null)" -d "Context keyword"

# For all subsequent arguments, inherit kubectl completions
complete -c keach -n "test (count (commandline -opc)) -ge 2" --wraps kubectl
