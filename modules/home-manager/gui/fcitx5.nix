# Fcitx5 用户级配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.fcitx5;
  guiCfg = config.mengw.gui;

  rimeDir = "${config.home.homeDirectory}/.local/share/fcitx5/rime";

  # 记录上次部署时 rime 数据源指纹，用于判断是否需要清理构建缓存。
  # 放在 rime 目录之外，避免被 rime 当作自身数据文件处理。
  stampFile = "${config.home.homeDirectory}/.local/share/fcitx5/.rime-data-key";

  # rime 按 mtime 判断构建缓存是否失效，而 nix store 内文件 mtime 恒为 0，
  # 因此数据包路径变化时 rime 会重建词典却沿用旧 schema，导致输入法静默失效
  # （进程在、schema 在，却出不来候选词）。这里以数据源路径作为指纹显式失效。
  #
  # 指纹只参与字符串比较，故丢弃字符串上下文，避免把基线包拖进运行时闭包
  # （否则每次 switch 都会为 fcitx5-rime / rime-data 多下载约 16MB）。
  # 路径即使被 GC，只做比较也依然有效。
  pathKey = p: builtins.unsafeDiscardStringContext (toString p);
  rimeDataKey = lib.concatStringsSep ":" [
    (pathKey pkgs.rime-wanxiang)
    (pathKey pkgs.fcitx5-rime)
  ];
in
{
  options.mengw.gui.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 用户级配置（Rime）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
      patch:
        __include: wanxiang_suggested_default:/
        __patch:
          menu/page_size: 7
    '';

    # 只在数据源指纹变化时才清理，避免每次 switch 都触发全量重建。
    # 仅删除 build/（纯派生产物）；用户词典 *.userdb、*.gram、sync/ 均保留。
    home.activation.rimeBuildCacheInvalidate =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${rimeDir}" ]; then
          verboseEcho "rime 数据目录不存在，跳过构建缓存清理: ${rimeDir}"
        elif [ "$(cat "${stampFile}" 2>/dev/null || true)" != "${rimeDataKey}" ]; then
          verboseEcho "rime 数据源已变化，清理构建缓存（保留用户词典）"
          $DRY_RUN_CMD rm -rf "${rimeDir}/build"
          $DRY_RUN_CMD mkdir -p "$(dirname "${stampFile}")"
          $DRY_RUN_CMD printf '%s\n' "${rimeDataKey}" > "${stampFile}"
        else
          verboseEcho "rime 数据源未变化，保留构建缓存"
        fi
      '';
  };
}
