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
