# Task 10 Spec Compliance Review

## Task
Create `modules/fish.nix`, delete `modules/zsh.nix`

## Requirements
1. Create `modules/fish.nix` with fish shell config
2. Enable fish with starship prompt
3. Load QuickShell-generated terminal colors
4. Add aliases (clear, ls, q)
5. Deploy upstream auto-Hypr.fish
6. Delete `modules/zsh.nix`
7. Commit with message "modules: add fish.nix, remove zsh.nix (upstream uses fish)"

## Review Results

| Requirement | Status |
|-------------|--------|
| Fish enabled | ✅ |
| Starship prompt | ✅ |
| QuickShell color loading | ✅ |
| Alias: clear | ✅ |
| Alias: ls (eza) | ✅ |
| Alias: q (quickshell) | ✅ |
| Deploy auto-Hypr.fish | ✅ |
| zsh.nix deleted | ✅ |

**✅ Spec compliant**

## Notes

- `foot.nix` shell configuration will be updated in Task 12
- Fish is enabled conditionally based on `illogical-impulse.enable`

## Commit

`52fa61c` - modules: add fish.nix, remove zsh.nix (upstream uses fish)
