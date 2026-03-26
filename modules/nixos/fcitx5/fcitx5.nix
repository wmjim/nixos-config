{pkgs, ...}: {
  # 选择输入法类型为 fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  # 设置输入法环境变量
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}