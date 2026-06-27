# NixOS 核心配置（所有 NixOS 主机共享）
# 定义 mySystem 选项命名空间，导入所有子模块
{ config, pkgs, lib, inputs, ... }:
{
  # mySystem 选项命名空间 — 各主机通过设置这些选项来声明启用的功能
  options.mySystem = {
    hardware.enable = lib.mkEnableOption "硬件支持（蓝牙、音频、网络）";
    desktop.enable = lib.mkEnableOption "桌面环境（GDM、Niri、GNOME）";
    virtualization.enable = lib.mkEnableOption "QEMU/KVM 虚拟化";
  };

  imports = [
    ./users.nix
    ./locale.nix
    ./stylix.nix
    ../hardware
    ../desktop
    ../virtualization
    ../networking
  ];

  config = {
    # ==========================================
    # Boot
    # ==========================================
    boot.loader.systemd-boot.enable = lib.mkIf (!config.boot.isContainer) (lib.mkDefault true);
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
    boot.loader.efi.canTouchEfiVariables = lib.mkIf (!config.boot.isContainer) (lib.mkDefault true);
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # 开机自动升级
    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
    };

    # 垃圾回收
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Nix 配置
    nix.settings = {
      experimental-features = [ "flakes" "nix-command" ];
      connect-timeout = 5;
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [ "root" "mengw" ];
    };

    # 硬件加速
    hardware.graphics.enable = true;

    # FHS 兼容
    programs.nix-ld.enable = true;

    # 系统总线
    services.dbus = {
      enable = true;
      implementation = "broker";
    };

    # 允许非自由软件
    nixpkgs.config.allowUnfree = true;

    # 允许不安全的包
    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];

    # valgrind 放行
    nixpkgs.config.problems.handlers.valgrind.broken = "warn";

    # NUR overlay（系统级字体 harmonyos-sans 等依赖）
    nixpkgs.overlays = [ inputs.nur.overlays.default ];

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    # 键盘布局
    services.xserver.xkb = {
      layout = "us";
      options = "caps:escape";
    };

    # 防火墙
    networking.firewall.allowedTCPPorts = [ 22 ];

    # 系统级包
    environment.systemPackages = with pkgs; [
      iwd
      git
      wget
    ];

    system.stateVersion = "26.05";
  };
}
