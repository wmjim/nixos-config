# macOS 基础配置（所有 Darwin 主机共享）
{ config, pkgs, lib, ... }:

{
  # Nix 配置
  nix.settings = {
    # 启用 Flakes 特性以及配套的新 nix 命令行工具
    experimental-features = [ "nix-command" "flakes" ];
    # 自动存储优化，定期优化存储以节省空间
    auto-optimise-store = true;
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

  # 键盘
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = false;

  # 安全
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 5;
}
