{ config, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "Gabarito";
          terminal = "foot -e";
          prompt = ">>  ";
          layer = "overlay";
        };

        border = {
          radius = 17;
          width = 1;
        };

        dmenu = {
          exit-immediately-if-empty = "yes";
        };

        # Colors are omitted here - they will be managed by matugen/QuickShell
        # at runtime via fuzzel_theme.ini
      };
    };
  };
}
