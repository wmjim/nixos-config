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
        format = "[](red)$os$username[](bg:orange fg:red)$directory[](bg:yellow fg:orange)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:blue)$conda[](fg:blue bg:base07)$cmd_duration[ ](fg:base07)$line_break$character";
        scan_timeout = 100;
        os = {
          disabled = false;
          style = "bg:red fg:base01";
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
          style_user = "bg:red fg:base01";
          style_root = "bg:red fg:base01";
          format = "[ $user]($style)";
        };
        directory = {
          style = "bg:orange fg:base01";
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
          format = "[[ $symbol $branch ](fg:base01 bg:yellow)]($style)";
        };
        git_status = {
          style = "bg:yellow";
          format = "[[($all_status$ahead_behind )](fg:base01 bg:yellow)]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base01 bg:green)]($style)";
        };
        c = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base01 bg:green)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base01 bg:green)]($style)";
        };
        golang = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base01 bg:green)]($style)";
        };
        python = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:base01 bg:green)]($style)";
        };
        cmd_duration = {
          min_time = 0;
          show_milliseconds = true;
          style = "bg:base07";
          format = "[[ $duration ](fg:base01 bg:base07)]($style)";
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
      };
    };
  };
}
