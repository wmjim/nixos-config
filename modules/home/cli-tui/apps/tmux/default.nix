# Tmux 配置
{ config, pkgs, ... }:

{
  # 主题文件部署到 ~/.config/tmux/themes/theme.conf
  xdg.configFile."tmux/themes/theme.conf".source = ./config/theme.conf;

  # 主题脚本部署到 ~/.config/tmux/themes/scripts/（保留可执行权限）
  xdg.configFile."tmux/themes/scripts/helpers.sh" = {
    source = ./config/scripts/helpers.sh;
    executable = true;
  };
  xdg.configFile."tmux/themes/scripts/cpu_percentage.sh" = {
    source = ./config/scripts/cpu_percentage.sh;
    executable = true;
  };
  xdg.configFile."tmux/themes/scripts/ram_percentage.sh" = {
    source = ./config/scripts/ram_percentage.sh;
    executable = true;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;
    mouse = true;
    focusEvents = true;
    keyMode = "vi";
    sensibleOnTop = true;
    terminal = "tmux-256color";

    extraConfig = ''
      # 终端真彩色支持
      set -ga terminal-overrides ",xterm-256color:Tc"

      # 快速重载配置文件
      bind p source-file ~/.tmux.conf \; display-message "Config reloaded!"

      # 复制到系统剪贴板
      set -g set-clipboard on

      # 允许将某些转义序列传递给终端
      set -g allow-passthrough on

      # 不同 ssh 客户端自动调整面板大小
      setw -g aggressive-resize on

      # 防止意外退出会话
      set -g detach-on-destroy off

      # 复制模式 vi 风格
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # 自动重命名窗口
      set -gw automatic-rename on
      set -gw automatic-rename-format '#{b:pane_current_path}'

      # ========== 面板相关快捷键 ==========
      # 分割面板：prefix + h/v
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      # 退出当前面板：prefix + x
      bind x kill-pane

      # 切换面板：Alt + ←/→/↑/↓
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # 调整面板大小：prefix + ←/→/↑/↓（可连续按）
      bind -r Left resize-pane -L 5
      bind -r Down resize-pane -D 5
      bind -r Up resize-pane -U 5
      bind -r Right resize-pane -R 5

      # ========== 窗口相关快捷键 ==========
      # 重命名窗口：prefix + r
      bind r command-prompt -I "#W" "rename-window -- '%%'"
      # 创建新窗口：prefix + c
      bind c new-window -c "#{pane_current_path}"
      # 退出窗口：prefix + k
      bind k kill-window

      # 切换窗口：Shift + ←/→
      bind -n S-Left select-window -t -1
      bind -n S-Right select-window -t +1
      # 交换窗口：Ctrl + Shift + ←/→
      bind -n C-S-Left swap-window -t -1 \; select-window -t -1
      bind -n C-S-Right swap-window -t +1 \; select-window -t +1

      # ========== 会话相关快捷键 ==========
      # 重命名会话：prefix + R
      bind R command-prompt -I "#S" "rename-session -- '%%'"
      # 创建新会话：prefix + C
      bind C new-session -c "#{pane_current_path}"
      # 退出会话：prefix + K
      bind K kill-session
      # 切换会话：Shift + ↑/↓
      bind -n S-Up switch-client -p
      bind -n S-Down switch-client -n

      # ========== 主题 ==========
      source-file ~/.config/tmux/themes/theme.conf
    '';

    plugins = with pkgs.tmuxPlugins; [
      # 保存和恢复会话
      resurrect
      # 自动定时保存 + 开机自动恢复
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '10'
          set -g @continuum-restore 'on'
        '';
      }
      # fzf 会话切换
      {
        plugin = tmux-fzf;
        extraConfig = ''
          set -g @tmux-fzf-launch-key 'F'
          set -g @tmux-fzf-options '--no-preview'
        '';
      }
    ];
  };
}