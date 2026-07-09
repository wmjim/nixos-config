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
      interactiveShellInit = ''
        set fish_greeting ""
        set -gx EDITOR hx

        if not set -q TMUX
          if test "$TERM" != dumb; and command -q starship
            starship init fish | source
          end
        end
      '';
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        arch = "distrobox enter arch";
        ubuntu = "distrobox enter ubuntu";
        updatewsl = "sudo nixos-rebuild switch --flake ~/nixos-config#wsl";
        # 构建 desktop 主机 NixOS
        updatedp = "sudo nixos-rebuild switch --flake ~/nixos-config#desktop"; 
        # 构建 desktop 主机 NixOS，并获取详细错误信息
        updatedplog = "sudo nixos-rebuild switch --flake ~/nixos-config#desktop --show-trace --print-build-logs --verbose";
        # 构建 laptop 笔记本 NixOS
        updatelp = "sudo nixos-rebuild switch --flake ~/nixos-config#laptop";
        # 构建 laptop 笔记本 NixOS，并获取详细错误信息
        updatelplog = "sudo nixos-rebuild switch --flake ~/nixos-config#laptop --show-trace --print-build-logs --verbose";
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
        key = "dms ipc call keybinds toggle";
      };
      shellInit = ''
        fish_add_path /home/mengw/.cargo/bin
        fish_add_path /home/mengw/.local/bin
        set -gx NPM_CONFIG_PREFIX /home/mengw/.npm-global
        fish_add_path /home/mengw/.npm-global/bin

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
          set -l dir ~/.config/DankMaterialShell/cheatsheets
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
