# QEMU/KVM + libvirtd 虚拟化模块
# 集中配置虚拟化服务，供各主机按需导入
{ config, pkgs, lib, ... }:
{
  # Virt-Manager 图形管理工具（含 polkit/dbus 权限，非 root 可用）
  programs.virt-manager.enable = true;

  # SPICE/VNC 虚拟机控制台查看器（轻量，可脱离 virt-manager 单独使用）
  environment.systemPackages = with pkgs; [
    virt-viewer
  ];

  # libvirtd 守护进程 + QEMU/KVM
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm; # KVM 加速版 QEMU
      swtpm.enable = true;     # TPM 2.0 仿真（Windows 11 安装必需）
    };
  };

  # SPICE USB 重定向（virt-manager 中直通主机 USB 设备到虚拟机）
  virtualisation.spiceUSBRedirection.enable = true;

  # 信任 libvirt 虚拟网桥（否则虚拟机 NAT 网络无法通信）
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # 嵌套虚拟化（允许在虚拟机内再运行虚拟机，如 WSL2 / Docker Desktop）
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1   # Intel CPU
    # options kvm_amd nested=1   # AMD CPU
  '';
}
