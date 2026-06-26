{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # 登录管理器由 common/thyx.nix 统一提供 SDDM

  # Noctalia Shell（桌面 UI）
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
