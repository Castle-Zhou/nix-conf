-- Neovide GUI 专属配置

if vim.g.neovide then
  -- 字体（带回退）
  local function font_available(name)
    if vim.fn.executable("fc-list") == 0 then
      return false
    end
    vim.fn.system("fc-list -q \"" .. name .. "\" 2>/dev/null")
    return vim.v.shell_error == 0
  end

  local font_size = 18
  local font_candidates = {
    "Maple Mono NF CN",
    "JetBrainsMono Nerd Font",
    "FiraCode Nerd Font",
    "CascadiaCode NF",
    "Hack Nerd Font",
    "monospace",
  }

  for _, font in ipairs(font_candidates) do
    if font_available(font) then
      vim.o.guifont = font .. ":h" .. font_size
      break
    end
  end

  -- 缩放/窗口
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_remember_window_size = true

  -- 渲染
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_length = 0.08
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_fullscreen = false
  vim.g.neovide_confirm_quit = true
end
