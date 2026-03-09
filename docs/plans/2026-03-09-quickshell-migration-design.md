# QuickShell Migration Design

## Context

The end-4-dots fork (originally bigsaltyfishes/end-4-dots) packages end-4/dots-hyprland
for NixOS as a home-manager module. The upstream project has migrated from AGS (Aylur's
GTK Shell) v1 to QuickShell, a QML-based shell. This fork is pinned to a May 2025 commit
and all AGS-based code is now obsolete. The fork fails to build because dependencies like
gradience, pywal, materialyoucolor, and dart-sass are no longer used upstream.

## Decision

Clean rewrite (Approach 2) of the fork, using upstream's `sdata/dist-nix/home-manager/`
as reference for dependency mapping and QuickShell packaging. The bigsaltyfishes module
architecture pattern is preserved, and credit is given in the README.

## Flake Structure

```
flake.nix
  inputs:
    nixpkgs          → github:nixos/nixpkgs/nixos-unstable
    quickshell       → github:quickshell-mirror/quickshell/<pinned-commit>
    anyrun           → github:Kirottu/anyrun
  outputs:
    legacyPackages   → import ./pkgs { inherit pkgs quickshell; }
    homeManagerModules.default → import ./modules self anyrun quickshell
```

AGS flake input is removed entirely. QuickShell is pinned to commit
`db1777c20b936a86528c1095cbcb1ebd92801402` (same as upstream's flake). anyrun stays as
an independent launcher alternative.

## Package Structure (`pkgs/`)

```
pkgs/
├── default.nix
├── illogical-impulse-dotfiles/default.nix
├── illogical-impulse-quickshell/default.nix
├── illogical-impulse-hyprland-shaders/default.nix
└── illogical-impulse-kvantum/default.nix
```

### illogical-impulse-dotfiles

Fetches `dots/` from end-4/dots-hyprland at a pinned commit. Provides all upstream config
files (.config/quickshell, .config/hypr, .config/foot, .config/fuzzel, .config/kitty,
.config/Kvantum, .config/matugen, etc.) as a single derivation. Replaces the pattern where
multiple packages each fetched the same repo.

### illogical-impulse-quickshell

Adapted from upstream's `sdata/dist-nix/home-manager/quickshell.nix`. Wraps the QuickShell
flake package with `wrapQtAppsHook` and all required Qt6 dependencies:

- qt6.qtbase, qt6.qtdeclarative, qt6.qt5compat, qt6.qtimageformats
- qt6.qtmultimedia, qt6.qtpositioning, qt6.qtquicktimeline
- qt6.qtsensors, qt6.qtsvg, qt6.qttools, qt6.qttranslations
- qt6.qtvirtualkeyboard, qt6.qtwayland
- kdePackages.kirigami, kdePackages.kdialog, kdePackages.syntax-highlighting
- kdePackages.qtwayland, kdePackages.qtpositioning, kdePackages.qtlocation
- gsettings-desktop-schemas

Exposes `$out/bin/qs`.

### illogical-impulse-hyprland-shaders (updated)

Same structure, source changed from bigsaltyfishes/dots-hyprland to end-4/dots-hyprland.
Copies `dots/.config/hypr/shaders/`.

### illogical-impulse-kvantum (updated)

Same structure, source changed to end-4/dots-hyprland. Copies `dots/.config/Kvantum/`.

### Removed packages

- `illogical-impulse-ags` — AGS no longer used upstream
- `illogical-impulse-ags-launcher` — replaced by QuickShell launch
- `illogical-impulse-oneui4-icons` — already reverted

## Module Structure (`modules/`)

```
modules/
├── default.nix       # Updated imports
├── options.nix       # agsPackage → quickshellPackage
├── quickshell.nix    # NEW: replaces ags.nix
├── hyprland.nix      # REWRITTEN: deploy upstream configs directly
├── packages.nix      # REWRITTEN: new dependency set
├── hyprlock.nix      # Kept
├── hypridle.nix      # Kept
├── foot.nix          # Kept
├── kitty.nix         # Kept
├── theme.nix         # Kept/updated
├── fish.nix          # NEW: replaces zsh.nix
├── fuzzel.nix        # Renamed from fuzzle.nix
└── anyrun.nix        # Kept
```

### Removed modules

- `ags.nix` — replaced by quickshell.nix
- `zsh.nix` — upstream uses fish
- `fuzzle.nix` — renamed to fuzzel.nix

## Module Options

```nix
illogical-impulse = {
  enable = mkEnableOption;

  hyprland = {
    package = mkOption { default = pkgs.hyprland; };
    xdgPortalPackage = mkOption { default = pkgs.xdg-desktop-portal-hyprland; };
    quickshellPackage = mkOption {
      # Default: wrapped QuickShell from pkgs/illogical-impulse-quickshell
    };
    monitor = mkOption {
      type = listOf str;
      default = [ ",preferred,auto,1" ];
      # Written to ~/.config/hypr/monitors.conf
    };
    ozoneWayland.enable = mkEnableOption;
  };

  theme.cursor = {
    package = mkOption { default = pkgs.bibata-cursors; };
    name = mkOption { default = "Bibata-Modern-Classic"; };
  };
};
```

## Hyprland Config Strategy

Upstream's keybinds now use Hyprland's `global` dispatcher with QuickShell IPC signals
(e.g., `global, quickshell:searchToggleRelease`), new bind types (`bindid`, `bindit`,
`binditn`, `bindp`), complex fallback chains, `$qsConfig` variable references, and
submaps. This cannot be practically expressed in Nix's `wayland.windowManager.hyprland.settings`.

**Decision:** Deploy upstream's config files directly instead of generating them in Nix.

```
~/.config/hypr/
├── hyprland.conf          ← from dotfiles
├── hyprland/
│   ├── env.conf           ← from dotfiles
│   ├── execs.conf         ← from dotfiles
│   ├── general.conf       ← from dotfiles
│   ├── rules.conf         ← from dotfiles
│   ├── colors.conf        ← from dotfiles
│   ├── keybinds.conf      ← from dotfiles
│   └── scripts/           ← from dotfiles
├── custom/                ← skeleton deployed, user-editable
│   ├── env.conf
│   ├── execs.conf
│   ├── general.conf
│   ├── rules.conf
│   └── keybinds.conf
├── monitors.conf          ← Nix-generated from module option
├── workspaces.conf        ← empty, for nwg-displays
└── shaders/               ← from shaders package
```

Nix manages: monitor config, environment variables, custom/ skeleton.
Upstream manages: keybinds, execs, general settings, rules, colors.

## Dotfile Deployment Flow

```
end-4/dots-hyprland (pinned commit)
        │
        ▼
illogical-impulse-dotfiles (single fetch)
        │
        ├──► quickshell.nix   → home.file.".config/quickshell"
        ├──► hyprland.nix     → home.file.".config/hypr/{hyprland.conf,hyprland/}"
        ├──► foot.nix         → home.file.".config/foot"
        ├──► kitty.nix        → home.file.".config/kitty"
        ├──► fuzzel.nix       → home.file.".config/fuzzel"
        └──► theme.nix        → home.file.".config/matugen", ".config/Kvantum"
```

## Dependencies (packages.nix)

Full list from upstream's home.nix, grouped by purpose:

**Audio:** libcava, lxqt.pavucontrol-qt, wireplumber, pipewire, libdbusmenu-gtk3, playerctl

**Backlight:** geoclue2 (with demo agent), brightnessctl, ddcutil

**Basic CLI:** bc, uutils-coreutils-noprefix, cliphist, cmake, curlFull, wget, ripgrep, jq,
xdg-user-dirs, rsync, yq-go

**Fonts & Themes:** adw-gtk3, kdePackages.breeze, kdePackages.breeze-icons, darkly,
darkly-qt5, eza, fontconfig, kitty, matugen, starship, nerd-fonts.jetbrains-mono,
material-symbols, rubik, twemoji-color-font

**Hyprland:** hyprsunset, wl-clipboard, hypridle, hyprpicker, hyprshot

**KDE:** kdePackages.bluedevil, kdePackages.plasma-nm, kdePackages.dolphin,
kdePackages.systemsettings, kdePackages.kconfig

**Python/build:** uv, gtk4, libadwaita, libsoup_3, libportal-gtk4, gobject-introspection

**Screen capture:** slurp, swappy, tesseract, wf-recorder

**Widgets/tools:** fuzzel, glib, imagemagick, songrec, translate-shell, wlogout,
libqalculate, upower, wtype, ydotool

**Other:** inetutils, libnotify, dbus, xorg.xlsclients, foot, bibata-cursors, networkmanager

**Removed (no longer used upstream):** gradience, pywal, dart-sass, materialyoucolor,
material-color-utilities, pywayland, nautilus, gnome-control-center, gnome-tweaks,
gnome-system-monitor, gnome-text-editor, swww, easyeffects

## Source Pinning Strategy

All packages fetch from `end-4/dots-hyprland` at a single pinned commit. To update:

1. Pick a new upstream commit
2. Update the commit hash and sha256 in `illogical-impulse-dotfiles`
3. The shaders and kvantum packages reference the same dotfiles package (no duplicate fetches)
4. QuickShell commit is pinned separately in flake.nix (matches upstream's pin)

## Desktop Ecosystem

Follows upstream: KDE apps and portals (dolphin, kcmshell6, systemsettings, plasma-nm,
bluedevil). GNOME apps removed.
