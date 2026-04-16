function _pure_k8s_context
    set --local context (kubectl config current-context 2>/dev/null)
    if test -z "$context"
        return
    end

    set --local max_length 20
    if set --query pure_k8s_context_max_length
        set max_length $pure_k8s_context_max_length
    end

    set --local context_length (string length -- "$context")
    if test "$context_length" -le "$max_length"
        echo "$context"
        return
    end

    set --local start (math "$context_length - $max_length + 1")
    echo "…" (string sub --start="$start" -- "$context")
end
