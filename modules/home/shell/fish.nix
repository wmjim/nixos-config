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


      # 配置交叉工具链
      set -gx ARCH arm
      set -gx CROSS_COMPILE arm-buildroot-linux-gnueabihf-
      set -gx PATH $HOME/embed/100ask_imx6ull_mini-sdk/ToolChain/arm-buildroot-linux-gnueabihf_sdk-buildroot/bin $PATH

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
      # repo
      fish_add_path /home/mengw/app/repo

      # fzf 配置（如果安装了）
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
      end
    '';
  };
}
