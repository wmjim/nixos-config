# 媒体 / 录屏 / 截图
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.media;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;

  picgo-clipboard-upload = pkgs.writeShellScriptBin "picgo-clipboard-upload" ''
    set -euo pipefail
    TMPFILE=$(mktemp -t picgo-upload.XXXXXX.png)
    trap 'rm -f "$TMPFILE"' EXIT
    if ! ${pkgs.wl-clipboard}/bin/wl-paste --type image/png > "$TMPFILE" 2>/dev/null; then
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "剪贴板中没有图片"
      exit 1
    fi
    if [ ! -s "$TMPFILE" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "剪贴板图片为空"
      exit 1
    fi
    RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST http://127.0.0.1:36677/upload \
      -H "Content-Type: application/json" \
      -d "{\"list\":[\"$TMPFILE\"]}" 2>/dev/null || echo "")
    URL=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r \
      '.result[0] // .data[0] // .result // .data // empty' 2>/dev/null || echo "")
    if [ -n "$URL" ] && [ "$URL" != "null" ]; then
      echo -n "$URL" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send \
        -i picgo \
        "PicGo 上传成功" "URL 已复制到剪贴板"
    else
      ERR_MSG=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r \
        '.message // .error // "Server 未响应"' 2>/dev/null || echo "$RESPONSE")
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "请确认 PicGo 已启动且 Server 已开启（端口 36677）"
      exit 1
    fi
  '';

  picgo-wrapped = pkgs.symlinkJoin {
    name = "picgo-wrapped";
    paths = [ pkgs.picgo ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/picgo \
        --set ELECTRON_OZONE_PLATFORM_HINT wayland \
        --set NIXOS_OZONE_WL 1 \
        --prefix PATH : ${pkgs.wl-clipboard}/bin
    '';
  };
in
{
  options.mengw.gui.apps.media.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用媒体和录屏应用";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      vlc
      obs-studio
      snipaste
      picgo-wrapped
      picgo-clipboard-upload
      wl-clipboard
      calibre
      freetube
      bilibili
      flclash
    ];
  };
}
