# Niri 窗口管理器 — 系统级配置
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mySystem.desktop.niri;
  desktopCfg = config.mySystem.desktop;

  # XWayland 上 X11 世界的"标称 DPI"：X11 px 就是物理像素，故缩放 N 等价于把
  # DPI 从 96 提到 96N。供 xwayland-xft-dpi 补写 Xft.dpi 使用（见下方注释）。
  xftDpi = builtins.floor (desktopCfg.scale * 96);
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    # 启用 niri
    programs.niri.enable = true;

    # 修补 niri-session 脚本，静默 systemd/dbus 弃用警告
    programs.niri.package = pkgs.niri.overrideAttrs (prev: {
      postPatch = (prev.postPatch or "") + ''
        substituteInPlace resources/niri-session \
          --replace-fail 'systemctl --user import-environment' 'systemctl --user import-environment >/dev/null 2>&1' \
          --replace-fail 'dbus-update-activation-environment --all' 'dbus-update-activation-environment --all >/dev/null 2>&1'
      '';
    });

    # 触控板
    services.libinput.enable = true;

    # Polkit + 密钥环
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # 认证代理：polkit-gnome 的二进制位于 libexec/，加入 systemPackages 后
    # 也不会出现在 PATH 上，此处包一层同名 wrapper 供按名调用。
    # startup.kdl 是 git 仓库内的纯文本（symlink 进 ~/.config/niri），
    # 无法插入 store 路径，只能依赖 PATH 解析。
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "polkit-gnome-authentication-agent-1"
        ''exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"'')

      # XWayland 下的 Xft.dpi 补写（workaround）。
      #
      # fcitx5 的候选窗由 ClassicUI 按"输入上下文所属显示"选择渲染后端：
      #   原生 Wayland 客户端（VSCode 等）→ WaylandUI，按合成器给的分数缩放渲染；
      #   XWayland 客户端（微信、QQ 等，wrapper 里 unset WAYLAND_DISPLAY）→ XCBUI，
      #   其缩放 = DPI / 96，而 DPI 只取自 X11 的 Xft.dpi 资源（RESOURCE_MANAGER），
      #   缺失时回退到 X screen 的 mm 尺寸。
      #
      # xwayland-satellite 0.8.2 把缩放写进 XSETTINGS 的 Xft/DPI，但 fcitx5 读
      # XSETTINGS 时只消费 Net/IconThemeName；它同时也没给 Xwayland 传 -dpi
      # （默认 96，屏幕被报成 3840x2160/1016x571mm）。于是 XCBUI 得到 96 → 缩放
      # 1.0，候选词比 Wayland 侧小 scale 倍（桌面 1.5× 屏上尤其明显）。
      # 这里把 96×scale 补写进 RESOURCE_MANAGER——fcitx5 唯一会读的通道；
      # 该值与 satellite 已广播的 XSETTINGS Xft/DPI 一致，不会造成二次缩放。
      #
      # TODO(检查上游 PR 后删除): xwayland-satellite PR #477
      # "feat: sync Xft.dpi through RESOURCE_MANAGER"（2026-09-08 合并，关闭上游
      # issue #301）已在 master 里做了同样的同步；nixpkgs 当前为 v0.8.2
      # （2026-07-22 发布），不含该修复。后续每次升级 nixpkgs / 改动本模块时确认：
      # 若 nixpkgs 内的 xwayland-satellite 已含 PR #477（版本 > 0.8.2），
      # 则删除本 workaround —— 即这个 xwayland-xft-dpi wrapper、下方 xftDpi 绑定，
      # 以及 startup.kdl 中的 xwayland-xft-dpi 自启项。
      (pkgs.writeShellScriptBin "xwayland-xft-dpi" ''
        set -eu
        dpi=${toString xftDpi}
        # niri 与 xwayland-satellite 并发启动，X server 可能尚未就绪：
        # 有限次重试，超时后报错退出（stderr 进 niri 日志）。
        # 注：scale = 1 的主机上 dpi = 96，与 Xwayland 默认值一致，等同于不改动。
        for _ in {1..120}; do
          if printf 'Xft.dpi:\t%s\n' "$dpi" | ${pkgs.xrdb}/bin/xrdb -merge 2>/dev/null; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 0.5
        done
        echo "[xwayland-xft-dpi] 60s 内未能把 Xft.dpi=$dpi 写入 Xwayland 资源库（Xwayland 未就绪？）" >&2
        exit 1
      '')
    ];

    # dconf 数据库
    programs.dconf.enable = true;

    # 桌面门户
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.niri = {
        default = lib.mkForce "gtk;gnome";
      };
    };

    # 注意：XDG_CURRENT_DESKTOP 由 niri-session 在会话启动时自动设置，
    # 不要在此处全局写死，否则 GNOME 等共存桌面会读取到错误的值。

    # RDP 远程桌面端口
    networking.firewall.allowedTCPPorts = [ 3389 ];
  };
}
