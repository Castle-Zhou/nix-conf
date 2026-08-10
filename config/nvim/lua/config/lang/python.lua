-- Python 语言配置
-- 社区标准: tabstop=4, 空格缩进, 最大行宽 ~88/100
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
    vim.wo.colorcolumn = "88"
  end,
})
