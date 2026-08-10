-- Neovim 配置入口

-- 加载基本选项
require("config.options")

-- 加载快捷键映射
require("config.keymaps")

-- Neovide 专属设置
require("config.neovide")

-- 加载各语言配置（按 FileType 设置 buffer-local 参数）
require("config.lang")

-- 加载插件管理器及全部插件
require("config.lazy")
