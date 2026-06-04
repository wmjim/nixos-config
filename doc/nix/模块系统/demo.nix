{ config, pkgs, ... }: # 这些参数由构建系统自动输入，你先别管

{
  /*
    我们开始在下面的 options 属性集中声明这个模块的选项了，
    你可以将模块声明成你任意喜欢的名字，这里示例用 “myModule”，注意小驼峰规范。
    同时请注意一件事，那就是模块名称只取决于现在你在 options 的命名，而不是该模块的文件名，
    我们将模块命名与文件名一致也是出于直观？
    */

  options = {
    myModule.enable = mkOption {
      type = types.bool; # 此选项的类型是布尔类型
      default = false; # 默认情况下，此选项被禁用
      description = "描述一下这个模块";
    };
  };

  config = mkIf config.myModule.enable {
    systemd.services.myService = {
      # 创建新的 systemd 服务
      wantedBy = [ "multi-user.target" ]; # 此服务希望在多用户目标下启动
      script = ''  # 服务启动时运行此脚本
                echo "Hello, NixOS!"
            '';
    };
  };
}
