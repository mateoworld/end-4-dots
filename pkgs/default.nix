{
  quickshell,
  pkgs,
}:
let
  inherit (pkgs) lib;
in
lib.fix (self: {
  illogical-impulse-dotfiles = pkgs.callPackage ./illogical-impulse-dotfiles {};
  illogical-impulse-quickshell = pkgs.callPackage ./illogical-impulse-quickshell { inherit quickshell; };
  illogical-impulse-hyprland-shaders = pkgs.callPackage ./illogical-impulse-hyprland-shaders {};
  illogical-impulse-kvantum = pkgs.callPackage ./illogical-impulse-kvantum {};
})
