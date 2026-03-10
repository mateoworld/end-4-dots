# Task 9 Spec Compliance Review

## Task
Rewrite `modules/packages.nix`

## Requirements
1. Replace content with full upstream dependency list
2. Include all categories: Basic CLI, Audio, Backlight, Hyprland ecosystem, KDE integration, Fonts & themes, Screen capture, Python/build, Widgets & tools, Terminals, Cursor
3. Commit with message "modules: rewrite packages.nix with upstream dependency set"

## Review Results

| Requirement | Status |
|-------------|--------|
| `let enabled = ... in` structure | ✅ |
| `with pkgs;` for package list | ✅ |
| Basic CLI category | ✅ |
| Audio category | ✅ |
| Backlight category | ✅ |
| Hyprland ecosystem category | ✅ |
| KDE integration category | ✅ |
| Fonts & themes category | ✅ |
| Screen capture category | ✅ |
| Python/build category | ✅ |
| Widgets & tools category | ✅ |
| Terminals category | ✅ |
| Cursor category | ✅ |

**✅ Spec compliant**

## Fix Applied

- Moved `eza` and `starship` from "Fonts & themes" to "Basic CLI & system" for better categorization

## Commit

`693f330` - modules: rewrite packages.nix with upstream dependency set
