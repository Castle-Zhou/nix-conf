return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  -- cafetiere 自动将 devicons 颜色适配为 Catppuccin 调色板
  dependencies = {
    { "lpnh/cafetiere.nvim", opts = {} },
  },
}
