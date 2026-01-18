{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # 交互式 shell 启动时执行的命令
    interactiveShellInit = ''
      # 禁用 greeting 消息
      set -g fish_greeting

      # 设置编辑器
      set -gx EDITOR hx

      # 设置语言环境
      set -gx LANG en_US.UTF-8
      set -gx LC_ALL en_US.UTF-8

      # 初始化 Fisher 插件管理器
      if not functions -q fisher
        set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
      end
    '';

    # Fish 插件管理（使用 Nix 包管理的插件）
    plugins = [
      # z - 智能目录跳转，根据频率学习
      {
        name = "z";
        src = pkgs.fishPlugins.z;
      }

      # 彩色 man 文档显示
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages;
      }

      # fzf - 模糊搜索工具集成
      # {
      #   name = "fzf";
      #   src = pkgs.fishPlugins.fzf;
      # }

      # forgit - Git 交互式工具
      # {
      #   name = "forgit";
      #   src = pkgs.fishPlugins.forgit;
      # }
    ];

    # Fish 别名
    shellAliases = {
      # 常用命令别名
      ls = "eza";
      ll = "eza -la";
      la = "eza -A";
      l = "eza -CF";
      ".." = "cd ..";
      "..." = "cd ../..";

      # Git 别名（可选，如果你在 .gitconfig 中已经配置了可以不重复）
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";

      # 其他实用别名
      cat = "bat";
      grep = "rg";
      find = "fd";

      # 终端复用器，将 zellij 映射为 tmux
      tmux = "zellij";

      # NixOS 重建命令
      nix-rebuild = "sudo nixos-rebuild switch --flake /home/mengw/nixos-config#nixos";
    };

    # Fish 函数
    functions = {
      # 创建并进入目录
      mkcd = ''
        mkdir -p $argv[1] && cd $argv[1]
      '';

      # 快速备份文件
      backup = ''
        cp $argv[1] $argv[1].backup
      '';

      # 显示 Git 分支
      git_branch = ''
        git branch --show-current
      '';

      # 使用 fzf 浏览 Git 历史记录
      git_log_fzf = ''
        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv | fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\`)
      '';

      # 使用 fzf 查找文件
      find_file = ''
        fd -t f -H -I | fzf --multi --preview 'bat --color=always {}'
      '';

      # Yazi 文件管理器集成
      yy = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };

    # 环境变量
    shellInit = ''
      # 设置 PATH（如果需要添加额外的路径）
      # fish_add_path /path/to/bin

      # fzf 配置（如果安装了）
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
      end
    '';
  };

  # 安装 fish 相关的实用工具和插件
  home.packages = with pkgs; [
    bat      # cat 的替代品，支持语法高亮
    fd       # find 的替代品，更友好
    eza      # 更好的 ls 替代品
    jq       # JSON 处理工具
    httpie   # 人性化的 HTTP 客户端
  ];

  # 配置 zoxide（智能目录跳转）
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # 配置 fzf
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };
}
