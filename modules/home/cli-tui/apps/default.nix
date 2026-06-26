# CLI 应用配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.apps;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 CLI 应用（fastfetch、lazygit 等）";
  };

  imports = [
    ./yazi
    # ./tmux
    ./zellij
  ];

  config = lib.mkIf (cfg.enable && cliCfg.enable) {
    home.packages = with pkgs; [
      fastfetch
      lazydocker
      yt-dlp
      lazygit
      claude-code
      codex
      unzip
      tree
      file
      net-tools
      # nvtopPackages.nvidia
      btop
      duf
      glow
      hugo
      ffmpeg
    ];

    home.sessionVariables = {
      # claude 插件安装目录
      TMPDIR = "$HOME/.tmp";
    };

    # fastfetch 配置
    home.file.".config/fastfetch/config.jsonc" = {
      source = ./fastfetch/nixos-01.jsonc;
      force = true;
    };
  };
}
