# MacTahoe GTK 主题（vinceliuice，macOS Tahoe 风格）
# nixpkgs 未收录，此处仿照 whitesur-gtk-theme 打包
# 构建方式：install.sh 内部用 sassc 编译 SCSS 到 $out/share/themes
{ lib, stdenv, fetchFromGitHub, dialog, glib, gnome-themes-extra, jdupes, libxml2, sassc, util-linux }:

stdenv.mkDerivation {
  pname = "mactahoe-gtk-theme";
  version = "2026-08-07";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-gtk-theme";
    rev = "a626e946f79886703abe72a178f1223a986885f1";
    hash = "sha256-UEJZFXCVox3KCTZqSeOILumKCbUIeDTzcbLjimtotEI=";
  };

  nativeBuildInputs = [
    dialog
    glib
    jdupes
    libxml2
    sassc
    util-linux
  ];

  buildInputs = [
    gnome-themes-extra # adwaita engine for Gtk2
  ];

  postPatch = ''
    find -name "*.sh" -print0 | while IFS= read -r -d ''' file; do
      patchShebangs "$file"
    done

    # 构建环境无 sudo，install 脚本只用于装到 $out，无需提权
    substituteInPlace libs/lib-core.sh --replace-fail '$(which sudo)' false

    # 提供假 home 目录，避免读取真实用户信息
    substituteInPlace libs/lib-core.sh --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes

    # 只装 normal 透明度下的深浅两个变体（默认会生成 4 个组合，冗余）
    ./install.sh \
      --color light \
      --color dark \
      --opacity normal \
      --dest $out/share/themes

    # Firefox/zen 浏览器主题：与 GTK 主题共用同一份源码，一并安装到
    # share/firefox-theme，由 home-manager 软链进浏览器 profile 的 chrome/ 目录
    mkdir -p $out/share/firefox-theme
    cp -r other/firefox/MacTahoe $out/share/firefox-theme/
    cp other/firefox/userChrome.css other/firefox/userContent.css other/firefox/customChrome.css $out/share/firefox-theme/

    # GDM 登录界面主题：把 other/gdm/theme 编译为 gnome-shell-theme.gresource。
    # gnome-shell 的 gresource 路径在编译期烘焙进二进制，只能由 NixOS overlay
    # 覆盖 gnome-shell 包内同名文件实现 GDM 换肤（见 desktop/gnome 模块）
    mkdir -p $out/share/gnome-shell
    glib-compile-resources \
      --sourcedir=other/gdm/theme \
      --target=$out/share/gnome-shell/gnome-shell-theme.gresource \
      other/gdm/gnome-shell-theme.gresource.xml

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  meta = {
    description = "MacOS Tahoe like theme for GTK desktops";
    homepage = "https://github.com/vinceliuice/MacTahoe-gtk-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
