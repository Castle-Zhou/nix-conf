local icons = require("utils.icons")

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      highlights = require("catppuccin.special.bufferline").get_theme(),
      options = {
        always_show_bufferline = true,
        show_close_icon = false,
        -- 显示错误
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, _, _)
          local icon = level:match("error") and icons.error
            or level:match("warn") and icons.warning
            or icons.hint
          return " " .. icon .. " " .. count
        end,
        custom_filter = function(buf_id, _)
          return vim.fn.bufname(buf_id) ~= ""
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    })
  end,
}
