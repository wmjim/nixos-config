# 服务器服务模块
{ config, pkgs, ... }:

{
  # 服务器特定服务
  # 示例：
  # services.nginx = {
  #   enable = true;
  #   recommendedGzipSettings = true;
  #   recommendedProxySettings = true;
  # };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "myapp" ];
  # };

  # services.redis.enable = true;

  # 监控
  # services.prometheus.enable = true;
  # services.grafana.enable = true;
}
