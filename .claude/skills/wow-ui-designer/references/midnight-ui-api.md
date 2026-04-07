# WoW Midnight 12.x UI API Reference

Deep reference for frame API patterns validated in WoW Midnight (12.x).

---

## Frame Strata & Layers

### Strata (bottom to top)
`BACKGROUND` → `LOW` → `MEDIUM` → `HIGH` → `DIALOG` → `FULLSCREEN` → `FULLSCREEN_DIALOG` → `TOOLTIP`

```lua
frame:SetFrameStrata("HIGH")     -- above most UI, below dialogs
frame:SetFrameLevel(10)          -- relative ordering within same strata (0–127)
```

### Draw Layers (within a frame, bottom to top)
`BACKGROUND` → `BORDER` → `ARTWORK` → `OVERLAY` → `HIGHLIGHT`

```lua
local tex = frame:CreateTexture(nil, "ARTWORK")
local fs  = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
```

---

## Anchor Reference

```lua
-- All 9 anchor points:
-- "TOPLEFT"    "TOP"    "TOPRIGHT"
-- "LEFT"       "CENTER" "RIGHT"
-- "BOTTOMLEFT" "BOTTOM" "BOTTOMRIGHT"

frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
-- xOffset: positive = right,  negative = left
-- yOffset: positive = up,     negative = down

-- Shorthand helpers:
frame:SetAllPoints(parent)          -- fills parent completely
frame:ClearAllPoints()              -- detach before re-anchoring

-- Common patterns:
child:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -PAD)    -- top-left with padding
child:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -PAD) -- top-right with padding
-- Stack vertically under another element:
row2:SetPoint("TOPLEFT", row1, "BOTTOMLEFT", 0, -PAD_INNER)
```

---

## Texture API

```lua
local tex = frame:CreateTexture(nil, "ARTWORK")
tex:SetSize(w, h)
tex:SetPoint(...)

-- Solid colour (no file needed):
tex:SetColorTexture(r, g, b, a)

-- Atlas / Interface file:
tex:SetTexture("Interface\\Icons\\Spell_Holy_HolyBolt")
tex:SetTexture("Interface\\Buttons\\WHITE8X8")   -- white 1px, good for solid rects

-- Texture coords (crop):
tex:SetTexCoord(left, right, top, bottom)  -- 0.0–1.0 UV coords

-- Colour tinting over a texture:
tex:SetVertexColor(r, g, b, a)

-- Gradient:
tex:SetGradient("HORIZONTAL", { r=0, g=0, b=0, a=0 }, { r=0, g=0, b=0, a=0.8 })
-- Direction: "HORIZONTAL" | "VERTICAL"
```

---

## FontString API

```lua
local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fs:SetPoint(...)
fs:SetText("Hello")
fs:SetTextColor(r, g, b, a)
fs:SetJustifyH("LEFT")   -- "LEFT" | "CENTER" | "RIGHT"
fs:SetJustifyV("MIDDLE") -- "TOP"  | "MIDDLE" | "BOTTOM"
fs:SetWordWrap(true)
fs:SetMaxLines(3)
-- Custom font:
fs:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
-- Get current text size:
local w, h = fs:GetStringWidth(), fs:GetStringHeight()
```

### Available built-in font objects
| Object | Use |
|---|---|
| `GameFontNormalLarge` | Panel titles |
| `GameFontNormal` | Section headers, labels |
| `GameFontNormalSmall` | Body text, list rows |
| `GameFontNormalTiny` | Metadata, timestamps |
| `GameFontHighlightLarge` | Big numbers (ratings) |
| `GameFontHighlight` | Highlighted body text |
| `GameFontDisable` | Muted / disabled text |
| `NumberFontNormalLarge` | Large numeric displays |

---

## BackdropTemplate

Always inherit `"BackdropTemplate"` in `CreateFrame`:

```lua
local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
f:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",  -- solid fill
    edgeFile = "Interface\\Buttons\\WHITE8X8",  -- solid border
    -- OR for classic tooltip look:
    -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 1,       -- border pixel width (use 1 for crisp 1px)
    tile     = false,
    insets   = { left=0, right=0, top=0, bottom=0 },
})
f:SetBackdropColor(r, g, b, a)
f:SetBackdropBorderColor(r, g, b, a)
```

**Gotcha:** `BackdropTemplate` must be inherited — you cannot call `SetBackdrop` on a raw Frame without it in 12.x.

---

## ScrollBox + ScrollBar (12.x)

Replaces old `FauxScrollFrame`. Use for all list UI.

```lua
-- Template names:
"WowScrollBoxList"   -- for variable/uniform height item lists
"ScrollBox"          -- for arbitrary scrollable content

"MinimalScrollBar"   -- thin right-side scrollbar (preferred for addons)
"ScrollBar"          -- full-width classic scrollbar

-- Wire them together:
ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar)

-- Data provider:
local dp = CreateDataProvider()
dp:Insert({ text="Row 1", data=myData })
dp:Flush()   -- clear all

-- View initialiser (called per visible row):
local view = CreateScrollBoxListLinearView()
view:SetElementInitializer("Frame", function(row, elementData)
    -- elementData is what you passed to dp:Insert()
end)
```

---

## Animation System

```lua
-- AnimationGroup on any frame or texture:
local ag = frame:CreateAnimationGroup()
ag:SetLooping("NONE")   -- "NONE" | "REPEAT" | "BOUNCE"

-- Alpha animation:
local anim = ag:CreateAnimation("Alpha")
anim:SetFromAlpha(0); anim:SetToAlpha(1)
anim:SetDuration(0.3)
anim:SetOrder(1)   -- sequence order within the group

-- Translation (movement):
local move = ag:CreateAnimation("Translation")
move:SetOffset(0, 10)   -- x, y delta
move:SetDuration(0.2)

-- Scale:
local scale = ag:CreateAnimation("Scale")
scale:SetScale(1.1, 1.1)
scale:SetOrigin("CENTER", 0, 0)
scale:SetDuration(0.15)

-- Callbacks:
ag:SetScript("OnFinished", function() ... end)
ag:SetScript("OnPlay",     function() ... end)

-- Control:
ag:Play()
ag:Stop()
ag:Pause()
ag:IsPlaying()   -- returns bool
```

**Gotcha:** Animations run on the frame's alpha/position independently — don't set frame alpha directly while an alpha animation is playing, or you'll fight each other.

---

## UIFrameFadeIn / FadeOut (convenience)

```lua
-- Built-in helpers — use for simple show/hide fades:
UIFrameFadeIn(frame, duration, fromAlpha, toAlpha)
UIFrameFadeOut(frame, duration, fromAlpha, toAlpha)
-- Example:
UIFrameFadeIn(myFrame, 0.3, 0, 1)
UIFrameFadeOut(myFrame, 0.2, 1, 0)
```

---

## Timer Patterns (never use OnUpdate for polling)

```lua
-- One-shot:
C_Timer.After(1.5, function()
    -- runs once after 1.5 seconds
end)

-- Repeating:
local ticker = C_Timer.NewTicker(5, function()
    -- runs every 5 seconds
end)
ticker:Cancel()  -- stop it

-- Throttled OnUpdate (only when you genuinely need per-frame):
local elapsed = 0
frame:SetScript("OnUpdate", function(self, dt)
    elapsed = elapsed + dt
    if elapsed < 0.1 then return end  -- throttle to 10 Hz
    elapsed = 0
    -- do work
end)
```

---

## Mouse Interaction

```lua
frame:EnableMouse(true)           -- required for OnClick, OnEnter, OnLeave
frame:EnableMouseWheel(true)      -- required for OnMouseWheel
frame:SetMovable(true)            -- required for StartMoving()
frame:RegisterForDrag("LeftButton")  -- required before StartMoving

frame:SetScript("OnEnter",      function(self) ... end)
frame:SetScript("OnLeave",      function(self) ... end)
frame:SetScript("OnClick",      function(self, button) ... end)
frame:SetScript("OnMouseDown",  function(self, button) ... end)
frame:SetScript("OnMouseUp",    function(self, button) ... end)
frame:SetScript("OnMouseWheel", function(self, delta) ... end)  -- delta: +1/-1
frame:SetScript("OnDragStart",  function(self) self:StartMoving() end)
frame:SetScript("OnDragStop",   function(self) self:StopMovingOrSizing() end)
```

---

## Frame Pooling (for dynamic lists without ScrollBox)

```lua
local pool = CreateFramePool("Frame", parent, nil, function(p, f)
    f:Hide()  -- reset callback
end)

-- Acquire a frame from the pool:
local row = pool:Acquire()
row:Show()

-- Release all back to pool:
pool:ReleaseAll()
```

---

## Common Gotchas

| Problem | Solution |
|---|---|
| `BackdropTemplate` not found | Must pass template string to `CreateFrame` 4th arg |
| Frame invisible but exists | Check `SetShown(true)`, strata, and parent visibility |
| Anchor errors in chat | ClearAllPoints before re-anchoring |
| SavedVariables nil at file scope | Always read in `ADDON_LOADED` handler |
| ScrollBox rows not populating | Check view's DataProvider is set before `InitScrollBoxListWithScrollBar` |
| `SetGradient` wrong args | 12.x uses CreateColor objects: `CreateColor(r,g,b,a)` |
| Registering unknown events | Hard Lua error — verify event name on WoWpedia first |
| Pixel gaps on 1px borders | Ensure frame position is at integer coords: `math.floor(x)` |
| Font not showing | FontString layer must be "OVERLAY" or higher, not "BACKGROUND" |
| Animation not playing | AnimationGroup needs `:Play()` called; check `ag:IsPlaying()` |