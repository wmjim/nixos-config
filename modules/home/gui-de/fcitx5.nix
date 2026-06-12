# Fcitx5 用户级配置
{ config, pkgs, ... }:

{
  # 用户 rime 配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      # 引入万象拼音的默认推荐配置
      __include: wanxiang_suggested_default:/
      __patch:
        menu/page_size: 7   #候选词个数
  '';
}
