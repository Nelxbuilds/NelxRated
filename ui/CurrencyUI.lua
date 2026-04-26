local addonName, NXR = ...

local PAD_OUTER  = 12
local PAD_INNER  = 8
local ROW_HEIGHT = 28
local ROW_GAP    = 2

local COL_CHAR_W   = 160
local COL_VAL_W    = 80
local HEADER_H     = 24

local sortKey     = "char"
local sortAsc     = true
local currPanel   = nil
local scrollChild = nil
local rows        = {}
local emptyLabel  = nil
local headerBtns  = {}

local COLUMNS = {
    { key = "char",  label = "Character" },
}
for _, c in ipairs(NXR.TRACKED_CURRENCIES) do
    table.insert(COLUMNS, { key = "currency_" .. c.id, label = c.name, currencyId = c.id })
end
for _, item in ipairs(NXR.TRACKED_ITEMS) do
    table.insert(COLUMNS, { key = "item_" .. item.id, label = item.name, itemId = item.id })
end

local function GetColWidth(col)
    if col.key == "char" then return COL_CHAR_W end
    return COL_VAL_W
end

local function GetCharValue(char, col)
    if col.currencyId then
        if char.currencies and char.currencies[col.currencyId] then
            return char.currencies[col.currencyId].amount or 0
        end
        return nil
    elseif col.itemId then
        if char.items and char.items[col.itemId] then
            return char.items[col.itemId].count or 0
        end
        return nil
    end
    return nil
end

local function BuildSortedKeys(characters)
    local keys = {}
    for k, char in pairs(characters) do
        local hidden = NelxRatedDB.settings and
            NelxRatedDB.settings.hiddenCharacters and
            NelxRatedDB.settings.hiddenCharacters[k]
        if not hidden then
            table.insert(keys, k)
        end
    end

    table.sort(keys, function(a, b)
        local charA = characters[a]
        local charB = characters[b]
        local valA, valB

        if sortKey == "char" then
            valA = a:lower()
            valB = b:lower()
            if sortAsc then return valA < valB else return valA > valB end
        end

        for _, col in ipairs(COLUMNS) do
            if col.key == sortKey then
                valA = GetCharValue(charA, col) or -1
                valB = GetCharValue(charB, col) or -1
                break
            end
        end

        valA = valA or -1
        valB = valB or -1
        if sortAsc then return valA < valB else return valA > valB end
    end)

    return keys
end

local function HasAnyCurrencyData(characters)
    for _, char in pairs(characters) do
        if char.currencies or char.items then
            return true
        end
    end
    return false
end

local function UpdateHeaderHighlights()
    for _, hdr in ipairs(headerBtns) do
        if hdr.colKey == sortKey then
            hdr.label:SetTextColor(unpack(NXR.COLORS.CRIMSON_BRIGHT))
        else
            hdr.label:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

local function Refresh()
    for _, row in ipairs(rows) do row:Hide() end

    local characters = NelxRatedDB and NelxRatedDB.characters or {}

    if not HasAnyCurrencyData(characters) then
        emptyLabel:Show()
        scrollChild:SetHeight(1)
        return
    end
    emptyLabel:Hide()

    local keys = BuildSortedKeys(characters)

    local yOff = 0
    for i, key in ipairs(keys) do
        local char = characters[key]

        if not rows[i] then
            local row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
            row:SetHeight(ROW_HEIGHT)
            row:SetBackdrop({
                bgFile   = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })

            row.cols = {}
            local xOff = 0
            for ci, col in ipairs(COLUMNS) do
                local w = GetColWidth(col)
                local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                if ci == 1 then
                    fs:SetPoint("LEFT", row, "LEFT", xOff + 8, 0)
                else
                    fs:SetPoint("LEFT", row, "LEFT", xOff + 4, 0)
                end
                fs:SetWidth(w - 8)
                fs:SetJustifyH(ci == 1 and "LEFT" or "CENTER")
                row.cols[ci] = fs
                xOff = xOff + w
            end

            rows[i] = row
        end

        local row = rows[i]
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -yOff)
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

        if i % 2 == 0 then
            row:SetBackdropColor(0.12, 0.12, 0.12, 0.5)
        else
            row:SetBackdropColor(0.08, 0.08, 0.08, 0.5)
        end
        row:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.3)

        for ci, col in ipairs(COLUMNS) do
            local fs = row.cols[ci]
            if ci == 1 then
                fs:SetText(key)
                if char.classFileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[char.classFileName] then
                    local cc = RAID_CLASS_COLORS[char.classFileName]
                    fs:SetTextColor(cc.r, cc.g, cc.b)
                else
                    fs:SetTextColor(0.8, 0.8, 0.8)
                end
            else
                local val = GetCharValue(char, col)
                if val ~= nil then
                    fs:SetText(tostring(val))
                    fs:SetTextColor(1, 1, 1)
                else
                    fs:SetText("--")
                    fs:SetTextColor(0.4, 0.4, 0.4)
                end
            end
        end

        row:Show()
        yOff = yOff + ROW_HEIGHT + ROW_GAP
    end

    for j = #keys + 1, #rows do
        rows[j]:Hide()
    end

    scrollChild:SetHeight(math.max(yOff, 1))
end

function NXR.CreateCurrencyPanel(parent)
    if currPanel then return currPanel end

    currPanel = CreateFrame("Frame", nil, parent)
    currPanel:SetAllPoints()

    local title = currPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", PAD_INNER, -PAD_INNER)
    title:SetText("Currency")
    title:SetTextColor(unpack(NXR.COLORS.GOLD))

    emptyLabel = currPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyLabel:SetPoint("CENTER", 0, 0)
    emptyLabel:SetText("No data -- play a game or reload")
    emptyLabel:SetTextColor(0.55, 0.55, 0.55)
    emptyLabel:SetJustifyH("CENTER")
    emptyLabel:Hide()

    local headerFrame = CreateFrame("Frame", nil, currPanel, "BackdropTemplate")
    headerFrame:SetPoint("TOPLEFT", 0, -32)
    headerFrame:SetPoint("RIGHT", currPanel, "RIGHT", 0, 0)
    headerFrame:SetHeight(HEADER_H)
    headerFrame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    headerFrame:SetBackdropColor(0.06, 0.04, 0.04, 0.9)
    headerFrame:SetBackdropBorderColor(unpack(NXR.COLORS.CRIMSON_DIM))

    local xOff = 0
    for _, col in ipairs(COLUMNS) do
        local w = GetColWidth(col)
        local btn = CreateFrame("Button", nil, headerFrame)
        btn:SetHeight(HEADER_H)
        btn:SetWidth(w)
        btn:SetPoint("LEFT", headerFrame, "LEFT", xOff, 0)
        btn.colKey = col.key

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.label:SetPoint("CENTER")
        btn.label:SetText(col.label)
        btn.label:SetTextColor(0.7, 0.7, 0.7)

        btn:SetScript("OnClick", function()
            if sortKey == col.key then
                sortAsc = not sortAsc
            else
                sortKey = col.key
                sortAsc = true
            end
            UpdateHeaderHighlights()
            Refresh()
        end)

        btn:SetScript("OnEnter", function(self)
            self.label:SetTextColor(1, 1, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            UpdateHeaderHighlights()
        end)

        table.insert(headerBtns, btn)
        xOff = xOff + w
    end

    UpdateHeaderHighlights()

    local scroll = CreateFrame("ScrollFrame", nil, currPanel)
    scroll:SetPoint("TOPLEFT", 0, -(32 + HEADER_H + 2))
    scroll:SetPoint("BOTTOMRIGHT", 0, 4)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(cur - delta * 40, max)))
    end)

    scrollChild = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(scrollChild)
    scrollChild:SetHeight(1)
    scroll:SetScript("OnSizeChanged", function(self, w)
        scrollChild:SetWidth(w)
    end)

    currPanel:SetScript("OnShow", function() Refresh() end)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    eventFrame:SetScript("OnEvent", function()
        if currPanel and currPanel:IsShown() then
            Refresh()
        end
    end)

    function currPanel:Refresh()
        Refresh()
    end

    return currPanel
end
