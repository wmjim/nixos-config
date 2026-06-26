-- 插件管理器配置

-- 设置 lazy.nvim 存放目录
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 自动安装 lazy.nvim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
 -- 将 lazy.nvim 插件目录强制放到运行路径首位
-- Neovim 首先加载 lazy.nvim，保证插件管理器优先启动，再去加载其它插件
vim.opt.rtp:prepend(lazypath)

-- 配置 mapleader(全局前缀键) 和 maplocalleader(局部缓冲区前缀键)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 引入 lazy.nvim
require("lazy").setup({
	spec = {
		-- 导入插件: 自动读取 lua/plugins 下插件
		{ import = "plugins" },
	},
	-- 安装插件时所使用的配色方案
	install = { colorscheme = { "habamax" } },
	-- 自动检查插件更新
	checker = { enabled = true },
})
