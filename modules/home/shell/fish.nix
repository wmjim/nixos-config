# Fish 配置
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # 禁用 greeting 消息
      set fish_greeting ""

      # 设置编辑器
      set -gx EDITOR hx

      # 设置语言环境
      set -gx LANG zh_CN.UTF-8
      set -gx LC_ALL zh_CN.UTF-8

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
      ".." = "cd ..";
      "..." = "cd ../..";
      
      ls = "eza";
      ll = "eza -la";
      la = "eza -A";
      lt = "eza --tree";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";

      bat = "bat --style=plain";
      cat="bat --style=plain --paging=never";

      cd = "z";
      grep = "rg";
      find = "fd";

      vim = "hx";
      vi = "hx";

      cc  = "claude";
    };

    # 环境变量
    shellInit = ''
      # 设置 PATH（如果需要添加额外的路径）
      # fish_add_path /path/to/bin

      # npm 全局模块路径
      fish_add_path /home/mengw/.npm-global/bin

      # fzf 配置（如果安装了）
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
      end
    '';
  };
}
