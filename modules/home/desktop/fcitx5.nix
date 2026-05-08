# Fcitx5 用户级配置
{ config, pkgs, ... }:

{
  # 设置默认输入法环境变量
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # 用户 rime 配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      __include: rime_ice_suggestion:/
      __patch:
        menu/page_size: 5
  '';
}
