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

      # tmux 外启用 starship；tmux 内使用 fish 默认提示符
      if not set -q TMUX
        if test "$TERM" != dumb; and command -q starship
          starship init fish | source
        end
      end
    '';
    shellAliases = {
      # 常用别名
      ".." = "cd ..";
      "..." = "cd ../..";
      updatewsl = "sudo nixos-rebuild switch --flake ~/nixos-config#wsl";

      # distrobox
      arch = "distrobox enter arch";
      ubuntu = "distrobox enter ubuntu";

      # eza 推荐别名
      # 基础替换：带图标、目录优先、文件类型颜色
      ls = "eza --icons=auto --group-directories-first --color=auto";
      # 详细列表 + Git 状态（最常用）
      ll = "eza -l --icons=auto --group-directories-first --git --header";
      # 显示隐藏文件
      la = "eza -a --icons=auto --group-directories-first";
      # 详细版显示隐藏文件
      lla = "eza -la --icons=auto --group-directories-first --git --header";
      # 树形显示，限制 2 层，避免刷屏
      lt = "eza --tree --level=2 --icons=auto";
      # 只看目录
      ldir = "eza -D --icons=auto";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";

      # bat 推荐别名
      bat = "bat --style=plain";
      cat = "bat --style=plain --paging=never";

      # duf 推荐别名
      df = "duf --only local"; # 替代 df，只显示本地磁盘
      duf = "duf --sort usage"; # 默认按使用率排序（最满的在前）
      dufall = "duf --all"; # 查看所有（含伪文件系统）
      dufjson = "duf --json"; # JSON 输出，用于脚本

      # zoxide 别名
      zquery = "zoxide query -l -s";


      cc = "claude --dangerously-skip-permissions";

      # 查询快捷键
      # 可用 niri、
      key = "dms ipc call keybinds toggle";
    };

    # 环境变量
    shellInit = ''
      # 设置 PATH（如果需要添加额外的路径）
      # fish_add_path /path/to/bin
      fish_add_path /home/mengw/.cargo/bin
      fish_add_path /home/mengw/.local/bin

      # npm 全局模块路径
      # 同时显式设置 NPM_CONFIG_PREFIX，避免 npm 把 prefix 探测到只读的
      # /nix/store/...nodejs.../，进而导致工具（如 claude-code）反复 fork
      # `npm config get prefix` 触发 Node 冷启动、推高 CPU、风扇狂转。
      set -gx NPM_CONFIG_PREFIX /home/mengw/.npm-global
      fish_add_path /home/mengw/.npm-global/bin

      # fzf 配置（如果安装了）
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
      end

      # fzf 命令收藏夹，从 ~/.config/fish/commands 中查询并插入命令行
      # 文件格式：命令  |  备注（用 | 分割）
      function fish_command_picker
        set -l commands_file ~/.config/fish/commands
        if not test -f $commands_file
          echo "commands file not found: $commands_file"
          return 1
        end
        set -l selected (grep -v '^\s*#' $commands_file | grep -v '^\s*$' | env FZF_DEFAULT_OPTS="" fzf --prompt="Cmd > " --height=40% --layout=reverse --border --no-hscroll)
        if test -n "$selected"
          set -l cmd (string trim -- (string split -m1 '|' -- $selected)[1])
          commandline --replace -- $cmd
          commandline -f repaint
        end
      end
      bind \co fish_command_picker

      # 快捷键速查表查询工具
      # 用法: cheat [provider]  — 不带参数则通过 fzf 选择
      function cheat
        set -l dir ~/.config/DankMaterialShell/cheatsheets

        if not test -d $dir
          echo "cheatsheets directory not found: $dir"
          return 1
        end

        set -l provider $argv[1]

        if test -z "$provider"
          set provider (for f in $dir/*.json
            jq -r '"\(.provider): \(.title)"' $f
          end | env FZF_DEFAULT_OPTS="" fzf \
            --prompt="Cheatsheet > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview "jq -r '.binds | to_entries[] | .key as \$cat | .value[] | \"  \" + .key + \"\t\" + .desc + (if .subcat then \" [\" + .subcat + \"]\" else \"\" end)' $dir/{1}.json" \
            --preview-window=right:60% \
            --delimiter=':')

          if test -z "$provider"
            return
          end
          set provider (string split -m1 ':' -- $provider | head -1 | string trim)
        end

        set -l file $dir/$provider.json
        if not test -f $file
          echo "cheatsheet not found: $provider"
          return 1
        end

        echo ""
        jq -r '.title + " (" + .provider + ")"' $file
        echo "────────────────────────────────────────────"
        jq -r '
          .binds | to_entries[] |
          "\n" + .key + ":",
          (.value[] | "  " + .key + "\t" + .desc + (if .subcat then " [" + .subcat + "]" else "" end))
        ' $file
      end
    '';
  };
  # zoxide 替代 cd
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  # fzf 命令收藏夹文件
  xdg.configFile."fish/commands".source = ./fish-commands;
}
