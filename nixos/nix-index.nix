# nix-index 自动更新服务
# 定期更新 nix-index 数据库以保持最新

{ config, pkgs, ... }:

{
  # 为用户启用 nix-index 自动更新
  systemd.user.services.nix-index-update = {
    description = "Update nix-index database";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix-index}/bin/nix-index";
    };
  };

  systemd.user.timers.nix-index-update = {
    description = "Update nix-index database weekly";
    wantedBy = [ "timers.target" ];
    partOf = [ "nix-index-update.service" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
