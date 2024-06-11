return {
  'rebelot/kanagawa.nvim',
  lazy = true,
  priority = 1000,
  config = function()
    require('kanagawa').setup {}
  end,
  init = function()
    vim.cmd 'colorscheme kanagawa'
  end,
}
