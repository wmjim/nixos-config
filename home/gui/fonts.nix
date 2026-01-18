{ config, pkgs, ... }:

{
  # 启用用户级 fontconfig
  fonts.fontconfig.enable = true;

  # 字体包已通过系统级配置安装
  # 这里只需要配置用户特定的字体设置（如果需要）
}
