vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- add your own colorscheme here
    -- install new colorschemes by adding them as a plugin
    vim.cmd 'colorscheme monokai-pro-ristretto'
  end,
})
