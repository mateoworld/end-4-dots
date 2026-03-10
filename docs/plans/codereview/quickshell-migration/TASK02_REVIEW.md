# Task 2 Spec Compliance Review

## Task
Create `illogical-impulse-dotfiles` package

## Requirements
1. Get upstream commit hash from end-4/dots-hyprland main branch
2. Write package with `fetchFromGitHub`, `lib.fakeHash` (or actual hash), `fetchSubmodules = true`
3. installPhase copies `dots/.config/*` to `$out/`
4. Commit with message "pkgs: add illogical-impulse-dotfiles package"

## Review Results

| Requirement | Status |
|-------------|--------|
| File created at `pkgs/illogical-impulse-dotfiles/default.nix` | ✅ |
| Uses `fetchFromGitHub` with owner="end-4", repo="dots-hyprland" | ✅ |
| Uses actual commit hash `a7f1cddd45ae02e6a2ee4178d2f1e72d00fea7f3` | ✅ |
| Has `fetchSubmodules = true` | ✅ |
| installPhase copies config files to `$out/` | ✅ (fixed to use `$src/` prefix and include hidden files) |

**Note:** The implementer prefetched the actual sha256 hash during implementation, which is acceptable.

**Fix applied:** Changed installPhase from `cp -r dots/.config/* $out/` to `cp -r $src/dots/.config/. $out/` to:
1. Use `$src/` prefix for consistency with other packages
2. Include hidden files (files starting with `.`)

**✅ Spec compliant (after fix)**

## Commit

`68098832b3619761492b8a1200dfd1a675480740` - pkgs: add illogical-impulse-dotfiles package
