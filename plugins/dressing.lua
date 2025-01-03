return {
  'stevearc/dressing.nvim',
  config = function()
    require('dressing').setup {
      input = {
        enabled = true,
        default_prompt = 'Input:',
        border = 'rounded', -- Optional: Customize border style
        relative = 'editor', -- Center the prompt in the editor window
        prefer_width = 40, -- Set preferred width
        win_options = {
          winblend = 10, -- Transparency
          winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
        },
        mappings = {
          n = {
            ['<Esc>'] = 'Close', -- Allow Esc to cancel
          },
        },
      },
    }
  end,
}
