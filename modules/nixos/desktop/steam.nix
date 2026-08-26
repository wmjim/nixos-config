# Steam 游戏平台 — 系统级配置（仅 desktop 游戏机）
# gamescope/MangoHud/GameMode 注入 Steam FHS 环境，游戏启动项可直接用 mangohud / gamemoderun
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  options.mySystem.desktop.steam.enable = lib.mkEnableOption "Steam 游戏平台";

  config = lib.mkIf (cfg.enable && cfg.steam.enable) {
    programs.steam = {
      enable = true;
      # 注入 Steam FHS 环境：游戏内启动项可写 mangohud %command% / gamemoderun %command%
      extraPackages = with pkgs; [
        gamescope
        gamemode
        mangohud
      ];
      # 局域网串流 / 局域网游戏转移（放行防火墙端口）
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # 手柄/控制器 udev 规则（Xbox、Steam Controller 等）
    hardware.steam-hardware.enable = true;

    # GameMode 提频守护进程（gamemoderun 提升 CPU governor、降低进程 nice）
    programs.gamemode.enable = true;
  };
}
