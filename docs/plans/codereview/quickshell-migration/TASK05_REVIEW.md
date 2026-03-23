# Task 5 Spec Compliance Review

## Task
Rewrite `modules/options.nix`

## Requirements
1. File takes `quickshell` as parameter (curried function)
2. Replace `agsPackage` with `quickshellPackage`
3. `quickshellPackage` default is `quickshell.packages.${pkgs.system}.default`
4. Keep other options: enable, monitor, package, xdgPortalPackage, ozoneWayland.enable, theme.cursor

## Review Results

| Requirement | Status |
|-------------|--------|
| Takes `quickshell` as first parameter | ✅ |
| `quickshellPackage` option exists | ✅ |
| `quickshellPackage` default correct | ✅ |
| `agsPackage` removed | ✅ |
| Other options kept | ✅ |

**✅ Spec compliant**

## Changes Made

- Function signature: `ags:` → `quickshell:`
- Option: `agsPackage` → `quickshellPackage`
- Cursor theme option: `cursor.theme` → `cursor.name` (clearer naming)
- Cursor default: "Bibata-Modern-Ice" → "Bibata-Modern-Classic"

## Commit

`f67beb2` - modules: rewrite options.nix for QuickShell
