# 自定义函数库
# 提供跨模块共享的工具函数，避免重复代码
{ lib }:
let
  # 包装 Qt 应用以在 XWayland 下正确运行（带输入法和缩放适配）
  # 许多国产 Qt 应用（微信、欧陆词典等）在 Wayland 原生模式下存在
  # 渲染异常或输入法无法调起的问题，因此统一走 XWayland 回退路径。
  #
  # extraWrapArgs 用于注入应用专属的附加参数（如欧陆词典需要
  # 额外设置 XKB_CONFIG_ROOT 和清理 GST 插件路径）。
  wrapQtXWayland =
    {
      pkgs,
      pkg,
      binary ? null,
      scale ? 1.25,
      extraWrapArgs ? "",
    }:
    let
      bin = if binary != null then binary else pkg.pname or (builtins.baseNameOf pkg);
    in
    pkgs.symlinkJoin {
      name = "${bin}-wrapped";
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${bin} \
          --unset WAYLAND_DISPLAY \
          --set QT_QPA_PLATFORM "wayland;xcb" \
          --set QT_SCALE_FACTOR ${builtins.toString scale} \
          --set GTK_IM_MODULE "fcitx" \
          --set QT_IM_MODULE "fcitx" \
          --set XMODIFIERS "@im=fcitx" \
          ${extraWrapArgs}
      '';
    };
in
{
  inherit wrapQtXWayland;

  # 为所有支持的平台生成属性集
  # 用法: forAllSystems (system: pkgs: ...)
  forAllSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
