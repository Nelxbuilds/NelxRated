# Bug Tracker

Add bugs here as you find them. Format: one entry per bug, newest at the top.

---

<!--
Template:
## BUG-N — Short description
**Story**: X-Y
**Status**: open | in progress | fixed
**Found**: how/where you found it
**Description**: what's wrong
**Fix**: (fill in when resolved)
-->

## BUG-1 — /nxr doesn't open on first enter
**Story**: 2-2
**Status**: fixed
**Found**: human checkpoint for this story
**Description**: first command execution of /nxr does nothing. No LUA error just nothing. On second execution the challenges frame is being shown
**Fix**: Frame was shown by default on creation, then the toggle immediately hid it. Added early return after first creation so the frame stays visible.
