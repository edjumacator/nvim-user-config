return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'buffers',
        numbers = 'ordinal',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        left_mouse_command = 'buffer %d',
        indicator = {
          icon = '▎',
          style = 'icon',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        separator_style = 'slant',
        enforce_regular_tabs = false,
        always_show_bufferline = true,
      },
      highlights = {
        fill = { bg = '#1E1E2E' },
        buffer_selected = { fg = '#A6E3A1', bold = true },
        buffer_visible = { fg = '#FAB387' },
        buffer = { fg = '#C9CBFF' },
      },
    }
  end,
}
