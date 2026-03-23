{
  pkgs,
}:
let
  inherit (pkgs) lib;
in
lib.fix (self: {
  illogical-impulse-dotfiles = pkgs.callPackage ./illogical-impulse-dotfiles {};
  illogical-impulse-quickshell = quickshellPackage: pkgs.callPackage ./illogical-impulse-quickshell { inherit quickshellPackage; };
  illogical-impulse-hyprland-shaders = pkgs.callPackage ./illogical-impulse-hyprland-shaders {};
  illogical-impulse-kvantum = pkgs.callPackage ./illogical-impulse-kvantum {};
})
