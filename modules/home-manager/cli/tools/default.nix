# CLI 工具配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.tools;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.tools.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 CLI 工具（fastfetch、lazygit 等）";
  };

  imports = [
    ./yazi.nix
    ./tmux.nix
  ];

  config = lib.mkIf (cfg.enable && cliCfg.enable) {
    home.packages = with pkgs; [
      fastfetch
      lazydocker
      yt-dlp
      lazygit
      claude-code
      pi-coding-agent
      codex
      unzip
      gzip
      tree
      file
      net-tools
      duf
      glow
      hugo
      ffmpeg
    ];

    # btop：终端系统监控。此前只装包、零配置，于是它跑在自带的 Default 主题上
    # （终端里多出第 4 套配色），且 theme_background 默认为 True —— btop 自画不透明
    # 背景，使 frosted-glass.kdl 里针对 app-id=btop 的 opacity 0.70 与模糊
    # 完全无从体现。这里补主题，并改用终端背景让 foot 的半透明透出来。
    programs.btop = {
      # 包由本模块提供，故上面 home.packages 里不再列 btop
      enable = true;
      settings = {
        color_theme = "catppuccin-frappe";
        # 由 btop 内嵌的配置说明："set to False if you want terminal background
        # transparency"；置 True 时 theme[main_bg] 会画成不透明底
        theme_background = false;
      };
      themes.catppuccin-frappe = ./btop/catppuccin-frappe.theme;
    };

    home.file.".config/fastfetch/config.jsonc" = {
      source = ../../../../assets/fastfetch/nixos-01.jsonc;
      force = true;
    };
  };
}
