# Qt/GTK 统一主题配置
# 参考: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
{ pkgs, ... }:

{
  # --- GTK 主题 (via home-manager, 生成 settings.ini) ---
  gtk = {
    enable = true;
    # 样式主题
    theme = {
      package = pkgs.adapta-gtk-theme;
      name = "Adapta-Nokto";
    };
    # 图标主题
    iconTheme = {
      package = pkgs.whitesur-icon-theme;
      name = "WhiteSur";
    };
    # 光标主题
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    # 字体
    font = {
      name = "HarmonyOS Sans SC";
      size = 12;
    };
  };

  # --- Qt 主题 ---
  xdg.configFile = {
    # KDE 全局字体设置
    "kdeglobals".text = ''
      [General]
      font=HarmonyOS Sans SC,12,-1,5,50,0,0,0,0,0
      fixed=Maple Mono Normal NL NF CN,12,-1,5,50,0,0,0,0,0
      smallestReadableFont=HarmonyOS Sans SC,10,-1,5,50,0,0,0,0,0
      toolBarFont=HarmonyOS Sans SC,12,-1,5,50,0,0,0,0,0
      menuFont=HarmonyOS Sans SC,12,-1,5,50,0,0,0,0,0
    '';

    # Qt6CT 配置
    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      icon_theme=WhiteSur
      style=kvantum

      [Fonts]
      fixed="Maple Mono Normal NL NF CN,12,-1,5,50,0,0,0,0,0"
      general="HarmonyOS Sans SC,12,-1,5,50,0,0,0,0,0"
    '';

    # Qt5CT 配置
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      icon_theme=WhiteSur
      style=kvantum

      [Fonts]
      fixed="Maple Mono Normal NL NF CN,12,-1,5,50,0,0,0,0,0"
      general="HarmonyOS Sans SC,12,-1,5,50,0,0,0,0,0"
    '';

    # Breeze 窗口装饰: 缩小标题栏
    "breezerc".text = ''
      [Common]
      DrawTitleBarSeparator=false

      [Windeco]
      ButtonSize=0
    '';

    # Kvantum 主题引擎
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Adapta
    '';
  };

  # 环境变量: Qt 使用 qt6ct 读取配置, 强制 Kvantum 风格
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };
}
