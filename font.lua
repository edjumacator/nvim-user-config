-- format: '<Font Name>:h<size>(:<style flags>)'
-- vim.opt.guifont = 'FiraMono Nerd Font Mono:h15'

-- use a bold font for regular text and set normal bold to extrabold
if not vim.g.neovide then
  vim.opt.guifont = 'JetBrainsMono Nerd Font:h16:b'
else
  vim.opt.guifont = 'JetBrainsMono Nerd Font:h18:b'
  vim.g.neovide_scale_factor = 0.94
  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_vfx_particle_lifetime = 1.5
  vim.g.neovide_vfx_particle_density = 10
  vim.g.neovide_cursor_vfx_particle_curl = 2.0
end
vim.cmd [[ highlight! link Bold ExtraBold ]]
