-- C / C++ 配置
-- 常见风格: tabstop=4, 空格缩进, 80-100 列
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
    vim.wo.colorcolumn = "100"
  end,
})
