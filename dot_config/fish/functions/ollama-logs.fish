function ollama-logs --description "View or tail Ollama serve logs"

    set -l logfile
    if test -f /opt/homebrew/var/log/ollama.log
        set logfile /opt/homebrew/var/log/ollama.log
    else if test -f "$HOME/.ollama/logs/server.log"
        set logfile "$HOME/.ollama/logs/server.log"
    else
        echo "Ollama logs not found. Try: brew services start ollama or install from ollama.ai" >&2
        return 1
    end

    for i in (seq (count $argv))
        switch $argv[$i]
            case '-n' '--lines'
                set next (math $i + 1)
                if test $next -le (count $argv)
                    tail -n "$argv[$next]" "$logfile"
                    return
                end
                echo "--lines requires a value" >&2
                return 1
            case '-n=*' '--lines=*'
                set val (string split '=' $argv[$i])
                tail -n "$val[2]" "$logfile"
                return
        end
    end

    tail -f "$logfile"
end
