# 桌面环境模块
{ ... }:

{
  imports = [
    ./common
    # ./gnome          # 切换到 KDE 后保留以备调试回退
    ./kde
    # ./niri
  ];
}
