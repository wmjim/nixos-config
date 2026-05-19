## 命令

`nix-collect-garbage` - 删除不再使用的存储对象

## 示例

```bash
# 1. 以root身份删除所有旧版本的配置文件。
sudo nix-collect-garbage --delete-old
```