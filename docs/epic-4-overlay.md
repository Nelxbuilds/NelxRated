# Epic 4 — Overlay

A movable overlay frame showing spec rows from the **active challenge**. Each row displays a spec icon, character name, and rating with color-coded progress. Supports opacity control, arena-state detection, drag-to-move, and a background toggle.

**Depends on**: Epic 2 (challenge system — `NXR.GetActiveChallenge()`)

**Reference**: See `resources-to-delete/002-overlay-example.png` for the target look.

---

## Story 4-1 — Overlay Frame (Movable, Persisted, Background Toggle)

**Goal**: Create the overlay frame with drag-to-move, position persistence, and an optional background/border.

**Acceptance Criteria**:

- [ ] On `ADDON_LOADED`, a frame is created via `CreateFrame("Frame", nil, UIParent, "BackdropTemplate")`
- [ ] The frame is draggable via `SetMovable(true)` + `RegisterForDrag("LeftButton")`
- [ ] Position is saved to `NelxRatedDB.overlayPosition` on drag stop and restored on load
- [ ] Default position: `CENTER` offset slightly right
- [ ] The frame uses PvP crimson design system (crimson border, dark background)
- [ ] If `NelxRatedDB.settings.showOverlayBackground` is false, the backdrop is cleared (icons float without a frame)
- [ ] `NXR.Overlay.OnBackgroundChanged()` re-applies or clears the backdrop
- [ ] Frame strata: `MEDIUM`, clamped to screen
- [ ] If no challenge is active, the overlay is hidden

**Technical Hints**:

- Store backdrop definition as a module-level constant for reuse
- `ApplyBackground()` checks the setting and calls `SetBackdrop(nil)` or `SetBackdrop(OVERLAY_BACKDROP)`
- Register `ADDON_LOADED` to build the frame, `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA` for arena state

---

## Story 4-2 — Spec List Display

**Goal**: Populate the overlay with one row per spec from the active challenge, showing spec icon, character name, and rating.

**Acceptance Criteria**:

- [ ] The overlay reads the active challenge via `NXR.GetActiveChallenge()`
- [ ] For each specID in the challenge's `specs` table, one row is rendered
- [ ] Each row shows: icon (left, ~20px), character name (middle), rating number (right)
- [ ] Row icon: if the challenge's `classes` table contains the class that owns this specID, use the class icon (`GetClassIcon(classID)` or `select(4, GetClassInfo(classIndex))`); otherwise use the spec icon (`select(4, GetSpecializationInfoByID(specID))`)
- [ ] Character matching: find all characters whose `specID` matches AND who have rating > 0 in any of the challenge's selected brackets
- [ ] Display the **highest-rated** character per spec row (highest rating across any selected bracket)
- [ ] If no character matches a spec, show the spec icon with "—" for rating and no character name
- [ ] Rows are laid out vertically; the overlay resizes dynamically
- [ ] Row height: ~20-22px with compact spacing
- [ ] The overlay refreshes when: challenges change, character data updates, active challenge changes
- [ ] `NXR.RefreshOverlay` is exposed globally so Events.lua and Settings.lua can call it

**Technical Hints**:

- Use an icon pool / row pool pattern: pre-create row frames, show/hide as needed
- Call `ClearAllPoints()` before `SetPoint()` when reusing pooled frames
- For matching, iterate `NelxRatedDB.characters` and check `charRecord.specID` against `challenge.specs`
- For the best rating across brackets: `for bIdx in pairs(challenge.brackets) do ... end`, take max

---

## Story 4-3 — Hover Tooltips

**Goal**: Hovering a spec row shows a tooltip with character details and goal progress. If multiple characters match, list all of them.

**Acceptance Criteria**:

- [ ] Hovering a spec row shows a `GameTooltip` with:
  - Spec name as the title
  - For each matching character (sorted by rating descending): name-realm, rating, and bracket name
  - Goal progress line: `"Goal: 1800 (94%)"` colored by progress threshold
- [ ] If no character matches, tooltip says: "No character tracked for this spec"
- [ ] Tooltip hides on mouse leave
- [ ] When overlay opacity is 0, mouse is disabled on all rows — no tooltips fire

**Technical Hints**:

- Use `GameTooltip:SetOwner(row, "ANCHOR_RIGHT")`, `:AddLine()`, `:Show()`
- Attach via row's `OnEnter` / `OnLeave` scripts
- For multi-character listing: iterate all characters matching the specID, not just the best one

---

## Story 4-4 — Rating Progress Colors

**Goal**: Color each spec row's rating text based on progress toward the goal.

**Acceptance Criteria**:

- [ ] < 80% of goal: white (default) `{1.00, 1.00, 1.00}`
- [ ] >= 80% and < 90%: orange `{0.93, 0.55, 0.05}`
- [ ] >= 90% and < 100%: yellow `{0.95, 0.80, 0.20}`
- [ ] >= 100%: checkmark texture (`Interface\\RaidFrame\\ReadyCheck-Ready`) shown next to the rating
- [ ] Progress = `bestRating / challenge.goalRating`
- [ ] Color applies to the rating FontString only

---

## Story 4-5 — Overlay Opacity & Arena/BG State

**Goal**: Apply different opacity values depending on whether the player is inside or outside a rated PvP instance. When opacity is 0, disable all mouse interaction.

**Acceptance Criteria**:

- [ ] In arena or rated BG: use `NelxRatedDB.settings.opacityInArena`
- [ ] Outside: use `NelxRatedDB.settings.opacityOutOfArena`
- [ ] `frame:SetAlpha(opacity)` applied on zone change
- [ ] When opacity is 0: `EnableMouse(false)` on overlay and all child rows
- [ ] When opacity > 0: `EnableMouse(true)` restored
- [ ] Arena/BG detection: `IsActiveBattlefieldArena()` for arenas; check `C_PvP.IsBattleground()` or similar for Blitz BG
- [ ] Re-evaluate on `PLAYER_ENTERING_WORLD` and `ZONE_CHANGED_NEW_AREA`
- [ ] `NXR.Overlay.OnOpacityChanged()` is exposed for the Settings tab to call

**Technical Hints**:

- `IsActiveBattlefieldArena()` returns true in rated arenas
- For Blitz BG detection, try `C_PvP.IsRatedBattleground()` or `IsInActiveWorldPVP()` — verify in-game
- Iterate all row child frames to toggle `EnableMouse()`
