# Task 15 Spec Compliance Review

## Task
Simplify `modules/hyprlock.nix` and `modules/hypridle.nix`

## Requirements
1. Simplify hyprlock.nix to just `programs.hyprlock.enable = true;`
2. Simplify hypridle.nix to just `services.hypridle.enable = true;`
3. Remove duplicate enables from hyprland.nix
4. Commit with message "modules: simplify hyprlock/hypridle, deploy upstream configs"

## Review Results

| Requirement | Status |
|-------------|--------|
| hyprlock.nix simplified | ✅ |
| hypridle.nix simplified | ✅ |
| hyprland.nix duplicate enables removed | ✅ (already done in Task 8) |

**✅ Spec compliant**

## Changes

- hyprlock.nix: 99 lines → 9 lines
- hypridle.nix: 33 lines → 9 lines
- Configs now deployed from upstream dotfiles via hyprland.nix

## Commit

`7f3aac6` - modules: simplify hyprlock/hypridle, deploy upstream configs
