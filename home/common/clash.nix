{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    clash-verge-rev
  ];

  # 可选: 配置环境变量 (取消注释以启用)
  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    all_proxy = "socks5://127.0.0.1:7897";
  };
}
