# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Deploy a host
sudo nixos-rebuild switch --flake ~/nixos-config#desktop
sudo nixos-rebuild switch --flake ~/nixos-config#laptop
sudo nixos-rebuild switch --flake ~/nixos-config#wsl

# Verbose build (for debugging)
sudo nixos-rebuild switch --flake ~/nixos-config#desktop --show-trace --print-build-logs --verbose

# Format all Nix files
nix fmt                    # uses nixpkgs-fmt

# Update flake lock
nix flake update
nix flake update <input>   # update a single input

# Garbage collection
sudo nix-collect-garbage --delete-old

# Enter dev shell (git + nixpkgs-fmt)
nix develop
```

## Architecture

### Option-driven host configuration (`mySystem` namespace)

Rather than importing modules per-host, `modules/nixos/core/default.nix` defines an options namespace:

```nix
options.mySystem = {
  hardware.enable = ...;
  desktop.enable = ...;
  virtualization.enable = ...;
};
```

Each host in `hosts/` sets these boolean flags. Modules use `lib.mkIf config.mySystem.<foo>.enable` to conditionally activate. New features should follow this pattern: add an option in `core/default.nix`, gate the module on it, then toggle it in the host.

### Module layering

```
modules/
  nixos/core/          Always imported on NixOS → users, locale, stylix, hardware, desktop, virtualization, networking
  nixos/desktop/       Gated on mySystem.desktop.enable → boot, GDM, env, niri, gnome, distrobox
  nixos/hardware/      Gated on mySystem.hardware.enable → audio (PipeWire), bluetooth, network (iwd+NM), NVIDIA base
  home-manager/        Per-user config, shared across NixOS and macOS
    cli/               Always loaded → shell (fish/starship), editors (helix/neovim), dev tools, TUI tools
    gui/               Only for desktop/laptop → apps, themes (fallback), wm (niri/noctalia), vscode, fcitx5
  darwin/              macOS-specific → system defaults, Homebrew casks
```

### `mkHomeManager` boilerplate

`flake.nix` defines a `mkHomeManager` function that generates the home-manager integration block shared by all NixOS hosts. GUI hosts pass `extraModules = [ ./modules/home-manager/gui ]`; headless/WSL hosts omit it. macOS has its own inline home-manager block (not using `mkHomeManager`) because it needs `lib.mkForce` on NUR overlays and different shared module setup.

### Stylix theming

Themes are defined inline in `modules/nixos/core/stylix.nix` (four custom base16 schemes: aurora-dark, claude-light, macos-light, macos-dark). The host selects the theme via `mySystem.stylix.theme`. Several Stylix targets are intentionally disabled:
- `fish` — base16 color commands override terminal themes
- `zen-browser` — manages its own theme
- `vscode` — manages its own theme

Niri WM colors are generated from Stylix at build time and written via `home.activation.niriStylixColors` into `layout.kdl` and `overview.kdl`.

### Hosts

| Host | System | Key features |
|------|--------|-------------|
| desktop | x86_64-linux | Niri WM, NVIDIA RTX 3060Ti, 4K@150Hz, custom EDID firmware |
| laptop | x86_64-linux | GNOME, NVIDIA MX150 (legacy driver, PRIME offload), btrfs, TLP |
| wsl | x86_64-linux | CLI-only, WSL container |
| server | x86_64-linux | Stub, only nixosCore |
| macbook | aarch64-darwin | nix-darwin, Homebrew casks |

### Platform quirks

- **China mirrors**: Both substituters and nixpkgs source use `mirrors.tuna.tsinghua.edu.cn` — expect slower downloads outside China unless mirrors are changed.
- **Fish 4.8.0 overlay**: `modules/home-manager/default.nix` patches fish to copy `create_manpage_completions.py` which was missing (nixpkgs#535122). Remove this overlay once the fix is upstreamed.
- **NVIDIA VRAM fix**: `modules/nixos/hardware/nvidia-base.nix` sets a Niri application profile limiting the free buffer pool to work around VRAM leaks.
- **Stylix release checks disabled**: Stylix follows unstable, but home-manager follows release-26.05; release checks must stay disabled.
- **`cuda-maintainers` cache**: Enabled for NVIDIA driver builds — need the public key trusted.
