{ config, pkgs, ... }:

{
  # Home Manager 必须设置的选项
  # 注意：在 Termux 中需要根据实际情况修改用户名和主目录
  home.username = "mengw";  # 替换为你的 Termux 用户名（运行 whoami 查看）
  home.homeDirectory = "/data/data/com.termux/files/home";  # Termux 默认主目录
  home.stateVersion = "25.11";

  # Termux 特定配置
  home.sessionVariables = {
    # Termux 环境标识
    TERMUX_VERSION = "1";
    TERMUX_APP_ID = "com.termux";

    # 使用 Termux API 打开文件
    BROWSER = "termux-open";

    # 编辑器
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Termux 相关包（只包含能在 Termux 上运行的）
  home.packages = with pkgs; [
    # CLI 工具（大部分在 Termux 中可用）
    bat           # cat 替代品
    exa           # ls 替代品（或 eza）
    fd            # find 替代品
    ripgrep       # grep 替代品
    fzf           # 模糊查找器
    zoxide        # cd 替代品
    jq            # JSON 处理
    htop          # 系统监控
    tmux          # 终端复用器
    git           # 版本控制
    lazygit       # Git TUI
    helix
    # 注意：以下包可能需要在 Termux 中通过 pkg 安装而非 Nix
    # 因为某些包需要 Android 特定的编译配置
  ];

  # 针对 Termux 的 Fish shell 配置
  programs.fish.shellInit = ''
    # Termux 特定初始化
    if test -f /data/data/com.termux/files/usr/etc/profile
      set -gx IS_TERMUX 1
    end

    # Termux 存储路径别名
    if test -d /storage/emulated/0
      alias android-storage='cd /storage/emulated/0'
    end
  '';

  # 其他配置可以继承自 cli-common
  # 但需要注意某些系统级配置在 Termux 中不可用
}
