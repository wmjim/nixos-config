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
    source-serif-pro # 衬线字体
    pkgs.nur.repos.guanran928.harmonyos-sans # 无衬线字体
    maple-mono.NormalNL-NF-CN-unhinted # 等宽字体（CN 变体）
    maple-mono.NormalNL-NF-unhinted # 等宽字体（非 CN 变体，补充）
    noto-fonts-color-emoji # Emoji 字体
    lxgw-wenkai # 霞鹜文楷，中文衬线补充字体
  ];

  # ── 字形渲染：灰度 + 不 hinting（macOS 自 Mojave 起就是这套）────────────
  # 这两件事是一对：hinting 把笔画对齐到像素网格，次像素渲染再借 R/G/B 子像素
  # 骗出更高的横向分辨率 —— 两者都是为了在小字号下抢清晰度，代价是字形失去字体
  # 原本的比例、字边出现彩边。这里两个都不要。
  #
  # autohint 尤其与字体选型矛盾：fonts.packages 里的等宽字体特意选了 **-unhinted**
  # 构建（同一包也有 NormalNL-NF / NormalNL-NF-CN 两个 hinted 变体而没选），
  # 而 autohint 正是对“没有自带 hinting”的字体生效的开关 —— 等于把那份刻意
  # 不 hinting 的轮廓重新对齐一遍。
  #
  # 说明：hinting.style 与 subpixel.* 不是写进生成的那个 conf 文件，而是替换
  # conf.d 里指向 fontconfig 自带预设的软链（10-hinting-none.conf /
  # 10-sub-pixel-none.conf），所以核实时要看软链目标。
  fonts.fontconfig.hinting.style = "none";
  fonts.fontconfig.hinting.autohint = false;
  fonts.fontconfig.subpixel.rgba = "none";
  # 不写 subpixel.lcdfilter：LCD 滤镜只对次像素渲染有意义，rgba = none 时它是空转，
  # 而它的默认值本来就是 "default"（即上游默认，不替换任何 conf.d 软链）。

  # 中文回退加固：部分国产 Qt 应用（迅雷、欧陆词典等）对 fontconfig
  # 的逐字回退依赖不可靠，若命中的字体（如 HarmonyOS Sans SC 仅覆盖
  # U+4E00–U+9FA5）缺字则直接渲染成方块。因此把全量覆盖的 Noto CJK SC
  # 提前进默认字体链，并给常见中文家族名做别名，让应用请求 SimSun /
  # 微软雅黑 / PingFang 等名称时也能命中覆盖完整的字体。
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "HarmonyOS Sans SC"
      "LXGW WenKai"
    ];
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
