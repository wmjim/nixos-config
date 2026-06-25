# 媒体 / 录屏 / 截图
{ pkgs, ... }:

let
  # PicGo 剪贴板快捷上传脚本
  # Electron globalShortcut API 在 Wayland 下不可用，
  # 因此通过 Niri 组合器快捷键 + PicGo Server API 实现上传
  picgo-clipboard-upload = pkgs.writeShellScriptBin "picgo-clipboard-upload" ''
    set -euo pipefail

    TMPFILE=$(mktemp -t picgo-upload.XXXXXX.png)
    trap 'rm -f "$TMPFILE"' EXIT

    # 从 Wayland 剪贴板读取图片
    if ! ${pkgs.wl-clipboard}/bin/wl-paste --type image/png > "$TMPFILE" 2>/dev/null; then
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "剪贴板中没有图片"
      exit 1
    fi

    # 检查文件是否非空
    if [ ! -s "$TMPFILE" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "剪贴板图片为空"
      exit 1
    fi

    # 通过 PicGo Server API 上传（默认端口 36677）
    RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST http://127.0.0.1:36677/upload \
      -H "Content-Type: application/json" \
      -d "{\"list\":[\"$TMPFILE\"]}" 2>/dev/null || echo "")

    # 从响应中提取上传后的 URL
    URL=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r \
      '.result[0] // .data[0] // .result // .data // empty' 2>/dev/null || echo "")

    if [ -n "$URL" ] && [ "$URL" != "null" ]; then
      echo -n "$URL" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send \
        -i picgo \
        "PicGo 上传成功" "URL 已复制到剪贴板"
    else
      ERR_MSG=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r \
        '.message // .error // "Server 未响应"' 2>/dev/null || echo "${"$"}{RESPONSE:-Server 无响应}")
      ${pkgs.libnotify}/bin/notify-send -u critical \
        -i dialog-error \
        "PicGo 上传失败" "请确认 PicGo 已启动且 Server 已开启（端口 36677）"
      exit 1
    fi
  '';

  # PicGo 包覆盖：显式设置 Wayland 模式以确保剪贴板正常工作
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
  environment.systemPackages = with pkgs; [
    mpv # 视频播放器
    splayer # 音乐播放器
    obs-studio # 录屏
    snipaste # 截图工具
    picgo-wrapped # 图床管理（Wayland 优化）
    picgo-clipboard-upload # 剪贴板快捷上传脚本
    wl-clipboard # Wayland 剪贴板工具
    calibre
    freetube # YouTube 客户端
    bilibili # 哔哩哔哩
  ];
}
