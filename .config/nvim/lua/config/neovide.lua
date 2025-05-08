-- Taken from: https://github.com/chrisgrieser/.config/blob/main/nvim/lua/config/neovide-gui-settings.lua

-- DOCS https://neovide.dev/configuration.html
--------------------------------------------------------------------------------

---ensures unique keymaps https://www.reddit.com/r/neovim/comments/16h2lla/can_you_make_neovim_warn_you_if_your_config_maps/
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?:boolean, nowait?: boolean}
local function keymap(mode, lhs, rhs, opts)
  if not opts then
    opts = {}
  end
  if opts.unique == nil then
    opts.unique = true
  end -- allows to disable with `unique=false`

  -- violating `unique=true` throws an error; using `pcall` so other mappings
  -- are still loaded
  pcall(vim.keymap.set, mode, lhs, rhs, opts)
end

--------------------------------------------------------------------------------
-- cmd+ / cmd- to change zoom
local function changeScaleFactor(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
  local icon = delta > 0 and "" or ""
  local opts = { id = "scale_factor", icon = icon, title = "Scale factor" }
  vim.notify(tostring(vim.g.neovide_scale_factor), nil, opts)
end
keymap({ "n", "x", "i" }, "<D-=>", function()
  changeScaleFactor(0.01)
end, { desc = " Zoom" })
keymap({ "n", "x", "i" }, "<D-->", function()
  changeScaleFactor(-0.01)
end, { desc = " Zoom" })

--------------------------------------------------------------------------------

-- CMD & ALT Keys
vim.g.neovide_input_use_logo = true -- enable, so `cmd` on macOS can be used
vim.g.neovide_input_macos_option_key_is_meta = "none" -- disable, so `{@~` etc. can be used

-- Appearance
vim.g.neovide_underline_stroke_scale = 1.5 -- fix underline thickness
vim.g.neovide_remember_window_size = true
vim.g.neovide_hide_mouse_when_typing = true
vim.opt.linespace = -1 -- less line height

--------------------------------------------------------------------------------
-- CURSOR
vim.opt.guicursor = {
  "i-ci-c:ver25",
  "n-sm:block",
  "r-cr-o-v:hor10",
}

-- vim.g.neovide_cursor_animation_length = 0.01
-- vim.g.neovide_cursor_trail_size = 0.9
-- vim.g.neovide_cursor_unfocused_outline_width = 0.1
-- vim.g.neovide_cursor_vfx_mode = "railgun" -- railgun|torpedo|pixiedust|sonicboom|ripple|wireframe
--
-- vim.g.neovide_cursor_animate_in_insert_mode = true
-- vim.g.neovide_cursor_animate_command_line = true
--
-- -- only railgun, torpedo, and pixiedust
-- vim.g.neovide_cursor_vfx_particle_lifetime = 0.8
-- vim.g.neovide_cursor_vfx_particle_density = 20.0
-- vim.g.neovide_cursor_vfx_particle_speed = 40.0
--
-- -- only railgun
-- vim.g.neovide_cursor_vfx_particle_phase = 1.3
-- vim.g.neovide_cursor_vfx_particle_curl = 1.3

vim.g.neovide_fullscreen = true
vim.o.guifont = "Operator Mono Book,Fira Code:h20"
vim.g.neovide_theme = "gruvybox"

-- vim.api.nvim_set_keymap("i", "<d-v>", '<ESC>l"+Pli', { noremap = true })
-- vim.api.nvim_set_keymap("n", "<d-v>", 'l"+P', { noremap = true })
-- vim.api.nvim_set_keymap("c", "<c-v>", '<C-o>l<C-o>"+<C-o>P<C-o>l', { noremap = true })
-- vim.api.nvim_set_keymap("t", "<sc-v>", '<C-\\><C-n>"+PA', { noremap = true })

dofile(vim.env.HOME .. "/.neovide_local.lua")
