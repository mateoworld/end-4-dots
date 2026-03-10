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
    home.packages = [ hypr ];

    xdg.portal = {
      enable = true;
      extraPortals = [ hypr-xdg ];
      config.common.default = [ "hyprland" "gtk" ];
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
    home.activation.hyprCustomSkeleton = lib.hm.dag.entryAfter ["writeBoundary"] ''
      hypr_custom="$HOME/.config/hypr/custom"
      if [ ! -d "$hypr_custom" ]; then
        mkdir -p "$hypr_custom"
        cp -r "${dotfiles}/hypr/custom/"* "$hypr_custom/"
        chmod -R u+w "$hypr_custom"
      fi
    '';

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
    home.activation.hyprWorkspaces = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ws="$HOME/.config/hypr/workspaces.conf"
      if [ ! -f "$ws" ]; then
        touch "$ws"
      fi
    '';

    # Shaders
    home.file.".config/hypr/shaders" = {
      source = "${selfPkgs.illogical-impulse-hyprland-shaders}";
    };

    # Kvantum theme
    home.file.".config/Kvantum" = {
      source = "${selfPkgs.illogical-impulse-kvantum}";
      recursive = true;
    };

    # Wlogout config
    home.file.".config/wlogout" = {
      source = "${dotfiles}/wlogout";
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
