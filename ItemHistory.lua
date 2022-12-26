--[[
Class: ItemHistory

variables:
    frame

methods:

--]]

StriLi.ItemHistory = { items = {}, players = {}, rollTypes = {}, rolls = {}, playerClasses = {}, frame = nil, contentFrame = nil, count = 0};

local function getItemID_fromLink(itemLink)

    assert(type(itemLink) == "string", StriLi.Lang.ErrorMsg.Argument.." itemLink "..StriLi.Lang.ErrorMsg.IsNotString);
    local firstChar = string.sub(itemLink, 1, 1);
    assert(firstChar == "|", StriLi.Lang.ErrorMsg.Argument.." itemLink "..StriLi.Lang.ErrorMsg.IsNotItemLink);

    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
            CONSTS.itemLinkPatern)

    return Id;

end

-- CreateFrame("Frame","NAME", StriLi.ItemHistory.frame.ScrollFrame, "StriLi_Row_Template");

function StriLi.ItemHistory:init()

    self.frame = CreateFrame("FRAME","StriLi_ItemHistory_Frame", StriLi.MainFrame.frame,"StriLi_ItemHistory_Template");
    self.contentFrame = self.frame.ScrollFrame.Content;
    self.frame.ScrollFrame.ScrollBar = StriLi_ItemHistory_Frame_ScrollFrameScrollBar;
    self.frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT",StriLi_ItemHistory_Frame_ScrollFrame,490,-16);
    self.frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT",StriLi_ItemHistory_Frame_ScrollFrame,490,16);
    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);

end

function StriLi.ItemHistory:add(itemLink, player, playerClass, rollType, roll)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(rollType) == "string", StriLi.Lang.ErrorMsg.Argument.." rollType "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(roll), "number", StriLi.Lang.ErrorMsg.Argument.." roll "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    table.insert(self.items, itemLink);
    table.insert(self.players, player);
    table.insert(self.playerClasses, playerClass);
    table.insert(self.rollTypes, rollType);
    table.insert(self.rolls, roll);

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() + 30);

    local frame = CreateFrame("Frame",nil, self.contentFrame, "StriLi_ItemHistoryPlate_Template");
    frame:SetPoint("BOTTOMLEFT", 0, 30*self.count-2);

    frame.ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    frame.ItemText.FontString:SetText(itemLink);
    frame.ItemPlayer.FontString:SetText(player);
    frame.ItemRollType.FontString:SetText(rollType);
    frame.ItemRoll.FontString:SetText(roll);

    frame:SetScript("OnMouseUp", nil); ---todo

    StriLi_SetTextColorByClass(frame.ItemPlayer.FontString, playerClass);

    self.count = self.count + 1;

    if self.contentFrame.children == nil then
        self.contentFrame.children = {};
    end

    self.contentFrame.children[self.count] = frame;

end

function StriLi.ItemHistory:editItem(itemLink, index)

    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    self.items[index] = itemLink;
    self.contentFrame.children[index].ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    self.contentFrame.children[index].ItemText.FontString:SetText(itemLink);

end

function StriLi.ItemHistory:editPlayer(player, playerClass, index)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    self.players[index] = player;

    self.contentFrame.children[index].ItemPlayer.FontString:SetText(player)
    StriLi_SetTextColorByClass(self.contentFrame.children[index].ItemPlayer.FontString, playerClass);

end

function StriLi.ItemHistory:OnMouseWheel(value)

    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);

    local height, viewHeight = self.frame.ScrollFrame:GetHeight(), self.contentFrame:GetHeight();

    if height > viewHeight then
        --self.frame.ScrollFrame.ScrollBar:Hide()
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

function StriLi.ItemHistory:reset()

    for i = 1, self.count do
        HideUIPanel(self.contentFrame.children[i]);
        self.contentFrame.children[i] = nil; --- quick and dirty. TODO: memory efficient implementation
        self.items = {};
        self.players = {};
        self.playerClasses = {};
        self.rollTypes = {};
        self.rolls = {};
    end

    self.contentFrame:SetHeight(0);
    self.count = 0;

end

function StriLi.ItemHistory:getRawData()

    local t = {};

    t["count"] = self.count;
    t["items"] = self.items;
    t["players"] = self.players;
    t["playerClasses"] = self.playerClasses;
    t["rollTypes"] = self.rollTypes;
    t["rolls"] = self.rolls;

    return t;

end

function StriLi.ItemHistory:initFromRawData(rawData)

    self:init();

    if rawData["count"] == nil then return end

    for i = 1, rawData["count"] do
        self:add(rawData["items"][i], rawData["players"][i], rawData["playerClasses"][i], rawData["rollTypes"][i], rawData["rolls"][i]);
    end

end