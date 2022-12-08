--[[
Class: ItemHistory

variables:
    frame

methods:

--]]

StriLi.ItemHistory = { items = {}, players = {}, rollType = {}, frame = nil, contentFrame = nil, count = 0};

local function getItemID_fromLink(itemLink)

    assert(type(itemLink) == "string", "Argument itemLink was not a string type.");
    local firstChar = string.sub(itemLink, 1, 1);
    assert(firstChar == "|", "Argument itemLink is not an item link.");

    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
            "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

    return Id;

end

-- CreateFrame("Frame","NAME", StriLi.ItemHistory.frame.ScrollFrame, "StriLi_Row_Template");

function StriLi.ItemHistory:init()

    self.frame = CreateFrame("Frame","StriLi_ItemHistory_Frame", StriLi.MainFrame.frame,"StriLi_ItemHistory_Template");
    self.contentFrame = self.frame.ScrollFrame.Content;
    self.frame.ScrollFrame.ScrollBar = StriLi_ItemHistory_Frame_ScrollFrameScrollBar;
    self.frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT",StriLi_ItemHistory_Frame_ScrollFrame,420,-16);
    self.frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT",StriLi_ItemHistory_Frame_ScrollFrame,420,16);
    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);
    self.frame.ScrollFrame.ScrollBar:Hide();

    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "1","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "2","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "3","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "4","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "5","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "6","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "7","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "8","SHAMAN", "Main", 65);
    self:add("|cffff8000|Hitem:49623:3789:3524:3524:3524:0:0:0:80|h[Schattengram]|h|r", "9","SHAMAN", "Main", 65);



end

function StriLi.ItemHistory:add(itemLink, player, playerClass, rollType, roll)

    assert(type(player) == "string", "Argument player was not a string type.");
    assert(type(playerClass) == "string", "Argument playerClass was not a string type.");
    assert(type(rollType) == "string", "Argument rollType was not a string type.");
    assert(type(roll), "number", "Argument roll was not a number type.");

    local itemId = getItemID_fromLink(itemLink);

    table.insert(self.items, itemLink);
    table.insert(self.players, player);
    table.insert(self.rollType, rollType);

    local frame = CreateFrame("Frame",nil, self.contentFrame, "StriLi_ItemHistoryPlate_Template");
    frame:SetPoint("TOPLEFT", 0, -30*self.count-2);

    frame.ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    frame.ItemText.FontString:SetText(itemLink);
    frame.ItemPlayer.FontString:SetText(player);

    frame:SetScript("OnMouseUp", nil); ---todo

    StriLi_SetTextColorByClass(frame.ItemPlayer.FontString, playerClass);

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() + 30);

    self.count = self.count + 1;

    if self.contentFrame.children == nil then
        self.contentFrame.children = {};
    end

    self.contentFrame.children[self.count] = frame;

end

function StriLi.ItemHistory:editItem(itemLink, index)

    assert(type(index), "number", "Argument index was not a number type.");

    local itemId = getItemID_fromLink(itemLink);

    self.items[index] = itemLink;
    self.contentFrame.children[index].ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    self.contentFrame.children[index].ItemText.FontString:SetText(itemLink);

end

function StriLi.ItemHistory:editPlayer(player, playerClass, index)

    assert(type(player) == "string", "Argument player was not a string type.");
    assert(type(playerClass) == "string", "Argument playerClass was not a string type.");
    assert(type(index), "number", "Argument index was not a number type.");

    self.players[index] = player;

    self.contentFrame.children[index].ItemPlayer.FontString:SetText(player)
    StriLi_SetTextColorByClass(self.contentFrame.children[index].ItemPlayer.FontString, playerClass);

end

function StriLi.ItemHistory:OnMouseWheel(value)

    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);

    local height, viewHeight = self.frame.ScrollFrame:GetHeight(), self.contentFrame:GetHeight();

    if height > viewHeight then
        self.frame.ScrollFrame.ScrollBar:Hide()
    else
        self.frame.ScrollFrame.ScrollBar:Show()
        local diff = height - viewHeight
        local delta = 1
        if value < 0 then
            delta = -1
        end
        self.frame.ScrollFrame.ScrollBar:SetValue(math.min(math.max(self.frame.ScrollFrame.ScrollBar:GetValue() + delta*(1000/(diff/(viewHeight/100))),0), 1000))
    end

end