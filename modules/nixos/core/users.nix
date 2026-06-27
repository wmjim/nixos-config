# NixOS 用户配置（带 options）
# 主机可在 default.nix 中覆盖 mySystem.users.<name> 来定制用户
{ lib, config, pkgs, ... }:
{
  options.mySystem.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "此用户";
        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "用户附加组";
        };
        shell = lib.mkOption {
          type = lib.types.package;
          default = pkgs.fish;
          description = "用户默认 Shell";
        };
      };
    });
    default = { };
    description = "系统用户定义";
  };

  config = {
    # 默认用户 mengw
    mySystem.users.mengw = {
      enable = true;
      # 用户组
      extraGroups = [
        "wheel"       # 允许使用sudo以管理员权限执行命令
        "audio"
        "video"
        "render"
        "input"
        "network"     # 赋予网络配置权限
        "libvirtd"
        "kvm"
        "i2c"
      ];
    };

    # 启用 fish
    programs.fish.enable = true;

    # 创建用户
    users.users = lib.mapAttrs'
      (name: cfg:
        lib.nameValuePair name (lib.mkIf cfg.enable {
          # 标识该用户为真实用户，系统自动将 group 设置为 users
          isNormalUser = true;
          extraGroups = cfg.extraGroups;
          shell = cfg.shell;
        })
      )
      config.mySystem.users;
  };
}
