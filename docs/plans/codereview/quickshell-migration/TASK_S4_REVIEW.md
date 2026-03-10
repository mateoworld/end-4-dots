# Task S4 Spec Compliance Review

## Task
Fix hyprlock/hypridle conflict

## Requirements
1. Update hyprlock.nix to only install package (not enable HM module)
2. Update hypridle.nix to only install package (not enable HM module)
3. Configs stay in hyprland.nix as raw dotfile deployment
4. Commit with message "fix(hyprlock,hypridle): resolve home.file conflict with HM module enables"

## Review Results

| Requirement | Status |
|-------------|--------|
| hyprlock.nix only installs package | ✅ |
| hypridle.nix only installs package | ✅ |
| Configs remain in hyprland.nix | ✅ |
| Explanatory comments present | ✅ |

**✅ Spec compliant**

## Commit

`33e88ee` - fix(hyprlock,hypridle): resolve home.file conflict with HM module enables
