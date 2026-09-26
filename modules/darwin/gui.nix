# macOS GUI 管理：系统默认值 + Homebrew GUI 应用
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mengw.darwin.gui;
  darwinCfg = config.mengw.darwin;
in
{
  options.mengw.darwin.gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 macOS GUI 配置（系统默认值 + Homebrew 应用）";
  };

  config = lib.mkIf (cfg.enable && darwinCfg.enable) {
    # macOS 系统设置
    system.defaults = {
      # Finder
      finder.AppleShowAllExtensions = true;
      finder.FXEnableExtensionChangeWarning = false;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;

      # Dock
      dock.autohide = true;
      dock.mru-spaces = false;
      dock.show-recents = false;

      # 键盘
      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain.InitialKeyRepeat = 15;

      # 触控板
      trackpad.Clicking = true;
      trackpad.TrackpadRightClick = true;

      # 登录
      loginwindow.GuestEnabled = false;
    };

    # Homebrew GUI 应用
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
      };

      # Homebrew 4.x 起 cask 已并入核心 tap，无需额外 tap homebrew/cask
      # GUI 应用
      # alacritty 是 macOS 侧的终端：foot 只支持 Wayland，无法在 darwin 上替代
      casks = [
        "alacritty"
        "visual-studio-code"
        "obsidian"
        "brave"
      ];

      # 字体
      caskArgs = {
        fontdir = "/Library/Fonts";
      };
    };
  };
}
