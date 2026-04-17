# Epic 8 — History Bug Fixes & Polish

Fix visual bugs and inconsistencies on the History tab: goal label readability, dropdown styling alignment, z-order issues, and icon consistency.

**Depends on**: Epic 7 (history improvements)

---

## Story 8-1 — Add Background Behind Goal Label to Prevent Line Overlap

**Goal**: When the rating data line passes through the goal line's Y position, the goal label text becomes unreadable. Add a semi-transparent dark background behind the goal label so it stays legible.

**Bug Reference**: `bugs/open-bugs.md` — "Goal label overlaps with drawn line"
**Screenshot**: `bugs/history-goal-overlap-with-line.png`

**Acceptance Criteria**:

- [x] A dark semi-transparent texture (`goalLabelBg`) is created behind `goalLabel`, covering the text extents plus at least 2px padding on each side
- [x] Background color is near-black with sufficient alpha to occlude the data line (e.g., `0, 0, 0, 0.85`)
- [x] `goalLabelBg` draw layer is `"ARTWORK"` (below `goalLabel` at `"OVERLAY"`), so gold text renders on top
- [x] `goalLabelBg` is anchored to `goalLabel`'s four points with negative insets — auto-resizes with label text width
- [x] `goalLabelBg` is shown/hidden in sync with `goalLabel` at all three code paths: line 154 (clear), line 306 (show), line 309 (hide)
- [x] No visual change to goal line or data line rendering

**Technical Hints**:

- Create `goalLabelBg` as a `Texture` parented to `graphFrame`, anchor all four points to `goalLabel` with -2px insets
- Declare `goalLabelBg` alongside `goalLabel` at line 29 as a local

---

## Story 8-2 — Unify History Tab Dropdown Styles to Custom Crimson Design

**Goal**: Replace `MenuUtil.CreateContextMenu()` popups (Spec and Bracket dropdowns) with the same custom crimson dropdown style the Character selector uses.

**Bug Reference**: `bugs/open-bugs.md` — "Two different dropdown visualisation"
**Screenshot**: `bugs/history-two-different-dropdown.png`

**Acceptance Criteria**:

- [x] Spec and Bracket dropdowns use identical styling to the existing `charDropdown` (lines 558-567): same `BackdropTemplate`, backdrop colors, `CRIMSON_DIM` border, `DIALOG` strata, crimson hover highlight
- [x] `MenuUtil.CreateContextMenu()` is no longer called anywhere in `HistoryUI.lua` (remove calls at lines 622 and 636)
- [x] Each dropdown anchors `TOPLEFT` to button's `BOTTOMLEFT` with 2px gap, matching `charDropdown`
- [x] Clicking an entry updates the filter variable, button label, calls `RefreshGraph()` (and `UpdateSpecButtonState()` for bracket), and closes the dropdown
- [x] Only one dropdown open at a time — opening any dropdown closes the others via shared `ddClickCatcher`
- [x] Entry text uses `GameFontNormal`, left-justified with 6px horizontal padding, same `ENTRY_HEIGHT` as `charDropdown`
- [x] Spec dropdown stays disabled (`alpha 0.4`) for non-per-spec brackets

**Technical Hints**:

- Extract a reusable dropdown helper from the `charDropdown` pattern to avoid duplicating frame creation three times
- Reuse the existing `ddClickCatcher` — extend `HideCharDropdown` to close all three dropdowns

---

## Story 8-3 — Fix Character Dropdown Rendering Behind Graph Frame

**Goal**: Remove the graph container's visual backdrop so the character dropdown is never obscured by it.

**Bug Reference**: `bugs/open-bugs.md` — "History character dropdown behind frame"
**Screenshot**: `bugs/history-character-dropdown-behind-frame.png`

**Acceptance Criteria**:

- [x] Remove `SetBackdrop()`, `SetBackdropColor()`, `SetBackdropBorderColor()` calls from `graphFrame` (lines 690-696)
- [x] Remove `"BackdropTemplate"` mixin from `graphFrame`'s `CreateFrame` call (line 687)
- [x] Existing axis border lines (`axisL`, `axisB`) remain unchanged — they provide the graph area's visual boundary
- [x] All dropdowns render above `graphFrame` content when open
- [x] Graph elements (axis lines, grid lines, data lines, dots, labels, goal line, placeholder) render unchanged

**Technical Hints**:

- Child elements use explicit draw layers (`ARTWORK`, `BACKGROUND`, `OVERLAY`) so removing backdrop has no effect on them

---

## Story 8-4 — Align Character Dropdown Button and Entry Icon Display

**Goal**: Fix two related issues: (1) the selected character button shows only `[class-icon] Name - Realm` while dropdown entries show `[race-icon][class-icon] Name - Realm`, and (2) `classicon-*` (flat) and `raceicon-*` (3D) have mismatched visual styles. Solve both by using only race icon + class-colored text everywhere.

**Bug Reference**: `bugs/open-bugs.md` — "History character entry" and "Two different styles of icons"
**Screenshot**: `bugs/history-character-dropdown-behind-frame.png`

**Acceptance Criteria**:

- [x] `FormatCharDisplay()` (line 349) no longer includes `classicon-*` atlas markup — remove the class icon line (lines 357-359)
- [x] `FormatCharDisplay()` output format: `[race-icon] ColoredName - Realm` when race data available, `ColoredName - Realm` when missing
- [x] `FormatCharButtonLabel()` (line 369) no longer includes `classicon-*` atlas markup — remove class icon line (lines 372-374)
- [x] `FormatCharButtonLabel()` adds race icon atlas (`raceicon-<raceFileName>-<gender>`, lowercased, 14x14) when `char.raceFileName` and `char.gender` are available, using same gender mapping as `FormatCharDisplay()` (2=male, 3=female; nil/1 omits icon)
- [x] `FormatCharButtonLabel()` output format: `[race-icon] ColoredName - Realm` when race data available, `ColoredName - Realm` when missing, `"Select"` when `char` is nil
- [x] Class-colored text (`RAID_CLASS_COLORS` colorStr wrapping) remains in both functions
- [x] Both dropdown entries and selected button now display identically

**Out of Scope**:

- Changing icons outside History tab (overlay, challenges use `classicon-*` in different context)
- Adding spec icons to character dropdown
