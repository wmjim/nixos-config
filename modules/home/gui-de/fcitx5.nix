# Fcitx5 用户级配置
{ config, pkgs, ... }:

{
  # 用户 rime 配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      # 引入万象拼音的默认推荐配置
      __include: wanxiang_suggested_default:/
      __patch:
        menu/page_size: 7   #候选词个数
  '';

  # classicui 候选框外观配置
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    # 候选框字体
    Font="HarmonyOS Sans SC 11"
    # 菜单字体
    MenuFont="HarmonyOS Sans SC 11"
    # 垂直候选列表
    Vertical Candidate List=False
    # 使用鼠标滚轮翻页
    WheelForPaging=True
  '';

  # 支持运行于 Xwayland 的 GTK 应用
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-im-module = fcitx
  '';
}
