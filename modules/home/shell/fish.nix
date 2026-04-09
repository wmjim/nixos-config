# Fish 配置
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # 启动时运行 fastfetch
      if type -q fastfetch
        fastfetch
      end

      # 设置代理快捷命令
      function proxy
        set -gx http_proxy http://127.0.0.1:7897
        set -gx https_proxy http://127.0.0.1:7897
        set -gx ftp_proxy http://127.0.0.1:7897
        set -gx no_proxy "localhost,127.0.0.1,local.domain,192.168.0.0/16"
        echo "Proxy enabled"
      end

      function unproxy
        set -e http_proxy
        set -e https_proxy
        set -e ftp_proxy
        set -e no_proxy
        echo "Proxy disabled"
      end
    '';
    shellAliases = {
      # 常用别名
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";
      cd = "z";
      vim = "nvim";
      vi = "nvim";
    };
  };
}
