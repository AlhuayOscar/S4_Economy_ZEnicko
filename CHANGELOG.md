# Changelog

All notable changes to this project are documented in this file.

## [1.5.0] - 2026-02-21

## Feature: Knox OS Desktop Expansion & Retro BBS

- **Knox BBS Terminal:**
  - Added retro 90s Dial-Up Bulletin Board System (`S4_IE_BBS`).
  - Immersive ANSI-style interface with "Shareware" file directory referencing other unreleased mod apps.
  - Interactive "Download" buttons with lore-friendly warning prompts.
- **S4 Community Hub:**
  - "Knox Municipality" dashboard designed for server event voting.
  - Active Government Proposals (e.g. "Prop 104: Demolition of West Point Bridge").
  - Dynamically restricts voting rights based on tax delinquency.
- **FarmWatch Agrosystems:**
  - Subscription-based ($500/mo) satellite crop monitoring.
  - Tracks specific agricultural blocks (Rosewood, Muldraugh, etc.).
  - Reports primary crops, hydration percentage, disease risk, and estimated yields using a visual hazard interface.
- **Scout & Recon:**
  - Tactical military encrypted terminal for purchasing map intel.
  - Packages include Zombie Density Thermal Maps, Random Safehouse Generation, and Animal/Bio-scans.
  - Simulates scanning with detailed contextual diagnostic popup warnings.
- **Knox Weather Service:**
  - Premium Weather Access ($250/mo) system.
  - 7-Day predictive forecast covering Temperature, Conditions (Fog, Storms, Snow), and precise hourly-breakdowns (85% accuracy).
- **Corpse Recovery & Tool Repair:**
  - Expanded desktop layout with dummy application interfaces referencing future service integrations.
- **Engine Optimization & Stability:**
  - Added Python pipeline fix script.
  - Fixed Kahlua/Java engine crashes (`Object tried to call nil in createChildren`) across all IE modules caused by missing `initialise()` calls on ISButton classes.
  - Fixed Kahlua engine crashes in `S4_IE_Twitboid` and `S4_IE_KarmaAdmin` caused by unsupported `math.random` usage; replaced with engine-native `ZombRand()`.
- **UI Bug Fixes:**
  - Fixed `Knox BBS`, `Weather App`, `Taxes`, and `Twitboid` overflowing bottom bounds by fully migrating their static inner panels to dynamic `ISScrollingListBox` containers.
  - Fixed `Crimeboid` "Bribe/Pay Faction" buttons visually clipping outside the right edge of the screen by dynamically recalculating their coordinate offset.
  - Fixed `Vehicle Shop` interface superimposing the GoodShop shopping cart behind the vehicle queue buttons.
  - Increased `Pager Terminal` window height from 280 to 330 to safely accommodate all tracking texts without squashing sentences together.
  - Replaced bugged `°C` Unicode character symbol in the Weather App with standard `Cel` text to ensure compatibility.

## [1.4.0] - 2026-02-21

## Feature: Global Logistics, Twitboid & Karma Admin

- **S4 Logistics & Commerce:**
  - New dedicated desktop app connecting directly to `S4_PlayerStats`.
  - Added support for persistent data: `Warehouses` and `Stocks` variables saved to player profile.
  - Dynamic Stock Market interface: Buy and Sell shares of SPIFF, KNOX, and PHM dynamically linking to the database.
  - My Warehouses tab reading active capacity and physical off-map ownership states.
- **Karma Admin Tool:**
  - Added developer-only shortcut app visible only to `admin` access levels or Debug Mode.
  - Live readout of player's general Karma and specific Faction Reputation.
  - Debug control buttons: `+10`, `-10`, `Reset (0)` for fast testing of alignment mechanics.
  - Logistics Testing bounds: `Spawn Test Warehouse`, `Add 10 SPIFF Stocks`, `Remove 10 SPIFF Stocks`.
- **Twitboid Interactivity:**
  - Sidebar expanded with "Notifications" and "Profile".
  - Posts now contain interactive `Reply`, `ReBoid`, and `<3 Like` buttons with color feedback states and RNG hit counters.
- **UI Bug Fixes:**
  - Fixed Crimeboid tab overlapping by swapping manual array removal for native `clearChildren()`.
  - Fixed Zeddit thread wrapping to prevent text overflowing bounds by utilizing `luautils.split()`.

## [1.3.1] - 2026-02-20

### Patch: Vehicle Preview UI & Job Expansion

- **UI Fix:** Fixed overlap in vehicle preview window where control buttons were covering the specifications text.
- **Documentation:** Added "Armored Truck Attack" to `Jobs_Proposal.md`, detailing a multi-stage heist involving decoy vehicles and revenge lore.

## [1.3.0] - 2026-02-20

## Feature: Global Economy Overhaul

- **High-Stakes Pager Rewards:**
  - Standard mission rewards boosted to **$15,000 - $60,000**.
  - High-tier multi-part missions (Heists) now scale up to a maximum of **$323,000**.
  - Balanced payouts to allow vehicle purchases ($450k+) within **10-15 missions**.
- **Shop Data Cleanup & Categorization:**
  - Fixed categories for over 13,000 items in `S4_Shop_Data.lua`.
  - Moved metals, tools, and ammo out of the "Food" section.
  - Implemented specific sub-categories: **HandGun, Rifle, Shotgun, Tools, Medical, Ammo, GunParts, VehicleParts**.
- **Food Scarcity & Inflation:**
  - Doubled the **BuyPrice** for all items in the "Food" category.
  - Reduced **Stock** for food items to a range of **1-2 units**, forcing players to rely more on looting/farming.
- **Daily Deals System:**
  - Implemented automatic **Daily Recommended Items** (Hot Items) rotation in the server.
  - Picks 5-15 random items every day with a **5% to 30% discount**.
  - Resets previous discounts/hot status daily to keep the market dynamic.

## [1.2.2] - 2026-02-20

## Patch: Pager Missions Stability + New Mission Set

- Added new Rosewood-focused mission set for Pager contracts (simple eliminate + photo/evidence flow).
- Hardened Pager mission/lore string fallbacks to avoid nil-format crashes after mission completion.
- Note: **UNSTABLE LOCATIONS AND COORDINATES OR LACKING PRECISION**.

## [1.2.1] - 2026-02-19

## Feature: Pager Mission Evidence Flow

- Added mission-point target system for Pager contracts with map marker support and debug fixed-point mode.
- Added target elimination progression (`killsDone/killGoal`) and auto-complete when mission targets are eliminated.
- Added evidence object pipeline for Pager missions:
  - Work-object metadata (`S4WorkObject`, `S4WorkCode`, lore fields).
  - Valuable halo notifications when evidence is found.
  - Evidence-loss warning: `Object destroyed, you will have to explain it to the client`.
- Added disposable camera mission capture flow:
  - Inventory context option `Use Disposable Camera`.
  - Requires being within 10 tiles from the active/completed mission point.
  - Generates mission evidence item directly and consumes one disposable camera.
- Added post-completion camera support:
  - Last completed mission point is cached so players can recreate destroyed evidence by returning to the location.
- Improved compatibility/fallback behavior for mission evidence item resolution across different item IDs/builds.
- Removed rich-text RGB formatting from evidence tooltip for consistent display across UI contexts.

## [1.2.0] - 2026-02-18

## Feature: Dynamic Job System (Knox Careers)

- **Comprehensive Job Grid:** Implemented an interactive UI with 8 distinct career paths:
  - Call Center, Graphic Designer, Insurance Seller, Programmer, Banker, Cleaner, Journalist, and Spy.
- **Generic Action Framework:** Refactored the underlying system to handle all jobs through a single data-driven Timed Action, supporting dynamic salaries and XP.
- **Equipment & Dress Codes:**
  - Implemented strict inventory requirements for each profession using verified vanilla Item IDs.
  - Added clothing requirements (Suits, Ties, Formal Shirts) for corporate roles.
  - Specialized gear checks: Firearm + Ammo (7+) for Cleaners/Spies, Electronics (Visors, CD Players, Pagers, Cordless Phones) for Programmers.
  - Document requirements: Passports, Stock Certificates, Business Cards, Index Cards, and Press IDs.
- **Dynamic Pain Mechanics:**
  - **Risk-Based System:** Pain probability now scales with daily hours worked, player level (resilience), and negative stats (Fatigue, Hunger, Stress, Thirst).
  - **Periodic Sounds:** Characters now groan in pain periodically during work if they are in poor condition or overworked.
  - **Back Pain Injury:** High-risk sessions can lead to actual back pain injuries, with intensity scaling based on accumulated stress.
- **Economic & Progression Balance:**
  - **Difficulty Scaling:** Job XP thresholds now scale based on profession difficulty (e.g., Spy requires 40% more XP than Call Center).
  - **Salary Balancing:** Adjusted base pay (Call Center nerfed to $125/2h) and high-risk bonuses (Spy/Cleaner/Journalist boosted up to 125%).
  - payments are automated every 2 working hours and logged in the ZomBank system.


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
