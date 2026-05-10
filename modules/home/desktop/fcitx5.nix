# Fcitx5 用户级配置
{ config, pkgs, ... }:

{
  # 设置默认输入法环境变量
  home.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";  # 中文输入法环境变量
    SDL_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "";
  };

  # 用户 rime 配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      # 引入雾凇拼音的默认推荐配置
      __include: rime_ice_suggestion:/
      __patch:
        menu/page_size: 7   #候选词个数
  '';
}
