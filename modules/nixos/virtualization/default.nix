# QEMU/KVM + libvirtd 虚拟化模块
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.virtualization;
in
{
  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-viewer
    ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
  };
}
