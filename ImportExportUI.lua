local addonName, NXR = ...

-- ============================================================================
-- Import/Export Tab (Story 3-4)
-- ============================================================================

local HEADER = "NelxRated-Export-v1"
local panel

-- ============================================================================
-- Export
-- ============================================================================

local function SerializeCharacters()
    local lines = { HEADER }

    for key, char in pairs(NelxRatedDB.characters) do
        table.insert(lines, "[BEGIN_CHAR]")
        table.insert(lines, "key=" .. key)
        table.insert(lines, "name=" .. (char.name or ""))
        table.insert(lines, "realm=" .. (char.realm or ""))
        table.insert(lines, "account=" .. (char.account or ""))
        table.insert(lines, "classFileName=" .. (char.classFileName or ""))
        table.insert(lines, "classDisplayName=" .. (char.classDisplayName or ""))
        table.insert(lines, "specID=" .. tostring(char.specID or ""))
        table.insert(lines, "specName=" .. (char.specName or ""))

        -- Non-spec brackets (2v2, 3v3)
        if char.brackets then
            for bi, data in pairs(char.brackets) do
                table.insert(lines, "bracket_" .. bi .. "_rating=" .. (data.rating or 0))
                table.insert(lines, "bracket_" .. bi .. "_mmr=" .. (data.mmr or 0))
            end
        end

        -- Per-spec brackets (Blitz, Solo Shuffle)
        if char.specBrackets then
            for specID, brackets in pairs(char.specBrackets) do
                for bi, data in pairs(brackets) do
                    table.insert(lines, "specbracket_" .. specID .. "_" .. bi .. "_rating=" .. (data.rating or 0))
                    table.insert(lines, "specbracket_" .. specID .. "_" .. bi .. "_mmr=" .. (data.mmr or 0))
                end
            end
        end

        table.insert(lines, "[END_CHAR]")
    end

    return table.concat(lines, "\n")
end

-- ============================================================================
-- Import
-- ============================================================================

local function DeserializeCharacters(text)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line:match("^%s*(.-)%s*$")) -- trim
    end

    if #lines == 0 or lines[1] ~= HEADER then
        return nil, "Invalid format: missing header line '" .. HEADER .. "'"
    end

    local chars = {}
    local current = nil

    for i = 2, #lines do
        local line = lines[i]

        if line == "[BEGIN_CHAR]" then
            current = { brackets = {}, specBrackets = {} }
        elseif line == "[END_CHAR]" then
            if current and current.key then
                chars[current.key] = current
                current.key = nil -- remove internal key from stored data
            end
            current = nil
        elseif current then
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then
                -- Per-spec bracket data
                local specID, bi, field = k:match("^specbracket_(%d+)_(%d+)_(%a+)$")
                if specID and bi and field then
                    specID = tonumber(specID)
                    bi = tonumber(bi)
                    current.specBrackets[specID] = current.specBrackets[specID] or {}
                    current.specBrackets[specID][bi] = current.specBrackets[specID][bi] or {}
                    current.specBrackets[specID][bi][field] = tonumber(v) or 0
                    current.specBrackets[specID][bi].updatedAt = current.specBrackets[specID][bi].updatedAt or time()
                else
                    -- Regular bracket data
                    local bracketIdx, bracketField = k:match("^bracket_(%d+)_(%a+)$")
                    if bracketIdx and bracketField then
                        bracketIdx = tonumber(bracketIdx)
                        current.brackets[bracketIdx] = current.brackets[bracketIdx] or {}
                        current.brackets[bracketIdx][bracketField] = tonumber(v) or 0
                        current.brackets[bracketIdx].updatedAt = current.brackets[bracketIdx].updatedAt or time()
                    elseif k == "specID" then
                        current[k] = tonumber(v)
                    elseif k == "key" then
                        current.key = v
                    else
                        current[k] = v
                    end
                end
            end
        end
    end

    return chars
end

local function MergeCharacters(imported)
    local added, skipped = 0, 0

    for key, char in pairs(imported) do
        if NelxRatedDB.characters[key] then
            skipped = skipped + 1
        else
            NelxRatedDB.characters[key] = char
            added = added + 1
        end
    end

    return added, skipped
end

-- ============================================================================
-- UI
-- ============================================================================

function NXR.CreateImportExportPanel(parent)
    if panel then return panel end

    panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -8)
    title:SetText("Import / Export")
    title:SetTextColor(unpack(NXR.COLORS.GOLD))

    -- ----------------------------------------------------------------
    -- Export section
    -- ----------------------------------------------------------------
    local exportLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    exportLabel:SetPoint("TOPLEFT", 8, -36)
    exportLabel:SetText("Export")

    local exportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    exportBtn:SetSize(80, 24)
    exportBtn:SetPoint("LEFT", exportLabel, "RIGHT", 12, 0)
    exportBtn:SetText("Export")
    exportBtn:SetNormalFontObject("GameFontNormalSmall")

    local exportBox = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
    exportBox:SetPoint("TOPLEFT", 8, -60)
    exportBox:SetPoint("RIGHT", panel, "RIGHT", -8, 0)
    exportBox:SetHeight(120)
    exportBox:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    exportBox:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    exportBox:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.6)
    exportBox:SetFontObject("ChatFontSmall")
    exportBox:SetTextInsets(6, 6, 6, 6)
    exportBox:SetAutoFocus(false)
    exportBox:SetMultiLine(true)
    exportBox:EnableMouse(true)

    -- Make read-only: restore text if user types
    local exportText = ""
    exportBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            self:SetText(exportText)
        end
    end)
    exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Select all on focus
    exportBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)

    exportBtn:SetScript("OnClick", function()
        exportText = SerializeCharacters()
        exportBox:SetText(exportText)
        exportBox:SetFocus()
        exportBox:HighlightText()
    end)

    -- ----------------------------------------------------------------
    -- Import section
    -- ----------------------------------------------------------------
    local importLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    importLabel:SetPoint("TOPLEFT", 8, -192)
    importLabel:SetText("Import")

    local importBox = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
    importBox:SetPoint("TOPLEFT", 8, -212)
    importBox:SetPoint("RIGHT", panel, "RIGHT", -8, 0)
    importBox:SetHeight(120)
    importBox:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    importBox:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    importBox:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.6)
    importBox:SetFontObject("ChatFontSmall")
    importBox:SetTextInsets(6, 6, 6, 6)
    importBox:SetAutoFocus(false)
    importBox:SetMultiLine(true)
    importBox:EnableMouse(true)
    importBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local statusText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", 8, -344)

    local importBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    importBtn:SetSize(80, 24)
    importBtn:SetPoint("LEFT", importLabel, "RIGHT", 12, 0)
    importBtn:SetText("Import")
    importBtn:SetNormalFontObject("GameFontNormalSmall")

    importBtn:SetScript("OnClick", function()
        local text = importBox:GetText()
        if not text or text == "" then
            statusText:SetTextColor(1, 0.3, 0.3)
            statusText:SetText("Paste export data above first.")
            return
        end

        local chars, err = DeserializeCharacters(text)
        if not chars then
            statusText:SetTextColor(1, 0.3, 0.3)
            statusText:SetText(err)
            return
        end

        local added, skipped = MergeCharacters(chars)
        statusText:SetTextColor(0.3, 1, 0.3)
        statusText:SetText("Imported " .. added .. " character(s), skipped " .. skipped .. " duplicate(s).")

        -- Refresh overlay and characters tab
        if NXR.RefreshOverlay then NXR.RefreshOverlay() end

        importBox:SetText("")
    end)

    return panel
end
