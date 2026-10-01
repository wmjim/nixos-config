# magpie —— 把本机各 AI agent 的模型选择收在一处的工具（上游 yetone/magpie）
#
# nixpkgs 未收录，故自维护。上游是单个 Go 程序，界面是手写 HTML，没有前端构建
# 步骤，buildGoModule 直接可编。同一份源码与 vendor 出两个产物（gui 参数）：
#   - gui = true：桌面版，经 cgo 链接系统 webview（Linux 下 GTK3 + WebKitGTK 4.1），
#     闭包 847 MiB，故只给有图形会话的主机（desktop/laptop，见 gui 层 apps/utilities）
#   - gui = false：纯终端版，即上游 `make cli` 的形态（nogui tag + CGO_ENABLED=0，
#     无 cgo 依赖），无图形会话的主机用这份（wsl，见 hosts/wsl/default.nix）
# 上游 Makefile 在 Linux 上主动加 gtk3 tag：Wails 默认走 GTK4 + WebKitGTK 6，
# 该 tag 是为兼容老发行版。本包的 nixpkgs 两个 WebKitGTK 版本都有，这里沿用
# gtk3 与上游 release-linux 保持一致（ldd 落在 gtk+3 / webkitgtk+abi=4.1）。
#
# metadata.platforms 只声明 linux：终端版在 darwin 上理论可编，但本机没有 darwin
# 构建器可验证，先不给 macbook 装机（要装另说）。
#
# doCheck = false：上游 internal/proc 的测试扫描源码树里的 os/exec 调用，而 nix
# 的 vendoring 把依赖铺进 vendor/，扫描必然命中 vendor 内的第三方代码，测试在
# nix 下必挂（不是本包配置问题，也不是真实回归）。
#
# 升级不走 `magpie update`（自带的后台自更新会替换自己的二进制，store 只读，
# 必然失败），改的是这个文件：
#   1. 改 version；
#   2. src.hash 先填 lib.fakeHash 跑一次，取报错里的 got:；
#   3. vendorHash 同理，仅在 go.mod/go.sum 有变化时才需要变。
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  gui ? true,
}:

buildGoModule rec {
  pname = if gui then "magpie" else "magpie-cli";
  version = "0.1.99";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    rev = "v${version}";
    hash = "sha256-avzYGy59JHIjGJiquKUo4IMNzOl/9dOvtfqtGXzOOUM=";
  };

  vendorHash = "sha256-Vav3u9uK0u1NMby81XkksfuUSnUr6n5bm1F5c0JuH2s=";

  tags =
    if gui then
      [
        "production"
        "gtk3"
      ]
    else
      [ "nogui" ];

  # 只编主包（上游 `go build .` 同义）：buildGoModule 默认会把模块内每个含
  # .go 的目录都编一遍，而 internal/gui 无条件 import Wails，在 nogui + 无 cgo
  # 的终端版下必然报 undefined（它本就不该被编译）。
  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # Wails 的 Linux 后端在编译期用 pkg-config 探 gtk/webkit
  nativeBuildInputs = lib.optional gui pkg-config;

  buildInputs = lib.optionals gui [
    gtk3
    webkitgtk_4_1
  ];

  env.CGO_ENABLED = if gui then 1 else 0;

  doCheck = false;

  meta = {
    description = "One place to pick every AI agent's model";
    homepage = "https://github.com/yetone/magpie";
    changelog = "https://github.com/yetone/magpie/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "magpie";
    platforms = lib.platforms.linux;
  };
}
