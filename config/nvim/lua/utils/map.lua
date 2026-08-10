-- 统一按键定义：自动设置 desc + 可选图标

local M = {}

function M.map(mode, lhs, rhs, desc, icon)
  local opts = { noremap = true, silent = true }
  if desc then
    opts.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, opts)

  if icon then
    vim.schedule(function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({ { lhs, icon = icon } })
      end
    end)
  end
end

return M
