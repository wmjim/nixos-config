{pkgs, ...}: {
  # 选择输入法类型为 fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime        # Rime 输入引擎（中州韵）
      qt6Packages.fcitx5-chinese-addons  # 拼音、五笔等
      fcitx5-gtk         # GTK 程序支持
    ];
  };

  # 设置输入法相关环境变量
  # 告诉应用程序使用 fcitx5 作为输入法
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";

    # Wayland 环境补充（GNOME 默认使用 Wayland）
    SDL_IM_MODULE = "fcitx";      # SDL 游戏/应用
    GLFW_IM_MODULE = "ibus";      # GLFW 应用（如 Minecraft）
  };

  # GNOME Wayland 额外配置
  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";     # Firefox 原生 Wayland
    QT_QPA_PLATFORM = "wayland";  # Qt 应用使用 Wayland 后端
  };
}