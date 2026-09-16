# Fish 配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.shell.fish;
  shellCfg = config.mengw.cli.shell;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.shell.fish.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fish Shell 配置";
  };

  config = lib.mkIf (cfg.enable && shellCfg.enable && cliCfg.enable) {
    programs.fish = {
      enable = true;
      plugins = [
        # 默认绑定: Ctrl-Alt-F 目录搜索 / Ctrl-R 历史 / Ctrl-Alt-L git log /
        # Ctrl-Alt-S git status / Ctrl-Alt-P 进程 / Ctrl-V 变量
        # 本仓库锁定的 home-manager 要求 { name, src }，不能直接传包
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      # decors/fish-colored-man 未入 nixpkgs，该插件整体即这一个函数，直接托管
      # 上游: https://github.com/decors/fish-colored-man/blob/master/functions/man.fish
      functions.man = {
        wraps = "man";
        description = "Format and display manual pages";
        body = ''
          set -q man_blink; and set -l blink (set_color $man_blink); or set -l blink (set_color -o red)
          set -q man_bold; and set -l bold (set_color $man_bold); or set -l bold (set_color -o 5fafd7)
          set -q man_standout; and set -l standout (set_color $man_standout); or set -l standout (set_color 949494)
          set -q man_underline; and set -l underline (set_color $man_underline); or set -l underline (set_color -u afafd7)

          set -l end (printf "\e[0m")

          set -lx LESS_TERMCAP_mb $blink
          set -lx LESS_TERMCAP_md $bold
          set -lx LESS_TERMCAP_me $end
          set -lx LESS_TERMCAP_so $standout
          set -lx LESS_TERMCAP_se $end
          set -lx LESS_TERMCAP_us $underline
          set -lx LESS_TERMCAP_ue $end
          set -lx LESS '-R -s'

          set -lx GROFF_NO_SGR yes # fedora

          set -lx MANPATH (string join : $MANPATH)
          if test -z "$MANPATH"
            type -q manpath
            and set MANPATH (command manpath)
          end

          # Check data dir for Fish 2.x compatibility
          set -l fish_data_dir
          if set -q __fish_data_dir
            set fish_data_dir $__fish_data_dir
          else
            set fish_data_dir $__fish_datadir
          end

          set -l fish_manpath (dirname $fish_data_dir)/fish/man
          if test -d "$fish_manpath" -a -n "$MANPATH"
            set MANPATH "$fish_manpath":$MANPATH
            command man $argv
            return
          end
          command man $argv
        '';
      };
      interactiveShellInit = ''
        set fish_greeting ""
        # 设置终端为英文环境
        set -gx LC_ALL en_US.UTF-8
        set -gx EDITOR hx
        # API 密钥存放于 git 外的本地文件，避免明文入库
        set -l atria_env ~/.config/atria/env.fish
        if test -f $atria_env
          source $atria_env
        end
      '';
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        arch = "distrobox enter arch";
        ubuntu = "distrobox enter ubuntu";
        updatewsl = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config#wsl";
        # 构建 desktop 主机 NixOS
        updatedp = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop";
        # 构建 desktop 主机 NixOS，并获取详细错误信息
        updatedplog = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop --show-trace --print-build-logs --verbose";
        # 构建 laptop 笔记本 NixOS
        updatelp = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config#laptop";
        # 构建 laptop 笔记本 NixOS，并获取详细错误信息
        updatelplog = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config#laptop --show-trace --print-build-logs --verbose";
        ls = "eza --icons=auto --group-directories-first --color=auto";
        ll = "eza -l --icons=auto --group-directories-first --git --header";
        la = "eza -a --icons=auto --group-directories-first";
        lla = "eza -la --icons=auto --group-directories-first --git --header";
        lt = "eza --tree --level=2 --icons=auto";
        ldir = "eza -D --icons=auto";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline --graph --decorate";
        bat = "bat --style=plain";
        cat = "bat --style=plain --paging=never";
        df = "duf --only local";
        duf = "duf --sort usage";
        dufall = "duf --all";
        dufjson = "duf --json";
        zquery = "zoxide query -l -s";
        cc = "claude --dangerously-skip-permissions";
      };
      shellInit = ''
        fish_add_path ${config.home.homeDirectory}/.cargo/bin
        fish_add_path ${config.home.homeDirectory}/.local/bin
        set -gx NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.npm-global
        fish_add_path ${config.home.homeDirectory}/.npm-global/bin

        if type -q fzf
          set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --color=always {}" --preview-window=right:60%'
          set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        end

        function fish_command_picker
          set -l commands_file ~/.config/fish/commands
          if not test -f $commands_file
            echo "commands file not found: $commands_file"
            return 1
          end
          set -l selected (grep -vE '^\s*(#|$)' $commands_file | env FZF_DEFAULT_OPTS="" fzf --prompt="Cmd > " --height=40% --layout=reverse --border --no-hscroll)
          if test -n "$selected"
            set -l cmd (string trim -- (string split -m1 '|' -- $selected)[1])
            commandline --replace -- $cmd
            commandline -f repaint
          end
        end
        bind \co fish_command_picker

        function cheat
          set -l dir ~/.config/cheatsheets
          if not test -d $dir
            echo "cheatsheets directory not found: $dir"
            return 1
          end
          set -l provider $argv[1]
          if test -z "$provider"
            # 一次 jq 调用处理所有文件（input_filename 获取文件名作 fzf key）
            set provider (jq -r '
              input_filename as $f |
              "\($f | sub(".*/";"") | sub("\\.json$";"")):\(.provider): \(.title)"
            ' $dir/*.json | env FZF_DEFAULT_OPTS="" fzf \
              --prompt="Cheatsheet > " \
              --height=40% \
              --layout=reverse \
              --border \
              --with-nth=2.. \
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

    programs.zoxide.enable = true;
    programs.zoxide.enableFishIntegration = true;

    xdg.configFile."fish/commands".source = ./fish-commands;
  };
}
