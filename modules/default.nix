self: anyrun: quickshell: { ... }:
{
  imports = [
    (import ./options.nix quickshell)
    (import ./anyrun.nix anyrun)
    ./quickshell.nix
    ./hyprland.nix
    ./kitty.nix
    ./fish.nix
    ./hypridle.nix
    ./fuzzel.nix
    ./foot.nix
    ./packages.nix
    ./hyprlock.nix
    ./theme.nix
  ];
}
