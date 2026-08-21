# fish completions for herdr

function __fish_herdr_needs_command
    set -l cmd (commandline -opc)
    set -e cmd[1]

    for token in $cmd
        switch $token
            case '-*'
                continue
            case '*'
                return 1
        end
    end

    return 0
end

function __fish_herdr_seen_command
    set -l cmd (commandline -opc)
    set -e cmd[1]
    contains -- $argv[1] $cmd
end

function __fish_herdr_subcommand
    set -l cmd (commandline -opc)
    set -e cmd[1]

    set -l subcmds
    for token in $cmd
        switch $token
            case '-*'
                continue
            case '*'
                set -a subcmds $token
        end
    end

    test (count $subcmds) -eq (count $argv)
    and test "$subcmds" = "$argv"
end

function __fish_herdr_sessions
    if command -sq jq
        command herdr session list --json 2>/dev/null | command jq -r '.sessions[]?.name' 2>/dev/null
    end
end

function __fish_herdr_plugins
    if command -sq jq
        command herdr plugin list --json 2>/dev/null | command jq -r '.result.plugins[]?.plugin_id' 2>/dev/null
    end
end

function __fish_herdr_list_first_column
    command $argv 2>/dev/null | string replace -rf '^\s*([^[:space:]]+).*' '$1'
end

function __fish_herdr_workspaces
    __fish_herdr_list_first_column herdr workspace list
end

function __fish_herdr_tabs
    __fish_herdr_list_first_column herdr tab list
end

function __fish_herdr_panes
    __fish_herdr_list_first_column herdr pane list
end

complete -c herdr -e
complete -c herdr -f

# global options, before a command
complete -c herdr -n __fish_herdr_needs_command -l no-session -d 'Run without server/client session'
complete -c herdr -n __fish_herdr_needs_command -l session -r -f -a '(__fish_herdr_sessions)' -d 'Use or create named session'
complete -c herdr -n __fish_herdr_needs_command -l remote -r -d 'Attach through SSH to remote Herdr server'
complete -c herdr -n __fish_herdr_needs_command -l remote-keybindings -r -f -a 'local server' -d 'Remote attach keybindings'
complete -c herdr -n __fish_herdr_needs_command -l handoff -d 'Opt into live handoff'
complete -c herdr -n __fish_herdr_needs_command -l default-config -d 'Print default configuration'
complete -c herdr -n __fish_herdr_needs_command -s V -l version -d 'Print version'
complete -c herdr -n __fish_herdr_needs_command -s h -l help -d 'Show help'

# top-level commands
complete -c herdr -n __fish_herdr_needs_command -a status -d 'Show client/server status'
complete -c herdr -n __fish_herdr_needs_command -a update -d 'Download and install latest version'
complete -c herdr -n __fish_herdr_needs_command -a server -d 'Server commands'
complete -c herdr -n __fish_herdr_needs_command -a config -d 'Config commands'
complete -c herdr -n __fish_herdr_needs_command -a channel -d 'Manage update channel'
complete -c herdr -n __fish_herdr_needs_command -a workspace -d 'Workspace helpers'
complete -c herdr -n __fish_herdr_needs_command -a worktree -d 'Git worktree helpers'
complete -c herdr -n __fish_herdr_needs_command -a tab -d 'Tab helpers'
complete -c herdr -n __fish_herdr_needs_command -a notification -d 'Notification helpers'
complete -c herdr -n __fish_herdr_needs_command -a agent -d 'Agent helpers'
complete -c herdr -n __fish_herdr_needs_command -a pane -d 'Pane helpers'
complete -c herdr -n __fish_herdr_needs_command -a wait -d 'Wait helpers'
complete -c herdr -n __fish_herdr_needs_command -a session -d 'Session commands'
complete -c herdr -n __fish_herdr_needs_command -a integration -d 'Integration commands'
complete -c herdr -n __fish_herdr_needs_command -a plugin -d 'Plugin commands'

# status/update/server/config/channel
complete -c herdr -n '__fish_herdr_subcommand status' -a 'server client' -d 'Status target'
complete -c herdr -n '__fish_herdr_seen_command status' -l json -d 'Output JSON'
complete -c herdr -n '__fish_herdr_subcommand update' -l handoff -d 'Opt into live handoff'

complete -c herdr -n '__fish_herdr_subcommand server' -a 'stop live-handoff reload-config agent-manifests update-agent-manifests reload-agent-manifests' -d 'Server command'
complete -c herdr -n '__fish_herdr_subcommand server agent-manifests; or __fish_herdr_subcommand server update-agent-manifests' -l json -d 'Output JSON'

complete -c herdr -n '__fish_herdr_subcommand config' -a reset-keys -d 'Reset keybindings'
complete -c herdr -n '__fish_herdr_subcommand channel' -a 'show set' -d 'Channel command'
complete -c herdr -n '__fish_herdr_subcommand channel set' -a 'stable preview' -d 'Update channel'

# workspace
complete -c herdr -n '__fish_herdr_subcommand workspace' -a 'list create get focus rename close' -d 'Workspace command'
complete -c herdr -n '__fish_herdr_subcommand workspace create' -l cwd -r -F -d 'Working directory'
complete -c herdr -n '__fish_herdr_subcommand workspace create' -l label -r -d 'Workspace label'
complete -c herdr -n '__fish_herdr_subcommand workspace create' -l env -r -d 'Environment KEY=VALUE'
complete -c herdr -n '__fish_herdr_subcommand workspace create' -l focus -d 'Focus after create'
complete -c herdr -n '__fish_herdr_subcommand workspace create' -l no-focus -d 'Do not focus after create'
complete -c herdr -n '__fish_herdr_subcommand workspace get; or __fish_herdr_subcommand workspace focus; or __fish_herdr_subcommand workspace rename; or __fish_herdr_subcommand workspace close' -a '(__fish_herdr_workspaces)' -d 'Workspace ID'

# worktree
complete -c herdr -n '__fish_herdr_subcommand worktree' -a 'list create open remove' -d 'Worktree command'
complete -c herdr -n '__fish_herdr_subcommand worktree list; or __fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open; or __fish_herdr_subcommand worktree remove' -l workspace -r -f -a '(__fish_herdr_workspaces)' -d 'Workspace ID'
complete -c herdr -n '__fish_herdr_subcommand worktree list; or __fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l cwd -r -F -d 'Repository path'
complete -c herdr -n '__fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l branch -r -d 'Branch name'
complete -c herdr -n '__fish_herdr_subcommand worktree create' -l base -r -d 'Base ref'
complete -c herdr -n '__fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l path -r -F -d 'Worktree path'
complete -c herdr -n '__fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l label -r -d 'Label'
complete -c herdr -n '__fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l focus -d 'Focus after open'
complete -c herdr -n '__fish_herdr_subcommand worktree create; or __fish_herdr_subcommand worktree open' -l no-focus -d 'Do not focus after open'
complete -c herdr -n '__fish_herdr_seen_command worktree' -l json -d 'Output JSON'
complete -c herdr -n '__fish_herdr_subcommand worktree remove' -l force -d 'Force remove'

# tab
complete -c herdr -n '__fish_herdr_subcommand tab' -a 'list create get focus rename close' -d 'Tab command'
complete -c herdr -n '__fish_herdr_subcommand tab list; or __fish_herdr_subcommand tab create' -l workspace -r -f -a '(__fish_herdr_workspaces)' -d 'Workspace ID'
complete -c herdr -n '__fish_herdr_subcommand tab create' -l cwd -r -F -d 'Working directory'
complete -c herdr -n '__fish_herdr_subcommand tab create' -l label -r -d 'Tab label'
complete -c herdr -n '__fish_herdr_subcommand tab create' -l env -r -d 'Environment KEY=VALUE'
complete -c herdr -n '__fish_herdr_subcommand tab create' -l focus -d 'Focus after create'
complete -c herdr -n '__fish_herdr_subcommand tab create' -l no-focus -d 'Do not focus after create'
complete -c herdr -n '__fish_herdr_subcommand tab get; or __fish_herdr_subcommand tab focus; or __fish_herdr_subcommand tab rename; or __fish_herdr_subcommand tab close' -a '(__fish_herdr_tabs)' -d 'Tab ID'

# notification
complete -c herdr -n '__fish_herdr_subcommand notification' -a show -d 'Show notification'
complete -c herdr -n '__fish_herdr_subcommand notification show' -l body -r -d 'Notification body'
complete -c herdr -n '__fish_herdr_subcommand notification show' -l position -r -f -a 'top-left top-right bottom-left bottom-right' -d 'Position'
complete -c herdr -n '__fish_herdr_subcommand notification show' -l sound -r -f -a 'none done request' -d 'Sound'

# agent
complete -c herdr -n '__fish_herdr_subcommand agent' -a 'list get read send rename focus wait attach start explain' -d 'Agent command'
complete -c herdr -n '__fish_herdr_subcommand agent get; or __fish_herdr_subcommand agent read; or __fish_herdr_subcommand agent send; or __fish_herdr_subcommand agent rename; or __fish_herdr_subcommand agent focus; or __fish_herdr_subcommand agent wait; or __fish_herdr_subcommand agent attach' -a '(__fish_herdr_panes)' -d 'Agent target'
complete -c herdr -n '__fish_herdr_subcommand agent read' -l source -r -f -a 'visible recent recent-unwrapped' -d 'Output source'
complete -c herdr -n '__fish_herdr_subcommand agent read' -l lines -r -d 'Line count'
complete -c herdr -n '__fish_herdr_subcommand agent read' -l format -r -f -a 'text ansi' -d 'Output format'
complete -c herdr -n '__fish_herdr_subcommand agent read' -l ansi -d 'ANSI output'
complete -c herdr -n '__fish_herdr_subcommand agent rename' -l clear -d 'Clear name'
complete -c herdr -n '__fish_herdr_subcommand agent wait' -l status -r -f -a 'idle working blocked unknown' -d 'Target status'
complete -c herdr -n '__fish_herdr_subcommand agent wait' -l timeout -r -d 'Timeout ms'
complete -c herdr -n '__fish_herdr_subcommand agent attach' -l takeover -d 'Take over terminal'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l cwd -r -F -d 'Working directory'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l workspace -r -f -a '(__fish_herdr_workspaces)' -d 'Workspace ID'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l tab -r -f -a '(__fish_herdr_tabs)' -d 'Tab ID'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l split -r -f -a 'right down' -d 'Split direction'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l env -r -d 'Environment KEY=VALUE'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l focus -d 'Focus after start'
complete -c herdr -n '__fish_herdr_subcommand agent start' -l no-focus -d 'Do not focus after start'
complete -c herdr -n '__fish_herdr_subcommand agent explain' -l file -r -F -d 'Transcript file'
complete -c herdr -n '__fish_herdr_subcommand agent explain' -l agent -r -d 'Agent label'
complete -c herdr -n '__fish_herdr_subcommand agent explain' -l json -d 'Output JSON'

# pane
complete -c herdr -n '__fish_herdr_subcommand pane' -a 'list current get layout process-info neighbor edges focus resize zoom rename read split swap move close send-text send-keys report-agent report-agent-session release-agent report-metadata run' -d 'Pane command'
complete -c herdr -n '__fish_herdr_subcommand pane get; or __fish_herdr_subcommand pane zoom; or __fish_herdr_subcommand pane rename; or __fish_herdr_subcommand pane read; or __fish_herdr_subcommand pane split; or __fish_herdr_subcommand pane move; or __fish_herdr_subcommand pane close; or __fish_herdr_subcommand pane send-text; or __fish_herdr_subcommand pane send-keys; or __fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session; or __fish_herdr_subcommand pane release-agent; or __fish_herdr_subcommand pane report-metadata; or __fish_herdr_subcommand pane run' -a '(__fish_herdr_panes)' -d 'Pane ID'
complete -c herdr -n '__fish_herdr_subcommand pane list; or __fish_herdr_subcommand pane move' -l workspace -r -f -a '(__fish_herdr_workspaces)' -d 'Workspace ID'
complete -c herdr -n '__fish_herdr_subcommand pane current; or __fish_herdr_subcommand pane layout; or __fish_herdr_subcommand pane process-info; or __fish_herdr_subcommand pane neighbor; or __fish_herdr_subcommand pane edges; or __fish_herdr_subcommand pane focus; or __fish_herdr_subcommand pane resize; or __fish_herdr_subcommand pane zoom; or __fish_herdr_subcommand pane split; or __fish_herdr_subcommand pane swap' -l pane -r -f -a '(__fish_herdr_panes)' -d 'Pane ID'
complete -c herdr -n '__fish_herdr_subcommand pane current; or __fish_herdr_subcommand pane layout; or __fish_herdr_subcommand pane process-info; or __fish_herdr_subcommand pane neighbor; or __fish_herdr_subcommand pane edges; or __fish_herdr_subcommand pane focus; or __fish_herdr_subcommand pane resize; or __fish_herdr_subcommand pane zoom; or __fish_herdr_subcommand pane split; or __fish_herdr_subcommand pane swap' -l current -d 'Use current pane'
complete -c herdr -n '__fish_herdr_subcommand pane neighbor; or __fish_herdr_subcommand pane focus; or __fish_herdr_subcommand pane resize; or __fish_herdr_subcommand pane swap' -l direction -r -f -a 'left right up down' -d 'Direction'
complete -c herdr -n '__fish_herdr_subcommand pane resize' -l amount -r -d 'Resize amount'
complete -c herdr -n '__fish_herdr_subcommand pane zoom' -l toggle -d 'Toggle zoom'
complete -c herdr -n '__fish_herdr_subcommand pane zoom' -l on -d 'Zoom on'
complete -c herdr -n '__fish_herdr_subcommand pane zoom' -l off -d 'Zoom off'
complete -c herdr -n '__fish_herdr_subcommand pane rename' -l clear -d 'Clear name'
complete -c herdr -n '__fish_herdr_subcommand pane read' -l source -r -f -a 'visible recent recent-unwrapped' -d 'Output source'
complete -c herdr -n '__fish_herdr_subcommand pane read' -l lines -r -d 'Line count'
complete -c herdr -n '__fish_herdr_subcommand pane read' -l format -r -f -a 'text ansi' -d 'Output format'
complete -c herdr -n '__fish_herdr_subcommand pane read' -l ansi -d 'ANSI output'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l direction -r -f -a 'right down' -d 'Split direction'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l ratio -r -d 'Split ratio'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l cwd -r -F -d 'Working directory'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l env -r -d 'Environment KEY=VALUE'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l focus -d 'Focus after split'
complete -c herdr -n '__fish_herdr_subcommand pane split' -l no-focus -d 'Do not focus after split'
complete -c herdr -n '__fish_herdr_subcommand pane swap' -l source-pane -r -f -a '(__fish_herdr_panes)' -d 'Source pane ID'
complete -c herdr -n '__fish_herdr_subcommand pane swap; or __fish_herdr_subcommand pane move' -l target-pane -r -f -a '(__fish_herdr_panes)' -d 'Target pane ID'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l tab -r -f -a '(__fish_herdr_tabs)' -d 'Tab ID'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l split -r -f -a 'right down' -d 'Split direction'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l ratio -r -d 'Split ratio'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l new-tab -d 'Move to new tab'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l new-workspace -d 'Move to new workspace'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l label -r -d 'New tab/workspace label'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l tab-label -r -d 'New tab label'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l focus -d 'Focus after move'
complete -c herdr -n '__fish_herdr_subcommand pane move' -l no-focus -d 'Do not focus after move'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session; or __fish_herdr_subcommand pane release-agent; or __fish_herdr_subcommand pane report-metadata' -l source -r -d 'Reporter source ID'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session; or __fish_herdr_subcommand pane release-agent; or __fish_herdr_subcommand pane report-metadata' -l agent -r -d 'Agent label'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent' -l state -r -f -a 'idle working blocked unknown' -d 'Agent state'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent' -l status -r -f -a 'idle working blocked done unknown' -d 'Agent status'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent' -l message -r -d 'Status message'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-metadata' -l custom-status -r -d 'Custom status'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session; or __fish_herdr_subcommand pane release-agent; or __fish_herdr_subcommand pane report-metadata' -l seq -r -d 'Sequence number'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session' -l agent-session-id -r -d 'Agent session ID'
complete -c herdr -n '__fish_herdr_subcommand pane report-agent; or __fish_herdr_subcommand pane report-agent-session' -l agent-session-path -r -F -d 'Agent session path'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l applies-to-source -r -d 'Applies-to source ID'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l title -r -d 'Pane title'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l clear-title -d 'Clear title'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l display-agent -r -d 'Display agent'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l clear-display-agent -d 'Clear display agent'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l clear-custom-status -d 'Clear custom status'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l state-label -r -d 'State label STATUS=TEXT'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l clear-state-labels -d 'Clear state labels'
complete -c herdr -n '__fish_herdr_subcommand pane report-metadata' -l ttl-ms -r -d 'TTL ms'

# wait
complete -c herdr -n '__fish_herdr_subcommand wait' -a 'output agent-status' -d 'Wait command'
complete -c herdr -n '__fish_herdr_subcommand wait output; or __fish_herdr_subcommand wait agent-status' -a '(__fish_herdr_panes)' -d 'Pane ID'
complete -c herdr -n '__fish_herdr_subcommand wait output' -l match -r -d 'Text/regex to match'
complete -c herdr -n '__fish_herdr_subcommand wait output' -l source -r -f -a 'visible recent recent-unwrapped' -d 'Output source'
complete -c herdr -n '__fish_herdr_subcommand wait output' -l lines -r -d 'Line count'
complete -c herdr -n '__fish_herdr_subcommand wait output; or __fish_herdr_subcommand wait agent-status' -l timeout -r -d 'Timeout ms'
complete -c herdr -n '__fish_herdr_subcommand wait output' -l regex -d 'Use regex matching'
complete -c herdr -n '__fish_herdr_subcommand wait output' -l raw -d 'Raw output'
complete -c herdr -n '__fish_herdr_subcommand wait agent-status' -l status -r -f -a 'idle working blocked done unknown' -d 'Target status'

# session
complete -c herdr -n '__fish_herdr_subcommand session' -a 'list attach stop delete' -d 'Session command'
complete -c herdr -n '__fish_herdr_subcommand session attach; or __fish_herdr_subcommand session stop; or __fish_herdr_subcommand session delete' -a '(__fish_herdr_sessions)' -d 'Session name'
complete -c herdr -n '__fish_herdr_subcommand session list; or __fish_herdr_subcommand session stop; or __fish_herdr_subcommand session delete' -l json -d 'Output JSON'

# integration
complete -c herdr -n '__fish_herdr_subcommand integration' -a 'install uninstall status' -d 'Integration command'
complete -c herdr -n '__fish_herdr_subcommand integration install; or __fish_herdr_subcommand integration uninstall' -r -f -a 'pi omp claude codex copilot devin droid kimi opencode kilo hermes qodercli cursor' -d 'Integration'
complete -c herdr -n '__fish_herdr_subcommand integration status' -l outdated-only -d 'Show outdated only'

# plugin
complete -c herdr -n '__fish_herdr_subcommand plugin' -a 'install uninstall link list config-dir unlink enable disable action log pane' -d 'Plugin command'
complete -c herdr -n '__fish_herdr_subcommand plugin uninstall; or __fish_herdr_subcommand plugin config-dir; or __fish_herdr_subcommand plugin unlink; or __fish_herdr_subcommand plugin enable; or __fish_herdr_subcommand plugin disable' -a '(__fish_herdr_plugins)' -d 'Plugin ID'
complete -c herdr -n '__fish_herdr_subcommand plugin install' -l ref -r -d 'Git ref'
complete -c herdr -n '__fish_herdr_subcommand plugin install' -l yes -d 'Skip prompts'
complete -c herdr -n '__fish_herdr_subcommand plugin link' -l disabled -d 'Link disabled'
complete -c herdr -n '__fish_herdr_subcommand plugin list' -l plugin -r -f -a '(__fish_herdr_plugins)' -d 'Plugin ID'
complete -c herdr -n '__fish_herdr_subcommand plugin list' -l json -d 'Output JSON'
complete -c herdr -n '__fish_herdr_subcommand plugin action' -a 'list invoke' -d 'Action command'
complete -c herdr -n '__fish_herdr_subcommand plugin log' -a list -d 'List plugin logs'
complete -c herdr -n '__fish_herdr_subcommand plugin log list' -l plugin -r -f -a '(__fish_herdr_plugins)' -d 'Plugin ID'
complete -c herdr -n '__fish_herdr_subcommand plugin log list' -l limit -r -d 'Log entry limit'
complete -c herdr -n '__fish_herdr_subcommand plugin pane' -a 'open focus close' -d 'Pane command'
