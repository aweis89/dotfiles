return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-a>h", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-a>j", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-a>k", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-a>l", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-a>\\", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
