return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<Leader>e", "<Cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
  },
  init = function()
    vim.schedule(function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({ { "<Leader>e", icon = "" } })
      end
    end)
  end,
  opts = {
    filesystem = {
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = false, -- 让空格只作为 <Leader> 使用
        },
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
