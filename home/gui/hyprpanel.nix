{ config, pkgs, lib, ... }:

{
  programs.hyprpanel = {
    enable = true;

    settings = {
      # 栏布局配置
      bar = {
        layouts = {
          "0" = {
            left = [ "dashboard" "workspaces" ];
            middle = [ "clock" ];
            right = [ "volume" "cpu" "storage" "systray" "power" ];
          };
        };

        # 启动器配置
        launcher = {
          icon = "󱄅";
          autoDetectIcon = false;
        };

        # 工作区配置
        workspaces = {
          show_icons = true;
          show_numbered = true;
          showWsIcons = true;
          showApplicationIcons = true;
          workspaces = 10;
          numbered_active_indicator = "underline";
        };

        # CPU 模块
        cpu = {
          show_icon = true;
          show_label = true;
          label = "CPU";
        };

        # 存储模块
        storage = {
          show_icon = true;
          show_label = true;
          label = "Disk";
        };


        # 电源模块
        power = {
          show_label = false;
        };


        # 音量模块
        volume = {
          show_icon = true;
          show_label = true;
          label = "Vol";
        };


        # 按钮样式
        buttons = {
          style = "wave2";
          monochrome = false;
          enableBorders = true;
          innerRadiusMultiplier = "0.4";
          radius = "16px";
          y_margins = "8px";
          x_margins = "8px";
          padding = "12px";
          hover_opacity = 0.85;
          background = "#414559";

          # 特定模块边框
          dashboard.enableBorder = false;
          workspaces.enableBorder = false;
        };
      };

      # 菜单配置
      menus = {
        transition = "crossfade";

        # 时钟配置（只显示日历）
        clock = {
          time.hide = false;
          weather.enabled = false;
          calendar = {
            show = true;
            format = {
              date = "%Y年%m月";
            };
          };
        };


        # 音量配置
        volume = {
          raiseMaximumVolume = true;
        };

        # Dashboard 统计配置
        dashboard = {
          stats.enable_gpu = true;
          directories.enabled = false;
          quicklinks.enabled = false;
          shortcuts.enabled = true;
        };
      };

      # 缩放优先级
      scalingPriority = "gdk";

      # 主题配置（Catppuccin Frappe）
      theme = {
        font = {
          name = "Maple Mono NF CN";
          size = "14px";
        };

        notification.opacity = 80;

        bar = {
          # 间距配置
          outer_spacing = "8px";
          margin = "8px";
          padding = "8px";

          # 透明度配置
          transparent = false;
          background = "#303446";
          opacity = 95;
          menus.opacity = 100;

          # 边框配置
          border.location = "none";

          # 工作区间距
          workspaces.spacing = "4px";
        };

        # 颜色主题（Catppuccin Frappe）
        palette = {
          background = "#303446";
          foreground = "#c6d0f5";
          primary = "#8caaee";
          secondary = "#ca9ee6";
          tertiary = "#a6d189";
          error = "#e78284";
          warning = "#ef9f76";
          success = "#a6d189";
          info = "#8caaee";

          # 额外颜色
          surface = "#414559";
          surface0 = "#494d64";
          overlay0 = "#737994";
          overlay1 = "#838ba7";
          overlay2 = "#949cbb";
        };
      };
    };
  };
}
