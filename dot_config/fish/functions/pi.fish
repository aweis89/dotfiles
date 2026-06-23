function pi --wraps pi --description 'Run pi with Cursor SDK ambient rules, skills, and bridge disabled'
    set -lx PI_CURSOR_SETTING_SOURCES none
    set -lx PI_CURSOR_PI_TOOL_BRIDGE 0
    set -lx PI_CURSOR_TOOL_MANIFEST 0
    command pi $argv
end
