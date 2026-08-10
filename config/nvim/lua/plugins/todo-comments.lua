return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    sign_column = false, -- 不在 signcolumn 显示图标
    keywords = {
      FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = "", color = "info" },
      HACK = { icon = "", color = "warning" },
      WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = "", color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = "", color = "info", alt = { "INFO" } },
    },
  },
  keys = {
    { "<Leader>st", "<Cmd>TodoTelescope<CR>", desc = "Todo comments" },
  },
}
