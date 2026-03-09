{
  pkgs,
  quickshell,
}:
let
  inherit (pkgs) lib;
in
lib.fix(self: {
  illogical-impulse-ags = pkgs.callPackage ./illogical-impulse-ags {};
  illogical-impulse-dotfiles = pkgs.callPackage ./illogical-impulse-dotfiles {};
  illogical-impulse-hyprland-shaders = pkgs.callPackage ./illogical-impulse-hyprland-shaders {};
  illogical-impulse-kvantum = pkgs.callPackage ./illogical-impulse-kvantum {};
  illogical-impulse-oneui4-icons = pkgs.callPackage ./illogical-impulse-oneui4-icons {};
})
