# Ghostty 终端配置
{ config, pkgs, ... }:

{
  # Ghostty 通过 home-manager 配置
  programs.ghostty = {
    enable = true;
    settings = {
      # 字体配置
      font-family = "Maple Mono NF Medium";
      font-size = 15;
      font-thicken = true;
      adjust-cell-height = 2;

      # 主题 - 使用自定义 HardHacker 主题
      theme = "github";


      shell-integration = "fish";
    };
  };
}
