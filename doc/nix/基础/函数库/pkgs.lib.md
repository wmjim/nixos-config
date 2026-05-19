[`nixpkgs`](https://github.com/NixOS/nixpkgs) 仓库包含一个名为 [`lib`](https://github.com/NixOS/nixpkgs/blob/master/lib/default.nix) 的属性集，它提供了大量有用的函数。

Nixpkgs 的属性集通常约定命名为 `pkgs`，通过 `pkgs.lib` 使用这些函数。

```nix
let
  pkgs = import <nixpkgs> {};
in
pkgs.lib.strings.toUpper "Have a good day!"
# "HAVE A GOOD DAY!"
```