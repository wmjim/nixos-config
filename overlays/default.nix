# 自定义包 overlay —— pkgs/ 下自维护包的单一注入点
#
# 消费方：
#   - NixOS 系统级：modules/nixos/core/default.nix 的 nixpkgs.overlays
#   - macOS 系统级：modules/darwin/base.nix 的 nixpkgs.overlays
#   - flake 输出：overlays.default 与 packages.*（见 flake.nix），
#     nix flake check 会逐一评估 packages.*，nixpkgs 滚动时包级回归
#     （fetch 哈希失配、依赖 API 变更）在 CI 即暴露，不再只靠主机 dry-build 兜底
#
# 为什么是 { inputs }: final: prev: 而不是裸 final: prev:：
#   windows-vm-media 需要按 flake.lock 的 winapps 输入 rev 固定抓取 oem 脚本，
#   overlay 本身拿不到 flake inputs，只能由调用方注入。
{ inputs }:
final: prev: {
  # 自打包主题（nixpkgs 未收录）：MacTahoe GTK / 图标主题 / Kvantum(Qt) 主题
  mactahoe-gtk-theme = prev.callPackage ../pkgs/mactahoe-gtk-theme { };
  mactahoe-icon-theme = prev.callPackage ../pkgs/mactahoe-icon-theme { };
  mactahoe-kvantum = prev.callPackage ../pkgs/mactahoe-kvantum { };

  # mcpp：C++23 模块优先的构建工具（上游 mcpp-community/mcpp）。
  # 名字不能省成 `mcpp`：nixpkgs 的 mcpp 是 Matsui 的 C 预处理器，同名不同物
  #（打包理由见 pkgs/mcpp-m/default.nix 顶部）。
  mcpp-m = prev.callPackage ../pkgs/mcpp-m { };

  # Windows 客户机装机介质（virtio-win ISO + WinApps oem 脚本）。
  # winappsRev 取自 flake.lock 的 winapps 输入，升级输入后 oem 脚本哈希失配
  # 会显式报错，保证介质与 winapps 版本同步（消费方：modules/nixos/virtualization）。
  windows-vm-media = prev.callPackage ../pkgs/windows-vm-media {
    winappsRev = inputs.winapps.rev;
  };
}
