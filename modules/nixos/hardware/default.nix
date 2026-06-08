# 硬件模块聚合
# 各主机按需导入此目录下的子模块
{
  imports = [
    ./bluetooth.nix
    ./audio.nix
    ./network.nix
  ];
}
