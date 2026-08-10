-- JavaScript / TypeScript / HTML / CSS / JSON / YAML 配置
-- 前端通用风格: tabstop=2, 空格缩进
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "json",
    "jsonc",
    "yaml",
    "toml",
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
