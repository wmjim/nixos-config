# 微信桌面客户端
# 将 $HOME 重定向到 ~/files/apps/wechat，防止在主目录生成 ~/WeChat Files 等
{ pkgs, ... }:
let
  wrapper = pkgs.symlinkJoin {
    name = "wechat";
    paths = [ pkgs.wechat ];
    postBuild = ''
      rm $out/bin/wechat
      cp ${pkgs.writeShellScript "wechat" ''
        WECHAT_DIR="$HOME/files/apps/wechat"
        mkdir -p "$WECHAT_DIR"
        exec env HOME="$WECHAT_DIR" ${pkgs.wechat}/bin/wechat "$@"
      ''} $out/bin/wechat
    '';
  };
in {
  environment.systemPackages = [ wrapper ];
}
