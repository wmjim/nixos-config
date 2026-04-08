{pkgs, ...}: {
  programs.clash-verge = {
    enable = true;      # 启用 Clash Verge 功能（核心开关）
    autoStart = true;   # 系统开机/用户登录后自动启动应用
    tunMode = true;     # 启用 TUN 虚拟网卡模式（全局流量代理，比普通代理更彻底）
    serviceMode = true; # 启用系统服务模式（后台守护进程运行，不依赖图形界面）
  };
}