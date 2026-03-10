{ config, lib, pkgs, ... }:
let
  enabled = config.illogical-impulse.enable;
  selfPkgs = import ../pkgs {
    inherit pkgs;
    quickshell = config.illogical-impulse.hyprland.quickshellPackage;
  };
in
{
  config = lib.mkIf enabled {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # No greeting
        set fish_greeting

        # Use starship prompt
        starship init fish | source

        # Load QuickShell-generated terminal color scheme
        if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
            cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        end

        # Aliases
        alias clear "printf '\\033[2J\\033[3J\\033[1;1H'"
        alias ls 'eza --icons'
        alias q 'qs -c ii'
      '';
    };

    # Deploy upstream fish config files
    home.file.".config/fish/auto-Hypr.fish" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/fish/auto-Hypr.fish";
    };
  };
}
