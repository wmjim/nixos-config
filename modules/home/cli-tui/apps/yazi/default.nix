# Yazi — 终端文件管理器
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.apps.yazi;
  appsCfg = config.mengw.cli.apps;
  cliCfg = config.mengw.cli;

  mkYaziFlavor = { pname, owner, repo, rev, sha256 }: pkgs.stdenv.mkDerivation {
    inherit pname;
    version = "unstable";
    src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  flexoki-light-yazi = mkYaziFlavor {
    pname = "flexoki-light.yazi";
    owner = "gosxrgxx";
    repo = "flexoki-light.yazi";
    rev = "1b1e67795a3eeec51aec0be74b3d76316be9aaa1";
    sha256 = "sha256-yIYkgGeYHl3/iRrKzsPnh2nw0PwPD/LYm1BQMy/yvBw=";
  };

  everforest-medium-yazi = mkYaziFlavor {
    pname = "everforest-medium.yazi";
    owner = "Chromium-3-Oxide";
    repo = "everforest-medium.yazi";
    rev = "e1ead7b5a3bfc8eb572fd269a369775842752705";
    sha256 = "sha256-2Fx7+xnSsc+aVHBZUtLtVUDEzb1y8BcPBASciKk8x7o=";
  };

  catppuccin-mocha-yazi = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-mocha.yazi";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "flavors";
      rev = "36c49acfd7d3924bd751fd74e37b6ff438af691a";
      sha256 = "sha256-IK0Ye/EPjOGC+//HpjExVTAKfXtlgOrYbFLrhy/DF6k=";
    };
    installPhase = ''
      mkdir -p $out
      cp -r catppuccin-mocha.yazi/* $out/
    '';
  };
in
{
  options.mengw.cli.apps.yazi.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Yazi 终端文件管理器";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && cliCfg.enable) {
    programs.yazi = {
      enable = true;
      # 启用 Fish 集成
      enableFishIntegration = true;
      shellWrapperName = "y";
      settings = {
        # 文件排序方式：自然排序
        sort_by = "natural";
        # 排序时区分大小写
        sort_sensitive = true;
        preview = {
          tab_size = 2;
          # 图片预览最大宽/高（设大值以撑满栏宽）
          max_width = 2000;
          max_height = 2000;
        };
      };
      theme = {
        flavor = {
          dark = "catppuccin-mocha";
          light = "flexoki-light";
        };
      };
      flavors = {
        flexoki-light = flexoki-light-yazi;
        everforest-medium = everforest-medium-yazi;
        catppuccin-mocha = catppuccin-mocha-yazi;
      };
    };
  };
}
