# NixOS 笔记本（GNOME 桌面）
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./laptop.nix
    ./nvidia.nix
  ];

  networking.hostName = "laptop";

  # 修复 libvirtd TPM2 凭证解密失败
  systemd.services.libvirtd.serviceConfig.LoadCredential = [
    "secrets-encryption-key:/var/lib/libvirt/secrets/secrets-encryption-key"
  ];
  system.activationScripts.libvirtSecretsKey = {
    text = ''
      # umask 077 保证重定向创建密钥时即为 0600，无 0644→0600 的瞬时可读窗口
      umask 077
      if [ ! -f /var/lib/libvirt/secrets/secrets-encryption-key ]; then
        mkdir -p /var/lib/libvirt/secrets
        ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/libvirt/secrets/secrets-encryption-key
        chmod 600 /var/lib/libvirt/secrets/secrets-encryption-key
      fi
    '';
    deps = [ ];
  };

  mySystem = {
    hardware.enable = true;
    hardware.nvidia.enable = true;
    desktop.enable = true;
    # 内屏 1080p，分数缩放 1.25（desktop.scale 由此派生）
    desktop.monitors = [
      {
        name = "eDP-1";
        mode = "1920x1080@59.977";
        scale = 1.25;
        focus = true;
      }
    ];
    desktop.gnome.enable = true;
    desktop.niri.enable = true;
    desktop.distrobox.enable = true;
    virtualization.enable = true;
    proxy.enable = true;
    # 客户机（libvirt NAT 网段）经网桥地址 192.168.122.1 使用宿主代理
    proxy.exposeToVms = true;
  };
}
