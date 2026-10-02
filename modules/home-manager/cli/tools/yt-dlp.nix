# yt-dlp — 视频/音频下载器
#
# settings 由 HM 模块渲染成 $XDG_CONFIG_HOME/yt-dlp/config（长选项形式，布尔 = 有无
# --no- 前缀，见 home-manager/modules/programs/yt-dlp.nix）。包也由该模块提供，
# 故 default.nix 的 home.packages 里不再单独列 yt-dlp。
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mengw.cli.tools.yt-dlp;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.tools.yt-dlp.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 yt-dlp 及下载配置";
  };

  config = lib.mkIf (cfg.enable && cliCfg.enable) {
    programs.yt-dlp = {
      enable = true;
      # 默认下载最佳画质
      # 自动合并为 mp4
      # 保存到统一目录
      # 嵌入元数据、封面、章节
      # 字幕默认下载
      # 单视频 URL 不意外下载整个 playlist
      # 网络波动时自动重试
      settings = {
        # 下载根目录（yt-dlp 内部对 --paths 做 expanduser，~ 可用）。
        # output 相对此目录 → ~/Videos/yt-dlp/<uploader>/...
        paths = "~/Videos/yt-dlp";
        output = "%(title)s.%(ext)s";
        
        # 画质：最佳画质，mp4 格式
        format = "bestvideo*+bestaudio/best";
        merge-output-format = "mp4";

        # 元数据
        embed-metadata = true;
        embed-thumbnail = true;
        embed-chapters = true;

        # 字幕
        write-subs = true;
        write-auto-subs = true;
        sub-langs = "en.*,zh-Hans,zh-Hant";

        # 默认只下载指定的视频
        no-playlist = true;

        # 网络重试
        retries = 10;
        fragment-retries = 10;
        retry-sleep = "exp=1:20";

        # 文件处理
        no-overwrites = true;
        continue = true;
        trim-filenames = 180;
      };
    };
  };
}
