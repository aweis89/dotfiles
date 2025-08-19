function edit-config
    set file $argv[1]

    if test -z "$file"
        echo "Usage: e <file>"
        return 1
    end

    if chezmoi managed --exact --exclude=externals --include=files -- "$file" >/dev/null 2>&1
        echo "Using Chezmoi"
        chezmoi edit -- "$file"
        return $status
    end
    echo "Using nvim"
    nvim $argv
end
