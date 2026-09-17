-- 取自 omarchy 的 themes/catppuccin/neovim.lua（Omarchy 3.8 遗留格式）。上游把
-- colorscheme 写成 "catppuccin-nvim"，但 catppuccin 注册的配色名是 catppuccin /
-- catppuccin-frappe 等，LazyVim 会因 pcall 失败而回落到 tokyonight，故在此修正。
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe", -- 与 Foot 的 catppuccin_frappe 配色保持一致
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
