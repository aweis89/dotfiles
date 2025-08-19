function goinit
    set -l name $argv[1]
    set -l org $argv[2]
    test -d "$name" || mkdir $name
    cd $name
    go mod init github.com/$org/$name
end