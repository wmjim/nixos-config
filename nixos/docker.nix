# Docker 完整配置（服务 + 用户工具）
{ config, pkgs, ... }:

{
  # ========== Docker 服务配置 ==========
  virtualisation.docker = {
    enable = true;

    # 自动清理（每周清理未使用的资源）
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" "--volumes" ];
    };

    # Docker 守护进程配置
    daemon.settings = {
      # 日志配置
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };

      # 存储驱动
      storage-driver = "overlay2";

      # 使用 systemd cgroup 驱动
      exec-opts = [ "native.cgroupdriver=systemd" ];

      # 镜像加速（可选，取消注释以启用）
      registry-mirrors = [
        "https://docker.1ms.run"
        "https://docker-0.unsee.tech"
        "https://d36hdol5.mirror.aliyuncs.com"
        "https://ccr.ccs.tencentyun.com"
      ];
    };
  };

  # 将用户添加到 docker 组（无需 sudo 运行 docker）
  users.users.mengw.extraGroups = [ "docker" ];

  # ========== Docker 用户工具 ==========
  environment.systemPackages = with pkgs; [
    docker-compose   # Docker Compose v1（兼容性工具）
    lazydocker       # Docker TUI 管理工具
  ];
}
