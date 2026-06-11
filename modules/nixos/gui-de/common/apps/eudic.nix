# 欧路英语词典（闭源 Qt5 应用，只支持 XCB 插件）
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "eudic" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.eudic}/bin/eudic "$@"
    '')
  ];
}
