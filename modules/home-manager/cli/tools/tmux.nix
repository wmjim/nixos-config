# Tmux — 终端复用器
{ lib, config, ... }:
let
  cfg = config.mengw.cli.tools.tmux;
  toolsCfg = config.mengw.cli.tools;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.tools.tmux.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 tmux 终端复用器";
  };

  config = lib.mkIf (cfg.enable && toolsCfg.enable && cliCfg.enable) {
    # 交给 HM 的 tmux 模块生成 ~/.config/tmux/tmux.conf（用 home.file 直写会与
    # 模块自身的 xdg.configFile 撞车），配置主体放在外部文件里保持可读。
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux/tmux.conf;
    };
  };
}
