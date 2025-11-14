function aws-profile
    # Select and/or set AWS profile. If no profile arg given, always invoke fzf.
    # Flags:
    #   -p|--persist  Persist profile across sessions
    #   -d|--delete   Remove persisted profile (unset)
    #   -c|--current  Show current profile and exit

    set -l persist false
    set -l delete false
    set -l show_current false
    set -l profile_name

    # Parse args / flags
    for arg in $argv
        switch $arg
            case -p --persist
                set persist true
            case -d --delete
                set delete true
            case -c --current
                set show_current true
            case '-*'
                echo "Unknown option: $arg"
                echo "Usage: aws-profile [-p|--persist] [profile]"
                echo "       aws-profile -d|--delete"
                echo "       aws-profile -c|--current"
                return 1
            case '*'
                if test -z "$profile_name"
                    set profile_name $arg
                end
        end
    end

    if test $show_current = true
        if set -q AWS_PROFILE
            echo $AWS_PROFILE
        else
            echo default
        end
        return
    end

    # Handle delete request
    if test $delete = true
        if set -q AWS_PROFILE
            set -e AWS_PROFILE
            set -e -U AWS_PROFILE
            echo "Removed persisted AWS profile"
        else
            echo "No AWS profile set"
        end
        return
    end

    set -l profiles
    set -l aws_config ~/.aws/config
    if test -f $aws_config
        # Include default first if present
        if grep -q '^\[default\]' $aws_config
            set profiles $profiles default
        end
        for p in (grep -E '^\[profile ' $aws_config | sed -E 's/^\[profile (.+)\]/\1/')
            set profiles $profiles $p
        end
    else if type -q aws
        for p in (aws configure list-profiles 2>/dev/null)
            set profiles $profiles $p
        end
    else
        echo "AWS config not found and aws CLI not available"
        return 1
    end

    if test (count $profiles) -eq 0
        # Fallback to default
        set profiles default
    end

    # Always invoke fzf if no profile_name provided
    if test -z "$profile_name"
        if not type -q fzf
            echo "fzf not installed; select manually by passing a profile name. Available profiles:"
            printf '%s\n' $profiles
            return 1
        end
        set profile_name (printf '%s\n' $profiles | fzf)
        if test -z "$profile_name"
            echo "No selection made"
            return 1
        end
    end

    # Apply profile (handle default by unsetting variable)
    if test $persist = true
        if test "$profile_name" = default
            set -e -U AWS_PROFILE
            set -e AWS_PROFILE
            echo "Using default AWS profile (persist cleared)"
        else
            set -Ux AWS_PROFILE $profile_name
            echo "Switched to AWS profile (persisted): $profile_name"
        end
    else
        if test "$profile_name" = default
            set -e AWS_PROFILE
            echo "Using default AWS profile"
        else
            set -gx AWS_PROFILE $profile_name
            echo "Switched to AWS profile: $profile_name"
        end
    end

    # Update kubeconfig after switching profiles
    if type -q aws-update-kubeconfig
        aws-update-kubeconfig
    end
end
