# Dev Notes (Project Zomboid Mod)

## Why changes sometimes don't appear in-game

Project Zomboid can keep old state loaded even after editing files. This is normal.

Main causes:

1. Lua runtime/cache still loaded from previous session.
2. Editing the wrong file path (duplicate/old file).
3. `media/scripts/*.txt` changes (items/sounds) usually need full restart.
4. Bad file encoding (UTF-16/binary-like save) after crashes/power loss.

## Safe reload workflow

1. Save all files.
2. For `.lua` changes:
   - Use `Reset Lua`, or restart the game.
3. For `media/scripts/*.txt` (items, sounds, recipes):
   - Full game restart is recommended.
4. For textures/sounds:
   - Full restart is recommended.
5. Re-enter world and test.

## Encoding rule

- Keep source files in UTF-8 (or ANSI if already project-standard).
- Do **not** save Lua files as UTF-16.
- If a file suddenly appears as binary in `git diff`, restore from git and reapply.

## Path hygiene

- Avoid duplicate feature files in different folders.
- Keep one active implementation path per feature.
- Example used in this repo:
  - `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Pager_UI/S4_Pager_UI.lua`

## Minimal test checklist before commit

1. Open/close each affected UI once.
2. Trigger at least one positive action path.
3. Trigger one cancel/close path.
4. Check `console.txt` for new Lua errors.
5. Re-test after full restart if scripts/assets changed.

## Git workflow (solo now, scalable later)

1. Work in short branch (`feat/...`, `fix/...`).
2. Commit small logical chunks (`feat:`, `fix:`, `refactor:`).
3. Merge to `main` only when stable.
4. Update `CHANGELOG.md` per version (not per commit).
5. Create/push tag for each release version.
