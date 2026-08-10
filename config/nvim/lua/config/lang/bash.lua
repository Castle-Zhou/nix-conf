-- Bash / Shell 语言配置
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "bash", "sh", "zsh" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
