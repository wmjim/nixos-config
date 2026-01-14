{ config, pkgs, ... }:

{ 
  home.packages = with pkgs; [
    waybar    # 状态栏
    wofi      # 应用启动器
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod, D, exec, wofi --show drun"
      ];
    };
  };
}
