# macOS 基础配置（所有 Darwin 主机共享）
{ config, pkgs, lib, inputs, ... }:

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

  # valgrind 在 nixpkgs 26.05 中被标记为 broken，放行以允许评估
  nixpkgs.config.problems.handlers.valgrind.broken = "warn";

  # 放行 Linux-only 包的评估（flakehub-push 会评估所有平台，但 darwin 不需要这些包）
  nixpkgs.config.allowUnsupportedSystem = true;

  # NUR overlay（home-manager useGlobalPkgs=true 时需在系统级设置）
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  # 系统级包
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  # 键盘
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = false;

  # 安全
  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;
}
