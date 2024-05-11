---------------------------------------------------------Minimap Icon---------------------------------------------------------
local StriLiLDB = LibStub("LibDataBroker-1.1"):NewDataObject("StriLi!", {
    type = "data source",
    text = "StriLi!",
    icon = "Interface\\AddOns\\StriLi\\StriLiIcon",
    OnTooltipShow = function(tooltip)
        tooltip:SetText(string.format("%40s","StriLi "..GetAddOnMetadata("StriLi", "Version")), 0,0.9,1)
        tooltip:AddLine(StriLi.Lang.Tooltip.leftClickText, 1, 1, 1)
        tooltip:AddLine(StriLi.Lang.Tooltip.rightClickText, 1, 1, 1)
        tooltip:AddLine(StriLi.Lang.Tooltip.dragClickText, 1, 1, 1)
        tooltip:Show()
    end,
    OnClick = function(_, button)
        if button == "LeftButton" then
            StriLi.MainFrame:toggle()
        elseif button == "RightButton" then
            StriLi.ItemHistory:toggle()
        end
    end,
})
local icon = LibStub("LibDBIcon-1.0")

function StriLi:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("StriLiDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    });

    icon:Register("StriLi!", StriLiLDB, self.db.profile.minimap);

end

------------------------------------------------------------------------------------------------------------------------------
StriLi.VersionEncrypt = { 95219, 65423, 112556, 8858, 160013, 104715, 39416 };
StriLi.Key = { n = 205889, d = 2633 };
StriLi.EventHandler:init();
