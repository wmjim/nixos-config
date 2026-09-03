# NixOS 本地化配置
{ config, pkgs, ... }:
{
  # 时区
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
  };

  # 启用默认字体包
  fonts.enableDefaultPackages = true;
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    source-serif-pro                                # 衬线字体
    pkgs.nur.repos.guanran928.harmonyos-sans        # 无衬线字体
    maple-mono.NormalNL-NF-CN-unhinted              # 等宽字体（CN 变体）
    maple-mono.NormalNL-NF-unhinted                 # 等宽字体（非 CN 变体，补充）
    noto-fonts-color-emoji                          # Emoji 字体
    lxgw-wenkai                                     # 霞鹜文楷，中文衬线补充字体
  ];

  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.hinting.autohint = true;

  # 中文回退加固：部分国产 Qt 应用（迅雷、欧陆词典等）对 fontconfig
  # 的逐字回退依赖不可靠，若命中的字体（如 HarmonyOS Sans SC 仅覆盖
  # U+4E00–U+9FA5）缺字则直接渲染成方块。因此把全量覆盖的 Noto CJK SC
  # 提前进默认字体链，并给常见中文家族名做别名，让应用请求 SimSun /
  # 微软雅黑 / PingFang 等名称时也能命中覆盖完整的字体。
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "HarmonyOS Sans SC" "LXGW WenKai" ];
    serif = [ "LXGW WenKai" ];
    monospace = [ "Maple Mono Normal NL NF CN" ];
  };

  # 优先级高于 defaultFonts；用 strong 绑定把全量中文字体提到家族列表首位
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <!-- 无衬线中文家族 → Noto Sans CJK SC
           fontconfig 单个 <test> 只允许一个 <string>（多值会告警且丢弃后续值），故逐名拆分 -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>HarmonyOS Sans SC</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Sans CJK SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>PingFang SC</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Sans CJK SC</string>
        </edit>
      </match>

      <!-- 衬线/宋体中文家族 → Noto Serif CJK SC -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>LXGW WenKai</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Serif CJK SC</string>
        </edit>
      </match>

      <!-- 兜底：任何请求的家族都追加全量中文字体，避免 Qt 短回退链够不到 -->
      <match target="pattern">
        <edit name="family" mode="append">
          <string>LXGW WenKai</string>
        </edit>
      </match>
    </fontconfig>
  '';
}
