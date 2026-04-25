# Tmux 配置
{ config, pkgs, ... }:

{
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

      # ========== 状态栏设置 ==========
      set -g status-position top            # 状态栏位置：顶部
      set -g status-interval 5              # 状态栏更新间隔：5 秒
      set -g status-justify left            # 状态栏对齐方式：左对齐
      set -g status-left-length 40          # 状态栏左对齐长度：40 字符
      set -g status-right-length 100        # 状态栏右对齐长度：100 字符
      set -g window-status-separator ""     # 窗口状态分隔符：空字符串
      set -gw automatic-rename on           # 自动重命名窗口：开启
      # 自动重命名窗口格式：{当前面板路径}
      set -gw automatic-rename-format '#{b:pane_current_path}'

      # ========== 面板相关快捷键 ==========
      # 分割面板：prefix + h/v
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      # 退出当前面板：prefix + x
      bind x kill-pane

      # 切换面板：Shift + ←/→/↑/↓
      bind -n S-Left select-pane -L 
      bind -n S-Right select-pane -R
      bind -n S-Up select-pane -U
      bind -n S-Down select-pane -D

      # 调整面板大小：Ctrl + Shift + ←/→/↑/↓
      bind -n C-S-Left resize-pane -L 5
      bind -n C-S-Down resize-pane -D 5
      bind -n C-S-Up resize-pane -U 5
      bind -n C-S-Right resize-pane -R 5

      # ========== 窗口相关快捷键 ==========
      # 重命名窗口：prefix + r
      bind r command-prompt -I "#W" "rename-window -- '%%'"
      # 创建新窗口：prefix + c
      bind c new-window -c "#{pane_current_path}"
      # 退出窗口：prefix + k
      bind k kill-window


      # 切换窗口：Alt + ←/→
      bind -n M-Left select-window -t -1
      bind -n M-Right select-window -t +1
      # 交换窗口：Shift + Alt + ←/→
      bind -n M-S-Left swap-window -t -1 \; select-window -t -1
      bind -n M-S-Right swap-window -t +1 \; select-window -t +1

      # ========== 会话相关快捷键 ==========
      # 重命名会话：prefix + R
      bind R command-prompt -I "#S" "rename-session -- '%%'"
      # 创建新会话：prefix + C
      bind C new-session -c "#{pane_current_path}"
      # 退出会话：prefix + K
      bind K kill-session
      # 切换会话：prefix + P/N
      bind P switch-client -p
      bind N switch-client -n
      # 切换会话：Alt + ↑/↓
      bind -n M-Up switch-client -p
      bind -n M-Down switch-client -n
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
        '';
      }
      # Dracula 主题
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-flags true
          set -g @dracula-refresh-rate 3
          set -g @dracula-border-contrast true
          set -g @dracula-show-powerline true
        '';
      }
    ];
  };
}
