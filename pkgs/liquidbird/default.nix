# LiquidBird —— Thunderbird 的 Liquid Glass 主题（上游 StatIndet/liquidbird）
#
# 它不是 add-on，而是 profile 内的 userChrome/userContent 体系：文件要落在
# <profile>/chrome/，并由 prefs 的 toolkit.legacyUserProfileCustomizations.stylesheets
# 打开。故本包只做「把上游发布包该给的那几样按 chrome/ 布局摆好」，落地交给
# HM 的 home.file（见 modules/home-manager/gui/apps/productivity.nix）。
#
# 为什么钉 main 的 commit 而不是 tag：v0.1.0 只有 macOS 侧，Linux/niri 移植在
# 其后 3 个 commit（0f8148d "Port LiquidBird to Linux and niri"），上游尚未为
# Linux 打 tag。升级改 rev + hash（hash 先填 lib.fakeHash，取报错里的 got:）。
#
# 命名跟随上游发布包：个人覆盖用的模板在包里叫 custom.css.example（上游的
# custom.css 只是注释模板），落地时不会覆盖同名的 custom.css。
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "liquidbird";
  version = "0-unstable-2026-09-25";

  src = fetchFromGitHub {
    owner = "StatIndet";
    repo = "liquidbird";
    rev = "0f8148d0581ce72e837ca34046cc120f754a1b8a";
    hash = "sha256-ujieTQ3I4/Jwad3g6p04N18rhuMzWe4D7H9Xa+BojCo=";
  };

  # 纯文件搬运：上游没有构建步骤（CSS/SVG/PNG + 两个 loader）
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/liquidbird/chrome
    cp -r Icons linux $out/share/liquidbird/chrome/
    install -m644 liquidbird.css liquidbird-content.css userChrome.css userContent.css \
      $out/share/liquidbird/chrome/
    install -m644 custom.css $out/share/liquidbird/chrome/custom.css.example

    runHook postInstall
  '';

  meta = {
    description = "Liquid glass theme for Thunderbird (userChrome/userContent)";
    homepage = "https://github.com/StatIndet/liquidbird";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
