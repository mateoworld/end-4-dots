# Subagent-Driven Implementation: QuickShell Migration

Use this prompt when executing the QuickShell migration with the **superpowers:subagent-driven-development** skill.

## Pre-Flight Checklist

Before using this prompt, ensure:
- [x] Design document exists (`docs/plans/2026-03-09-quickshell-migration-design.md`)
- [x] Implementation plan exists (`docs/plans/2026-03-09-quickshell-migration-plan.md`)
- [ ] Git worktree is set up and you're in it
- [ ] You've read the `subagent-driven-development/SKILL.md`

---

## Execution Prompt

You are implementing **QuickShell Migration** using the **superpowers:subagent-driven-development** skill.

### Context

**Worktree:** `quickshell-migration` (create at appropriate location)

**Design Document:** `docs/plans/2026-03-09-quickshell-migration-design.md`

**Implementation Plan:** `docs/plans/2026-03-09-quickshell-migration-plan.md`

**Goal:** Rewrite end-4-dots from AGS v1 to QuickShell, matching upstream end-4/dots-hyprland's current architecture, while preserving the home-manager module interface.

**Code Review Location:** `docs/plans/codereview/quickshell-migration/`

### Background

This repo is a fork of bigsaltyfishes/end-4-dots which packages end-4/dots-hyprland for NixOS as a home-manager module. The upstream project migrated from AGS (Aylur's GTK Shell) to QuickShell (QML-based shell). The fork is pinned to a May 2025 commit and completely broken because:
- AGS v1 is obsolete; upstream removed all `.config/ags/` files
- Upstream now uses 992 QuickShell config files under `.config/quickshell/`
- Dependencies like gradience, pywal, materialyoucolor, dart-sass no longer exist upstream
- Keybinds now use Hyprland's `global` dispatcher with QuickShell IPC signals
- Desktop ecosystem shifted from GNOME to KDE apps

Key upstream references (use `gh api` to fetch if needed):
- `sdata/dist-nix/home-manager/flake.nix` — working QuickShell flake for reference
- `sdata/dist-nix/home-manager/home.nix` — comprehensive dependency list with nixpkgs mappings
- `sdata/dist-nix/home-manager/quickshell.nix` — QuickShell Qt6 wrapper package
- `sdata/deps-info.md` — dependency documentation
- QuickShell pinned commit: `db1777c20b936a86528c1095cbcb1ebd92801402`

### Your Job as Controller

1. **Read the implementation plan ONCE** - Extract all tasks with full text
2. **Create TodoWrite** with all tasks upfront
3. **For each task:**
   - Dispatch implementer using skill's implementer-prompt.md
   - Dispatch spec reviewer using skill's spec-reviewer-prompt.md
   - Dispatch code quality reviewer using skill's code-quality-reviewer-prompt.md
   - **Ask user:** "Ready to proceed to Task N+1?" and **WAIT**

### Scene-Setting for Subagents

When dispatching subagents, provide this context:

**For implementer:**
```
Work from: /absolute/path/to/worktree/
Design doc: docs/plans/2026-03-09-quickshell-migration-design.md
Implementation plan: docs/plans/2026-03-09-quickshell-migration-plan.md

Upstream repo: end-4/dots-hyprland (use `gh api` to fetch file contents)
QuickShell commit: db1777c20b936a86528c1095cbcb1ebd92801402

When fetching sha256 hashes for fetchFromGitHub, use:
  nix-prefetch-url --unpack "https://github.com/end-4/dots-hyprland/archive/<COMMIT>.tar.gz"
Or use lib.fakeHash initially and let the build error reveal the correct hash.

Commit message should include: "Worktree: quickshell-migration"
```

**For reviewers:**
```
Save review to: docs/plans/codereview/quickshell-migration/TASKNN_REVIEW.md
Design doc: docs/plans/2026-03-09-quickshell-migration-design.md
```

---

## Task-Specific Handling

### Task 2 & 3 (Dotfiles + QuickShell packages)

These require fetching sha256 hashes. The implementer should:
1. Use `lib.fakeHash` initially
2. Attempt `nix build`
3. Extract correct hash from error output
4. Update and rebuild

### Task 4 (Delete old packages)

Build failures are EXPECTED after deleting AGS packages until modules are updated in Tasks 5-7. Document in reviews: "Build expected to fail - subsequent tasks fix references."

### Task 7 (quickshell.nix)

The `selfPkgs` pattern needs careful wiring. `pkgs/default.nix` receives the QuickShell flake output, and `illogical-impulse-quickshell/default.nix` extracts the package from it. Verify the parameter passing chain works.

### Task 8 (hyprland.nix rewrite)

This is the largest task. The implementer must NOT try to Nix-ify upstream's keybinds. Deploy config files via `home.file` from the dotfiles package. The only Nix-generated file is `monitors.conf`.

### Task 19 (Test build)

This is iterative. Expect multiple fix cycles. Common issues:
- Hash mismatches (fix with correct sha256)
- Missing nixpkgs attributes (some upstream deps may not exist or have different names)
- Path issues in dotfiles package (verify `dots/.config/` paths)
- QuickShell wrapper linking issues (Qt dependency tree)

---

## Human Checkpoint Format

After each task completes:

```
## Task N Complete

**Implementation:** [Brief description]
**Commit:** `SHA`

**Reviews:**
- Spec Review: [One-line summary]
- Code Quality Review: [One-line summary]

---

**Ready to proceed to Task N+1?** ([Task N+1 name])
```

---

## Commit Message Conventions

Use conventional commits with worktree reference:

```
refactor: replace AGS flake input with QuickShell

- Remove ags input and all references
- Add quickshell input pinned to upstream commit
- Update outputs to pass quickshell instead of ags

Worktree: quickshell-migration
```

Types: `refactor:` | `fix:` | `feat:` | `docs:` | `chore:` | `test:`

---

## Task Sequence

**20 tasks total - from implementation plan**

Execute sequentially:

### Phase 1: Foundation
- Task 1: Rewrite `flake.nix`
- Task 2: Create `illogical-impulse-dotfiles` package
- Task 3: Create `illogical-impulse-quickshell` package
- Task 4: Update existing packages and `pkgs/default.nix`

### Phase 2: Core Modules
- Task 5: Rewrite `modules/options.nix`
- Task 6: Rewrite `modules/default.nix`
- Task 7: Create `modules/quickshell.nix`
- Task 8: Rewrite `modules/hyprland.nix`
- Task 9: Rewrite `modules/packages.nix`

### Phase 3: Supporting Modules
- Task 10: Create `modules/fish.nix`, delete `modules/zsh.nix`
- Task 11: Rename `modules/fuzzle.nix` to `modules/fuzzel.nix`
- Task 12: Update `modules/foot.nix`
- Task 13: Update `modules/kitty.nix`
- Task 14: Update `modules/theme.nix`
- Task 15: Simplify `modules/hyprlock.nix` and `modules/hypridle.nix`
- Task 16: Review `modules/anyrun.nix` (likely no changes)
- Task 17: Deploy additional upstream dotfile configs

### Phase 4: Verification
- Task 18: Update `flake.lock`
- Task 19: Test build and fix issues
- Task 20: Update README

---

## Review File Naming

```
docs/plans/codereview/quickshell-migration/
├── TASK01_REVIEW.md
├── TASK01_CODE_REVIEW.md
├── TASK02_REVIEW.md
├── TASK02_CODE_REVIEW.md
├── ...
└── TASK20_REVIEW.md
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails during Task 4 deletions | Expected - document and continue |
| sha256 hash mismatch | Use `nix-prefetch-url --unpack` or extract from build error |
| nixpkgs attribute not found | Check nixpkgs search, may need different name or overlay |
| QuickShell wrapper fails | Compare with upstream's `quickshell.nix`, verify Qt deps |
| `home.file` conflicts | Ensure no two modules deploy to same path |
| Submodule not fetched | `fetchSubmodules = true` in fetchFromGitHub for dotfiles |
| Upstream config references `$qsConfig` | This is a Hyprland variable set in `hyprland.conf`, not a Nix variable |

---

## Start

Begin with Task 1. Follow the subagent-driven-development skill process.
