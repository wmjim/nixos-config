# Ghostty 终端配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.ghostty;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.ghostty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Ghostty 终端模拟器";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Catppuccin Mocha";
        font-family = [ "Maple Mono Normal NL NF" "LXGW WenKai Mono" ];
        font-size = 12;
        font-thicken = true;
        adjust-cell-height = 2;
        background-opacity = 1.0;
        background-blur-radius = 20;
        window-padding-x = 10;
        window-padding-y = 8;
        window-step-resize = false;
        window-save-state = "always";
        window-theme = "auto";
        cursor-style = "block";
        cursor-style-blink = true;
        cursor-opacity = 0.8;
        custom-shader = [
          "~/.config/ghostty/shader/cursor_smear_rainbow.glsl"
          "~/.config/ghostty/shader/party_sparks.glsl"
        ];
        custom-shader-animation = "always";
        mouse-hide-while-typing = true;
        copy-on-select = "clipboard";
        quick-terminal-position = "top";
        quick-terminal-screen = "mouse";
        quick-terminal-autohide = true;
        quick-terminal-animation-duration = 0.15;
        clipboard-paste-protection = true;
        clipboard-paste-bracketed-safe = true;
        shell-integration = "fish";
        shell-integration-features = "no-cursor";
        scrollback-limit = 25000000;
        term = "xterm-256color";
        keybind = [
          "performable:ctrl+c=copy_to_clipboard"
          "ctrl+v=paste_from_clipboard"
          "cmd+t=new_tab"
          "cmd+w=close_surface"
          "control+plus=increase_font_size:1"
          "control+minus=decrease_font_size:1"
          "control+zero=reset_font_size"
          "cmd+shift+comma=reload_config"
        ];
      };
    };

    xdg.configFile = {
      "ghostty/shader/cursor_smear_rainbow.glsl".source = ./ghostty-shader/cursor_smear_rainbow.glsl;
      "ghostty/shader/party_sparks.glsl".source = ./ghostty-shader/party_sparks.glsl;
    };
  };
}
