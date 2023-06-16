-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])
