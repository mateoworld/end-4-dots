# Task S6 Spec Compliance Review

## Task
Fix `hyprland.nix` mutability and collision issues

## Requirements
1. Remove `wayland.windowManager.hyprland` block, use package-only approach
2. Replace `custom/` home.file with home.activation (copy-once)
3. Replace `workspaces.conf` home.file with home.activation (create if not exists)

## Review Results

| Requirement | Status |
|-------------|--------|
| wayland.windowManager.hyprland block removed | ✅ |
| home.packages [ hypr ] added | ✅ |
| xdg.portal configuration added | ✅ |
| home.activation.hyprCustomSkeleton added | ✅ |
| home.activation.hyprWorkspaces added | ✅ |

**✅ Spec compliant**

## Commit

`3506f85` - fix(hyprland): resolve hyprland.conf collision, make custom/ and workspaces.conf mutable
