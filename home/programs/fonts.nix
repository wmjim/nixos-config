{ pkgs, ... }:

{
  # 字体配置
  # 注意：本地字体已安装在 ~/.local/share/fonts/，无需通过 Nix 复制
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      # 无衬线字体：Harmony Sans SC Medium 优先
      sansSerif = [ "Harmony Sans SC Medium" ];
      # 等宽字体：Maple Mono 为主，lxgw-wenkai-gb 为备选
      monospace = [ "Maple Mono NF Medium" "LXGW WenKai GB" ];
    };
  };
}
