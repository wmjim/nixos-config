# macOS GUI 管理：系统默认值 + Homebrew GUI 应用
{ config, pkgs, ... }:

{
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

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
    ];

    # GUI 应用
    casks = [
      "ghostty"
      "visual-studio-code"
      "obsidian"
      "microsoft-edge"
    ];

    # 字体
    caskArgs = {
      fontdir = "/Library/Fonts";
    };
  };
}
