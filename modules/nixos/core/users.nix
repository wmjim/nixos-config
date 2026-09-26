# NixOS 用户配置（带 options）
# 主机可在 default.nix 中覆盖 mySystem.users.<name> 来定制用户
{
  lib,
  config,
  pkgs,
  ...
}:
{
  # 主用户：configDir、trusted-users、home-manager 集成、keyd 组授权等
  # 系统级接线均由此派生（见 core/default.nix 与 flake.nix 的 mkHomeManager），
  # 改用户名只动这一处。
  options.mySystem.primaryUser = lib.mkOption {
    type = lib.types.str;
    default = "mengw";
    description = "主用户名：系统级接线（flake 路径、trusted-users、HM 集成）由此派生";
  };

  options.mySystem.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
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
      }
    );
    default = { };
    description = "系统用户定义";
  };

  config = {
    # 默认创建主用户（enable 用 mkDefault：主机可按需关闭）
    mySystem.users.${config.mySystem.primaryUser} = {
      enable = lib.mkDefault true;
      # 用户组
      extraGroups = [
        "wheel" # 允许使用sudo以管理员权限执行命令
        "audio"
        "video"
        "render"
        "input"
        "networkmanager" # NetworkManager polkit 规则授权的组，允许修改网络设置
        "libvirtd"
        "kvm"
        "i2c"
      ];
    };

    # 启用 fish
    programs.fish.enable = true;

    # 创建用户
    users.users = lib.mapAttrs' (
      name: cfg:
      lib.nameValuePair name (
        lib.mkIf cfg.enable {
          # 标识该用户为真实用户，系统自动将 group 设置为 users
          isNormalUser = true;
          extraGroups = cfg.extraGroups;
          shell = cfg.shell;
        }
      )
    ) config.mySystem.users;
  };
}
