# SDDM 登录管理器 + Thyx 主题
# 统一的图形登录界面，可在 GNOME / Niri 等桌面环境之间切换
{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # 使用 GDM 作为显示管理器（登录界面）
  # services.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  # 使用 Wayland 模式运行 SDDM（推荐）
  # services.displayManager.sddm.wayland.enable = true;
  # 启用 Thyx 主题
  # services.displayManager.sddm.thyx.enable = true;
}
