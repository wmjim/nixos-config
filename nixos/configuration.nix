# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # 开启自动升级
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # 禁用 systemd 的自动挂起，合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";              # 普通状态合盖
    HandleLidSwitchDocked = "ignore";        # 外接显示屏合盖
    HandleLidSwitchExternalPower = "ignore"; # 插电状态合盖
  };

  


  # 垃圾回收配置
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  # networking.networkmanager.enable = true;
  networking.wireless.iwd = {
    enable = true;
  };

  # 启用硬件加速
  hardware.graphics.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # 兼容 FHS 
  programs.nix-ld.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://127.0.0.1:7897";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #  font = "MapleMono-NF-CN--Regular.ttf";
  #  keyMap = "us";
  #  useXkbConfig = true; # use xkb.options in tty.
  # };

  # 字体配置
  fonts.packages = with pkgs; [
    # Maple Mono 字体
    maple-mono.NF-CN-unhinted
    maple-mono.truetype
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Maple Mono NF CN" ];
  };

  # 光标主题
  environment.variables = {
    XCURSOR_THEME = "Adwaita";
  };

  # 启用图形系统（wayland）
  services.xserver.enable = true;
  # 排除 xterm
  services.xserver.excludePackages = with pkgs; [ xterm ];
  # 启用基本图形支持，让系统提供 hyprland
  programs.hyprland.enable = true;

  # 启用 greetd（极简登录管理器）
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "mengw";
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  # networking.firewall.enable = false;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mengw = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "network" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
    ];
  };
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    openssh
    sshfs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # 开启 openssh 守护进程
  services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;  # 临时启用密码登录用于测试
        PermitRootLogin = "no";         # 禁止 root 登录
        X11Forwarding = true;
      };
      # SFTP 子系统配置
      extraConfig = ''
        # SFTP 子系统
        Subsystem sftp internal-sftp

        # SFTP 日志（用于调试）
        LogLevel VERBOSE
      '';
  };
  # Open ports in the firewall.
  # nixos 默认启用防火墙，需要允许放行22端口
  networking.firewall.allowedTCPPorts = [ 22 ];
  
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

