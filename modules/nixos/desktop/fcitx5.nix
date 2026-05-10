{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # fcitx5 本体
        kdePackages.fcitx5-with-addons
        # fcitx5 配置工具
        kdePackages.fcitx5-configtool
        # fcitx5 输入法模块
        kdePackages.fcitx5-qt
        fcitx5-gtk
        # 输入法主题
        fcitx5-mellow-themes
        # fcitx5-rime 中文输入引擎
        # rime-ice 中文词库
        # 构建 fcitx5-rime 的同时，将 rime-ice 数据文件一同打包）
        (fcitx5-rime.override {
          rimeDataPkgs = [ pkgs.rime-ice ];
        })
      ];
    };
  };
}
