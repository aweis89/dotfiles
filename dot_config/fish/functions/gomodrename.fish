function gomodrename
    set old $argv[1]
    set new $argv[2]
    go mod edit -module $new
    find . -type f -name '*.go' -exec sed -i '' -e 's|'"$old"'|'"$new"'|g' {} \;
end