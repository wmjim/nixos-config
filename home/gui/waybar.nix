{ config, pkgs, ... }:

{
  # Waybar 配置
  home.packages = with pkgs; [
    waybar
    font-awesome
    material-design-icons
  ];

  # 使用 programs.waybar 替代手动配置文件
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 8;
        margin-top = 4;
        margin-bottom = 0;
        margin-left = 4;
        margin-right = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "cpu" "memory" "network" ];

        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          format = "{name}";
        };

        "clock" = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          format = "{usage}%";
          interval = 2;
        };

        "memory" = {
          format = "{}%";
          interval = 2;
        };

        "network" = {
          format-wifi = "{bandwidthDownBytes}";
          format-ethernet = "{bandwidthDownBytes}";
          format-disconnected = "⚠";
          format-linked = "{bandwidthDownBytes}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n⬇ {bandwidthDownBytes}\n⬆ {bandwidthUpBytes}";
          tooltip-format-ethernet = "{ifname}\n⬇ {bandwidthDownBytes}\n⬆ {bandwidthUpBytes}";
        };

        "pulseaudio" = {
          format = "{volume}%";
          format-muted = "";
          format-icons = {
            default = "";
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        "tray" = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        font-family: "Maple Mono NF CN", "Font Awesome 6 Free", "Material Design Icons", sans-serif;
        font-size: 13px;
        font-weight: 600;
        min-height: 0;
        margin: 0px;
        padding: 0px;
      }

      /* Catppuccin Mocha 主题色 */
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      window#waybar {
        background: @base;
        border-radius: 2px;
        border: 2px solid @surface0;
        border-bottom: none;
        color: @text;
      }

      tooltip {
        background: @mantle;
        border: 1px solid @surface0;
        border-radius: 8px;
      }

      tooltip label {
        color: @text;
      }

      #workspaces {
        margin-left: 6px;
      }

      #workspaces button {
        padding: 0 12px;
        color: @overlay0;
        background: transparent;
        border-radius: 6px;
        margin: 4px 2px;
      }

      #workspaces button:hover {
        background: @surface0;
        color: @text;
      }

      #workspaces button.active {
        background: @lavender;
        color: @base;
      }

      #clock {
        color: @text;
        font-weight: 700;
      }

      #cpu {
        color: @blue;
        padding: 0 8px;
      }

      #memory {
        color: @green;
        padding: 0 8px;
      }

      #network {
        color: @peach;
        padding: 0 8px;
      }

      #pulseaudio {
        color: @mauve;
        padding: 0 8px;
      }

      #tray {
        margin-right: 6px;
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
