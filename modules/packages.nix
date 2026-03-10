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
        eza
        starship

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
        fontconfig
        matugen
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
