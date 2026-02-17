# Changelog

All notable changes to this project are documented in this file.

## [1.1.4] - 2026-02-17

## Feature: Random News Events & Custom Notifications

- Added 5 Random News Events (Breaking News) with custom immersive descriptions:
  - Market Surge, Market Crash, Guerrilla Sightings, Suspicious Jobs, and Fuel Shortage.
- Implemented smart notifications for Knox News:
  - Icon changes to `NewspaperIncoming.png` when a new event occurs.
  - Notification clears only after opening the app or re-focusing via the icon.
- Added Sandbox Options for full event customization:
  - Toggle random events (Enable/Disable).
  - Configurable interval in hours (Min/Max wait time between events).
- UI/UX Refinements:
  - Standardized Knox News desktop icon size and alignment to match system icons.
  - Mapped specific art backgrounds (`Event.png` to `Event_04.png`) to their respective events.
- Added Debug Tool:
  - "DEBUG: Test" button (Admins/Debug only) to force-trigger new events instantly.

## [1.1.3] - 2026-02-17

## Feature: Knox News Timeline

- Implemented Knox News Timeline with 13 chronological entries following lore.
- Added dynamic date-based news unlocking synced with the in-game calendar (Year, Month, Day).
- Redesigned Knox News UI:
  - Atmospheric blurred background image based on the current news.
  - Centered rich text panel with dark overlay for maximum readability.
  - Sequential "Previous" and "Next" navigation for an immersive story experience.
  - Page counter (e.g., "1 / 13").

## [1.1.2] - 2026-02-17

## Patch: Boot Sequence Skip

- Added left-click skip for the boot animation (`[LMB] Skip`) so players can enter faster.
- Added safe boot timer cleanup to avoid duplicate transitions while skipping/closing.
- Preserved existing behavior:
  - `Esc` still shuts down the computer.
  - Boot sounds still play normally when not skipped.
- Docs: added Knox News external reference source (timeline/resources):
  - `https://steamcommunity.com/sharedfiles/filedetails/?id=3389064477`

## [1.1.1] - 2026-02-17

## Patch: Non-disruptive Shop Sync

- Added non-disruptive refresh flow for GoodShop (preserves current category/search/page).
- Added auto-refresh cycle (10s) without forcing UI reset.
- Added sync status label next to Refresh:
  - shows `Sync: updating...`
  - shows elapsed time since last sync + in-game clock.
- Added fallback so `Sync: updating...` doesn't get stuck:
  - triggers soft refresh if ModData event is delayed,
  - force-clears pending state after timeout.
- Updated client-side ModData handling to avoid full `ReloadUI()` on shop updates.
- Synced Admin list state display after reload.

## [1.1.0] - 2026-02-17

### Added

- Added `Refresh` button to item list UI, available for Good Shop and Good Shop Admin flows.
- Added server command `RefreshShopDataFromLua` to reload and apply `S4_Shop_Data.lua` into runtime shop ModData.
- Added admin-side `ReloadData()` refresh path to rebind current UI item data from `S4_ShopData`.

### Changed

- Refactored shop data apply logic on server to normalize fields and update/add/remove entries consistently.
- Improved refresh source resolution using loaded Lua candidates plus fallback paths.
- Updated README with a dedicated refresh data flow section.

### Fixed

- Fixed Admin Shop initialization crash caused by mass `instanceItem()` calls on problematic third-party items.
- Hardened item cache creation by skipping unsafe instance creation for `WeaponPart` script items.
- Fixed search guard boolean checks to prevent nil-access in list search paths.
- Fixed server-side discount update typo in `UpdateShopData` (`Discount` now maps correctly).
