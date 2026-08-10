return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "auto", -- dark→mocha, light→latte
      transparent_background = false,
      integrations = {
        lualine = {},
        neo_tree = true,
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        gitsigns = true,
        cmp = true,
        treesitter = true,
        mason = true,
        aerial = true,
        todo_comments = true,
        indent_blankline = {
          enabled = true,
          scope_color = "lavender",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    })
    vim.cmd.colorscheme("catppuccin")

    -- 监听 background 变化，自动重算 flavour
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = function()
        vim.cmd.colorscheme("catppuccin")
      end,
    })
  end,
}
