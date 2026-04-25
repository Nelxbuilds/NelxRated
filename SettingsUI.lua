local addonName, NXR = ...

-- ============================================================================
-- Settings Tab (Story 3-3)
-- ============================================================================

local panel
local accountInput
local arenaSlider, arenaValueText
local outArenaSlider, outArenaValueText
local scaleSlider, scaleValueText
local columnsSlider, columnsValueText
local groupByRoleCheckbox
local hideZeroCheckbox
local progressBarCheckbox
local titleCheckbox
local bgCheckbox
local lockCheckbox
local overlayToggleBtn
local chartColorBtn

local function Round(val, step)
    return math.floor(val / step + 0.5) * step
end

local function CreateSliderRow(parent, labelText, yOffset, settingsKey, onChange, opts)
    opts = opts or {}
    local minVal  = opts.min or 0
    local maxVal  = opts.max or 1
    local step    = opts.step or 0.05
    local default = opts.default or 1.0
    local fmt     = opts.format or "%.0f%%"
    local fmtMul  = opts.formatMultiplier or 100

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 8, -yOffset)
    label:SetText(labelText)

    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    slider:SetSize(200, 16)
    slider:SetPoint("TOPLEFT", 10, -(yOffset + 20))
    slider:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    slider:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
    slider:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")

    -- Thumb texture
    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(12, 20)
    thumb:SetColorTexture(unpack(NXR.COLORS.CRIMSON_BRIGHT))
    slider:SetThumbTexture(thumb)

    local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    valueText:SetTextColor(0.8, 0.8, 0.8)

    local initial = NelxRatedDB.settings[settingsKey] or default
    slider:SetValue(initial)
    valueText:SetText(string.format(fmt, initial * fmtMul))

    slider:SetScript("OnValueChanged", function(self, value)
        value = Round(value, step)
        NelxRatedDB.settings[settingsKey] = value
        valueText:SetText(string.format(fmt, value * fmtMul))
        if onChange then onChange(value) end
    end)

    return slider, valueText
end

local function CreateCheckRow(parent, labelText, yOffset, settingsKey, onChange)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", 8, -yOffset)

    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    lbl:SetText(labelText)

    cb:SetScript("OnClick", function(self)
        NelxRatedDB.settings[settingsKey] = self:GetChecked()
        if onChange then onChange(self:GetChecked()) end
    end)

    return cb
end

-- ============================================================================
-- Tab system
-- ============================================================================

local TAB_NAMES  = { "Overlay", "History", "General" }
local tabButtons = {}
local tabContent = {}
local activeTab  = 1

local function SelectTab(idx)
    activeTab = idx
    for i, btn in ipairs(tabButtons) do
        if i == idx then
            btn.label:SetTextColor(unpack(NXR.COLORS.CRIMSON_BRIGHT))
            btn.activeLine:Show()
        else
            btn.label:SetTextColor(0.55, 0.52, 0.50)
            btn.activeLine:Hide()
        end
    end
    for i, content in ipairs(tabContent) do
        if i == idx then
            content:Show()
        else
            content:Hide()
        end
    end
end

local function CreateTabStrip(parent, yAnchor)
    local TAB_W = 80
    local TAB_H = 26
    for i, name in ipairs(TAB_NAMES) do
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(TAB_W, TAB_H)
        btn:SetPoint("TOPLEFT", (i - 1) * TAB_W + 8, yAnchor)

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.label:SetAllPoints()
        btn.label:SetJustifyH("CENTER")
        btn.label:SetText(name)

        -- Bottom active indicator
        btn.activeLine = btn:CreateTexture(nil, "OVERLAY")
        btn.activeLine:SetHeight(2)
        btn.activeLine:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 4, 0)
        btn.activeLine:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 0)
        btn.activeLine:SetColorTexture(unpack(NXR.COLORS.CRIMSON_BRIGHT))
        btn.activeLine:Hide()

        local tabIdx = i
        btn:SetScript("OnClick", function() SelectTab(tabIdx) end)
        btn:SetScript("OnEnter", function(self)
            if activeTab ~= tabIdx then
                self.label:SetTextColor(0.78, 0.75, 0.73)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if activeTab ~= tabIdx then
                self.label:SetTextColor(0.55, 0.52, 0.50)
            end
        end)

        tabButtons[i] = btn
    end
end

-- ============================================================================
-- Build content frames
-- ============================================================================

local function BuildOverlayContent(parent)
    local f = CreateFrame("ScrollFrame", nil, parent)
    f:SetPoint("TOPLEFT", 0, 0)
    f:SetPoint("BOTTOMRIGHT", 0, 0)
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(cur - delta * 40, max)))
    end)

    local sc = CreateFrame("Frame", nil, f)
    f:SetScrollChild(sc)
    sc:SetHeight(1)
    f:SetScript("OnSizeChanged", function(self, w)
        sc:SetWidth(w)
    end)

    local y = 8

    arenaSlider, arenaValueText = CreateSliderRow(sc, "Overlay Opacity (In Arena)", y,
        "opacityInArena", function()
            if NXR.Overlay and NXR.Overlay.OnOpacityChanged then
                NXR.Overlay.OnOpacityChanged()
            end
        end)
    y = y + 56

    outArenaSlider, outArenaValueText = CreateSliderRow(sc, "Overlay Opacity (Out of Arena)", y,
        "opacityOutOfArena", function()
            if NXR.Overlay and NXR.Overlay.OnOpacityChanged then
                NXR.Overlay.OnOpacityChanged()
            end
        end)
    y = y + 56

    scaleSlider, scaleValueText = CreateSliderRow(sc, "Overlay Scale", y,
        "overlayScale", function()
            if NXR.Overlay and NXR.Overlay.OnScaleChanged then
                NXR.Overlay.OnScaleChanged()
            end
        end, { min = 0.5, max = 2.0, step = 0.05, default = 1.0 })
    y = y + 56

    columnsSlider, columnsValueText = CreateSliderRow(sc, "Overlay Columns", y,
        "overlayColumns", function()
            NXR.RefreshOverlay()
        end, { min = 1, max = 10, step = 1, default = 1, format = "%d", formatMultiplier = 1 })
    y = y + 56

    bgCheckbox = CreateCheckRow(sc, "Show overlay background & border", y,
        "showOverlayBackground", function()
            if NXR.Overlay and NXR.Overlay.OnBackgroundChanged then
                NXR.Overlay.OnBackgroundChanged()
            end
        end)
    y = y + 34

    lockCheckbox = CreateCheckRow(sc, "Lock overlay position", y,
        "overlayLocked", function()
            if NXR.Overlay and NXR.Overlay.OnLockChanged then
                NXR.Overlay.OnLockChanged()
            end
        end)
    y = y + 34

    groupByRoleCheckbox = CreateCheckRow(sc, "Group overlay by role", y,
        "overlayGroupByRole", function()
            NXR.RefreshOverlay()
        end)
    y = y + 34

    hideZeroCheckbox = CreateCheckRow(sc, "Hide unrated rows", y,
        "hideZeroRatingRows", function()
            NXR.RefreshOverlay()
        end)
    y = y + 34

    progressBarCheckbox = CreateCheckRow(sc, "Show progress bar on overlay", y,
        "showOverlayProgressBar", function()
            NXR.RefreshOverlay()
        end)
    y = y + 34

    titleCheckbox = CreateCheckRow(sc, "Show challenge title on overlay", y,
        "showOverlayTitle", function()
            NXR.RefreshOverlay()
        end)
    y = y + 42

    overlayToggleBtn = NXR.CreateNXRButton(sc, "Show Overlay", 140, 28)
    overlayToggleBtn:SetPoint("TOPLEFT", 10, -y)
    overlayToggleBtn:SetScript("OnClick", function()
        if NXR.Overlay and NXR.Overlay.Toggle then
            NXR.Overlay.Toggle()
        end
        if NelxRatedDB.settings.showOverlay then
            overlayToggleBtn.label:SetText("Hide Overlay")
        else
            overlayToggleBtn.label:SetText("Show Overlay")
        end
    end)
    y = y + 40

    sc:SetHeight(y)
    return f
end

local function BuildHistoryContent(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetPoint("TOPLEFT", 0, 0)
    f:SetPoint("BOTTOMRIGHT", 0, 0)

    local y = 8

    local chartLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chartLabel:SetPoint("TOPLEFT", 8, -y)
    chartLabel:SetText("Chart Line Color")
    y = y + 18

    chartColorBtn = NXR.CreateNXRButton(f, "Default (Crimson)", 180, 24)
    chartColorBtn:SetPoint("TOPLEFT", 10, -y)

    local function UpdateChartColorLabel()
        local val = NelxRatedDB.settings.chartColor or "default"
        if val == "class" then
            chartColorBtn.label:SetText("Class Color")
        else
            chartColorBtn.label:SetText("Default (Crimson)")
        end
    end

    chartColorBtn:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(_, rootDescription)
            rootDescription:CreateButton("Default (Crimson)", function()
                NelxRatedDB.settings.chartColor = "default"
                UpdateChartColorLabel()
                if NXR.RefreshHistoryGraph then NXR.RefreshHistoryGraph() end
            end)
            rootDescription:CreateButton("Class Color", function()
                NelxRatedDB.settings.chartColor = "class"
                UpdateChartColorLabel()
                if NXR.RefreshHistoryGraph then NXR.RefreshHistoryGraph() end
            end)
        end)
    end)

    -- Store for OnShow refresh
    f.UpdateChartColorLabel = UpdateChartColorLabel

    return f
end

local function BuildGeneralContent(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetPoint("TOPLEFT", 0, 0)
    f:SetPoint("BOTTOMRIGHT", 0, 0)

    local y = 8

    local accLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    accLabel:SetPoint("TOPLEFT", 8, -y)
    accLabel:SetText("Account Name")
    y = y + 18

    accountInput = NXR.CreateNXRInput(f, 200, 24)
    accountInput:SetPoint("TOPLEFT", 10, -y)

    local saveAccBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveAccBtn:SetSize(60, 24)
    saveAccBtn:SetPoint("LEFT", accountInput, "RIGHT", 8, 0)
    saveAccBtn:SetText("Save")
    saveAccBtn:SetNormalFontObject("GameFontNormalSmall")

    local accStatus = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    accStatus:SetPoint("LEFT", saveAccBtn, "RIGHT", 8, 0)
    accStatus:SetTextColor(0.3, 1, 0.3)

    saveAccBtn:SetScript("OnClick", function()
        NelxRatedDB.settings.accountName = accountInput:GetText()
        accStatus:SetText("Saved")
        C_Timer.After(2, function() accStatus:SetText("") end)
    end)

    return f
end

-- ============================================================================
-- Public: create settings panel
-- ============================================================================

function NXR.CreateSettingsPanel(parent)
    if panel then return panel end

    panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -8)
    title:SetText("Settings")
    title:SetTextColor(unpack(NXR.COLORS.GOLD))

    -- Tab strip (below title)
    local TAB_H = 26
    local TAB_Y = -30  -- from top of panel
    CreateTabStrip(panel, TAB_Y)

    -- Divider line below tab strip
    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, TAB_Y - TAB_H)
    divider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, TAB_Y - TAB_H)
    divider:SetColorTexture(unpack(NXR.COLORS.CRIMSON_DIM))

    -- Content area below tab strip + divider
    local contentFrame = CreateFrame("Frame", nil, panel)
    contentFrame:SetPoint("TOPLEFT", 0, TAB_Y - TAB_H - 4)
    contentFrame:SetPoint("BOTTOMRIGHT", 0, 0)

    tabContent[1] = BuildOverlayContent(contentFrame)
    tabContent[2] = BuildHistoryContent(contentFrame)
    tabContent[3] = BuildGeneralContent(contentFrame)

    -- Default to Overlay tab
    SelectTab(1)

    panel:SetScript("OnShow", function()
        -- Overlay tab state
        arenaSlider:SetValue(NelxRatedDB.settings.opacityInArena or 1.0)
        outArenaSlider:SetValue(NelxRatedDB.settings.opacityOutOfArena or 1.0)
        scaleSlider:SetValue(NelxRatedDB.settings.overlayScale or 1.0)
        columnsSlider:SetValue(NelxRatedDB.settings.overlayColumns or 1)
        bgCheckbox:SetChecked(NelxRatedDB.settings.showOverlayBackground)
        lockCheckbox:SetChecked(NelxRatedDB.settings.overlayLocked or false)
        groupByRoleCheckbox:SetChecked(NelxRatedDB.settings.overlayGroupByRole or false)
        hideZeroCheckbox:SetChecked(NelxRatedDB.settings.hideZeroRatingRows or false)
        progressBarCheckbox:SetChecked(NelxRatedDB.settings.showOverlayProgressBar or false)
        titleCheckbox:SetChecked(NelxRatedDB.settings.showOverlayTitle or false)
        if NelxRatedDB.settings.showOverlay then
            overlayToggleBtn.label:SetText("Hide Overlay")
        else
            overlayToggleBtn.label:SetText("Show Overlay")
        end
        -- History tab state
        tabContent[2].UpdateChartColorLabel()
        -- General tab state
        accountInput:SetText(NelxRatedDB.settings.accountName or "")
    end)

    return panel
end
