return {
  "stevearc/aerial.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<Leader>ss", "<Cmd>AerialToggle!<CR>", desc = "Toggle outline" },
  },
  opts = {
    -- 优先使用 Treesitter，LSP 兜底
    backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

    layout = {
      default_direction = "prefer_right",
      placement = "window",
      max_width = { 40, 0.2 },
      min_width = 10,
      resize_to_content = true,
      preserve_equality = false,
      win_opts = {},
    },

    attach_mode = "window",

    -- 离开源码窗口时自动关闭 aerial
    close_automatic_events = { "unfocus" },

    -- 显示变量、字段等所有常见符号
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Property",
      "Struct",
      "Variable",
      "Constant",
    },

    -- 显示符号类型图标（取决于 devicons）
    show_guides = true,

    -- 符号窗口内的快捷键
    keymaps = {
      ["?"] = "actions.show_help",
      ["<CR>"] = "actions.jump",
      ["<2-LeftMouse>"] = "actions.jump",
      ["<C-v>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",
      ["p"] = "actions.scroll",
      ["{"] = "actions.prev",
      ["}"] = "actions.next",
      ["[count]"] = "actions.down_and_scroll",
      ["]"] = "actions.up_and_scroll",
    },

    on_attach = function(bufnr)
      -- 在 aerial 窗口内也可以用 [h / ]h 导航
      vim.keymap.set("n", "[h", require("aerial").prev, { buffer = bufnr, desc = "Prev symbol" })
      vim.keymap.set("n", "]h", require("aerial").next, { buffer = bufnr, desc = "Next symbol" })
    end,
  },
  init = function()
    -- which-key 注册 leader 组
    vim.schedule(function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({ { "<Leader>s", group = "Search", icon = "" } })
      end
    end)
  end,
}
