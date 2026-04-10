# Epic 5 — Home Screen

A Home tab in the main frame sidebar that serves as the default landing page. Provides an overview of the addon, quick-start guidance, and links to the project's external resources.

**Depends on**: Epic 3 (main frame & sidebar navigation)

---

## Story 5-1 — Home Tab

**Goal**: Add a Home tab as the first item in the sidebar navigation, serving as the default view when the frame opens.

**Acceptance Criteria**:

- [ ] "Home" appears as the first nav item in the sidebar, above Challenges
- [ ] Home is the default selected tab when the frame opens
- [ ] The tab displays: addon name, version number, and a short description of NelxRated
- [ ] A "Getting Started" section with brief instructions (e.g., "Play a rated game to start tracking", "Create a challenge to set rating goals")
- [ ] CurseForge and GitHub URLs displayed as selectable/copyable text (EditBox or highlight-on-click)
- [ ] Version number pulled from `C_AddOns.GetAddOnMetadata(addonName, "Version")`
- [ ] Uses the PvP crimson design system consistent with the rest of the frame

**Technical Hints**:

- For copyable links, use a small `EditBox` with `SetAutoFocus(false)`, `HighlightText()` on focus
- Keep the layout clean and simple — this is a welcome screen, not a dashboard
