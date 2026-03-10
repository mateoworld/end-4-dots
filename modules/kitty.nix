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
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrains Mono Nerd Font";
        size = 11;
      };
      settings = {
        cursor_shape = "beam";
        cursor_trail = 1;
        window_margin_width = "21.75";
        confirm_os_window_close = 0;
        shell = "fish";
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+f" = "launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id";
        "kitty_mod+f" = "launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id";
        "page_up" = "scroll_page_up";
        "page_down" = "scroll_page_down";
        "ctrl+plus" = "change_font_size all +1";
        "ctrl+equal" = "change_font_size all +1";
        "ctrl+kp_add" = "change_font_size all +1";
        "ctrl+minus" = "change_font_size all -1";
        "ctrl+underscore" = "change_font_size all -1";
        "ctrl+kp_subtract" = "change_font_size all -1";
        "ctrl+0" = "change_font_size all 0";
        "ctrl+kp_0" = "change_font_size all 0";
      };
    };

    # Deploy custom kittens (search.py, scroll_mark.py) — not managed by HM
    home.file.".config/kitty/search.py" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/kitty/search.py";
    };
    home.file.".config/kitty/scroll_mark.py" = {
      source = "${selfPkgs.illogical-impulse-dotfiles}/kitty/scroll_mark.py";
    };
  };
}
