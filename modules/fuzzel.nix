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
    home.packages = [ pkgs.fuzzel ];

    home.file.".config/fuzzel" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/fuzzel";
      recursive = true;
    };
  };
}
