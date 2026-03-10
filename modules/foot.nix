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
