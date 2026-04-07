# Human Verification Checkpoints

Tick each box after in-game testing. The verify-story agent handles static code checks — these are the things only you can confirm.

---

## Epic 1 — Core & Data Layer

### After Story 1-1 (Addon Bootstrap & SavedVariables)

- [ ] `/reload` on a fresh install — no Lua errors in chat.
- [ ] `/dump NelxRatedDB` — confirm structure has `settings`, `characters`, `challenges`, `overlayPosition`, `schemaVersion = 1`.
- [ ] Bracket constants present: `/dump NXR.BRACKET_2V2` → `0`, `/dump NXR.BRACKET_SOLO_SHUFFLE` → `7`.

### After Story 1-2 (Character Information Capture)

- [ ] Log in on your main character. `/dump NelxRatedDB.characters` — confirm `name`, `realm`, `class`, `spec`, `specID` are correct.
- [ ] Log in on a character on your **home realm** (where `UnitName()` returns nil for realm). Confirm realm is still stored correctly via `GetRealmName()` fallback.
- [ ] Log in on the same character twice (reload UI). Confirm only one record exists — no duplicates.
- [ ] Switch specs in-game. `/dump NelxRatedDB.characters` — confirm `specID` and `specName` updated, bracket data preserved.

### After Story 1-3 (Rating & MMR Capture) — CRITICAL GATE

Without this working, nothing else matters.

- [ ] Play a **2v2** game. Run `/dump NelxRatedDB` after. Confirm rating + MMR are present for bracket `0`.
- [ ] Play a **3v3** game. Confirm rating + MMR stored for bracket `1`.
- [ ] Play a **Solo Shuffle** game. Confirm rating + MMR stored for bracket `7`.
- [ ] Confirm data updates after a second game (not just the first).

---

## Epic 2 — Challenge System

### After Story 2-1 (Challenge CRUD & Active Logic)

- [ ] `/dump NXR.GetActiveChallenge()` — returns the first challenge if any exist, `nil` if none.
- [ ] Create a challenge via Lua console. Confirm it appears in `NelxRatedDB.challenges` with a unique `id`.
- [ ] Set it active. Confirm `active = true` on it and `active = false` on all others.
- [ ] Delete the active challenge. Confirm `NXR.GetActiveChallenge()` returns `nil` and overlay hides.
- [ ] `/reload` — all challenges persist.

### After Story 2-2 (Challenge List UI)

- [ ] Open `/nxr` → Challenges tab. Create a challenge — it appears in the list immediately.
- [ ] `/reload` — challenge is still there.
- [ ] Edit the goal rating. Confirm the new value persists after reload.
- [ ] Delete the challenge. Confirm it disappears from the list.
- [ ] With no challenges, the empty-state message is shown (not a blank panel).
- [ ] Set Active button highlights the active challenge visually.

### After Story 2-3 (Challenge Create/Edit Form)

- [ ] Open the create form. All five sections present: name input, bracket toggles, goal rating, spec picker, class picker.
- [ ] Select a class — all specs of that class become checked in the spec picker.
- [ ] Deselect one spec from a class-selected challenge — that spec becomes unchecked while others remain.
- [ ] Try to save with no name — inline error shown, save blocked.
- [ ] Try to save with no specs selected — inline error shown.
- [ ] Try to save with no bracket selected — inline error shown.
- [ ] Save a valid challenge — list refreshes, overlay updates if this challenge is active.
- [ ] Edit an existing challenge — form pre-populates with existing data.

---

## Epic 3 — Settings UI

### After Story 3-1 (Settings Frame, Tab Bar & Main Tab)

- [ ] `/nxr` opens the panel. `/nelxrated` also opens it.
- [ ] `/nxr help` prints available commands to chat.
- [ ] Panel looks correct — dark background, crimson borders, gold section titles, no layout breaks.
- [ ] All five tabs are visible: Main, Challenges, Characters, Settings, Import/Export.
- [ ] Pressing **Escape** closes the panel.
- [ ] Switching tabs shows the correct sub-panel and hides the others.
- [ ] Main tab shows addon name, description, and version number.

### After Story 3-2 (Characters Tab)

- [ ] After playing arenas on at least one character, the Characters tab lists that character with correct name, realm, class/spec, and ratings per bracket.
- [ ] Remove a character. Confirm it disappears from the list immediately.
- [ ] Confirm existing challenges are **not** deleted after removing a character.
- [ ] Empty state message shown when no characters are tracked.

### After Story 3-3 (Settings Tab)

- [ ] Type an account name and reload. Confirm it is restored.
- [ ] Opacity sliders move and display their current value.
- [ ] Opacity values persist after `/reload`.
- [ ] Background checkbox toggles overlay backdrop immediately (live update, no reload).
- [ ] *(Live opacity update wiring verified in Epic 4-5 below)*

### After Story 3-4 (Import/Export Tab)

- [ ] Click Export — a text string appears in the box beginning with `NelxRated-Export-v1`.
- [ ] The string contains recognizable data (character names, ratings).
- [ ] The text is selectable and copyable; typing in the export box does not alter the exported content.
- [ ] On **Account B**: paste the export string and click Import.
- [ ] Characters from A that don't exist on B are **added** to B's character list.
- [ ] Characters that already exist on B are **not overwritten** (verify ratings are unchanged).
- [ ] The Characters tab refreshes immediately showing the new characters.
- [ ] Status feedback shows: "Imported X character(s), skipped Y duplicate(s)."
- [ ] Paste a deliberately broken string — confirm a readable error message appears (no Lua error popup).

---

## Epic 4 — Overlay

### After Story 4-1 (Overlay Frame — Movable, Persisted, Background Toggle)

- [ ] Overlay frame is visible on login when a challenge is active.
- [ ] Frame can be dragged to a new position.
- [ ] `/reload` — overlay restores to the dragged position.
- [ ] With no active challenge, the overlay is hidden entirely.
- [ ] Toggle "Show overlay background" in Settings — backdrop appears/disappears immediately.

### After Story 4-2 (Spec List Display)

- [ ] Create a **spec** challenge — the correct spec icon(s) appear in the overlay.
- [ ] Create a **class** challenge — the correct **class** icon appears for those rows (not individual spec icons).
- [ ] Track two characters of the same spec in any selected bracket. Only **one** row appears in the overlay, showing the higher-rated character's data.
- [ ] Delete the active challenge — its rows disappear from the overlay.
- [ ] A spec with no tracked character shows "—" for rating and no character name.

### After Story 4-3 (Hover Tooltips)

- [ ] Hover over a spec row — tooltip appears showing spec name, character name-realm, rating, and bracket name.
- [ ] If multiple characters match the spec, all are listed (sorted by rating descending).
- [ ] Goal progress line shown: e.g. `"Goal: 1800 (94%)"`.
- [ ] Hovering a row with no tracked character shows: "No character tracked for this spec".
- [ ] Move mouse away — tooltip hides.

### After Story 4-4 (Rating Progress Colors)

- [ ] Set a challenge goal **above** your current rating by >20% — rating text is **white**.
- [ ] Set a goal so you are at ~80–89% progress — color is **orange**.
- [ ] Set a goal so you are at ~90–99% progress — color is **yellow**.
- [ ] Set a goal at or below your current rating (100%+) — a **checkmark texture** appears (not a ✓ character).

### After Story 4-5 (Overlay Opacity & Arena/BG State)

- [ ] Set outside-arena opacity to 0.5. Confirm overlay is semi-transparent in open world.
- [ ] Queue into an arena. Confirm opacity switches to inside-arena value on zone entry.
- [ ] Leave the arena. Confirm opacity switches back.
- [ ] Set either opacity to **0**. Confirm hovering over rows produces **no tooltip**.
- [ ] Set opacity back above 0. Confirm tooltips work again.
- [ ] Changing opacity slider in Settings updates the overlay **immediately** (no reload needed).
