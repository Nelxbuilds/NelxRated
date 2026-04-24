# Changelog

## [1.2.0] -- 2026-04-24

### Added
- Overlay polish: multi-column layout, checkmark replaces rating text at 100%, wider rating padding, current-character indicator
- Full data export/import covering characters, challenges, and settings

### Fixed
- Disable role grouping for class challenges
- Checkmark centering, settings scroll, role columns, melee/ranged split
- Typo in README

## [1.1.0] -- 2026-04-19

### Changed
- History tab improvements: race/gender icons in character dropdown, class-colored and class-ordered entries, scrollable dropdown, auto-bracket selection on character change
- History tab bugfixes: goal label background, dropdown style unification, z-order fixes, dropdown rendering above graph

## [1.0.1] -- 2026-04-17

### Fixed
- Interface info display corrections
- History tracking and persistence issues
- History visualization improvements and cleanup

## [1.0.0] -- 2026-04-12

### Changed
- Major version bump from 0.1.0 — all six epics complete

### Completed
- Epic 1: Core Tracking — arena rating and MMR capture for all brackets
- Epic 2: Challenge System — multi-spec, multi-bracket challenge CRUD
- Epic 3: Settings UI — full settings panel with all configuration options
- Epic 4: Overlay — movable overlay with color-coded progress and tooltips
- Epic 5: Home Screen — dashboard with summary stats
- Epic 6: Rating History — historical rating tracking and UI

## [0.1.0] — Initial Release

### Added
- Arena rating and MMR tracking for Solo Shuffle, 2v2, 3v3, and Blitz BG
- Personal challenge system — set rating goals by spec or class
- Movable overlay showing spec/class icons with color-coded progress (80% orange, 90% yellow, 100% checkmark)
- Hover tooltips showing character name and current rating
- Settings panel with Challenges, Characters, Settings, and Import/Export tabs
- Per-account character tracking with name, realm, and account metadata
- Cross-account Import/Export to share ratings between WoW accounts without overwriting each account's own data
- Overlay opacity control for inside and outside arena (tooltips auto-disabled at 0 opacity)
