# thunderbird 邮件客户端
# 将 $HOME 重定向到 ~/files/apps/thunderbird，防止在主目录生成 ~/thunderbird、~/.thunderbird
{ pkgs, ... }:
let
  wrapper = pkgs.symlinkJoin {
    name = "thunderbird";
    paths = [ pkgs.thunderbird ];
    postBuild = ''
      rm $out/bin/thunderbird
      cp ${pkgs.writeShellScript "thunderbird" ''
        TH_DIR="$HOME/files/apps/thunderbird"
        mkdir -p "$TH_DIR"
        exec env HOME="$TH_DIR" ${pkgs.thunderbird}/bin/thunderbird --profile "$HOME/files/apps/thunderbird" "$@"
      ''} $out/bin/thunderbird
    '';
  };
in {
  environment.systemPackages = [ wrapper ];
}
