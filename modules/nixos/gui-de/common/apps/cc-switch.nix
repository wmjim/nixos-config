# cc-switch — AI 管理工具
# 将 $HOME 重定向到 ~/files/apps/cc-switch，同时 symlink 主题配置保持 Adwaita 样式
{ pkgs, ... }:
let
  wrapper = pkgs.symlinkJoin {
    name = "cc-switch";
    paths = [ pkgs.cc-switch ];
    postBuild = ''
      rm $out/bin/cc-switch
      cp ${pkgs.writeShellScript "cc-switch" ''
        REAL_HOME="$HOME"
        CC_DIR="$REAL_HOME/files/apps/cc-switch"
        mkdir -p "$CC_DIR/.config"

        # 继承 GTK/Qt 主题配置，保持 Adwaita 样式统一
        [ -d "$REAL_HOME/.config/gtk-3.0" ] && ln -sfn "$REAL_HOME/.config/gtk-3.0" "$CC_DIR/.config/gtk-3.0"
        [ -d "$REAL_HOME/.config/gtk-4.0" ] && ln -sfn "$REAL_HOME/.config/gtk-4.0" "$CC_DIR/.config/gtk-4.0"
        [ -d "$REAL_HOME/.config/dconf" ]   && ln -sfn "$REAL_HOME/.config/dconf"   "$CC_DIR/.config/dconf"
        [ -f "$REAL_HOME/.gtkrc-2.0" ]      && ln -sfn "$REAL_HOME/.gtkrc-2.0"      "$CC_DIR/.gtkrc-2.0"

        exec env HOME="$CC_DIR" ${pkgs.cc-switch}/bin/cc-switch "$@"
      ''} $out/bin/cc-switch
    '';
  };
in {
  environment.systemPackages = [ wrapper ];
}
