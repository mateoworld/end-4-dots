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
