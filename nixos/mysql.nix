# MySQL 完整配置
{ config, pkgs, ... }:

{
  # ========== MySQL 服务配置 ==========
  services.mysql = {
    enable = true;

    # 数据包（使用 MySQL 8.4）
    package = pkgs.mysql84;

    # 数据目录
    dataDir = "/var/lib/mysql";

    # MySQL 配置选项
    settings = {
      mysqld = {
        # 连接配置
        max_connections = 100;

        # 字符集配置
        character-set-server = "utf8mb4";
        collation-server = "utf8mb4_unicode_ci";

        # 网络配置
        bind_address = "127.0.0.1";  # 仅本地访问
        port = 3306;
      };
    };

    # 初始化数据库
    ensureDatabases = [ "myapp" ];  # 确保这些数据库存在
    ensureUsers = [
      {
        name = "myapp";
        ensurePermissions = {
          "myapp.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # ========== MySQL 用户工具 ==========
  environment.systemPackages = with pkgs; [
    mysql84          # MySQL 客户端
    mysql-workbench  # MySQL GUI 工具（可选）
  ];

  # ========== 防火墙配置 ==========
  # 如果需要远程访问，取消注释以下行
  # networking.firewall.allowedTCPPorts = [ 3306 ];
}
