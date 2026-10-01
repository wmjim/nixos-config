# CLI 工具配置
# 门控：目录导入即生效（mengw.cli.enable 控制整个 CLI 层），无中间层开关；
# 单独关闭某个叶子（如 tmux）用该叶子自己的 enable 选项。
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cliCfg = config.mengw.cli;
in
{
  imports = [
    ./yazi.nix
    ./tmux.nix
    ./distrobox.nix
  ];

  config = lib.mkIf cliCfg.enable {
    home.packages = with pkgs; [
      fastfetch
      lazydocker
      yt-dlp
      lazygit
      claude-code
      pi-coding-agent
      codex
      herdr
      unzip
      gzip
      tree
      file
      net-tools
      duf
      glow
      hugo
      ffmpeg
    ];

    # btop：终端系统监控。此前只装包、零配置，于是它跑在自带的 Default 主题上
    # （终端里多出第 4 套配色）。这里补主题。
    #
    # theme_background 的更正：当时写“置 True 会让 btop 自画不透明底，使
    # frosted-glass.kdl 的 opacity 与模糊完全无从体现”——这是错的。niri 的
    # opacity 作用在**整个窗口**上（文档：“applied to every surface of the
    # window”），与窗口里面画不画底无关，磨砂效果一直都在。
    # 而且本主题的 theme[main_bg] = #303446 恰好等于 ghostty（Catppuccin Frappe）的背景色，两种取值
    # 在这个配色下是**视觉空操作**。
    # 保留 false 的真实理由：让 btop 的背景始终跟随终端，而不是把 #303446
    # 再硬编码一份——以后改终端主题的背景色时不会两者脱节。
    programs.btop = {
      # 包由本模块提供，故上面 home.packages 里不再列 btop
      enable = true;
      settings = {
        # 主题名固定为 catppuccin，亮/暗由**主题文件本身**换（下面两个变体 + theme-apply
        # 翻软链）：btop 的 color_theme 只是个名字，写成固定名才能运行时切换。
        color_theme = "catppuccin";
        # btop 内嵌配置说明：set to False if you want terminal background
        # transparency
        theme_background = false;
      };
      # 初始值 = 暗色（与改造前一致）；rebuild 后被还原，登录时 theme-apply 再按模式纠正。
      # 注意不能用 programs.btop.themes：那个选项写出来的软链不允许被覆盖，而 theme-apply
      # 运行时要把这里指到亮/暗变体，HM 的 checkLinkTargets 会判成外来文件而整份激活失败。
    };

    # 两套 btop 主题变体（Frappe / Latte）+ 登记给 theme-apply 翻软链。
    # 运行中的 btop 没有热重载，下次启动生效。
    xdg.configFile = {
      "theme-variants/btop/dark.theme".source = ./btop/catppuccin-frappe.theme;
      "theme-variants/btop/light.theme".source = ./btop/catppuccin-latte.theme;
    };

    mengw.appearance.switchTargets = [
      {
        live = ".config/btop/themes/catppuccin.theme";
        dark = ".config/theme-variants/btop/dark.theme";
        light = ".config/theme-variants/btop/light.theme";
      }
      {
        live = ".config/fastfetch/config.jsonc";
        dark = ".config/theme-variants/fastfetch/dark.jsonc";
        light = ".config/theme-variants/fastfetch/light.jsonc";
      }
      {
        live = ".config/fastfetch/logo/nixos_logo_1.txt";
        dark = ".config/theme-variants/fastfetch/logo-dark.txt";
        light = ".config/theme-variants/fastfetch/logo-light.txt";
      }
    ];

    # fastfetch 亮/暗两套：配置 jsonc 与 logo 文本（逐行内嵌 ANSI）各一份变体，
    # 由 theme-apply 翻软链。亮色那份的 10 阶渐变是**重算**的（Latte 底色上 blue 只有
    # 4.34:1，达不到 AA，改用 subtext1 → mauve 两个端点插值），算据写在那个文件的注释里。
    home.file = {
      ".config/fastfetch/config.jsonc" = {
        source = ../../../../assets/fastfetch/nixos-01.jsonc;
        force = true;
      };
      # fastfetch 的 logo：文本形式的 NixOS 美术图，逐行内嵌了 ANSI 码（暗色 = Frappe 蓝
      # #8CAAEE，亮色 = Latte 蓝 #1E66F5）。之所以是文件而不是内置 logo，见 jsonc 里的说明
      # —— 内置的 NixOS logo 不可着色。两套变体的文件名与源文件同名，只靠软链区分，
      # 所以 jsonc 里那句 source 路径（~/.config/fastfetch/logo/nixos_logo_1.txt）不用变。
      # btop 主题：初始值 = 暗色（与改造前一致），theme-apply 运行时按模式指到亮/暗变体。
      # 不能用 programs.btop.themes —— 那个选项写出的软链不允许覆盖，而这里会被接管，
      # HM 的 checkLinkTargets 判成外来文件「would be clobbered」会让整份激活失败。
      ".config/btop/themes/catppuccin.theme" = {
        source = ./btop/catppuccin-frappe.theme;
        force = true;
      };
      ".config/fastfetch/logo/nixos_logo_1.txt" = {
        source = ../../../../assets/fastfetch/logo/nixos_logo_1.txt;
        force = true;
      };

      ".config/theme-variants/fastfetch/dark.jsonc".source = ../../../../assets/fastfetch/nixos-01.jsonc;
      ".config/theme-variants/fastfetch/light.jsonc".source =
        ../../../../assets/fastfetch/nixos-01-light.jsonc;
      ".config/theme-variants/fastfetch/logo-dark.txt".source =
        ../../../../assets/fastfetch/logo/nixos_logo_1.txt;
      ".config/theme-variants/fastfetch/logo-light.txt".source =
        ../../../../assets/fastfetch/logo/nixos_logo_1-light.txt;
    };

  };
}
