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
