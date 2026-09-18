# Yazi — 终端文件管理器
# 暗色 flavor 用 Catppuccin Frappe，与 foot / Neovim 同家族（此前是 Everforest）
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.tools.yazi;
  toolsCfg = config.mengw.cli.tools;
  cliCfg = config.mengw.cli;

  # yazi flavor：把上游仓库里的 flavor 目录复制成 store 目录。
  # subdir 是为了应付上游两种组织方式：独立仓库（flexoki-light.yazi）的 flavor
  # 就在仓库根目录；而官方合集（yazi-rs/flavors）把每个 flavor 放在同名子目录下，
  # 根目录还有 README / scripts / package.json 等与 flavor 无关的内容。
  mkYaziFlavor =
    {
      pname,
      owner,
      repo,
      rev,
      sha256,
      subdir ? null,
    }:
    let
      flavorGlob = if subdir == null then "*" else "${subdir}/*";
    in
    pkgs.stdenv.mkDerivation {
      inherit pname;
      version = "unstable";
      src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };
      installPhase = ''
        mkdir -p $out
        cp -r ${flavorGlob} $out/
      '';
    };
  flexoki-light-yazi = mkYaziFlavor {
    pname = "flexoki-light.yazi";
    owner = "gosxrgxx";
    repo = "flexoki-light.yazi";
    rev = "1b1e67795a3eeec51aec0be74b3d76316be9aaa1";
    sha256 = "sha256-yIYkgGeYHl3/iRrKzsPnh2nw0PwPD/LYm1BQMy/yvBw=";
  };
  # 官方 flavor 合集里的 Catppuccin Frappe（含 flavor.toml 与 tmtheme.xml）
  catppuccin-frappe-yazi = mkYaziFlavor {
    pname = "catppuccin-frappe.yazi";
    owner = "yazi-rs";
    repo = "flavors";
    rev = "20b47bfd78880c2674899597fd26bc01b21ff48c";
    sha256 = "sha256-NGnfrQdsnQITKCZ0oh6DCxeCR2ozJoPAZetsi3ghHAI=";
    subdir = "catppuccin-frappe.yazi";
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
      # Yazi 26 移除了 yazi.toml 的顶层排序键，必须放进 [mgr] 段，
      # 顶层的 sort_by 会被当成 opener 表的键名解析，报 "must be 1-20 characters in kebab-case"
      settings = {
        mgr = {
          sort_by = "natural";
          sort_sensitive = true;
        };
        preview = {
          tab_size = 2;
          max_width = 2000;
          max_height = 2000;
        };
      };
      # foot 原生支持 sixel，yazi 会优先选内置的 Sixel 驱动（见 yazi-adapter
      # 的驱动选择：Brand::Foot => [Sixel]），ueberzugpp 仅作为 GNOME 终端 /
      # WSLg 等无图形协议终端的兜底（nixpkgs 的 yazi wrapper 不带它，图片会空白）
      extraPackages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.ueberzugpp;
      theme = {
        flavor = {
          light = "flexoki-light";
          dark = "catppuccin-frappe";
        };
      };
      flavors = {
        flexoki-light = flexoki-light-yazi;
        catppuccin-frappe = catppuccin-frappe-yazi;
      };
    };
  };
}
