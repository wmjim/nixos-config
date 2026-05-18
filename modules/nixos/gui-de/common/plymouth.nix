# Plymouth 在启动过程提供图形启动动画
{ pkgs, ... }: {
  boot = {

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # 默认情况下，会安装所有主题。
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # 启用“静默启动”
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # 隐藏引导加载程序的操作系统选择。
    # 仍然可以通过按任意键打开引导加载程序列表。
    # 除非按下某个键，否则它不会出现在屏幕上。
    loader.timeout = 0;

  };
}