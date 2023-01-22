---------------------------------------------------------Minimap Icon---------------------------------------------------------
local StriLiLDB = LibStub("LibDataBroker-1.1"):NewDataObject("StriLi!", {
    type = "data source",
    text = "StriLi!",
    icon = "Interface\\AddOns\\StriLi\\StriLiIcon",
    OnClick = function(this, button)
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

StriLi.EventHandler:init();
