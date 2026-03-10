quickshell: { lib, pkgs, ... }:
{
  options.illogical-impulse = {
    enable = lib.mkEnableOption "Enable illogical-impulse";
    hyprland = {
      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ",preferred,auto,1" ];
        description = "Monitor preferences for Hyprland";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hyprland;
        description = "Hyprland package";
      };
      xdgPortalPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xdg-desktop-portal-hyprland;
        description = "xdg-desktop-portal package for Hyprland";
      };
      quickshellPackage = lib.mkOption {
        type = lib.types.package;
        default = quickshell.packages.${pkgs.system}.quickshell;
        description = "QuickShell package (unwrapped)";
      };
      ozoneWayland.enable = lib.mkEnableOption "Set NIXOS_OZONE_WL=1";
    };
    theme = {
      cursor = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bibata-cursors;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Classic";
        };
      };
    };
  };
}
