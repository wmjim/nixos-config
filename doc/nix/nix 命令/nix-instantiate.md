## 命令

`nix-instantiate` - 从 Nix 表达式实例化存储派生。

## 示例

```bash
echo 1 + 2 > file.nix
nix-instantiate --eval file.nix
```


## 常用选项

### `--eval`

仅解析并评估输入文件，将结果值打印至标准输出。存储派生不会被序列化并写入存储，而是仅进行哈希处理后丢弃。

若未指定文件名，会尝试读取 `default.nix` 。