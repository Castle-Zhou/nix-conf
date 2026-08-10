-- 基本
vim.g.mapleader = " "          -- <Leader> 键设为空格
vim.g.maplocalleader = "\\"    -- <LocalLeader> 键

-- 显示
vim.opt.number = true          -- 显示行号
vim.opt.relativenumber = true  -- 相对行号（方便跳转）
vim.opt.cursorline = true      -- 高亮当前行
vim.opt.signcolumn = "yes"     -- 始终显示侧边符号列（给 git sign 用）
vim.opt.showmode = false       -- 底部不显示模式（lualine 会显示）

-- 缩进
vim.opt.tabstop = 2           -- Tab 宽度 2
vim.opt.softtabstop = 2       -- 编辑时 Tab 宽度
vim.opt.shiftwidth = 2        -- 缩进宽度 2
vim.opt.expandtab = true      -- 用空格代替 Tab
vim.opt.smartindent = true    -- 智能缩进

-- 搜索
vim.opt.hlsearch = true       -- 高亮搜索结果
vim.opt.incsearch = true      -- 实时搜索
vim.opt.ignorecase = true     -- 搜索忽略大小写
vim.opt.smartcase = true      -- 包含大写时区分大小写

-- 编辑
vim.opt.undofile = true       -- 持久化撤销历史
vim.opt.updatetime = 200      -- 更新间隔（ms），对实时显示很重要
vim.opt.timeoutlen = 300      -- 按键映射超时（ms）

-- 分屏
vim.opt.splitright = true     -- 垂直分屏在新窗口右侧
vim.opt.splitbelow = true     -- 水平分屏在新窗口下方

-- 其他
vim.opt.termguicolors = true  -- 启用真彩色
vim.opt.mouse = "a"           -- 启用鼠标支持
vim.opt.clipboard = "unnamedplus"  -- 与系统剪贴板互通
vim.opt.scrolloff = 8         -- 滚动时保留上下 8 行上下文
vim.opt.sidescrolloff = 8     -- 水平滚动保留左右 8 列
vim.opt.pumheight = 10        -- 弹出菜单最多显示 10 项
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.shortmess:append "sI" -- 去掉启动提示

-- 诊断：不在侧边显示图标，改为行尾带背景色的内联文本
local icons = require("utils.icons")
vim.diagnostic.config({
  signs = false,
  virtual_text = {
    prefix = function(diagnostic)
      local map = {
        [vim.diagnostic.severity.ERROR] = icons.error,
        [vim.diagnostic.severity.WARN]  = icons.warning,
        [vim.diagnostic.severity.HINT]  = icons.hint,
        [vim.diagnostic.severity.INFO]  = icons.info,
      }
      return (map[diagnostic.severity] or icons.info) .. " "
    end,
  },
  underline = true,
})
