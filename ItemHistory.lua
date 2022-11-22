--[[
Class: ItemHistory

variables:
    frame

methods:

--]]


StriLi.ItemHistory = { items = {}, players = {}, frame = nil, count = 0};

-- CreateFrame("Frame","NAME", StriLi.ItemHistory.frame.ScrollFrame, "StriLi_Row_Template");

function StriLi.ItemHistory:init()

    self.frame = CreateFrame("Frame","StriLi_ItemHistory_Frame", StriLi.MainFrame.frame,"StriLi_ItemHistory_Template");
    self.frame.ScrollFrame.ScrollBar = StriLi_ItemHistory_Frame_ScrollFrameScrollBar;
    self.frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT",StriLi_ItemHistory_Frame_ScrollFrame,266,-16);
    self.frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT",StriLi_ItemHistory_Frame_ScrollFrame,266,16);
    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);
    self.frame.ScrollFrame.ScrollBar:Hide();

    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "1","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN");
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN");




end

function StriLi.ItemHistory:add(itemLink, player, playerClass)

    assert(type(itemLink) == "string"); --should be an itemLink.
    assert(type(player) == "string");
    assert(type(playerClass) == "string");

    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
            "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

    table.insert(self.items, Name);
    table.insert(self.players, player);

    local frame = CreateFrame("Frame",nil, self.frame.ScrollFrame.Content, "StriLi_ItemHistoryPlate_Template");
    frame:SetPoint("TOPLEFT", 0, -30*self.count-2);

    frame.ItemIcon:SetTexture(GetItemIcon(Id));
    frame.ItemText:SetText(itemLink);
    frame.ItemPlayer:SetText(player);

    StriLi_SetTextColorByClass(frame.ItemPlayer, playerClass);

    self.frame.ScrollFrame.Content:SetHeight(self.frame.ScrollFrame.Content:GetHeight() + 30);

    self.count = self.count + 1;
    frame.itemHistoryIndex = self.count;

end

function StriLi.ItemHistory:editItem(item, index)
    self.items[index] = item;
end

function StriLi.ItemHistory:editPlayer(player, index)
    self.players[index] = player;
end

function StriLi.ItemHistory:OnMouseWheel(value)

    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);

    local height, viewHeight = self.frame.ScrollFrame:GetHeight(), self.frame.ScrollFrame.Content:GetHeight();

    if height > viewHeight then
        self.frame.ScrollFrame.ScrollBar:Hide()
    else
        self.frame.ScrollFrame.ScrollBar:Show()
        local diff = height - viewHeight
        local delta = 1
        if value < 0 then
            delta = -1
        end
        print(self.frame.ScrollFrame.ScrollBar:GetValue());
        self.frame.ScrollFrame.ScrollBar:SetValue(math.min(math.max(self.frame.ScrollFrame.ScrollBar:GetValue() + delta*(1000/(diff/45)),0), 1000))
    end

end