function aws-profile
    set -l persist false
    set -l delete false
    
    # Parse flags
    for arg in $argv
        switch $arg
            case -p --persist
                set persist true
            case -d --delete
                set delete true
            case '-*'
                echo "Unknown option: $arg"
                echo "Usage: aws-profile [-p|--persist] <profile-name>"
                echo "       aws-profile -d|--delete  (removes persisted profile)"
                return 1
        end
    end
    
    # Handle delete
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
    
    # Get profile name (non-flag argument)
    set -l profile_name
    for arg in $argv
        if not string match -q -- '-*' $arg
            set profile_name $arg
            break
        end
    end
    
    # Show current profile if no name provided
    if test -z "$profile_name"
        if set -q AWS_PROFILE
            echo "Current AWS profile: $AWS_PROFILE"
        else
            echo "No AWS profile set (using default)"
        end
        return
    end
    
    # Set profile
    if test $persist = true
        set -Ux AWS_PROFILE $profile_name
        echo "Switched to AWS profile (persisted): $profile_name"
    else
        set -gx AWS_PROFILE $profile_name
        echo "Switched to AWS profile: $profile_name"
    end
end
