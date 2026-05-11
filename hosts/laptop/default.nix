# NixOS 笔记本配置（GNOME 桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    # 磁盘分区
    ./hardware.nix
    # 桌面设置
    ../../modules/nixos/hardware               # NVIDIA + 蓝牙 + 音频 + 网络 + 笔记本电源
    ../../modules/nixos/gui-de
  ];

  # 主机名
  networking.hostName = "laptop";

  # 虚拟化
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [ "console=ttyS0" ];

  # 修复 libvirtd TPM2 凭证解密失败 (TPM "No locks available")
  systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = lib.mkForce [];
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
    deps = [];
  };

  # ==========================================
  # 为 nix-daemon 设置代理 (核心！)
  # ==========================================
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };

  # ==========================================
  # 系统级用户会话代理设置 (修正变量名)
  # ==========================================
  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };

  # RDP 防火墙端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
