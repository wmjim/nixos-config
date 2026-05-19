`import` 接受是 Nix 文件的路径 作为参数，会对其进行文件求值并返回结果。

此路径也可以是目录，这种情况下则会使用该目录下的 `default.nix` 文件。

```nix
# foo.nix
1 + 2

import ./foo.nix # 3

# foo.nix
x: x + 1

import ./foo.nix 4
```