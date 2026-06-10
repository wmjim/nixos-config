{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    # mutableExtensionsDir 默认为 true，允许从 VSCode 市场直接安装扩展
    # Nix 管理的扩展会以符号链接形式放在 ~/.vscode/extensions/ 中
    mutableExtensionsDir = true;

    extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      vscode-icons-team.vscode-icons
      alefragnani.bookmarks
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      ms-python.python
      llvm-vs-code-extensions.vscode-clangd
      tamasfe.even-better-toml
      donjayamanne.githistory
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
    ];
  };
}
