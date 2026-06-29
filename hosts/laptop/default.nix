# NixOS 笔记本（GNOME 桌面）
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./laptop.nix
    ./nvidia.nix
  ];

  networking.hostName = "laptop";

  # 修复 libvirtd TPM2 凭证解密失败
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

  mySystem = {
    hardware.enable = true;
    hardware.nvidia.enable = true;
    desktop.enable = true;
    desktop.gnome.enable = true;
    desktop.niri.enable = true;
    desktop.distrobox.enable = true;
    virtualization.enable = true;
    stylix.enable = true;
    stylix.theme = "aurora-dark";
    proxy = {
      enable = true;
      extraNoProxy = [ "bilibili.com" "*.bilibili.com" ];
    };
  };
}
