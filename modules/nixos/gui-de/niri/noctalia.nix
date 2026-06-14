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
    # 预选 niri 作为桌面会话
    greeter-args = "--session niri"; 
    settings.cursor = {
      theme = "Bibata-Modern-Classic"; # 光标主题
      size = 24; # 光标大小
      package = pkgs.bibata-cursors; # 提供光标主题的包（必须，否则 greeter 找不到主题文件）
    };
  };

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
