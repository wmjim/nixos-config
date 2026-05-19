- 参考 ((20260518222417-d6qjhfi 'nix-instantiate'))

```bash
echo 1 + 2 > file.nix
nix-instantiate --eval file.nix
```