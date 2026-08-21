function __fish_pi_enabled_models
    set -l settings_file ~/.pi/agent/settings.json
    if command -sq jq; and test -r $settings_file
        command jq -r '.enabledModels[]?' $settings_file 2>/dev/null
    end
end

function __fish_pi_enabled_models_for_cycle
    set -l models (__fish_pi_enabled_models)
    if test (count $models) -gt 0
        string join , $models
        printf '%s\n' $models
    end
end

complete -c pi -n '__fish_use_subcommand' -a 'install remove uninstall update list config' -d 'pi command'

complete -c pi -l provider -r -d 'Provider name'
complete -c pi -l model -r -f -a '(__fish_pi_enabled_models)' -d 'Model pattern or ID'
complete -c pi -l api-key -r -d 'API key'
complete -c pi -l system-prompt -r -d 'System prompt'
complete -c pi -l append-system-prompt -r -d 'Append system prompt'
complete -c pi -l mode -r -a 'text json rpc' -d 'Output mode'
complete -c pi -l print -s p -d 'Non-interactive mode'
complete -c pi -l continue -s c -d 'Continue previous session'
complete -c pi -l resume -s r -d 'Resume session'
complete -c pi -l session -r -d 'Use session path or ID'
complete -c pi -l session-id -r -d 'Use exact session ID'
complete -c pi -l fork -r -d 'Fork session'
complete -c pi -l session-dir -r -d 'Session directory'
complete -c pi -l no-session -d 'Do not save session'
complete -c pi -l name -s n -r -d 'Set session display name'
complete -c pi -l models -r -f -a '(__fish_pi_enabled_models_for_cycle)' -d 'Models for cycling'
complete -c pi -l no-tools -o nt -d 'Disable all tools'
complete -c pi -l no-builtin-tools -o nbt -d 'Disable built-in tools'
complete -c pi -l tools -s t -r -d 'Enable tool allowlist'
complete -c pi -l exclude-tools -o xt -r -d 'Disable tool denylist'
complete -c pi -l thinking -r -a 'off minimal low medium high xhigh' -d 'Thinking level'
complete -c pi -l extension -s e -r -d 'Load extension file'
complete -c pi -l no-extensions -o ne -d 'Disable extension discovery'
complete -c pi -l skill -r -d 'Load skill file or directory'
complete -c pi -l no-skills -o ns -d 'Disable skills'
complete -c pi -l prompt-template -r -d 'Load prompt template'
complete -c pi -l no-prompt-templates -o np -d 'Disable prompt templates'
complete -c pi -l theme -r -d 'Load theme'
complete -c pi -l no-themes -d 'Disable themes'
complete -c pi -l no-context-files -o nc -d 'Disable context files'
complete -c pi -l export -r -d 'Export session to HTML'
complete -c pi -l list-models -r -d 'List available models'
complete -c pi -l verbose -d 'Force verbose startup'
complete -c pi -l approve -s a -d 'Trust project-local files'
complete -c pi -l no-approve -o na -d 'Ignore project-local files'
complete -c pi -l offline -d 'Disable startup network operations'
complete -c pi -l help -s h -d 'Show help'
complete -c pi -l version -s v -d 'Show version'

complete -c pi -l mcp-config -r -d 'MCP config path'
complete -c pi -l cursor-fast -d 'Enable Cursor fast mode'
complete -c pi -l cursor-no-fast -d 'Disable Cursor fast mode'
complete -c pi -l cursor-mode -r -a 'agent plan' -d 'Cursor SDK mode'
