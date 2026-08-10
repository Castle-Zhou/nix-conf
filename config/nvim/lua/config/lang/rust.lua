-- Rust 语言配置
-- Rust 惯例: tabstop=4, 空格缩进, ~100 列
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
    vim.wo.colorcolumn = "100"
  end,
})
