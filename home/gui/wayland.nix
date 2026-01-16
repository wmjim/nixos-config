{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar                # 状态栏
    wofi                  # 应用启动器
    google-chrome         # 浏览器
    wayshot               # 截图工具
    wl-clipboard          # 剪贴板管理
    wf-recorder           # 录屏工具
    swaylock-effects      # 锁屏
    wlogout               # 注出菜单
    hyprpicker            # 取色器
    pavucontrol           # 音量控制
    blueman               # 蓝牙管理
    swww                  # 壁纸管理工具
    libnotify             # 桌面通知
    xdg-utils             # XDG 工具集
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # 变量定义
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$browser" = "google-chrome";
      "$menu" = "wofi --show drun";

      # 环境变量
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "GTK_THEME,Catppuccin-Mocha-Standard-Blue-dark"
      ];

      # 配置壁纸服务
      exec-once = [
        "swww-daemon"
        "~/.config/hypr/scripts/init-wallpaper.sh"
      ];

      # 通用设置
      general = {
        gaps_in = "2";
        gaps_out = "4";
        border_size = "2";
        "col.active_border" = "rgba(89b4faee)";
        "col.inactive_border" = "rgba(45475aee)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # 装饰设置
      decoration = {
        rounding = "2";
        blur = {
          enabled = true;
          size = "8";
          passes = "3";
          new_optimizations = true;
        };
        # drop_shadow = {
        #   enabled = true;
        #   size = "4";
        #   alpha = "0.3";
        # };
      };

      # 动画
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
        ];
        animation = [
          "windows,1,7,easeOutQuint"
          "windowsOut,1,7,default,popin 80%"
          "border,1,10,default"
          "borderangle,1,10,default"
          "fade,1,7,default"
          "workspaces,1,6,default"
        ];
      };

      # 窗口规则
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(wayshot)$"
        "size 50% 50%,class:^(wayshot)$"
        "center,class:^(wayshot)$"
        # wofi 居中
        "float,class:^(wofi)$"
        "center,class:^(wofi)$"
        "noborder,class:^(wofi)$"
      ];

      bind = [
        # 基础快捷键
        "$mod, RETURN, exec, $terminal"
        "$mod, SPACE, exec, $menu"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod SHIFT, SPACE, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # 移动焦点
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # 移动窗口
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        # 工作区切换
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # 移动窗口到工作区
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # 滚动切换工作区
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # 特殊功能
        "$mod, S, exec, wayshot | wl-copy"
        "$mod SHIFT, S, exec, wayshot - | wl-copy"
        "$mod, E, exec, $fileManager"
        "$mod, C, exec, hyprpicker"
        "$mod, V, exec, pavucontrol"
        "$mod, B, exec, blueman-manager"
        "$mod SHIFT, B, exec, $browser"
        "$mod, W, exec, ~/.config/hypr/scripts/random-wallpaper.sh"
        "$mod, X, exec, wlogout"

        # 调整窗口大小（使用 ALT 作为修饰键，避免干扰 shell）
        "$mod ALT, left, resizeactive, -20 0"
        "$mod ALT, right, resizeactive, 20 0"
        "$mod ALT, up, resizeactive, 0 -20"
        "$mod ALT, down, resizeactive, 0 20"
        "$mod ALT, h, resizeactive, -20 0"
        "$mod ALT, l, resizeactive, 20 0"
        "$mod ALT, k, resizeactive, 0 -20"
        "$mod ALT, j, resizeactive, 0 20"
      ];
    };
  };
}

