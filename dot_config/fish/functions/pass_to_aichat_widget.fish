function pass_to_aichat_widget
    # Retrieve the current command line input
    set current_input (commandline)
    # Replace the command line with 'aichat -e' followed by the current input
    commandline -r "aichat -e '$current_input'"
    # Execute the new command
    commandline -f execute
end