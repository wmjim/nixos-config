# WiFi 和网络管理
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.hardware;
in
{
  options.mySystem.hardware.network.enable = lib.mkEnableOption "WiFi 和网络管理（NetworkManager + iwd）";

  config = lib.mkIf (cfg.enable && cfg.network.enable) {
    networking.wireless.iwd.enable = true;
    # 启用 NetworkManager
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # 本机启动后无强依赖网络的服务（SSH/代理均在用户登录后拉起），
    # 等待全部接口上线纯属浪费时间，禁用以省下约 4.7s 启动耗时
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
