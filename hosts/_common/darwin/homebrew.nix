# macOS Homebrew 配置（可选）
{ config, pkgs, ... }:

{
  # 需要安装 nix-homebrew 或手动安装 Homebrew
  # 这里只是一个示例配置
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
    ];

    # GUI 应用
    casks = [
      "ghostty"
      "visual-studio-code"
      "obsidian"
    ];

    # 字体
    caskArgs = {
      fontdir = "/Library/Fonts";
    };
  };
}
