# Zellij — 终端复用器
{ ... }:
{
  # 启用 home-manager 的 Zellij 模块（安装二进制 + 管理配置文件）
  programs.zellij = { enable = true; };

  home.file.zellij-config = {
    target = ".config/zellij/config.kdl";
    source = ./config.kdl;
  };

  # home.file.zellij-layouts = {
  #   target = ".config/zellij/layouts/default.kdl";
  #   source = ./layouts/default.kdl;
  # };
}
