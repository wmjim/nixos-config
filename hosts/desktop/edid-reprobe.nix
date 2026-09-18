# 显示器 EDID 首读失败自愈：热插拔后发现"已连接但读不到目标模式"时强制重读
#
# 现象：4K 屏长时间断电再上电，桌面内容变得巨大（2026-09-15 15:21、2026-09-17
# 06:58、2026-09-18 11:40 各复现一次，此前只能重启解决）。
#
# 根因（已由 niri 日志 + 驱动源码确认）：
#   1. 显示器刚上电时其 DDC/EDID 还没就绪，而 NVIDIA 驱动在 HPD 之后立刻取一次
#      EDID，拿到的是合成 stub——niri 日志里连接器身份从 "ICD Inc ICD GX288UR"
#      变成 "Nvidia 0x0000 Unknown"，模式列表只剩 640x480 兜底项。
#   2. scale 1.5 照常生效，逻辑尺寸塌到 640/1.5 × 480/1.5 ≈ 427×320，于是所有
#      窗口都巨大。
#   3. stub EDID 校验和有效且连接器仍是 connected，内核判定"状态没变"，不会补发
#      hotplug；驱动也不会自己重试——这是 stub 而非"读失败"的直接后果。
#
# 修复思路：不改驱动行为，只做"强制重读 + 通知合成器"。
#   nvidia-drm 的 fill_modes = drm_helper_probe_single_connector_modes，其 detect
#   每次都会先释放缓存 EDID 再向 RM/DDC 重新取一次
#   （nvidia-drm-connector.c: __nv_drm_connector_detect_internal 开头 free(edid)，
#    再由 __nv_drm_detect_encoder 重新填充），因此
#   `echo detect > /sys/class/drm/<conn>/status`（drm_sysfs.c status_store →
#   connector->funcs->fill_modes）是一次真实的硬件重读；显示器 DDC 就绪前会持续
#   失败，故需要有限次重试。
#
# ⚠️ 触发源（旧版 bug 所在）：DRM 的 hotplug uevent 一律发在**显卡节点**上——
# drm_sysfs.c 里无论是 drm_sysfs_hotplug_event() 还是
# drm_sysfs_connector_hotplug_event()，都是
# kobject_uevent_env(&dev->primary->kdev->kobj, KOBJ_CHANGE, envp)，即 card1；
# 连接器子设备 card1-DP-2 永远收不到 change 事件（它也没有 devnum，niri/smithay
# 同样只跟踪 card[0-9]）。旧规则匹配 KERNEL=="card1-DP-2"，所以真实热插拔时
# 从未触发过（journal 里那两次 "Starting 重读显示器 EDID" 是手工
# `systemctl start` / `udevadm trigger` 打的），自愈自然没生效。
#
# 升级手段（若下次故障后 journal 显示 120s 超时，说明单纯 detect 也读不回来）：
#   echo off > status && echo detect > status —— 先把 force 置 OFF 触发一次强制重探
#   并重建 CRTC，再清回 UNSPECIFIED 重新读 EDID。代价是画面黑一下、niri 会短暂
#   认为输出消失（布局会重排），所以只在 detect 被证实无效时才上。
#
# 已排除的其他方案（理由见 nvidia.nix 注释）：
#   drm.edid_firmware  → 连接器恒 connected，阻止 DP 链路重训练，黑屏
#   video=DP-2:...     → user-defined 模式被 NVIDIA 拒绝，黑屏
{ pkgs, ... }:
let
  connector = "card1-DP-2";
  card = "card1";
  expectedMode = "3840x2160";

  reprobe = pkgs.writeShellScript "edid-reprobe" ''
    set -u

    sys=/sys/class/drm/${connector}
    expected=${expectedMode}
    # 60 轮 × 2s = 120s：足够覆盖显示器 DDC 就绪（实测冷启动后通常几秒内可读）
    maxRounds=60
    interval=2

    log() {
      printf '[%s] [edid-reprobe] %s\n' \
        "$(${pkgs.coreutils}/bin/date -Is)" "$*" >&2
    }

    connector_status() {
      ${pkgs.coreutils}/bin/cat "$sys/status" 2>/dev/null || echo unknown
    }

    has_expected_mode() {
      ${pkgs.gnugrep}/bin/grep -qx "$expected" "$sys/modes" 2>/dev/null
    }

    # 规则挂在 card1 上，正常热插拔、本服务自愈后自己触发的 change 事件都会走到
    # 这里，因此健康路径必须静默退出，避免刷日志。
    case "$(connector_status)" in
      connected) ;;
      # 显示器断电/拔线：没有可修复的东西，等下一次上电的 hotplug
      *) exit 0 ;;
    esac

    has_expected_mode && exit 0

    log "${connector} 已连接但模式列表无 $expected，判定为 EDID 首读失败（stub），开始强制重读"
    round=0
    while [ "$round" -lt "$maxRounds" ]; do
      round=$((round + 1))

      # 副作用：detect 只刷新内核侧模式列表（连接器状态不变），内核不会因此发
      # hotplug，合成器毫无感知——所以恢复后还要下面补一次显式通知。
      echo detect > "$sys/status"

      if has_expected_mode; then
        log "${connector} 第 $round 次重读后恢复，通知合成器重选模式"
        # niri（经 smithay 的 udev backend）只跟踪 sysname 匹配 card[0-9] 的显卡
        # 设备本身，戳 card1-DP-2 这类连接器子设备会被 change 事件过滤直接丢弃，
        # 通知目标必须是 card1。niri 收到后重新扫描连接器，模式列表已变
        # （DrmScanEvent::Changed），on_output_config_changed() 会按
        # niri-outputs/outputs.kdl 里的 mode "3840x2160@150.000" 重新 use_mode。
        ${pkgs.systemd}/bin/udevadm trigger \
          --subsystem-match=drm --sysname-match=${card} -c change
        exit 0
      fi

      # 重试期间用户又把显示器关了/拔了线：留给下一次上电事件
      if [ "$(connector_status)" != connected ]; then
        log "${connector} 在第 $round 次重试期间断开，放弃本次修复"
        exit 0
      fi

      ${pkgs.coreutils}/bin/sleep "$interval"
    done

    log "${connector} $((maxRounds * interval))s 内仍读不到 $expected：EDID 依旧不可读（可能需要物理重插 DP 线或重启）"
    exit 1
  '';
in
{
  # 显示器上电会触发 card1 的 change 事件（ACTION=="change"，见文件头 uevent 目标
  # 说明）。--no-block 避免阻塞 udev 事件处理；服务自身幂等，重复触发无副作用。
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ACTION=="change", KERNEL=="${card}", RUN+="${pkgs.systemd}/bin/systemctl --no-block start edid-reprobe.service"
  '';

  systemd.services.edid-reprobe = {
    description = "重读显示器 EDID，修复冷启动后分辨率塌陷";
    serviceConfig = {
      Type = "oneshot";
      # oneshot 默认无启动超时；脚本自带 120s 上限，这里再兜一层防止意外挂死
      TimeoutStartSec = 180;
      ExecStart = "${reprobe}";
    };
  };
}
