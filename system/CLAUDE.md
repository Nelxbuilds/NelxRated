# system/ — WoW Integration and Peripheral Hooks

Integrates with WoW subsystems. Files are independent of each other. All defer via events — load order within system/ is not significant. All load after ui/ (MainFrame.lua must be loaded before WoWOptionsPanel + MinimapButton execute).

## Sync.lua
- Addon messaging over C_ChatInfo (prefix: "NXR_SYNC")
- Chunked sends (200 chars/chunk), buffer timeout 30s, response timeout 5s
- NXR.InitiateSync() — /nxr sync; NXR.SyncSelfTest() — /nxr sync selftest
- After inbound merge: NXR.RefreshOverlay() (nil-guarded)
- Lint D2: merge by account key, never overwrite (NelxRatedDB.characters = importedData is forbidden)

## Tooltip.lua
- TooltipDataProcessor hooks for Enum.TooltipDataType.Currency and .Item
- Appends per-character amounts for IDs in NXR.TRACKED_CURRENCIES / NXR.TRACKED_ITEMS
- Respects NelxRatedDB.settings.disableTooltip

## WoWOptionsPanel.lua
- Settings.RegisterCanvasLayoutCategory — WoW Settings > AddOns discovery page
- Static launch page only; calls NXR.CreateNXRButton + NXR.ToggleMainFrame (deferred to ADDON_LOADED)
- Stores NXR.wowOptionsCategoryID = category:GetID()

## MinimapButton.lua
- LibDataBroker + LibDBIcon-1.0; deferred to PLAYER_LOGIN
- Left-click: NXR.ToggleMainFrame(); Right-click: NXR.SelectTab("Settings")
- Position saved to NelxRatedDB.settings.minimapPosition
