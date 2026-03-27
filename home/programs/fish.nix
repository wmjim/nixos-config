{ config, pkgs, ... }:

{
  # Starship 提示符 - Tokyo Night 主题
  programs.starship = {
    enable = true;
    settings = {
      format = "[░▒▓](#a3aed2)[   ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };

      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
    };
  };

  programs.fish = {
    enable = true;

    # 交互式 shell 启动时执行的命令
    interactiveShellInit = ''
      # 禁用 greeting 消息
      set fish_greeting ""

      # 设置编辑器
      set -gx EDITOR hx

      # 设置代理
      set -gx http_proxy http://127.0.0.1:7897
      set -gx https_proxy http://127.0.0.1:7897

      # 设置语言环境
      set -gx LANG zh_CN.UTF-8
      set -gx LC_ALL zh_CN.UTF-8

      # 初始化 Starship 提示符
      starship init fish | source

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

      vim = "nvim";
      vi  = "nvim";
      nv  = "nvim";

      # 其他实用别名
      bat = "bat --style=plain";
      cat="bat --style=plain --paging=never";
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

      # xlings 配置
      if test -d /home/xlings/.xlings/bin
        fish_add_path /home/xlings/.xlings/bin
      end
      if test -f /home/xlings/.xlings/config/shell/xlings-profile.fish
        source /home/xlings/.xlings/config/shell/xlings-profile.fish
      end

      # fzf 配置（如果安装了）
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
      end
    '';
  };

  # 安装 fish 相关的实用工具和插件
  home.packages = with pkgs; [
    bat      # cat 替代，支持语法高亮
    fd       # find 替代，更友好
    eza      # ls 替代
    jq       # json 处理
    ripgrep  # grep 替代
    fzf      # 模糊查找
    zoxide   # cd 替代
    delta    # git diff 美化
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