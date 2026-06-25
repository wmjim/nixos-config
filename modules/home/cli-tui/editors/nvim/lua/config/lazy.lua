-- 插件管理器配置
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
vim.opt.rtp:prepend(lazypath)

-- 配置 mapleader(全局前缀键) 和 maplocalleader(局部缓冲区前缀键)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 设置 lazy.nvim
require("lazy").setup({
	spec = {
		-- 导入插件
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- 安装插件时所使用的配色方案
	install = { colorscheme = { "habamax" } },
	-- 自动检查插件更新
	checker = { enabled = true },
})
