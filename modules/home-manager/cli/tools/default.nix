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
    ./zellij.nix
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
      btop
      duf
      glow
      hugo
      ffmpeg
    ];

    home.sessionVariables = {
      TMPDIR = "$HOME/.tmp";
    };

    home.file.".config/fastfetch/config.jsonc" = {
      source = ../../../../assets/fastfetch/nixos-01.jsonc;
      force = true;
    };
  };
}
