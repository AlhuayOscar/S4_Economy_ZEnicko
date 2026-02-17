# Changelog

All notable changes to this project are documented in this file.

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

