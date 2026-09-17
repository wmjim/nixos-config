# WinApps：把 Windows 虚拟机里的应用以独立窗口接入桌面（FreeRDP RemoteApp）
#
# 本模块只负责「接入层」：包、winapps.conf、RDP 密码取值方式。
# 虚拟机本身必须人工建一次——Windows 安装过程无法用 Nix 表达：
#   1. virt-manager 新建虚拟机，名称须与 winapps.vmName 一致；机器类型 q35，
#      固件 UEFI(OVMF, secure boot) + TPM 2.0(crb, swtpm) + virtio 磁盘/网卡，
#      安装 Windows 11 Pro（RemoteApp 需要 Pro/Enterprise，Home 版不行）；
#   2. 挂本仓库打包的装机介质（mySystem.virtualization 的 windows-vm-media.iso）：
#      装系统时用「加载驱动程序」指向盘内 amd64\w11，装完运行盘根目录
#      virtio-win-guest-tools.exe，再以管理员运行 oem\install.bat（导入 RemoteApp 注册表）。
#   3. 首次执行 `winapps-setup --user`：查询 Windows 已装程序并生成各应用的
#      .desktop 与启动脚本。仅此一步是命令式的，其余均由本模块托管。
#
# 硬件探针（ST-Link/J-Link/CMSIS-DAP）不进 RDP，而是以 libvirt <hostdev> 直通给
# 客户机：virt-manager → Add Hardware → USB Host Device，或用
# `virsh attach-device <VM> <xml> --live` 临时挂载（同一探针无法同时给 Linux 与 Windows）。
{ lib, config, pkgs, osConfig, inputs, ... }:
let
  cfg = config.mengw.gui.winapps;
  guiCfg = config.mengw.gui;

  winapps = inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system};

  homeDir = config.home.homeDirectory;

  # RDP 密码不能落进 nix store（store 路径全局可读），改由 FREERDP_ASKPASS
  # 从非托管的 0600 文件读取；该文件需手动创建一次（见下方 activation 提示）。
  rdpPassFile = "${homeDir}/.config/winapps/rdp-pass";

  # WinApps 只接受 100/140/180 三档，按桌面声明的缩放取最近值：
  # 1.5 倍屏 → 140，2 倍及以上 → 180，其余 → 100。可用 cfg.rdpScale 覆盖。
  desktopScale = osConfig.mySystem.desktop.scale;
  derivedScale =
    if desktopScale >= 1.7 then "180"
    else if desktopScale >= 1.3 then "140"
    else "100";
  rdpScale = if cfg.rdpScale != null then cfg.rdpScale else derivedScale;

  extraDriveFlags = lib.concatMapStrings (d: " /drive:${d.name},${d.path}") cfg.extraDrives;
in
{
  options.mengw.gui.winapps = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "WinApps（Windows 应用以独立窗口接入桌面）";
    };

    vmName = lib.mkOption {
      type = lib.types.str;
      default = "RDPWindows";
      description = "libvirt 中的 Windows 虚拟机名，须与 `virsh list --all` 一致";
    };

    windowsUser = lib.mkOption {
      type = lib.types.str;
      default = "mengw";
      description = "Windows 登录用户名（RDP 凭据）";
    };

    # null 表示按 mySystem.desktop.scale 自动派生
    rdpScale = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "100" "140" "180" ]);
      default = null;
      description = "RDP 缩放档位（FreeRDP 只支持 100/140/180 三档）";
    };

    extraDrives = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Windows 侧 \\\\tsclient\\<name> 的共享名";
          };
          path = lib.mkOption {
            type = lib.types.str;
            description = "暴露给 Windows 的主机目录绝对路径";
          };
        };
      });
      default = [{ name = "proj"; path = "${homeDir}/Projects"; }];
      description = "额外以 RDP 磁盘重定向暴露给 Windows 的目录";
    };
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # winapps 自己包装了 freerdp（仅限其脚本可见）；这里额外装一份到用户 PATH，
    # 供手动全屏 RDP 会话（xfreerdp / wlfreerdp）与排错用（xfreerdp +auth-only 验凭据、
    # 单跑一次 RemoteApp 会话）。不会改变 winapps 的自动探测结果：包装器把同一份 freerdp
    # 前置到 PATH，仍取 sdl-freerdp。
    home.packages = [ winapps.winapps winapps.winapps-launcher pkgs.freerdp ];

    # 与 virt-manager/virsh 统一 URI，避免默认落到 qemu:///session 找不到域
    home.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

    home.file.".local/bin/winapps-askpass" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # WinApps 把 RDP_ASKPASS 导出为 FREERDP_ASKPASS，FreeRDP 取本脚本 stdout 作为密码
        exec ${pkgs.coreutils}/bin/cat "${rdpPassFile}"
      '';
    };

    xdg.configFile."winapps/winapps.conf".text = ''
      # 由 home-manager 托管（modules/home-manager/gui/winapps.nix），请改配置而非本文件
      RDP_USER="${cfg.windowsUser}"
      RDP_ASKPASS="${homeDir}/.local/bin/winapps-askpass"
      RDP_DOMAIN=""
      WAFLAVOR="libvirt"
      VM_NAME="${cfg.vmName}"
      RDP_SCALE="${rdpScale}"
      # +home-drive → Windows 侧 \\tsclient\home；/drive: → 额外共享盘
      RDP_FLAGS="/cert:tofu /sound /microphone +home-drive${extraDriveFlags}"
      DEBUG="true"
    '';

    # 密码文件是唯一不托管的输入，缺失时明确提示而非静默失败
    home.activation.winappsRdpPasswordCheck =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -f "${rdpPassFile}" ]; then
          warnEcho "WinApps 尚未设置 Windows 密码，请执行：printf '%s' '你的密码' > ${rdpPassFile} && chmod 600 ${rdpPassFile}"
        fi
      '';
  };
}
