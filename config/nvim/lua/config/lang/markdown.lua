-- Markdown 配置
-- 更适合文本编辑的配置：软换行、禁用缩进
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
