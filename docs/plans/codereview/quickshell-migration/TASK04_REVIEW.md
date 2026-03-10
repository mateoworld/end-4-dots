# Task 4 Spec Compliance Review

## Task
Update existing packages and `pkgs/default.nix`

## Requirements
1. Rewrite `pkgs/default.nix` with `lib.fix` pattern, export 4 packages
2. Update shaders package to use same commit/hash as dotfiles
3. Update kvantum package to use same commit/hash as dotfiles
4. Delete all AGS-related packages
5. Commit with message "pkgs: rewrite package set for QuickShell, remove AGS packages"

## Review Results

| Requirement | Status |
|-------------|--------|
| `pkgs/default.nix` uses `lib.fix` and exports 4 packages | ✅ |
| Shaders uses same commit/hash as dotfiles | ✅ |
| Kvantum uses same commit/hash as dotfiles | ✅ |
| AGS packages deleted | ✅ |

**Commit/hash used:** `a7f1cddd45ae02e6a2ee4178d2f1e72d00fea7f3` with sha256 `sha256-Hubmivb84rXpoUHEtsJOxLOGw3w06OyEtkKYsI2zuBo=`

**✅ Spec compliant**

## Commit

`b0de5b4e6b8839b6d732172a297025f6f3a9c208` - pkgs: rewrite package set for QuickShell, remove AGS packages
