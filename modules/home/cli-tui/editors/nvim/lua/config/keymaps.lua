-- 快捷键映射
-- vim.keymap.set(mode, lhs, rhs, opts)
-- mode: n / i / c
-- lhs: 快捷键按键，Ctrl -> C、Alt -> A
-- rhs: 快捷键功能，映射另外一组按键或一个 lua 函数
-- opts: table，对快捷键的额外配置
--      remap: 默认为 false 禁用递归映射
--      silent: 默认 false，不在 command line 显示命令
-- eg: vim.keymap.set("n", "<C-a>b", ":lua print('hello world')<CR>", { silent = true })

-- 撤销
vim.keymap.set({"n", "i"}, "<C-z>", "<Cmd>undo<CR>", { silent = true })




