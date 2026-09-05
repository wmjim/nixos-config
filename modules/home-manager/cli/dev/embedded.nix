# 嵌入式单片机开发环境（STM32 / ESP32 / AVR / RP2040）
# 覆盖：交叉编译工具链 + 烧录/调试工具 + PlatformIO 统一构建框架
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.dev.embedded;
  devCfg = config.mengw.cli.dev;
  cliCfg = config.mengw.cli;

  # === stm32cubemx HiDPI 启动器包装 ===
  # CubeMX 的 Swing 窗口内嵌 JxBrowser(Chromium) 渲染整个配置界面。GNOME 分数缩放
  # (如桌面 4K@scale=1.5) 下 XWayland 只按整数缩放上报,AWT 因而默认落在 1x,
  # 整窗文字远小于桌面。且 AWT 的 sun.java2d.uiScale 只接受整数,全局 _JAVA_OPTIONS
  # 里设的 1.5 会被静默忽略(实测 defaultTransform 仍为 1x1),救不了 Chromium 内容。
  # 故启动时读 monitors.xml 的 GNOME 逻辑缩放,向上取整为整数(1→1、>1→2)再喂给 JVM:
  # 桌面(1.5)得到 uiScale=2,窗口逻辑分辨率与桌面一致,字号不再偏小;scale=1 的
  # 主机(如 laptop)取 1,行为与不设无异,不影响其他机器。
  stm32cubemxLauncher = pkgs.symlinkJoin {
    name = "stm32cubemx-launcher";
    paths = [
      (pkgs.writeShellScriptBin "stm32cubemx" ''
        uiScale=""
        if [ -r "$HOME/.config/monitors.xml" ]; then
          # 取文件里第一个 <scale>（首个配置布局的主显示器），如 1 / 1.5 / 2
          while IFS= read -r line; do
            if [[ "$line" =~ \<scale\>([0-9.]+)\</scale\> ]]; then
              case "''${BASH_REMATCH[1]}" in
                1 | 1.0 | 1.00) uiScale=1 ;;
                *) uiScale=2 ;;
              esac
              break
            fi
          done < "$HOME/.config/monitors.xml"
        fi

        # 覆盖外层环境变量（其 1.5 为无效值），补齐 AWT 字体抗锯齿选项
        export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true"
        if [ -n "$uiScale" ]; then
          _JAVA_OPTIONS="$_JAVA_OPTIONS -Dsun.java2d.uiScale=$uiScale"
        fi

        exec ${pkgs.stm32cubemx}/bin/stm32cubemx "$@"
      '')
    ];
    # 原包的 .desktop 菜单项与图标随启动器一起带出,应用菜单入口不受影响
    postBuild = ''
      mkdir -p $out/share
      ln -s ${pkgs.stm32cubemx}/share/applications $out/share/applications
      ln -s ${pkgs.stm32cubemx}/share/icons $out/share/icons
    '';
  };
in
{
  options.mengw.cli.dev.embedded.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用嵌入式单片机开发环境（ARM/AVR 交叉工具链、烧录调试、PlatformIO）";
  };

  config = lib.mkIf (cfg.enable && devCfg.enable && cliCfg.enable) {
    home.packages =
      # === 通用（跨平台可用的烧录/调试协议与格式工具）===
      (with pkgs; [
        openocd # 通用片上调试器：ST-Link / J-Link / CMSIS-DAP，SWD/JTAG 下载与调试
        dfu-util # USB DFU 烧录（STM32 内置 DFU、RP2040/RP2350 等）
        srecord # 固件镜像格式转换（bin/hex/srec 互转、地址拼接）
        platformio # 统一嵌入式构建/依赖管理（pio），内置 Arduino/ESP-IDF/mbed/STM32Cube 等
      ])
      # === ARM Cortex-M/R 工具链（STM32 等）===
      ++ (with pkgs; [
        gcc-arm-embedded # ARM 预编译交叉工具链（arm-none-eabi-gcc/ld/gdb + newlib）
        pyocd # Python 调试烧录（CMSIS-DAP/DAPLink 等）
        probe-rs-tools # Rust 调试烧录（ST-Link/J-Link/CMSIS-DAP），配合 cargo-embed
      ])
      # === ESP32（乐鑫）===
      ++ (with pkgs; [
        esptool # ESP8266/ESP32 串口烧录（esptool.py）
        espflash # Rust 编写的 ESP 串口烧录器（串口监视用 espmonitor/espflash monitor）
      ])
      # === AVR / Arduino ===
      ++ (with pkgs; [
        # docSupport=true（Linux 默认）会为编文档拉整条 texlive→asymptote→pyqt5，
        # 而 PyQt5 5.15.10 在 Python 3.14 上无法编译（sip ABI v12 不匹配），导致构建失败。
        # 关闭文档构建：avrdude 本体功能不受影响。
        (avrdude.override { docSupport = false; }) # AVR 烧录器（Arduino Uno/Nano/Mega、ATtiny 等）
      ])
      # === RP2040 / RP2350（树莓派 Pico）===
      ++ (with pkgs; [
        picotool # Pico 固件工具（BOOTSEL 模式 flash / info / 固件校验）
      ])
      # === Linux 专属（darwin 无缓存/不支持，见下注释）===
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        stlink # ST-Link 命令行烧录（st-flash / st-util），nixpkgs 仅构建 Linux 版
        stm32cubemxLauncher # STM32 引脚/外设图形化配置（unfree，仅 x86_64-linux；HiDPI 启动器包装见文件顶部）
        android-tools
        # 原生 AVR 交叉编译工具链（avr-gcc 走 pkgsCross 从源码构建，仅 Linux 加载；
        # macOS 上用上面的 PlatformIO 管理 AVR 工具链即可）
        pkgsCross.avr.buildPackages.gcc # avr-gcc 交叉编译器
        pkgsCross.avr.buildPackages.binutils # avr-objcopy/objdump/ld 等
        # 注意 1：不装 avr-gdb——它与 gcc-arm-embedded 自带同一批 GNU info 手册
        # （sframe-spec/ctf-spec/annotate 等），buildEnv 合并 profile 时路径冲突。
        # avr 调试可走 PlatformIO 或单机 devShell；需要 gdb 时在该 shell 里单独引入。
        # 注意 2：不带 avr-libc——它的 meta.platforms = ["avr-none"]，属于 AVR 目标运行库，
        # 不能被装进 x86_64 主机 profile。裸机 AVR（无 libc）avr-gcc 可直接用；
        # 需要 libc 的 AVR 工程请走 PlatformIO（已装）或在该工程的 devShell 里以
        # buildInputs 引用 pkgsCross.avr.avrlibc。
      ]);
  };
}
