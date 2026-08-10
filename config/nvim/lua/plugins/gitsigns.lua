return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "<Leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<Leader>hr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<Leader>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("v", "<Leader>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<Leader>hS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<Leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<Leader>hR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<Leader>hp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<Leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
      map("n", "<Leader>ug", gitsigns.toggle_current_line_blame, "Toggle line blame")
      map("n", "<Leader>hd", gitsigns.diffthis, "Diff this")
      map("n", "<Leader>hD", function() gitsigns.diffthis("~") end, "Diff this ~")
      map("n", "<Leader>ud", gitsigns.toggle_deleted, "Toggle deleted")
      map("n", "[h", gitsigns.prev_hunk, "Prev hunk")
      map("n", "]h", gitsigns.next_hunk, "Next hunk")
    end,
  },
}
