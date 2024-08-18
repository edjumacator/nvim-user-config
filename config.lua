-- Sync clipboard between OS and Neovim.
--  Uncomment this option if you want your OS clipboard to sync with Neovim.
--  See `:help 'clipboard'`
-- vim.opt.clipboard = 'unnamedplus'

vim.g.dap_home = os.getenv 'HOME' .. '/src/'

require 'user.font'
