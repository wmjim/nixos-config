# MacTahoe 图标主题（vinceliuice，macOS Tahoe 风格，MacTahoe GTK 主题配套）
# nixpkgs 未收录，此处仿照 whitesur-icon-theme 打包
{ lib, stdenv, fetchFromGitHub, gtk3 }:

stdenv.mkDerivation {
  pname = "mactahoe-icon-theme";
  version = "2026-07-28";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-icon-theme";
    rev = "b85923bb87f50578268abcff5698947a3ff24695";
    hash = "sha256-Ho71thvHpgQICfC0c67ClKRONdDeNVfg0bGU6ZjM3S8=";
  };

  nativeBuildInputs = [
    gtk3 # gtk-update-icon-cache
  ];

  postPatch = ''
    patchShebangs install.sh
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    # -n MacTahoe 显式指定主题名：nix 构建环境会注入与 derivation 同名的
    # 环境变量，若不加参数 install.sh 的 ${name:-MacTahoe} 会取到错误值。
    # 默认参数生成 MacTahoe / MacTahoe-light / MacTahoe-Dark 三个变体，
    # 桌面默认启用 MacTahoe-Dark，与 GTK 主题保持深色一致
    ./install.sh -d $out/share/icons -n MacTahoe

    runHook postInstall
  '';

  postFixup = ''
    # 上游 links/status/symbolic/globe-symbolic.svg 软链指向 install 从不
    # 创建的 status/places/，属上游自带的悬空软链；一并清理，避免 noBrokenSymlinks
    find $out/share/icons -type l | while read -r l; do
      [ -e "$l" ] || rm "$l"
    done
  '';

  meta = {
    description = "MacOS Tahoe like icon theme";
    homepage = "https://github.com/vinceliuice/MacTahoe-icon-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
  };
}
