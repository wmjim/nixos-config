# WSL 基础配置（所有 WSL 主机共享）
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # WSL 以容器模式运行，不需要 bootloader
  boot.isContainer = true;

  # 开机自动升级
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # 垃圾回收配置
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix 配置
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    connect-timeout = 5;
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [
      "root"
      "mengw"
    ];
  };

  # FHS 兼容
  programs.nix-ld.enable = true;

  # 系统总线
  services.dbus.enable = true;

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # NUR overlay
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  # 系统级包
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  system.stateVersion = "26.05";
}
