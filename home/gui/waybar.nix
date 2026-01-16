{ config, pkgs, ... }:

{
  # Waybar 配置
  home.packages = with pkgs; [
    waybar
    font-awesome
    material-design-icons
    pamixer  # 音量控制工具
  ];

  # 使用 programs.waybar 替代手动配置文件
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        spacing = 0;
        margin-top = 4;
        margin-bottom = 0;
        margin-left = 4;
        margin-right = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" "custom/screenrecording-indicator" ];
        modules-right = [ "tray" "bluetooth" "network" "pulseaudio" "cpu" "battery" ];

        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            "active" = "󱓻";
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "clock" = {
          format = "{:%A %H:%M}";
          format-alt = "{:%d %B %Y}";
          tooltip = false;
        };

        "cpu" = {
          interval = 5;
          format = "󰍛";
          on-click = "kitty btop";
        };

        "battery" = {
          format = "{capacity}% {icon}";
          format-discharging = "{icon}";
          format-charging = "{icon}";
          format-plugged = "󰚥";
          format-icons = {
            charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
            default = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };
          format-full = "󰁹";
          tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
          tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
        };

        "network" = {
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          interval = 3;
        };

        "pulseaudio" = {
          format = "{icon}";
          on-click = "pavucontrol";
          on-click-right = "pamixer -t";
          tooltip-format = "Playing at {volume}%";
          scroll-step = 5;
          format-muted = "";
          format-icons = {
            headphone = "";
            default = [ "" "" "" ];
          };
        };

        "tray" = {
          icon-size = 12;
          spacing = 17;
        };

        "custom/screenrecording-indicator" = {
          format = "󰑊";
          on-click = "wf-recorder -f ~/screen-$(date +\"%Y-%m-%d-%H-%M-%S\").mp4";
          on-click-right = "pkill -INT wf-recorder";
          interval = 1;
          exec = "pgrep -x wf-recorder && echo '{\"text\": \"󰑊\", \"tooltip\": \"Recording\", \"class\": \"active\"}' || echo '{\"text\": \"\", \"tooltip\": \"Not recording\"}'";
          return-type = "json";
        };
      };
    };

    style = ''
      * {
        background-color: @background;
        color: @foreground;
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: "Maple Mono NF CN";
        font-size: 12px;
      }

      /* Catppuccin Frappe 主题色 */
      @define-color background #303446;
      @define-color foreground #c6d0f5;
      @define-color rosewater #f2d5cf;
      @define-color flamingo #eebebe;
      @define-color pink #f4b8e4;
      @define-color mauve #ca9ee6;
      @define-color red #e78284;
      @define-color maroon #ea999c;
      @define-color peach #ef9f76;
      @define-color yellow #e5c890;
      @define-color green #a6d189;
      @define-color teal #81c8be;
      @define-color sky #99d1db;
      @define-color sapphire #85c1dc;
      @define-color blue #8caaee;
      @define-color lavender #babbf1;
      @define-color text #c6d0f5;
      @define-color subtext1 #b5bfe2;
      @define-color subtext0 #a5adce;
      @define-color overlay2 #949cbb;
      @define-color overlay1 #838ba7;
      @define-color overlay0 #737994;
      @define-color surface2 #626880;
      @define-color surface1 #51576d;
      @define-color surface0 #414559;
      @define-color base #303446;
      @define-color mantle #292c3c;
      @define-color crust #232634;

      window#waybar {
        background: @base;
        border-radius: 2px;
        border: 2px solid @surface0;
        border-bottom: none;
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #workspaces {
        margin-left: 8px;
      }

      #workspaces button {
        all: initial;
        padding: 0 6px;
        margin: 0 1.5px;
        min-width: 9px;
        color: @overlay0;
        background: transparent;
      }

      #workspaces button.empty {
        opacity: 0.5;
      }

      #workspaces button:hover {
        background: @surface0;
        color: @text;
      }

      #workspaces button.active {
        background: @lavender;
        color: @base;
      }

      #cpu,
      #battery,
      #pulseaudio,
      #custom-screenrecording-indicator {
        min-width: 12px;
        margin: 0 7.5px;
      }

      #tray {
        margin-right: 16px;
      }

      #bluetooth {
        margin-right: 17px;
      }

      #network {
        margin-right: 13px;
      }

      tooltip {
        padding: 2px;
        background: @mantle;
        border: 1px solid @surface0;
        border-radius: 8px;
      }

      #clock {
        margin-left: 8.75px;
        color: @text;
        font-weight: 700;
      }

      .hidden {
        opacity: 0;
      }

      #custom-screenrecording-indicator {
        min-width: 12px;
        margin-left: 5px;
        font-size: 10px;
        padding-bottom: 1px;
      }

      #custom-screenrecording-indicator.active {
        color: #a55555;
      }
    '';
  };

  # 确保 waybar 只运行一个实例
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      X-RestartIfChanged = true;
    };

    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
