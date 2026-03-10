# Task S2 Spec Compliance Review

## Task
Rewrite `modules/foot.nix` to use home-manager API

## Requirements
1. Use `programs.foot.settings` instead of `home.file.".config/foot"`
2. Configure main settings (shell=fish, font, pad, etc.)
3. Configure scrollback (lines=10000)
4. Configure cursor (style=beam)
5. Configure key-bindings
6. Configure search-bindings
7. Configure text-bindings

## Review Results

| Requirement | Status |
|-------------|--------|
| Uses `programs.foot.settings` | ✅ |
| Main settings configured | ✅ |
| Scrollback configured | ✅ |
| Cursor configured | ✅ |
| Key-bindings configured | ✅ |
| Search-bindings configured | ✅ |
| Text-bindings configured | ✅ |

**✅ Spec compliant**

## Notes

Changes from original (zsh→fish, SpaceMono→JetBrainsMono) are intentional per upstream migration.

## Commit

`9dbc804` - fix(foot): use home-manager module API instead of raw dotfile deployment
