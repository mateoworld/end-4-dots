{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    # hypridle package only — config is deployed from upstream dotfiles in hyprland.nix
    # We don't use services.hypridle.enable because upstream's config references
    # QuickShell IPC commands that are better kept as raw config
    home.packages = [ pkgs.hypridle ];
  };
}
