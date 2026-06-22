{ config, pkgs, ... }:

{
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
}
