function copilot-models
    curl -s https://api.githubcopilot.com/models \
        -H "Authorization: Bearer $COPILOT_KEY" \
        -H "Content-Type: application/json" \
        -H "Copilot-Integration-Id: vscode-chat" | jq -r '.data[].id'
end