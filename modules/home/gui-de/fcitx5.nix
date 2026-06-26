# Fcitx5 用户级配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.fcitx5;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 用户级配置（Rime）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # 用户 rime 配置
    home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
      patch:
        # 引入万象拼音的默认推荐配置
        __include: wanxiang_suggested_default:/
        __patch:
          menu/page_size: 7   #候选词个数
    '';
  };
}
