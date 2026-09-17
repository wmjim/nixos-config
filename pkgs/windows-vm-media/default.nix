# Windows 客户机装机介质（单个 ISO）
#
# 把装机需要的两样东西合成一个可挂载镜像，virt-manager 里挂一次即可：
#   1. virtio-win 驱动：直接复用 nixpkgs virtio-win 的 src（上游 ISO 本体）。
#      nixpkgs 的 virtio-win 输出是解包后的目录树（836MB，且再打成 ISO 会膨胀到
#      1.5GB——-R 与 -J 双份目录记录），故此处不对目录重打包，而是用 xorriso 往
#      上游 ISO 里追加文件，产物与上游 ISO 同尺寸。装系统时「加载驱动程序」指向
#      盘内 amd64\w11，装完运行盘根目录的 virtio-win-guest-tools.exe；
#   2. oem/：WinApps 的 RemoteApp 注册脚本（RDP 开关/NLA/允许名单、时钟、网络配置清理），
#      按 winapps rev 固定抓取，保持上游原样；
#   3. WINAPPS-SETUP.bat + winapps-fix-rdp.ps1（本仓库自有，单一入口）：先调上游
#      oem\install.bat，再补上游在本地化 Windows 上做不到的那一步——按英文组名
#      -DisplayGroup 'Remote Desktop' 启用规则会匹配不到「远程桌面」而静默失败，
#      导致 3389 被防火墙 DROP；最后打印校验信息。理由详见 winapps-fix-rdp.ps1 顶部。
#
# oem 脚本按 commit 固定抓取而非取自 inputs.winapps：上游 flake 的 nix-filter 未收录
# oem/ 目录，store 里没有这些文件。winappsRev 由调用方从 flake.lock 的输入传入，
# 保证与 winapps 版本同步（升级输入后哈希失配会显式构建失败，而非静默沿用旧脚本）。
{ lib
, stdenvNoCC
, fetchurl
, virtio-win
, winappsRev
, writeText
, xorriso
, gnused
,
}:
let
  oemFiles = {
    "RDPApps.reg" = "sha256-w7aY23wXGdaRNpRRR1KfRlzfV8wuUhtMAZLuk0yeVDQ=";
    "install.bat" = "sha256-O/71MZHOlAG4RC8iD8fZ2/TYEhuua93ASOoVUkrHLOE=";
    "TimeSync.ps1" = "sha256-aJ1+Jh9niYpO8P+u+0s6g3vYj0L9EKgK5tptf1YbHMI=";
    "NetProfileCleanup.ps1" = "sha256-zsgVCr/FHG9Xad7eWvs7MFl2kuwdJx8Fzg2c8hpnn6w=";
  };

  fetchOem = name: fetchurl {
    url = "https://raw.githubusercontent.com/winapps-org/winapps/${winappsRev}/oem/${name}";
    hash = oemFiles.${name};
  };

  # 客户机侧看不到 nix 配置，安装步骤必须落在介质上
  readme = writeText "README-WinApps.txt" ''
    WinApps Windows VM 装机步骤
    ===========================

    1. 安装 Windows 11 Pro（RemoteApp 需要 Pro/Enterprise，Home 版不可用）。
    2. 安装程序选择磁盘时点「加载驱动程序」→ 浏览本光盘 amd64\w11（Win10 用 amd64\w10）。
    3. 进入桌面后运行本光盘根目录的 virtio-win-guest-tools.exe。
    4. 以管理员身份运行本光盘根目录的 WINAPPS-SETUP.bat
       （= 上游 oem\install.bat 的注册表与计划任务 + 语言无关的 RDP 防火墙放行。
        上游用 -DisplayGroup 'Remote Desktop' 按英文组名启用规则，在中文 Windows 上
        匹配不到「远程桌面」而静默失败，3389 会被防火墙 DROP，故需本脚本补这一步。）
    5. 重启 Windows，然后在 Linux 侧执行：winapps-setup --user
  '';
in
stdenvNoCC.mkDerivation {
  pname = "windows-vm-media";
  inherit (virtio-win) version;

  nativeBuildInputs = [
    xorriso
    # 批处理文件需转 CRLF
    gnused
  ];
  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p extra/oem
    ${lib.concatMapStrings (name: "cp ${fetchOem name} extra/oem/${name}\n") (lib.attrNames oemFiles)}
    cp ${readme} extra/README-WinApps.txt
    # 本仓库自有的 Windows 侧脚本（上游 oem/ 之外的部分：语言无关的 RDP 防火墙放行）
    cp ${./winapps-fix-rdp.ps1} extra/winapps-fix-rdp.ps1
    cp ${./WINAPPS-SETUP.bat} extra/WINAPPS-SETUP.bat
    # 仓库里批处理文件按 LF 存（diff 友好），构盘时统一转 CRLF：
    # cmd.exe 解析带括号的 if/else 块依赖 CRLF，LF 会报「命令语法不正确」
    sed -i 's/\r*$/\r/' extra/WINAPPS-SETUP.bat
    xorriso -indev ${virtio-win.src} -outdev media.iso \
      -map extra/oem /oem \
      -map extra/README-WinApps.txt /README-WinApps.txt \
      -map extra/winapps-fix-rdp.ps1 /winapps-fix-rdp.ps1 \
      -map extra/WINAPPS-SETUP.bat /WINAPPS-SETUP.bat \
      -commit -end
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/windows-vm-media
    mv media.iso $out/share/windows-vm-media/windows-vm-media.iso
    runHook postInstall
  '';

  meta = {
    description = "Windows 客户机装机介质：virtio-win 驱动 ISO + WinApps oem 脚本 + 语言无关的 RDP 防火墙修正";
    platforms = lib.platforms.linux;
  };
}
