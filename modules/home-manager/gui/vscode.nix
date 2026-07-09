# VSCode 编辑器
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.vscode;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.vscode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 VSCode 编辑器";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # Stylix 不接管 VS Code 主题
    stylix.targets.vscode.enable = lib.mkForce false;

    programs.vscode = {
      enable = true;
      mutableExtensionsDir = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          anthropic.claude-code
          vscode-icons-team.vscode-icons
          alefragnani.bookmarks
          jeff-hykin.better-nix-syntax
          jnoortheen.nix-ide
          ms-python.python
          llvm-vs-code-extensions.vscode-clangd
          donjayamanne.githistory
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          vscodevim.vim
          # TOML 完整性特性支持
          tamasfe.even-better-toml
          # Rust 支持
          rust-lang.rust-analyzer
          # 管理 Rust 依赖
          fill-labs.dependi
        ];
      };
    };
  };
}
