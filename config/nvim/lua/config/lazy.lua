-- lazy.nvim 插件管理器

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    cache = {
      enabled = true,
    },
  },
})

-- nvim-treesitter × Neovim 0.12 兼容：失效节点上 get_node_text 会炸
-- 加 pcall 保护，失败时返回空字符串
pcall(function()
  local original = vim.treesitter.get_node_text
  vim.treesitter.get_node_text = function(node, source, opts)
    local ok, result = pcall(original, node, source, opts)
    if ok then
      return result
    end
    return ""
  end
end)
