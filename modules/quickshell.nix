{ config, pkgs, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs { inherit pkgs; };
  quickshellPackage = config.illogical-impulse.hyprland.quickshellPackage;
in
{
  config = lib.mkIf enabled {
    home.packages = [
      (selfPkgs.illogical-impulse-quickshell quickshellPackage)
    ];

    # QuickShell configuration
    home.file.".config/quickshell" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/quickshell";
      recursive = true;
    };
  };
}
