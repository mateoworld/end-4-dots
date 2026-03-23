# QuickShell Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite end-4-dots to use QuickShell instead of AGS, matching upstream end-4/dots-hyprland's current architecture.

**Architecture:** Clean rewrite of bigsaltyfishes fork. Deploy upstream dotfiles directly instead of Nix-generating configs. Wrap QuickShell with Qt6 deps. Expose as a home-manager module with configurable options.

**Tech Stack:** Nix flakes, home-manager, QuickShell, Hyprland, KDE ecosystem

**Design doc:** `docs/plans/2026-03-09-quickshell-migration-design.md`

---

### Task 1: Rewrite `flake.nix`

**Files:**
- Modify: `flake.nix`

**Step 1: Rewrite flake.nix**

Replace AGS input with QuickShell. Update outputs to pass `quickshell` instead of `ags`.

```nix
{
  description = "Illogical Impulse Hyprland Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "github:quickshell-mirror/quickshell/db1777c20b936a86528c1095cbcb1ebd92801402";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, quickshell, anyrun, systems, ... }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);
  in {
    legacyPackages = eachSystem (
      system:
      import ./pkgs {
        pkgs = nixpkgs.legacyPackages.${system};
        inherit quickshell;
      }
    );
    homeManagerModules.default = import ./modules self anyrun quickshell;
  };
}
```

**Step 2: Commit**

```bash
git add flake.nix
git commit -m "flake: replace AGS input with QuickShell"
```

---

### Task 2: Create `illogical-impulse-dotfiles` package

**Files:**
- Create: `pkgs/illogical-impulse-dotfiles/default.nix`

**Step 1: Get the upstream commit hash and sha256**

First, identify the latest stable commit from end-4/dots-hyprland main branch:

```bash
gh api repos/end-4/dots-hyprland/commits/main --jq '.sha'
```

Then prefetch:

```bash
nix-prefetch-url --unpack "https://github.com/end-4/dots-hyprland/archive/<COMMIT>.tar.gz"
```

Or use `nix flake prefetch` / `nix-prefetch-fetchFromGitHub` if available. Alternatively, use `lib.fakeHash` initially and let the build error reveal the correct hash.

**Step 2: Write the package**

```nix
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "illogical-impulse-dotfiles";
  version = "latest";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "<COMMIT_HASH>";
    sha256 = lib.fakeHash;
    fetchSubmodules = true;  # needed for quickshell/ii/modules/common/widgets/shapes
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r dots/.config/* $out/
  '';

  meta = {
    description = "Illogical Impulse dotfiles from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
```

**Step 3: Build to get correct hash, update sha256**

```bash
cd /home/mateo/Documents/gh/end-4-dots
nix build .#illogical-impulse-dotfiles 2>&1 | grep "got:"
```

Update the sha256 with the correct hash from the error output.

**Step 4: Commit**

```bash
git add pkgs/illogical-impulse-dotfiles/default.nix
git commit -m "pkgs: add illogical-impulse-dotfiles package"
```

---

### Task 3: Create `illogical-impulse-quickshell` package

**Files:**
- Create: `pkgs/illogical-impulse-quickshell/default.nix`

**Step 1: Write the package**

Adapted from upstream's `sdata/dist-nix/home-manager/quickshell.nix`:

```nix
{ pkgs, quickshell, ... }:
let
  qs = quickshell.packages.x86_64-linux.default;
in pkgs.stdenv.mkDerivation {
  name = "illogical-impulse-quickshell";
  meta = with pkgs.lib; {
    description = "QuickShell wrapped with Qt deps for NixOS";
    license = licenses.gpl3Only;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qs
    kdePackages.qtwayland
    kdePackages.qtpositioning
    kdePackages.qtlocation
    kdePackages.syntax-highlighting
    gsettings-desktop-schemas
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qt5compat
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtquicktimeline
    qt6.qtsensors
    qt6.qtsvg
    qt6.qttools
    qt6.qttranslations
    qt6.qtvirtualkeyboard
    qt6.qtwayland
    kdePackages.kirigami
    kdePackages.kdialog
    kdePackages.syntax-highlighting
  ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${qs}/bin/qs $out/bin/qs \
      --prefix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}
    chmod +x $out/bin/qs
  '';
}
```

**Note:** This package takes `quickshell` as a parameter passed from `pkgs/default.nix`, NOT from nixpkgs. The QuickShell flake input is passed through.

**Step 2: Commit**

```bash
git add pkgs/illogical-impulse-quickshell/default.nix
git commit -m "pkgs: add illogical-impulse-quickshell wrapper package"
```

---

### Task 4: Update existing packages and `pkgs/default.nix`

**Files:**
- Modify: `pkgs/default.nix`
- Modify: `pkgs/illogical-impulse-hyprland-shaders/default.nix`
- Modify: `pkgs/illogical-impulse-kvantum/default.nix`
- Delete: `pkgs/illogical-impulse-ags/default.nix`
- Delete: `pkgs/illogical-impulse-ags-launcher/default.nix` (and the launcher script)
- Delete: `pkgs/illogical-impulse-oneui4-icons/default.nix`

**Step 1: Rewrite `pkgs/default.nix`**

```nix
{
  quickshell,
  pkgs,
}:
let
  inherit (pkgs) lib;
in
lib.fix (self: {
  illogical-impulse-dotfiles = pkgs.callPackage ./illogical-impulse-dotfiles {};
  illogical-impulse-quickshell = pkgs.callPackage ./illogical-impulse-quickshell { inherit quickshell; };
  illogical-impulse-hyprland-shaders = pkgs.callPackage ./illogical-impulse-hyprland-shaders {};
  illogical-impulse-kvantum = pkgs.callPackage ./illogical-impulse-kvantum {};
})
```

**Step 2: Update `illogical-impulse-hyprland-shaders/default.nix`**

Change source to reference `illogical-impulse-dotfiles` or fetch from end-4 directly. Since shaders may not exist in current upstream (need to verify), update the fetchFromGitHub to use end-4/dots-hyprland at the same pinned commit:

```nix
{ lib, fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  pname = "illogical-impulse-hyprland-shaders";
  version = "latest";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "<SAME_COMMIT_HASH>";
    sha256 = "<SAME_SHA256>";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    if [ -d dots/.config/hypr/shaders ]; then
      cp -r dots/.config/hypr/shaders/* $out/
    fi
  '';

  meta = {
    description = "Hyprland Shaders from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
```

**Note:** Verify whether `dots/.config/hypr/shaders/` still exists in current upstream. If not, this package may need to be removed or made optional.

**Step 3: Update `illogical-impulse-kvantum/default.nix`**

Same pattern — update source to end-4/dots-hyprland, adjust path from `.config/Kvantum/` to `dots/.config/Kvantum/`:

```nix
{ lib, fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  pname = "illogical-impulse-kvantum";
  version = "latest";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "<SAME_COMMIT_HASH>";
    sha256 = "<SAME_SHA256>";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r dots/.config/Kvantum/* $out/

    runHook postInstall
  '';

  postInstall = ''
    mv $out/MaterialAdw/MaterialAdw.svg $out/MaterialAdw/MaterialAdw.svg.sample
    mv $out/MaterialAdw/MaterialAdw.kvconfig $out/MaterialAdw/MaterialAdw.kvconfig.sample
  '';

  meta = {
    description = "Kvantum theme from end-4/dots-hyprland";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3;
  };
}
```

**Step 4: Delete obsolete packages**

```bash
rm -rf pkgs/illogical-impulse-ags/
rm -rf pkgs/illogical-impulse-ags-launcher/
rm -rf pkgs/illogical-impulse-oneui4-icons/
```

**Step 5: Commit**

```bash
git add -A pkgs/
git commit -m "pkgs: rewrite package set for QuickShell, remove AGS packages"
```

---

### Task 5: Rewrite `modules/options.nix`

**Files:**
- Modify: `modules/options.nix`

**Step 1: Rewrite options.nix**

Replace `agsPackage` with `quickshellPackage`:

```nix
quickshell: { lib, pkgs, ... }:
{
  options.illogical-impulse = {
    enable = lib.mkEnableOption "Enable illogical-impulse";
    hyprland = {
      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ",preferred,auto,1" ];
        description = "Monitor preferences for Hyprland";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hyprland;
        description = "Hyprland package";
      };
      xdgPortalPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xdg-desktop-portal-hyprland;
        description = "xdg-desktop-portal package for Hyprland";
      };
      quickshellPackage = lib.mkOption {
        type = lib.types.package;
        default = quickshell.packages.${pkgs.system}.default;
        description = "QuickShell package (unwrapped)";
      };
      ozoneWayland.enable = lib.mkEnableOption "Set NIXOS_OZONE_WL=1";
    };
    theme = {
      cursor = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bibata-cursors;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Classic";
        };
      };
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/options.nix
git commit -m "modules: rewrite options.nix for QuickShell"
```

---

### Task 6: Rewrite `modules/default.nix`

**Files:**
- Modify: `modules/default.nix`

**Step 1: Update imports**

```nix
self: anyrun: quickshell: { ... }:
{
  imports = [
    (import ./options.nix quickshell)
    (import ./anyrun.nix anyrun)
    ./quickshell.nix
    ./hyprland.nix
    ./kitty.nix
    ./fish.nix
    ./hypridle.nix
    ./fuzzel.nix
    ./foot.nix
    ./packages.nix
    ./hyprlock.nix
    ./theme.nix
  ];
}
```

**Step 2: Commit**

```bash
git add modules/default.nix
git commit -m "modules: update default.nix imports for QuickShell migration"
```

---

### Task 7: Create `modules/quickshell.nix`

**Files:**
- Create: `modules/quickshell.nix`
- Delete: `modules/ags.nix`

**Step 1: Write quickshell.nix**

```nix
{ config, pkgs, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    home.packages = [
      selfPkgs.illogical-impulse-quickshell
    ];

    # QuickShell configuration
    home.file.".config/quickshell" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/quickshell";
      recursive = true;
    };
  };
}
```

**Note:** `selfPkgs` here passes the QuickShell package option through to `pkgs/default.nix`, which passes it to `illogical-impulse-quickshell`. This is awkward because `pkgs/default.nix` receives the raw quickshell flake, not the unwrapped package. This needs careful wiring — the `quickshell` parameter in `pkgs/default.nix` should be the flake output, and `illogical-impulse-quickshell/default.nix` extracts `.packages.x86_64-linux.default` from it. Revisit the exact wiring during implementation.

**Step 2: Delete ags.nix**

```bash
rm modules/ags.nix
```

**Step 3: Commit**

```bash
git add modules/quickshell.nix
git rm modules/ags.nix
git commit -m "modules: add quickshell.nix, remove ags.nix"
```

---

### Task 8: Rewrite `modules/hyprland.nix`

**Files:**
- Modify: `modules/hyprland.nix`

This is the biggest change. The current 500+ line Nix-generated config is replaced by deploying upstream's dotfiles directly.

**Step 1: Rewrite hyprland.nix**

```nix
{ config, lib, pkgs, ... }:
let
  hypr = config.illogical-impulse.hyprland.package;
  hypr-xdg = config.illogical-impulse.hyprland.xdgPortalPackage;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
  enabled = config.illogical-impulse.enable;
  hyprlandConf = config.illogical-impulse.hyprland;
  dotfiles = selfPkgs.illogical-impulse-dotfiles;

  # Generate monitors.conf content from module options
  monitorsConf = lib.concatStringsSep "\n"
    (map (m: "monitor=${m}") hyprlandConf.monitor);
in
{
  config = lib.mkIf enabled {
    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      xwayland.enable = true;
      package = hypr;
      portalPackage = hypr-xdg;
      # No settings — config is deployed from upstream dotfiles
      settings = {};
      extraConfig = "";
    };

    # Deploy upstream hyprland config files
    home.file.".config/hypr/hyprland.conf" = {
      source = "${dotfiles}/hypr/hyprland.conf";
    };
    home.file.".config/hypr/hyprland" = {
      source = "${dotfiles}/hypr/hyprland";
      recursive = true;
    };

    # Deploy custom/ skeleton (user-editable overrides)
    home.file.".config/hypr/custom" = {
      source = "${dotfiles}/hypr/custom";
      recursive = true;
    };

    # Deploy hypridle and hyprlock configs from upstream
    home.file.".config/hypr/hypridle.conf" = {
      source = "${dotfiles}/hypr/hypridle.conf";
    };
    home.file.".config/hypr/hyprlock.conf" = {
      source = "${dotfiles}/hypr/hyprlock.conf";
    };
    home.file.".config/hypr/hyprlock" = {
      source = "${dotfiles}/hypr/hyprlock";
      recursive = true;
    };

    # Nix-generated monitor config
    home.file.".config/hypr/monitors.conf" = {
      text = monitorsConf;
    };

    # Empty workspaces.conf for nwg-displays compatibility
    home.file.".config/hypr/workspaces.conf" = {
      text = "";
    };

    # Shaders
    home.file.".config/hypr/shaders" = {
      source = "${selfPkgs.illogical-impulse-hyprland-shaders}";
    };

    # Kvantum theme
    home.file.".config/Kvantum" = {
      source = "${selfPkgs.illogical-impulse-kvantum}";
      recursive = true;
    };

    # Environment variables for NixOS specifics
    home.sessionVariables = lib.mkIf hyprlandConf.ozoneWayland.enable {
      NIXOS_OZONE_WL = "1";
    };

    # GTK and Qt theming
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };
    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "kvantum";
    };
  };
}
```

**Key differences from current:**
- No `wayland.windowManager.hyprland.settings` block (no Nix-generated keybinds/animations/rules)
- Config deployed via `home.file` from dotfiles package
- Hypridle/hyprlock configs deployed from upstream dotfiles (not Nix-generated)
- Qt platform theme changed from `qt5ct` to `kde` to match upstream
- `monitors.conf` generated from module option

**Step 2: Commit**

```bash
git add modules/hyprland.nix
git commit -m "modules: rewrite hyprland.nix to deploy upstream configs directly"
```

---

### Task 9: Rewrite `modules/packages.nix`

**Files:**
- Modify: `modules/packages.nix`

**Step 1: Rewrite packages.nix**

Full dependency list from upstream's `home.nix`:

```nix
{ config, pkgs, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    home = {
      packages = with pkgs; [
        # Basic CLI & system
        inetutils
        libnotify
        dbus
        xorg.xlsclients
        bc
        uutils-coreutils-noprefix
        cliphist
        cmake
        curlFull
        wget
        ripgrep
        jq
        xdg-user-dirs
        rsync
        yq-go

        # Audio
        libcava
        lxqt.pavucontrol-qt
        wireplumber
        pipewire
        libdbusmenu-gtk3
        playerctl

        # Backlight
        (geoclue2.override { withDemoAgent = true; })
        brightnessctl
        ddcutil

        # Hyprland ecosystem
        hyprsunset
        wl-clipboard
        hyprpicker
        hyprshot

        # KDE integration
        kdePackages.bluedevil
        kdePackages.plasma-nm
        kdePackages.dolphin
        kdePackages.systemsettings
        kdePackages.kconfig

        # Fonts & themes
        adw-gtk3
        kdePackages.breeze
        kdePackages.breeze-icons
        darkly
        darkly-qt5
        eza
        fontconfig
        matugen
        starship
        nerd-fonts.jetbrains-mono
        material-symbols
        rubik
        twemoji-color-font

        # Screen capture
        slurp
        swappy
        tesseract
        wf-recorder

        # Python / build
        uv
        gtk4
        libadwaita
        libsoup_3
        libportal-gtk4
        gobject-introspection

        # Widgets & tools
        fuzzel
        glib
        imagemagick
        hypridle
        songrec
        translate-shell
        wlogout
        libqalculate
        upower
        wtype
        ydotool

        # Terminals
        foot
        kitty

        # Cursor
        bibata-cursors
      ];
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/packages.nix
git commit -m "modules: rewrite packages.nix with upstream dependency set"
```

---

### Task 10: Create `modules/fish.nix` and delete `modules/zsh.nix`

**Files:**
- Create: `modules/fish.nix`
- Delete: `modules/zsh.nix`

**Step 1: Write fish.nix**

Based on upstream's `config.fish`:

```nix
{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # No greeting
        set fish_greeting

        # Use starship prompt
        starship init fish | source

        # Load QuickShell-generated terminal color scheme
        if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
            cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        end

        # Aliases
        alias clear "printf '\033[2J\033[3J\033[1;1H'"
        alias ls 'eza --icons'
        alias q 'qs -c ii'
      '';
    };

    # Deploy upstream fish config files
    home.file.".config/fish/auto-Hypr.fish" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/fish/auto-Hypr.fish";
    };
  };
}
```

**Step 2: Delete zsh.nix**

```bash
rm modules/zsh.nix
```

**Step 3: Commit**

```bash
git add modules/fish.nix
git rm modules/zsh.nix
git commit -m "modules: add fish.nix, remove zsh.nix (upstream uses fish)"
```

---

### Task 11: Rename `modules/fuzzle.nix` to `modules/fuzzel.nix` and update

**Files:**
- Delete: `modules/fuzzle.nix`
- Create: `modules/fuzzel.nix`

**Step 1: Write fuzzel.nix**

Deploy upstream fuzzel config from dotfiles instead of Nix-generating it:

```nix
{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    home.file.".config/fuzzel" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/fuzzel";
      recursive = true;
    };
  };
}
```

**Step 2: Delete fuzzle.nix**

```bash
rm modules/fuzzle.nix
```

**Step 3: Commit**

```bash
git add modules/fuzzel.nix
git rm modules/fuzzle.nix
git commit -m "modules: rename fuzzle.nix to fuzzel.nix, deploy from dotfiles"
```

---

### Task 12: Update `modules/foot.nix`

**Files:**
- Modify: `modules/foot.nix`

**Step 1: Update foot.nix**

Deploy from dotfiles instead of Nix-generating config. Upstream uses fish shell, JetBrainsMono font:

```nix
{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    home.file.".config/foot" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/foot";
      recursive = true;
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/foot.nix
git commit -m "modules: update foot.nix to deploy from dotfiles"
```

---

### Task 13: Update `modules/kitty.nix`

**Files:**
- Modify: `modules/kitty.nix`

**Step 1: Update kitty.nix**

Deploy from dotfiles:

```nix
{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    home.file.".config/kitty" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/kitty";
      recursive = true;
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/kitty.nix
git commit -m "modules: update kitty.nix to deploy from dotfiles"
```

---

### Task 14: Update `modules/theme.nix`

**Files:**
- Modify: `modules/theme.nix`

**Step 1: Update theme.nix**

Update cursor default name, add matugen config deployment:

```nix
{ config, pkgs, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
  cursor = config.illogical-impulse.theme.cursor;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    # Fonts
    fonts.fontconfig.enable = true;

    # Cursor
    home.sessionVariables = {
      XCURSOR_THEME = cursor.name;
      XCURSOR_SIZE = 24;
    };

    home.pointerCursor = {
      package = cursor.package;
      name = cursor.name;
      size = 24;
      gtk.enable = true;
    };

    # Matugen config (replaces gradience/pywal for color generation)
    home.file.".config/matugen" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/matugen";
      recursive = true;
    };

    # KDE Material You Colors config
    home.file.".config/kde-material-you-colors" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/kde-material-you-colors";
      recursive = true;
    };
  };
}
```

**Step 2: Commit**

```bash
git add modules/theme.nix
git commit -m "modules: update theme.nix with matugen and KDE color config"
```

---

### Task 15: Simplify `modules/hyprlock.nix` and `modules/hypridle.nix`

**Files:**
- Modify: `modules/hyprlock.nix`
- Modify: `modules/hypridle.nix`

Since hyprland.nix now deploys upstream's `hyprlock.conf` and `hypridle.conf` directly, these modules can be simplified. The Nix-generated configs are replaced by upstream dotfiles.

**Step 1: Simplify hyprlock.nix**

The upstream hyprlock config is deployed in `hyprland.nix`. This module just needs to ensure `programs.hyprlock.enable = true` (already done in hyprland.nix). Check if there's any remaining purpose for this module. If hyprland.nix handles everything, this module can be removed from imports.

However, the `hyprlock-background` script might still be useful. Check if upstream still uses a similar pattern. Upstream's `hypridle.conf` uses `hyprctl dispatch global quickshell:lock & pidof qs quickshell hyprlock || hyprlock` — so lock is handled by QuickShell with hyprlock as fallback. The `hyprlock-background` script from the old fork uses `swww` which upstream no longer seems to use in the same way.

**Decision:** Remove the old `hyprlock-background` script. Upstream handles lock screen via QuickShell + hyprlock fallback. Simplify:

```nix
{ config, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    programs.hyprlock.enable = true;
  };
}
```

**Step 2: Simplify hypridle.nix**

Upstream's hypridle.conf is deployed via `hyprland.nix`. This module just enables the service:

```nix
{ config, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    services.hypridle.enable = true;
  };
}
```

**Step 3: Remove duplicate enables from hyprland.nix**

After this, remove `programs.hyprlock.enable = true` and `services.hypridle.enable = true` from `modules/hyprland.nix` since they're handled by their own modules.

**Step 4: Commit**

```bash
git add modules/hyprlock.nix modules/hypridle.nix modules/hyprland.nix
git commit -m "modules: simplify hyprlock/hypridle, deploy upstream configs"
```

---

### Task 16: Update `modules/anyrun.nix`

**Files:**
- Modify: `modules/anyrun.nix`

**Step 1: Review anyrun.nix**

The current anyrun.nix looks fine as-is. It doesn't reference AGS and is independent. No changes needed unless the anyrun API has changed. Keep as-is.

**Step 2: Verify no changes needed**

No commit for this task if no changes are required.

---

### Task 17: Deploy additional upstream dotfile configs

**Files:**
- Modify: `modules/hyprland.nix` or create new modules

**Step 1: Deploy remaining upstream configs**

Upstream has several config directories we should deploy:
- `.config/starship.toml`
- `.config/wlogout/`
- `.config/fontconfig/`
- `.config/xdg-desktop-portal/`

Add to `hyprland.nix` or create a `modules/misc.nix`:

Add these `home.file` entries in the appropriate module:

```nix
# In theme.nix or a new misc.nix
home.file.".config/starship.toml" = {
  source = "${dotfiles}/starship.toml";
};
home.file.".config/wlogout" = {
  source = "${dotfiles}/wlogout";
  recursive = true;
};
home.file.".config/fontconfig" = {
  source = "${dotfiles}/fontconfig";
  recursive = true;
};
```

**Step 2: Commit**

```bash
git add modules/
git commit -m "modules: deploy additional upstream config files"
```

---

### Task 18: Update `flake.lock`

**Files:**
- Modify: `flake.lock`

**Step 1: Update flake lock**

```bash
nix flake update
```

**Step 2: Commit**

```bash
git add flake.lock
git commit -m "flake: update flake.lock with QuickShell and new inputs"
```

---

### Task 19: Test build

**Step 1: Try building packages**

```bash
nix build .#illogical-impulse-dotfiles
nix build .#illogical-impulse-quickshell
nix build .#illogical-impulse-kvantum
```

**Step 2: Fix any build errors**

Address hash mismatches, missing dependencies, path issues. This is expected to take a few iterations.

**Step 3: Verify the module evaluates**

```bash
nix eval .#homeManagerModules.default --apply 'x: "ok"'
```

**Step 4: Commit fixes**

```bash
git add -A
git commit -m "fix: resolve build issues from migration"
```

---

### Task 20: Update README

**Files:**
- Modify: `README.md` (if it exists, otherwise create)

**Step 1: Update README**

Add credit to bigsaltyfishes, document the QuickShell migration, update usage instructions. Mention that this module now requires QuickShell instead of AGS and follows the upstream KDE ecosystem.

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README for QuickShell migration"
```
