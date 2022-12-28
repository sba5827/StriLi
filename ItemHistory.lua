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
    self.frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT",StriLi_ItemHistory_Frame_ScrollFrame,530,-16);
    self.frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT",StriLi_ItemHistory_Frame_ScrollFrame,530,16);
    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);

end

function StriLi.ItemHistory:add(itemLink, player, playerClass, rollType, roll, externIndex)

    if externIndex ~= nil and externIndex <= self.count then
        return;
    end

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(rollType) == "string", StriLi.Lang.ErrorMsg.Argument.." rollType "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(roll) == "number" or roll == StriLi.Lang.Rolls.RollReassigned, StriLi.Lang.ErrorMsg.Argument.." roll "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    table.insert(self.items, itemLink);
    table.insert(self.players, player);
    table.insert(self.playerClasses, playerClass);
    table.insert(self.rollTypes, rollType);
    table.insert(self.rolls, roll);

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() + 30);

    local frame = CreateFrame("Frame",nil, self.contentFrame, "StriLi_ItemHistoryPlate_Template");
    frame:SetPoint("BOTTOMLEFT", 0, 30*self.count-2);

    self.count = self.count + 1;

    frame.ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    frame.ItemText.FontString:SetText(itemLink);
    frame.ItemPlayer.FontString:SetText(player);
    frame.ItemRollType.FontString:SetText(rollType);
    frame.ItemRoll.FontString:SetText(roll);

    frame:SetScript("OnMouseUp", function(_frame, button)
        self:OnMouseUp(_frame, button, frame);
    end);

    StriLi_SetTextColorByClass(frame.ItemPlayer.FontString, playerClass);



    if self.contentFrame.children == nil then
        self.contentFrame.children = {};
    end

    self.contentFrame.children[self.count] = frame;

end

function StriLi.ItemHistory:On_ItemHistoryChanged(itemLink, player, playerClass, rollType, roll, index)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(rollType) == "string", StriLi.Lang.ErrorMsg.Argument.." rollType "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(roll) == "number" or roll == StriLi.Lang.Rolls.RollReassigned, StriLi.Lang.ErrorMsg.Argument.." roll "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    table.insert(self.items, itemLink);
    table.insert(self.players, player);
    table.insert(self.playerClasses, playerClass);
    table.insert(self.rollTypes, rollType);
    table.insert(self.rolls, roll);

    self.items[index] = itemLink;
    self.players[index] = player;
    self.playerClasses[index] = playerClass;
    self.rollTypes[index] = rollType;
    self.rolls[index] = roll;

    local frame = self.contentFrame.children[index];


    frame.ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    frame.ItemText.FontString:SetText(itemLink);
    frame.ItemPlayer.FontString:SetText(player);
    frame.ItemRollType.FontString:SetText(rollType);
    frame.ItemRoll.FontString:SetText(roll);

    StriLi_SetTextColorByClass(frame.ItemPlayer.FontString, playerClass);

end

function StriLi.ItemHistory:remove(index)

    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local raidMember = RaidMembersDB:get(self.players[index]);

    if raidMember[self.rollTypes[index]]:get() > 0 then
        raidMember[self.rollTypes[index]]:sub(1);
    else
        print(string.format(CONSTS.msgColorStringStart.."StriLi: "..StriLi.Lang.ErrorMsg.ItemRemoveFailed..CONSTS.msgColorStringEnd, self.players[index]));
        return;
    end

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() - 30);

    table.remove(self.items, index);
    table.remove(self.players, index);
    table.remove(self.playerClasses, index);
    table.remove(self.rollTypes, index);
    table.remove(self.rolls, index);


    local frame = table.remove(self.contentFrame.children, index);
    frame:Hide();

    self.count = self.count - 1;

end

function StriLi.ItemHistory:editItem(itemLink, index)

    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    self.items[index] = itemLink;
    self.contentFrame.children[index].ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    self.contentFrame.children[index].ItemText.FontString:SetText(itemLink);

    StriLi.ItemHistory:Send_ItemHistoryChanged(index)

end

function StriLi.ItemHistory:editPlayer(player, playerClass, index)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local oldOwner = self.players[index];

    if RaidMembersDB:get(oldOwner)[self.rollTypes[index]]:get() > 0 then
        RaidMembersDB:get(oldOwner)[self.rollTypes[index]]:sub(1);
        RaidMembersDB:get(player)[self.rollTypes[index]]:add(1);
    else
        print(string.format(CONSTS.msgColorStringStart.."StriLi: "..StriLi.Lang.ErrorMsg.ItemReassignFailed..CONSTS.msgColorStringEnd, player, oldOwner));
        return;
    end

    self.players[index] = player;
    self.playerClasses[index] = playerClass;
    self.rolls[index] = StriLi.Lang.Rolls.RollReassigned;

    self.contentFrame.children[index].ItemPlayer.FontString:SetText(player);
    self.contentFrame.children[index].ItemRoll.FontString:SetText(StriLi.Lang.Rolls.RollReassigned);
    StriLi_SetTextColorByClass(self.contentFrame.children[index].ItemPlayer.FontString, playerClass);

    StriLi.ItemHistory:Send_ItemHistoryChanged(index)

end

function StriLi.ItemHistory:Send_ItemHistoryChanged(index)
    StriLi.CommunicationHandler:Send_ItemHistoryChanged(self.items[index], self.players[index], self.playerClasses[index], self.rollTypes[index], self.rolls[index], index);
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

function StriLi.ItemHistory:OnMouseUp(frame, button, itemFrame)

    if (button ~= "RightButton") or (not MouseIsOver(frame) or ((StriLi.master ~= "") and (StriLi.master ~= UnitName("player")))) then
        return;
    end ;

    StriLi.dropdownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", frame, "UIDropDownMenuTemplate");
    -- Bind an initializer function to the dropdown;

    UIDropDownMenu_Initialize(StriLi.dropdownFrame, function(_frame, _level, _menuList)
        self:initDropdownMenu(_frame, _level, _menuList, itemFrame)
    end, "MENU");

    ToggleDropDownMenu(1, nil, StriLi.dropdownFrame, "cursor", 3, -3, nil, nil, 0.2);

end

function StriLi.ItemHistory:initDropdownMenu(frame, level, menuList, itemFrame)
    local info = UIDropDownMenu_CreateInfo();

    if level == 1 then

        -- Outermost menu level
        info.text, info.hasArrow, info.menuList = StriLi.Lang.Commands.PlayerChange, true, "Players";
        UIDropDownMenu_AddButton(info);

        info.text, info.hasArrow, info.func = StriLi.Lang.Commands.Remove, false, function(_, arg1)

            StriLi.dropdownFrame:Hide()

            local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.ItemRemove,
                    function()

                        local index = nil;

                        for k,v in pairs(self.contentFrame.children) do
                            if v == itemFrame then
                                index = k;
                            end
                        end

                        self:remove(index);

                    end,
                    nil);

            confirmFrame:show();

        end;
        UIDropDownMenu_AddButton(info);

    elseif menuList == "Players" then
        for k, v in pairs(RaidMembersDB.raidMembers) do

                info.text = k;
                info.colorCode = "|cff" .. Strili_GetHexClassCollerCode(v[1]);
                info.func = function(_, arg1)

                    StriLi.dropdownFrame:Hide()

                    local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..arg1.." "..StriLi.Lang.Confirm.ItemAssign,
                            function()

                                local index = nil;

                                for k,v in pairs(self.contentFrame.children) do
                                    if v == itemFrame then
                                        index = k;
                                    end
                                end

                                local arg1Class = RaidMembersDB:get(arg1)[1]; --get the raidmember via RaidMembersDB:get and extracting the class from table.

                                self:editPlayer(arg1, arg1Class, index);

                            end,
                            nil);

                    confirmFrame:show();

                end;
                info.arg1 = k;
                UIDropDownMenu_AddButton(info, level);

        end
    end
end