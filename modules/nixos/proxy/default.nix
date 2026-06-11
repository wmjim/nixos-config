# 代理配置模块
# 需要代理的主机通过 imports 引入，并可选择性添加 no_proxy 例外
{ lib, config, ... }:

let
  cfg = config.proxy;
in
{
  options.proxy = {
    enable = lib.mkEnableOption "HTTP/HTTPS proxy for nix-daemon and user sessions";
    port = lib.mkOption {
      type = lib.types.int;
      default = 7897;
      description = "代理端口（本机 Clash Verge 默认 7897）";
    };
    extraNoProxy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "额外的 no_proxy 域名/IP";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nix-daemon.environment = {
      http_proxy = "http://127.0.0.1:${toString cfg.port}";
      https_proxy = "http://127.0.0.1:${toString cfg.port}";
      ftp_proxy = "http://127.0.0.1:${toString cfg.port}";
      no_proxy = lib.concatStringsSep "," (
        [ "localhost" "127.0.0.1" "local.domain" "192.168.0.0/16" ] ++ cfg.extraNoProxy
      );
    };

    environment.sessionVariables = {
      http_proxy = "http://127.0.0.1:${toString cfg.port}";
      https_proxy = "http://127.0.0.1:${toString cfg.port}";
      ftp_proxy = "http://127.0.0.1:${toString cfg.port}";
      no_proxy = lib.concatStringsSep "," (
        [ "localhost" "127.0.0.1" "local.domain" "192.168.0.0/16" ] ++ cfg.extraNoProxy
      );
    };
  };
}
