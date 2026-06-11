# NixOS 笔记本配置（GNOME 桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    # 磁盘分区
    ./hardware.nix
    # 电池和风扇
    ./laptop.nix
    # 显卡
    ./nvidia.nix
    # 桌面设置
    ../../modules/nixos/hardware # NVIDIA + 蓝牙 + 音频 + 网络 + 笔记本电源
    ../../modules/nixos/gui-de
    ../../modules/nixos/proxy
  ];

  # 主机名
  networking.hostName = "laptop";

  # 虚拟化
  virtualisation.libvirtd.enable = true;
  # 启动日志通过 modules/nixos/gui-de/common/boot.nix 配置

  # 修复 libvirtd TPM2 凭证解密失败 (TPM "No locks available")
  systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = lib.mkForce [ ];
  systemd.services.libvirtd.serviceConfig.LoadCredential = [
    "secrets-encryption-key:/var/lib/libvirt/secrets/secrets-encryption-key"
  ];
  system.activationScripts.libvirtSecretsKey = {
    text = ''
      if [ ! -f /var/lib/libvirt/secrets/secrets-encryption-key ]; then
        mkdir -p /var/lib/libvirt/secrets
        ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/libvirt/secrets/secrets-encryption-key
        chmod 600 /var/lib/libvirt/secrets/secrets-encryption-key
      fi
    '';
    deps = [ ];
  };

  # 代理（通过 modules/nixos/proxy 集中配置）
  proxy.enable = true;
  proxy.extraNoProxy = [ "bilibili.com" "*.bilibili.com" ];
}
