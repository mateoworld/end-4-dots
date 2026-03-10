{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    # hyprlock package only — config is deployed from upstream dotfiles in hyprland.nix
    # We don't use programs.hyprlock.enable because upstream's config uses
    # source= directives and external scripts that can't be expressed in Nix
    home.packages = [ pkgs.hyprlock ];
  };
}
