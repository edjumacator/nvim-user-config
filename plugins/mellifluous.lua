return {
  'ramojus/mellifluous.nvim',
  lazy = true,
  priority = 1000,
  config = function()
    require('mellifluous').setup {}
  end,
  -- init = function()
  --   vim.cmd.colorscheme 'mellifluous'
  -- end,
}
