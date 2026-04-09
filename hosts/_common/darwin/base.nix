# macOS 基础配置（所有 Darwin 主机共享）
{ config, pkgs, lib, ... }:

{
  # Nix 配置
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # 系统级包
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

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

  # 键盘
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = false;

  # 安全
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 5;
}
