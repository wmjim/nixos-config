# 显示器冷启动自愈：EDID 读取失败后自动重读并通知合成器
#
# 现象：4K 屏长时间断电再上电，桌面内容变得巨大。
# 根因不是缩放配置，而是上电那一刻 NVIDIA 驱动第一次读 EDID 失败——niri 日志里
# 连接器身份从 "ICD Inc ICD GX288UR" 变成 "Nvidia 0x0000 Unknown"，驱动只能给出
# 640x480 兜底模式；而 scale 1.5 照常生效，逻辑尺寸塌到 640/1.5 × 480/1.5 ≈ 427×320，
# 于是所有窗口都巨大。EDID 一旦没读出来驱动不会自己重试，只能重启会话或显示器才恢复。
#
# 已排除的其他方案（理由见 nvidia.nix 注释）：
#   drm.edid_firmware  → 连接器恒 connected，阻止 DP 链路重训练，黑屏
#   video=DP-2:...     → user-defined 模式被 NVIDIA 拒绝，黑屏
# 本方案不改动驱动行为，只在检测到降级状态后"重读 + 通知"，无黑屏风险。
{ pkgs, ... }:
let
  connector = "card1-DP-2";
  card = "card1";
  expectedMode = "3840x2160";

  reprobe = pkgs.writeShellScript "edid-reprobe" ''
    set -u
    sys=/sys/class/drm/${connector}
    expected=${expectedMode}

    # 只处理"已连接但读不到目标模式"这一种降级状态：EDID 缺失时 nvidia-drm
    # 只剩 640x480 等兜底模式。显示器已拔掉（disconnected）或工作正常（模式齐全）
    # 时立即退出，避免每次热插拔事件都空跑。
    [ "$(${pkgs.coreutils}/bin/cat "$sys/status")" = connected ] || exit 0
    ${pkgs.gnugrep}/bin/grep -qx "$expected" "$sys/modes" && exit 0

    # 显示器冷启动后可能要过若干秒 EDID 才可读，有限次重试。
    for _ in {1..60}; do
      # detect 强制驱动重新读 EDID 并重建内核模式列表。副作用：连接器状态不变
      #（connected → connected），DRM 因此不发 hotplug，这一步只刷新内核，
      # 合成器毫无感知——必须靠下面补一次显式通知。
      echo detect > "$sys/status"
      if ${pkgs.gnugrep}/bin/grep -qx "$expected" "$sys/modes"; then
        # niri（经 smithay 的 udev backend）只跟踪 sysname 匹配 card[0-9] 的显卡
        # 设备本身，戳 card1-DP-2 这类连接器子设备会被 change 事件过滤直接丢弃，
        # 通知目标必须是 card1。
        ${pkgs.systemd}/bin/udevadm trigger --subsystem-match=drm --sysname-match=${card} -c change
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 2
    done
    echo "[edid-reprobe] ${connector} 120s 内仍未读到 ${expectedMode}（EDID 可能真的读不出来）" >&2
    exit 1
  '';
in
{
  # 显示器热插拔 / DPMS 唤醒都会触发 connector 的 change 事件，--no-block 避免
  # 阻塞 udev 事件处理；服务自身是幂等的，重复触发无副作用。
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ACTION=="change", KERNEL=="${connector}", RUN+="${pkgs.systemd}/bin/systemctl --no-block start edid-reprobe.service"
  '';

  systemd.services.edid-reprobe = {
    description = "重读显示器 EDID，修复冷启动后分辨率塌陷";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${reprobe}";
    };
  };
}
