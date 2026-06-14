{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  # 登录管理器：greetd + noctalia-greeter（Noctalia 风格登录界面）
  services.greetd.settings.default_session.user = "greeter";

  programs.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
