{ config, pkgs, ... }:

{
  # WSL 使用跨平台 CLI 配置
  imports = [
    ../home/cli-common/default.nix
  ];

  # WSL 特定配置
  home.sessionVariables = {
    # WSL 环境标识
    WSL_DISTRO_NAME = "Arch";
    WSL_INTEROP = "/run/WSL/1_interop";
    WT_SESSION = "1";

    # 浏览器集成（使用 wslu）
    BROWSER = "wslview";

    # 优化 WSL 性能
    WSL_UTF8 = "1";
  };

  # WSL 相关包
  home.packages = with pkgs; [
    wslu          # WSL 实用工具集合（wslview, wslusc 等）
    wl-clipboard  # Wayland 剪贴板工具
  ];

  # 针对 WSL 的优化配置
  programs.fish.shellInit = ''
    # WSL 特定初始化
    if test -f /etc/wsl.conf
      set -gx IS_WSL 1
    end

    # 设置 Windows 路径别名
    if test -d /mnt/c/Users/$USER
      alias winhome='cd /mnt/c/Users/$USER'
    end
  '';

  # WSL 相关的 systemd 用户服务（如果启用了 systemd）
  systemd.user.services.wsl-clipboard = {
    Unit = {
      Description = "WSL Clipboard Sync";
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.wslu}/bin/wsl-bridge";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}
