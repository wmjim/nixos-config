{ config, pkgs, inputs, ... }:
{
  # 登录管理器：greetd 自动登录 → 直接启动 niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        user = "mengw";
      };
    };
  };

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
