local addonName, NXR = ...

local minimapFrame = CreateFrame("Frame")
minimapFrame:RegisterEvent("PLAYER_LOGIN")
minimapFrame:SetScript("OnEvent", function(self, event)
    if event ~= "PLAYER_LOGIN" then return end
    self:UnregisterEvent("PLAYER_LOGIN")

    if not NelxRatedDB or not NelxRatedDB.settings then return end

    NelxRatedDB.settings.minimapPosition = NelxRatedDB.settings.minimapPosition or {}

    local LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
    local LDBIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)

    if not LDB or not LDBIcon then return end

    local dataObject = LDB:NewDataObject("NelxRated", {
        type  = "launcher",
        icon  = "Interface\\AddOns\\NelxRated\\images\\logo",
        label = "NelxRated",

        OnClick = function(_, button)
            if button == "LeftButton" then
                NXR.ToggleMainFrame()
            elseif button == "RightButton" then
                NXR.SelectTab("Settings")
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:SetText("NelxRated", 1, 0.82, 0)
            tooltip:AddLine("Left-click: Toggle window", 1, 1, 1)
            tooltip:AddLine("Right-click: Settings", 1, 1, 1)
            tooltip:Show()
        end,
    })

    LDBIcon:Register("NelxRated", dataObject, NelxRatedDB.settings.minimapPosition)

    local show = NelxRatedDB.settings.showMinimapButton
    if show == nil then show = true end
    if show then
        LDBIcon:Show("NelxRated")
    else
        LDBIcon:Hide("NelxRated")
    end
end)
