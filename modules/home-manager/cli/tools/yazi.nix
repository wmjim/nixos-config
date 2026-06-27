# Yazi — 终端文件管理器
# 深色主题由 Stylix 统一管理（自动设置 programs.yazi.theme）
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.tools.yazi;
  toolsCfg = config.mengw.cli.tools;
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
in
{
  options.mengw.cli.tools.yazi.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Yazi 终端文件管理器";
  };

  config = lib.mkIf (cfg.enable && toolsCfg.enable && cliCfg.enable) {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "y";
      settings = {
        sort_by = "natural";
        sort_sensitive = true;
        preview = {
          tab_size = 2;
          max_width = 2000;
          max_height = 2000;
        };
      };
      theme = {
        flavor = {
          light = "flexoki-light";
        };
      };
      flavors = {
        flexoki-light = flexoki-light-yazi;
        everforest-medium = everforest-medium-yazi;
      };
    };
  };
}
