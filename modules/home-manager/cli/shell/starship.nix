# Starship 提示符配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.shell.starship;
  shellCfg = config.mengw.cli.shell;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.shell.starship.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Starship 提示符";
  };

  config = lib.mkIf (cfg.enable && shellCfg.enable && cliCfg.enable) {
    programs.starship = {
      enable = true;
      enableFishIntegration = false;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        format = "[](red)$os$username[](bg:peach fg:red)$directory[](bg:yellow fg:peach)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$conda[](fg:sapphire bg:lavender)$cmd_duration[ ](fg:lavender)$line_break$character";
        scan_timeout = 100;
        palette = "catppuccin_mocha";
        os = {
          disabled = false;
          style = "bg:red fg:crust";
          symbols = {
            NixOS = "";
            Windows = "";
            Ubuntu = "󰕈";
            Macos = "󰀵";
            Linux = "󰌽";
            Arch = "󰣇";
            Debian = "󰣚";
          };
        };
        username = {
          show_always = true;
          style_user = "bg:red fg:crust";
          style_root = "bg:red fg:crust";
          format = "[ $user]($style)";
        };
        directory = {
          style = "bg:peach fg:crust";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
          };
        };
        git_branch = {
          symbol = "";
          style = "bg:yellow";
          format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
        };
        git_status = {
          style = "bg:yellow";
          format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        c = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        golang = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };
        python = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:crust bg:green)]($style)";
        };
        cmd_duration = {
          min_time = 0;
          show_milliseconds = true;
          style = "bg:lavender";
          format = "[[ $duration ](fg:crust bg:lavender)]($style)";
          disabled = false;
          show_notifications = true;
          min_time_to_notify = 45000;
        };
        character = {
          disabled = false;
          success_symbol = "[\\$](bold fg:green)";
          error_symbol = "[\\$](bold fg:red)";
        };
        line_break.disabled = false;
        time.disabled = true;
        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
      };
    };
  };
}
