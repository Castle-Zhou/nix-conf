local icons = require("utils.icons")

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    defaults = {},
    spec = {
      { "<Leader>f", group = "Find",       icon = icons.telescope },
      { "<Leader>b", group = "Buffer",     icon = icons.file },
      { "<Leader>c", group = "Code",       icon = icons.code },
      { "<Leader>h", group = "Hunk",       icon = icons.hunk },
      { "<Leader>u", group = "UI/Toggle",  icon = icons.ui },
      { "<Leader>g", group = "Git",        icon = icons.git },
      { "<Leader>l", group = "LSP",        icon = icons.code },
      { "<Leader>d", group = "Diagnostic", icon = icons.warning },
      { "[", group = "Prev",               icon = icons.left },
      { "]", group = "Next",               icon = icons.right },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
  end,
}
