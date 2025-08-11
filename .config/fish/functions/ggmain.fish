function ggmain
    git checkout (__git.default_branch)
    git pull origin (__git.current_branch)
end