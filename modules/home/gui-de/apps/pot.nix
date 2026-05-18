# Pot 翻译工具应用配置
{ pkgs, ... }:

# let
#   pot-icons = pkgs.runCommand "pot-icons" {
#     nativeBuildInputs = [ pkgs.p7zip ];
#   } ''
#     # 从 AppImage 提取图标
#     src="${pkgs.nur.repos.awa2333.pot-translation.src}"
#     mkdir -p $out/share/icons/hicolor/{32x32,128x128,256x256@2}/apps

#     if [ -f "$src" ]; then
#       7z x "$src" -oextracted '*.png' -y > /dev/null 2>&1 || true

#       for size in 32x32 128x128 256x256@2; do
#         icon=$(find extracted -path "*/$size/apps/pot.png" -type f 2>/dev/null | head -1)
#         if [ -n "$icon" ]; then
#           cp "$icon" "$out/share/icons/hicolor/$size/apps/pot.png"
#         fi
#       done

#       # 备选: 使用根目录的 pot.png 作为 128x128
#       if [ ! -f "$out/share/icons/hicolor/128x128/apps/pot.png" ]; then
#         root_icon=$(find extracted -maxdepth 2 -name 'pot.png' -type f 2>/dev/null | head -1)
#         if [ -n "$root_icon" ]; then
#           cp "$root_icon" "$out/share/icons/hicolor/128x128/apps/pot.png"
#         fi
#       fi
#     fi
#   '';
# in

{
  # # 安装图标到用户图标目录
  # home.file.".local/share/icons/hicolor".source = "${pot-icons}/share/icons/hicolor";

  # # 桌面启动器
  # xdg.desktopEntries.pot = {
  #   name = "Pot";
  #   exec = "pot";
  #   icon = "pot";
  #   categories = [ "Utility" ];
  #   comment = "跨平台划词翻译与OCR工具";
  #   terminal = false;
  #   type = "Application";
  # };
}
