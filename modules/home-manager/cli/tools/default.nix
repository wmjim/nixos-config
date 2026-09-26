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
      herdr
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
    # （终端里多出第 4 套配色）。这里补主题。
    #
    # theme_background 的更正：当时写“置 True 会让 btop 自画不透明底，使
    # frosted-glass.kdl 的 opacity 与模糊完全无从体现”——这是错的。niri 的
    # opacity 作用在**整个窗口**上（文档：“applied to every surface of the
    # window”），与窗口里面画不画底无关，磨砂效果一直都在。
    # 而且本主题的 theme[main_bg] = #303446 恰好等于 foot 的背景色，两种取值
    # 在这个配色下是**视觉空操作**。
    # 保留 false 的真实理由：让 btop 的背景始终跟随终端，而不是把 #303446
    # 再硬编码一份——以后改 foot 的背景色时不会两者脱节。
    programs.btop = {
      # 包由本模块提供，故上面 home.packages 里不再列 btop
      enable = true;
      settings = {
        color_theme = "catppuccin-frappe";
        # btop 内嵌配置说明：set to False if you want terminal background
        # transparency
        theme_background = false;
      };
      themes.catppuccin-frappe = ./btop/catppuccin-frappe.theme;
    };

    home.file.".config/fastfetch/config.jsonc" = {
      source = ../../../../assets/fastfetch/nixos-01.jsonc;
      force = true;
    };

    # fastfetch 的 logo：文本形式的 NixOS 美术图，逐行内嵌了 Frappe 蓝 (#8CAAEE) 的
    # ANSI 码。之所以是文件而不是内置 logo，见 assets/fastfetch/nixos-01.jsonc 里的说明
    # —— 内置的 NixOS logo 不可着色。
    home.file.".config/fastfetch/logo/nixos_logo_1.txt".source =
      ../../../../assets/fastfetch/logo/nixos_logo_1.txt;
  };
}
