import os
import subprocess
from Foundation import NSObject, NSDistributedNotificationCenter, NSUserDefaults
from AppKit import NSWorkspace
from PyObjCTools import AppHelper

class ThemeObserver(NSObject):
    def themeChanged_(self, notification):
        defaults = NSUserDefaults.standardUserDefaults()
        is_dark = defaults.stringForKey_("AppleInterfaceStyle") == "Dark"
        kitty_theme = f"Catppuccin Kitty {'Mocha' if is_dark else 'Latte'}"

        print(f"Apple Interface Style Changed to {'Dark' if is_dark else 'Light'}")

        commands = [
            "tmux source-file ~/.config/tmux/tmux.conf",
            "touch ~/.config/nvim/lua/plugins/editor.lua",
            f"kitty +kitten themes --reload-in=all {kitty_theme}",
        ]
        command = " && ".join(commands)
        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
            out, err = process.communicate()
            if out:
                print('Output: ' + out.decode('UTF-8'))
            if err:
                print('Error: ' + err.decode('UTF-8'))
        except Exception as e:
            print(f"Error executing command: {str(e)}")
            
        delete_line('~/.config/kitty/kitty.conf', kitty_theme)



def delete_line(filename, text):
    filename = os.path.expanduser(filename)

    with open(filename, 'r') as file:
        lines = file.readlines()

    with open(filename, 'w') as file:
        for line in lines:
            if text not in line:
                file.write(line)

def main():
    os.environ['PATH'] = '/opt/homebrew/bin' + os.pathsep + os.environ['PATH']
    observer = ThemeObserver.new()

    # Distributed Notification Center for theme change
    distributed_notification_center = NSDistributedNotificationCenter.defaultCenter()
    distributed_notification_center.addObserver_selector_name_object_(
        observer,
        "themeChanged:",
        "AppleInterfaceThemeChangedNotification",
        None,
    )

    # Workspace Notification Center for wake from sleep
    workspace_notification_center = NSWorkspace.sharedWorkspace().notificationCenter()
    workspace_notification_center.addObserver_selector_name_object_(
        observer,
        "themeChanged:",
        "NSWorkspaceDidWakeNotification",
        None,
    )

    AppHelper.runConsoleEventLoop()

if __name__ == "__main__":
    main()
