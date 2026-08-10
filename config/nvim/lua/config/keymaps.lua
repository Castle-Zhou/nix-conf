-- 快捷键映射

local map = require("utils.map").map
local icons = require("utils.icons")

-- Free up <Leader>
map("n", "<Space>", "")

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Go to Left Window",   icons.left)
map("n", "<C-j>", "<C-w>j", "Go to Bottom Window", icons.down)
map("n", "<C-k>", "<C-w>k", "Go to Top Window",    icons.up)
map("n", "<C-l>", "<C-w>l", "Go to Right Window",  icons.right)

-- Window resize
map("n", "<M-up>",    "<CMD>resize +2<CR>",          "Increase Height", icons.resize_up)
map("n", "<M-down>",  "<CMD>resize -2<CR>",          "Decrease Height", icons.resize_down)
map("n", "<M-right>", "<CMD>vertical resize +2<CR>", "Increase Width",  icons.resize_right)
map("n", "<M-left>",  "<CMD>vertical resize -2<CR>", "Decrease Width",  icons.resize_left)

-- Scroll (keep cursor centered)
map("n", "<C-d>", "<C-d>zz", "Scroll Down Half", icons.resize_down)
map("n", "<C-u>", "<C-u>zz", "Scroll Up Half",   icons.resize_up)

-- Clear search highlight
map("n", "<Esc>", "<CMD>nohlsearch<CR><Esc>", "Clear Search Highlight")

-- Move lines (Normal)
map("n", "∆",     ":m .+1<CR>==", "Move Line Down")
map("n", "˚",     ":m .-2<CR>==", "Move Line Up")
map("n", "<M-j>", ":m .+1<CR>==", "Move Line Down")
map("n", "<M-k>", ":m .-2<CR>==", "Move Line Up")

-- Move blocks (Visual)
map("v", "∆",     ":m '>+1<CR>gv=gv", "Move Block Down")
map("v", "˚",     ":m '<-2<CR>gv=gv", "Move Block Up")
map("v", "<M-j>", ":m '>+1<CR>gv=gv", "Move Block Down")
map("v", "<M-k>", ":m '<-2<CR>gv=gv", "Move Block Up")

-- Toggle background
map("n", "<Leader>ub", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end, "Toggle Background")

-- Toggle diagnostic virtual text
map("n", "<Leader>dt", function()
  -- _G.__diagnostic_vt_on 在第一次调用时根据当前配置自动判断
  if _G.__diagnostic_vt_on == nil then
    _G.__diagnostic_vt_on = vim.diagnostic.config().virtual_text ~= false
  end
  _G.__diagnostic_vt_on = not _G.__diagnostic_vt_on
  vim.diagnostic.config({
    virtual_text = _G.__diagnostic_vt_on and {
      prefix = function(diagnostic)
        local icons = require("utils.icons")
        local map = {
          [vim.diagnostic.severity.ERROR] = icons.error,
          [vim.diagnostic.severity.WARN]  = icons.warning,
          [vim.diagnostic.severity.HINT]  = icons.hint,
          [vim.diagnostic.severity.INFO]  = icons.info,
        }
        return (map[diagnostic.severity] or icons.info) .. " "
      end,
    } or false,
  })
  vim.notify((_G.__diagnostic_vt_on and " " or " ") .. "Diagnostic inline " .. (_G.__diagnostic_vt_on and "on" or "off"))
end, "Toggle diagnostic inline")

-- Command-line navigation
map("c", "<C-a>", "<Home>",  "Go to Beginning of Line")
map("c", "<C-e>", "<End>",   "Go to End of Line")
map("c", "<C-b>", "<Left>",  "Cursor Left")
map("c", "<C-f>", "<Right>", "Cursor Right")

-- Wrapped line navigation
map("n", "k", "gk", "Move Up (Wrapped Line)")
map("n", "j", "gj", "Move Down (Wrapped Line)")

-- Black hole
map("n", "x", "\"_x", "Delete (Black Hole)")
map("n", "r", "\"_r", "Replace (Black Hole)")

-- Buffer
map("n", "<Leader>bd", "<CMD>bdelete<CR>",             "Close Buffer",        icons.close)
map("n", "H",          "<CMD>BufferLineCyclePrev<CR>", "Previous Buffer",     icons.left)
map("n", "L",          "<CMD>BufferLineCycleNext<CR>", "Next Buffer",         icons.right)
map("n", "<Leader>bh", "<CMD>BufferLineCyclePrev<CR>", "Previous Buffer",     icons.left)
map("n", "<Leader>bl", "<CMD>BufferLineCycleNext<CR>", "Next Buffer",         icons.right)
map("n", "<Leader>bH", "<CMD>BufferLineMovePrev<CR>",  "Move Buffer Left",    icons.left)
map("n", "<Leader>bL", "<CMD>BufferLineMoveNext<CR>",  "Move Buffer Right",   icons.right)
