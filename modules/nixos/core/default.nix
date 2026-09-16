# NixOS 核心配置（所有 NixOS 主机共享）
# 定义 mySystem 选项命名空间，导入所有子模块
{ config, pkgs, lib, inputs, ... }:
let
  # 本机 flake 仓库路径（所有 NixOS 主机统一放在用户 Projects 目录下）
  configDir = "${config.users.users.mengw.home}/Projects/nixos-config";
in
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
    # 保留历史版本数量：10
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
    boot.loader.efi.canTouchEfiVariables = lib.mkIf (!config.boot.isContainer) (lib.mkDefault true);
    # WSL2 内核由 Windows 宿主提供，容器内设置此项无功能影响
    boot.kernelPackages = lib.mkIf (!config.boot.isContainer) pkgs.linuxPackages_latest;

    # 保持NixOS系统自动更新
    # 必须显式指向本机 flake：未设 flake 时 nixos-rebuild 回退 classic 路径，
    # 而本机 NIX_PATH 无 nixos-config，daily timer 只会反复失败。
    # 各主机 networking.hostName 与 flake 输出属性同名，据此自动选择目标主机。
    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
      flake = "${configDir}#${config.networking.hostName}";
      # 显式钉死 --refresh：nixpkgs 默认 flags 已含此项，此处重复声明仅为
      # 防止上游变更默认值后退化为只构建 flake.lock 锁定的旧 nixpkgs
      flags = [ "--refresh" ];
    };

    # --refresh 每次都重写工作区的 flake.lock，autoUpgrade 不会提交它，工作区
    # 将永久处于脏状态：Nix 对脏树令 self.rev = null，configurationRevision
    # 退化为 "dirty"，代际随之无法回溯到 commit。升级成功后以本人身份提交
    # flake.lock 保持工作区干净。root 的 HOME=/root 无 gitconfig，故用 runuser
    # 复用用户身份提交（与上面 safe.directory 同一根源）。
    systemd.services.nixos-upgrade.postStop = ''
      [ "$SERVICE_RESULT" = "success" ] || exit 0
      repo="${configDir}"
      ${pkgs.git}/bin/git -C "$repo" diff --quiet -- flake.lock && exit 0
      ${pkgs.util-linux}/bin/runuser -u ${config.users.users.mengw.name} -- \
        ${pkgs.git}/bin/git -C "$repo" commit -m "chore(autoUpgrade): 刷新 flake.lock" -- flake.lock
    '';

    # 自动将超过一周的垃圾回收，降低磁盘占用
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Nix 配置
    nix.settings = {
      experimental-features = [ "flakes" "nix-command" ];
      connect-timeout = 5;
      # 充分利用多核 CPU 加速构建
      max-jobs = "auto";
      cores = 0;
      # 自动存储优化
      auto-optimise-store = true;
      # 保留 derivations 和 outputs 的依赖关系，避免重复构建
      keep-outputs = true;
      keep-derivations = true;
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

    # 允许不安全的包（每条须写明被哪个包需要，并定期复核是否仍有效）
    nixpkgs.config.permittedInsecurePackages = [ ];

    # NUR overlay（系统级字体 harmonyos-sans 等依赖）
    nixpkgs.overlays = [ inputs.nur.overlays.default ];

    # nixos-upgrade.service 以 root 运行且 HOME=/root，读不到用户 ~/.gitconfig，
    # libgit2 因仓库属主非 root 而拒绝访问。必须在系统级 /etc/gitconfig 放开
    # safe.directory，否则 autoUpgrade 每日必然失败。
    # programs.git.enable 默认为 false：不开启则 /etc/gitconfig 根本不会生成。
    programs.git.enable = true;
    programs.git.config.safe.directory = [
      configDir
    ];

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        # 允许密码登录
        PasswordAuthentication = true;
        # 禁止root登录
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
      wget
    ];

    system.stateVersion = "26.05";
  };
}
