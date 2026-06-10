# Fcitx5 用户级配置
{ config, pkgs, ... }:

{
  # 设置默认输入法环境变量
  home.sessionVariables = {
    XMODIFIERS = "@im=fcitx"; # XWayland 应用
    QT_IM_MODULE = "fcitx";   # Qt 应用
    SDL_IM_MODULE = "fcitx";  # 
  };

  # 用户 rime 配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      # 引入万象拼音的默认推荐配置
      __include: wanxiang_suggested_default:/
      __patch:
        menu/page_size: 7   #候选词个数
  '';

  # # 修复 Wayland 下候选框偏移问题：关闭「在程序中显示预编辑文本」
  # # 候选框会由 fcitx5 自行绘制并跟随光标，而非依赖应用内嵌的预编辑区域
  # xdg.configFile."fcitx5/conf/rime.conf".text = ''
  #   [Behavior]
  #   PreeditInApplication=False
  # '';

  # # classicui 配置：确保候选框跟随光标
  # xdg.configFile."fcitx5/conf/classicui.conf".text = ''
  #   [Behavior]
  #   FollowCursor=True
  # '';
  xdg.configFile."fcitx5/conf/global.conf".text = ''
    [Behavior]
    FollowCursor=False
    UsePreedit=True
  '';
}
