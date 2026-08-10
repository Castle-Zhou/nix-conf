-- Lua 语言配置
-- Neovim Lua 常用风格: tabstop=2, 空格缩进
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
