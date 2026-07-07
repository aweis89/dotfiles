function ollama-logs
    --description "View or tail Ollama serve logs"

    set -l logfile
    if test -f /opt/homebrew/var/log/ollama.log
        set logfile /opt/homebrew/var/log/ollama.log
    else if test -f "$HOME/.ollama/logs/server.log"
        set logfile "$HOME/.ollama/logs/server.log"
    else
        echo "Ollama logs not found." >&2
        return 1
    end

    # --lines=N or --lines N → show last N lines; otherwise follow (-f)
    for i in (seq (count $argv))
        switch $argv[$i]
            case '--lines'
                test ($i + 1) -le (count $argv) && tail -n "$argv[(math $i + 1)]" "$logfile" && return
                echo "--lines requires a value" >&2
                return 1
            case '--lines=*'
                set val (string split '=' $argv[$i])
                tail -n "$val[2]" "$logfile" && return
        end
    end

    tail -f "$logfile"
end
