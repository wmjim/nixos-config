# Neovim 编辑器配置
#
# 配置树 nvim/ 复用 Omarchy 的 omarchy-nvim 包：LazyVim 官方 starter 骨架
# + Omarchy 的覆盖文件（lua/config、lua/plugins、plugin/after、lazyvim.json），
# 两处仅为适配 Nix 做了改动，见 nvim/lua/config/lazy.lua 与 nvim/lua/plugins/theme.lua
# 的注释。~/.config/nvim 是指向 store 的只读符号链接，插件在首次启动时联网装进
# ~/.local/share/nvim（Omarchy 用约 116MiB 预缓存规避这一次下载，Nix 侧不做）。
{ lib, config, ... }:
let
  cfg = config.mengw.cli.editors.neovim;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.editors.neovim.enable = lib.mkEnableOption "Neovim（Omarchy 的 LazyVim 配置）" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cliCfg.enable) {
    programs.neovim.enable = true;
    xdg.configFile."nvim".source = ./nvim;
  };
}
