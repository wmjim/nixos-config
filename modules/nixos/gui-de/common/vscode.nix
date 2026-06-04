{ pkgs, ... }:

{

  programs.vscode = {
    enable = true;
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
