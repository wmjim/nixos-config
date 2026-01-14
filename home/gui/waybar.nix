{ config, pkgs, ... }:

 {
   # Waybar 配置
   home.packages = with pkgs; [
     waybar
     # 依赖项
     font-awesome
     material-design-icons
   ];

   # Waybar 配置文件
   xdg.configFile."waybar/config".text = ''
     {
       "layer": "top",
       "position": "top",
       "height": 30,
       "spacing": 0,
       "margin-top": 6,
       "margin-left": 10,
       "margin-right": 10,

       "modules-left": ["hyprland/workspaces"],
       "modules-center": ["clock"],
       "modules-right": ["tray", "pulseaudio", "cpu", "memory", "network"],

       "hyprland/workspaces": {
         "disable-scroll": false,
         "all-outputs": true,
         "format": "{name}",
         "format-icons": {
           "1": "1",
           "2": "2",
           "3": "3",
           "4": "4",
           "5": "5",
           "urgent": "",
           "active": "",
           "default": ""
         }
       },

       "clock": {
         "format": "{:%H:%M}",
         "format-alt": "{:%Y-%m-%d %A}",
         "tooltip-format": "<tt><small>{calendar}</small></tt>",
         "calendar": {
           "mode"          : "year",
           "mode-mon-col"  : 3,
           "weeks-pos"     : "right",
           "format"        : {
             "months":     "<span color='#efff78'><b>{}</b></span>",
             "days":       "<span color='#efff78'>{}</span>",
             "weeks":      "<span color='#50fa7b'>W{}</span>",
             "weekdays":   "<span color='#ff79c6'>{}</span>",
             "today":      "<span color='#ff5555'><b><u>{}</u></b></span>"
           }
         }
       },

       "cpu": {
         "format": "  {usage}%",
         "tooltip": true,
         "interval": 2
       },

       "memory": {
         "format": "  {}%",
         "tooltip-format": "{used:0.1f}GB / {total:0.1f}GB",
         "interval": 2
       },

       "network": {
         "format-wifi": "  {signalStrength}%",
         "format-ethernet": "  {ipaddr}",
         "format-disconnected": "  ⚠",
         "tooltip-format-wifi": "{essid} ({signalStrength}%)",
         "tooltip-format-ethernet": "{ifname}: {ipaddr}",
         "on-click-right": "nm-connection-editor"
       },

       "pulseaudio": {
         "format": "{icon} {volume}%",
         "format-bluetooth": "{icon}  {volume}% ",
         "format-bluetooth-muted": "  {icon}  ",
         "format-muted": "󰝟",
         "format-source": "  {volume}%",
         "format-source-muted": "",
         "format-icons": {
           "headphone": "",
           "hands-free": "",
           "headset": "",
           "phone": "",
           "portable": "",
           "car": "",
           "default": ["", "", ""]
         },
         "on-click": "pavucontrol",
         "scroll-step": 5
       },

       "tray": {
         "icon-size": 16,
         "spacing": 8
       }
     }
   '';

   # Waybar 样式文件
   xdg.configFile."waybar/style.css".text = ''
     * {
         font-family: "Maple Mono NF CN", "Symbols Nerd Font", "Font Awesome 6 Free", sans-serif;
         font-size: 13px;
         font-weight: bold;
         min-height: 0;
         margin: 0px;
         padding: 0px;
     }

     window#waybar {
         background: rgba(30, 30, 46, 0.9);
         border-radius: 12px;
         border: 1px solid rgba(137, 180, 250, 0.2);
         color: #cdd6f4;
     }

     window#waybar.hidden {
         opacity: 0.2;
     }

     tooltip {
         background: rgba(30, 30, 46, 0.95);
         border: 1px solid rgba(137, 180, 250, 0.3);
         border-radius: 8px;
     }

     tooltip label {
         color: #cdd6f4;
         padding: 4px;
     }

     #workspaces {
         margin-left: 8px;
     }

     #workspaces button {
         padding: 0 10px;
         color: #6c7086;
         background: transparent;
         border-radius: 8px;
         margin: 4px 0;
         transition: all 0.3s ease;
     }

     #workspaces button:hover {
         background: rgba(137, 180, 250, 0.15);
         color: #cdd6f4;
     }

     #workspaces button.active {
         background: rgba(137, 180, 250, 0.25);
         color: #cdd6f4;
         border-radius: 8px;
     }

     #workspaces button.urgent {
         background: rgba(243, 139, 168, 0.3);
         color: #1e1e2e;
     }

     #clock,
     #cpu,
     #memory,
     #network,
     #pulseaudio,
     #tray {
         padding: 0 12px;
         margin: 4px 0;
         border-radius: 8px;
     }

     #clock {
         color: #cdd6f4;
         font-weight: bold;
     }

     #cpu {
         color: #89b4fa;
     }

     #cpu.warning {
         color: #f9e2af;
     }

     #cpu.critical {
         color: #f38ba8;
     }

     #memory {
         color: #a6e3a1;
     }

     #memory.warning {
         color: #f9e2af;
     }

     #memory.critical {
         color: #f38ba8;
     }

     #network {
         color: #f38ba8;
     }

     #network.disconnected {
         color: #6c7086;
     }

     #pulseaudio {
         color: #cba6f7;
     }

     #pulseaudio.muted {
         color: #6c7086;
     }

     #tray {
         margin-right: 8px;
     }

     #tray > .passive {
         -gtk-icon-effect: dim;
     }

     #tray > .needs-attention {
         -gtk-icon-effect: highlight;
     }
   '';
 }
