{ config, lib, pkgs, ... }:
let
  hypr = config.illogical-impulse.hyprland.package;
  hypr-xdg = config.illogical-impulse.hyprland.xdgPortalPackage;
  selfPkgs = import ../pkgs { inherit pkgs; };
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

    # Deploy custom/ directory (user-editable override templates)
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

    # Workspaces.conf - create via home.file then make mutable in activation
    home.file.".config/hypr/workspaces.conf".text = "# Managed by nwg-displays\n";
    home.activation.hyprWorkspacesMutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ws="$HOME/.config/hypr/workspaces.conf"
      # If it's a symlink (from home.file), replace with a real file so nwg-displays can edit it
      if [ -L "$ws" ]; then
        mv "$ws" "$ws.bak"
        cat "$ws.bak" > "$ws"
        rm "$ws.bak"
        chmod u+w "$ws"
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
