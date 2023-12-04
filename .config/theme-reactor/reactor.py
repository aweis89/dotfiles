import os
import subprocess
from Foundation import NSObject, NSDistributedNotificationCenter, NSUserDefaults
from PyObjCTools import AppHelper

class ThemeObserver(NSObject):
    def themeChanged_(self, notification):
        commands = [
            "tmux source-file ~/.config/tmux/tmux.conf",
            "touch ~/.config/nvim/lua/plugins/editor.lua",
        ]

        defaults = NSUserDefaults.standardUserDefaults()
        is_dark = defaults.stringForKey_("AppleInterfaceStyle") == "Dark"

        # theme_file = "mocha.conf" if is_dark else "latte.conf"
        # commands.append(f"ln -sf $HOME/.config/kitty/themes/{theme_file} $HOME/.config/current-theme.conf")
        # commands.append("ps -ef | grep kitty | grep -v grep | awk '{print $2}' | xargs kill -s SIGUSR1")

        theme = f"Catppuccin Kitty {'Mocha' if is_dark else 'Latte'}"
        commands.append(f"kitty +kitten themes --reload-in=all {theme}")
        commands.append(f"sed -i '/# {theme}/d' $HOME/.config/current-theme.conf")

        command = " && ".join(commands)

        print(f"Apple Interface Style Changed to {'Dark' if is_dark else 'Light'}")

        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
            out, err = process.communicate()
            if out:
                print('Output: ' + out.decode('UTF-8'))
            if err:
                print('Error: ' + err.decode('UTF-8'))
        except Exception as e:
            print(f"Error executing command: {str(e)}")

def main():
    os.environ['PATH'] = '/opt/homebrew/bin' + os.pathsep + os.environ['PATH']
    observer = ThemeObserver.new()
    NSDistributedNotificationCenter.defaultCenter().addObserver_selector_name_object_(
        observer,
        "themeChanged:",
        "AppleInterfaceThemeChangedNotification",
        None,
    )
    AppHelper.runConsoleEventLoop()

if __name__ == "__main__":
    main()
