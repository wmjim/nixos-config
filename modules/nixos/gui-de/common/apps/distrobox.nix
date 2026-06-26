{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.distrobox;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.apps.distrobox.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Distrobox 和 Podman 容器工具";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    # 安装 distrobox 和 podman (作为底层容器运行时)
    environment.systemPackages = with pkgs; [
      distrobox
      podman
    ];

    # 启用 podman 并设置相关服务
    virtualisation = {
      podman = {
        enable = true;
        # 允许非 root 用户运行容器
        dockerCompat = true;
      };
    };
  };
}
