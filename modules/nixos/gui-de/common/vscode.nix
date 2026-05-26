{ pkgs, ... }:

let
  # 从VS Code包装器中移除引发警告的Chromium命令行标志。
  # 这些标志在 Chromium 142（Electron 39）中均为默认值，且环境变量 NIXOS_OZONE_WL / ELECTRON_OZONE_PLATFORM_HINT 已全局设置。
  vscode-fixed = pkgs.vscode.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      # Remove Chromium flags that generate warnings in VS Code's argument parser
      for f in "$out/bin/"*; do
        if [ -f "$f" ] && grep -q 'ozone-platform-hint' "$f" 2>/dev/null; then
          substituteInPlace "$f" \
            --replace-quiet '--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3' \
            ""
        fi
      done
    '';
  });
in
{
    environment.systemPackages = with pkgs; [
        (vscode-with-extensions.override {
            vscode = vscode-fixed;
            vscodeExtensions = with vscode-extensions; [
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
        })
    ];
}