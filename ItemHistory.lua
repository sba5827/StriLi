StriLi.ItemHistory = { items = {}, players = {}, rollTypes = {}, rolls = {}, playerClasses = {}, allRolls = {}, frame = nil, contentFrame = nil, count = 0, };

local function repositionFrames()
    for index, frame in pairs(StriLi.ItemHistory.contentFrame.children) do
        frame:SetPoint("BOTTOMLEFT", 0, 30*(index-1)-2);
    end
end

local function getItemID_fromLink(itemLink)

    assert(type(itemLink) == "string", StriLi.Lang.ErrorMsg.Argument.." itemLink "..StriLi.Lang.ErrorMsg.IsNotString);
    local firstChar = string.sub(itemLink, 1, 1);
    assert(firstChar == "|", StriLi.Lang.ErrorMsg.Argument.." itemLink "..StriLi.Lang.ErrorMsg.IsNotItemLink);

    local _, _, _, _, Id = string.find(itemLink, CONSTS.itemLinkPatern)

    return Id;

end

function StriLi.ItemHistory:init()

    self.frame = CreateFrame("FRAME","StriLi_ItemHistory_Frame", UIParent,"StriLi_ItemHistory_Template");
    tinsert(UISpecialFrames, "StriLi_ItemHistory_Frame"); --making MainFrame closeable with esc-key
    self.contentFrame = self.frame.ScrollFrame.Content;
    self.frame.ScrollFrame.ScrollBar = StriLi_ItemHistory_Frame_ScrollFrameScrollBar;
    self.frame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT",StriLi_ItemHistory_Frame_ScrollFrame,530,-16);
    self.frame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT",StriLi_ItemHistory_Frame_ScrollFrame,530,16);
    self.frame.ScrollFrame.ScrollBar:SetValueStep(1);
    self.frame.ScrollFrame.ScrollBar:SetMinMaxValues(0, 1000);

    self.frame:SetScript("OnMouseDown", function(frame)
        if (not frame.isMoving) and (frame.isLocked ~= 1) then
            frame:StartMoving();
            frame.isMoving = true;
        end
    end);
    self.frame:SetScript("OnMouseUp", function(frame)
        if (frame.isMoving) then
            frame:StopMovingOrSizing();
            frame.isMoving = false;
        end
    end);

end

function StriLi.ItemHistory:toggle()
    if self.frame:IsShown() then
        self.frame:Hide();
    else
        self.frame:Show();
    end
end

-----------------------------------------------------------------------------------------------------------
--- allRolls_table: {["Main"]= {["Roll"]=1-100, ["Name"]=XYZ}, ["Sec"] = {["Roll"]=1-99, ["Name"]=XYZ}} ---
-----------------------------------------------------------------------------------------------------------
function StriLi.ItemHistory:add(itemLink, player, playerClass, rollType, roll, externIndex, allRolls_table)

    ---print("number: "..tostring(externIndex)..", type: "..type(externIndex));

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
    table.insert(self.allRolls, allRolls_table);

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() + 30);

    local frame = CreateFrame("Frame",nil, self.contentFrame, "StriLi_ItemHistoryPlate_Template");
    frame:SetPoint("BOTTOMLEFT", 0, 30*self.count-2);
    frame:SetScript("OnEnter", function()
        if (itemLink) then
            GameTooltip:SetOwner(frame, "ANCHOR_TOP")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()
        end
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

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

function StriLi.ItemHistory:printRollsForItem(index)

    print(self.items[index])
    print(CONSTS.msgColorStringStart..StriLi.Lang.Labels.Main..CONSTS.msgColorStringEnd);
    for _,v in pairs(self.allRolls[index]["Main"]) do
        print(CONSTS.msgColorStringStart..v["Name"]..": "..v["Roll"]..CONSTS.msgColorStringEnd);
    end

    print(CONSTS.msgColorStringStart..StriLi.Lang.Labels.Sec..CONSTS.msgColorStringEnd);
    for _,v in pairs(self.allRolls[index]["Sec"]) do
        print(CONSTS.msgColorStringStart..v["Name"]..": "..v["Roll"]..CONSTS.msgColorStringEnd);
    end

end

function StriLi.ItemHistory:On_ItemHistoryChanged(itemLink, player, playerClass, rollType, roll, index)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(rollType) == "string", StriLi.Lang.ErrorMsg.Argument.." rollType "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(roll) == "number" or roll == StriLi.Lang.Rolls.RollReassigned, StriLi.Lang.ErrorMsg.Argument.." roll "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

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

    if StriLi_isPlayerMaster() then -- if not master this function was called by communication handler -> only edit UI.
        local exists, raidMember = pcall(RaidMembersDB.get, RaidMembersDB ,self.players[index]);

        if exists then
            if raidMember[self.rollTypes[index]]:get() > 0 then
                raidMember[self.rollTypes[index]]:sub(1);
            else
                print(string.format(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.ErrorMsg.ItemRemoveFailed..CONSTS.msgColorStringEnd, self.players[index]));
                return;
            end
        end
    end

    self.contentFrame:SetHeight(self.contentFrame:GetHeight() - 30);

    table.remove(self.items, index);
    table.remove(self.players, index);
    table.remove(self.playerClasses, index);
    table.remove(self.rollTypes, index);
    table.remove(self.rolls, index);
    table.remove(self.allRolls, index);


    local frame = table.remove(self.contentFrame.children, index);
    frame:Hide();

    self.count = self.count - 1;

    repositionFrames();
    StriLi.CommunicationHandler:Send_ItemHistoryRemove(index);

end

function StriLi.ItemHistory:editItem(itemLink, index)

    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local itemId = getItemID_fromLink(itemLink);

    self.items[index] = itemLink;
    self.contentFrame.children[index].ItemIcon.Texture:SetTexture(GetItemIcon(itemId));
    self.contentFrame.children[index].ItemText.FontString:SetText(itemLink);

    StriLi.ItemHistory:Send_ItemHistoryChanged(index)

end

function StriLi.ItemHistory:editRollType(rollType, index)

    assert(type(rollType) == "string", StriLi.Lang.ErrorMsg.Argument.." rollType "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local exists = RaidMembersDB:checkForMember(self.players[index]);

    if exists then
        local raidMember = RaidMembersDB:get(self.players[index]);

        if raidMember[self.rollTypes[index]]:get() > 0 then
            raidMember[self.rollTypes[index]]:sub(1);
            raidMember[rollType]:add(1);
        else
            print(string.format(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.ErrorMsg.ItemRolltypeChangeFailed..CONSTS.msgColorStringEnd, self.rollTypes[index], rollType, self.players[index], self.rollTypes[index]));
            return;
        end
    else
        print(string.format(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.ErrorMsg.ItemRolltypeChangeFailed2..CONSTS.msgColorStringEnd, self.rollTypes[index], rollType, self.players[index]));
        return;
    end

    self.rollTypes[index] = rollType;
    self.rolls[index] = StriLi.Lang.Rolls.RollReassigned;
    self.contentFrame.children[index].ItemRollType.FontString:SetText(rollType);
    self.contentFrame.children[index].ItemRoll.FontString:SetText(StriLi.Lang.Rolls.RollReassigned);

    StriLi.ItemHistory:Send_ItemHistoryChanged(index);

end

function StriLi.ItemHistory:editPlayer(player, playerClass, index)

    assert(type(player) == "string", StriLi.Lang.ErrorMsg.Argument.." player "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(playerClass) == "string", StriLi.Lang.ErrorMsg.Argument.." playerClass "..StriLi.Lang.ErrorMsg.IsNotString);
    assert(type(index) == "number", StriLi.Lang.ErrorMsg.Argument.." index "..StriLi.Lang.ErrorMsg.IsNotNumber);

    local oldOwner = self.players[index];

    local exists = RaidMembersDB:checkForMember(oldOwner);

    if exists then
        if RaidMembersDB:get(oldOwner)[self.rollTypes[index]]:get() > 0 then
            RaidMembersDB:get(oldOwner)[self.rollTypes[index]]:sub(1);
            RaidMembersDB:get(player)[self.rollTypes[index]]:add(1);
        else
            print(string.format(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.ErrorMsg.ItemReassignFailed..CONSTS.msgColorStringEnd, player, oldOwner));
            return;
        end
    else
        RaidMembersDB:get(player)[self.rollTypes[index]]:add(1);
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
        self.allRolls = {};
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
    t["allRolls"] = self.allRolls;

    return t;

end

function StriLi.ItemHistory:initFromRawData(rawData)

    self:init();

    if rawData["count"] == nil then return end

    for i = 1, rawData["count"] do
        self:add(rawData["items"][i], rawData["players"][i], rawData["playerClasses"][i], rawData["rollTypes"][i], rawData["rolls"][i], nil,  rawData["allRolls"][i]);
    end

end

function StriLi.ItemHistory:OnMouseUp(frame, button, itemFrame)

    if (button ~= "RightButton") or not MouseIsOver(frame) then
        return;
    end

    StriLi.dropdownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", frame, "UIDropDownMenuTemplate");
    -- Bind an initializer function to the dropdown;

    UIDropDownMenu_Initialize(StriLi.dropdownFrame, function(_frame, _level, _menuList)
        if ((StriLi.master:get() ~= "") and (not StriLi_isPlayerMaster())) and not RaidMembersDB:isMemberAssist(UnitName("player")) then
            self:initDropdownMenuSlave(_frame, _level, _menuList, itemFrame);
        else
            self:initDropdownMenu(_frame, _level, _menuList, itemFrame)
        end
        end, "MENU");

    ToggleDropDownMenu(1, nil, StriLi.dropdownFrame, "cursor", 3, -3, nil, nil, 0.2);

end

function StriLi.ItemHistory:initDropdownMenu(_, level, menuList, itemFrame)
    local info = UIDropDownMenu_CreateInfo();
    local bAssist = RaidMembersDB:isMemberAssist(UnitName("player")) and not StriLi_isPlayerMaster();

    if level == 1 then

        -- Outermost menu level
        info.disabled, info.text, info.hasArrow, info.menuList = false, StriLi.Lang.Commands.PlayerChange, true, "Players";
        UIDropDownMenu_AddButton(info);

        info.disabled, info.text, info.hasArrow, info.menuList = false, StriLi.Lang.Commands.RolltypeChange, true, "Lists";
        UIDropDownMenu_AddButton(info);

        info.disabled, info.text, info.hasArrow, info.func = bAssist, StriLi.Lang.Commands.Remove, false, function(_, _)

            StriLi.dropdownFrame:Hide()

            local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.ItemRemove,
                    function()

                        local index;

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

        info.disabled, info.text, info.hasArrow, info.func = false, StriLi.Lang.Commands.Print, false, function(_, _)
            local index;

            for k,v in pairs(self.contentFrame.children) do
                if v == itemFrame then
                    index = k;
                end
            end
            self:printRollsForItem(index);
        end;
        UIDropDownMenu_AddButton(info);

    elseif menuList == "Players" then
        for k, v in pairs(RaidMembersDB.raidMembers) do

            if k ~= itemFrame.ItemPlayer.FontString:GetText() then

                info.disabled = false;
                info.text = k;
                info.colorCode = "|cff" .. StriLi_GetHexClassColorCode(v[1]);
                info.func = function(_, arg1)

                    StriLi.dropdownFrame:Hide()

                    local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..arg1.." "..StriLi.Lang.Confirm.ItemAssign,
                            function()

                                local index;

                                for k2,v2 in pairs(self.contentFrame.children) do
                                    if v2 == itemFrame then
                                        index = k2;
                                    end
                                end

                                local arg1Class = RaidMembersDB:get(arg1)[1]; --get the raid member via RaidMembersDB:get and extracting the class from table.

                                self:editPlayer(arg1, arg1Class, index);

                            end,
                            nil);

                    confirmFrame:show();

                end;

                info.arg1 = k;
                UIDropDownMenu_AddButton(info, level);

            end
        end
    elseif menuList == "Lists" then
        local aList;

        if StriLiOptions["TokenSecList"] then
            aList = {   ["Main"] = StriLi.Lang.TallyMarkTypes.Main,
                        ["Sec"] = StriLi.Lang.TallyMarkTypes.Sec,
                        ["Token"] = StriLi.Lang.TallyMarkTypes.Token,
                        ["TokenSec"] = StriLi.Lang.TallyMarkTypes.TokenSec};
        else
            aList = {   ["Main"] = StriLi.Lang.TallyMarkTypes.Main,
                        ["Sec"] = StriLi.Lang.TallyMarkTypes.Sec,
                        ["Token"] = StriLi.Lang.TallyMarkTypes.Token};
        end

        for k, list in pairs(aList) do

            if list ~= itemFrame.ItemRollType.FontString:GetText() then

                info.disabled = false;
                info.text = list;
                info.func = function(_, arg1)

                    StriLi.dropdownFrame:Hide()

                    local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..StriLi.Lang.Confirm.ItemRolltypeChange,
                            function()

                                local index;

                                for k2,v2 in pairs(self.contentFrame.children) do
                                    if v2 == itemFrame then
                                        index = k2;
                                    end
                                end

                                self:editRollType(arg1, index);

                            end,
                            nil);

                    confirmFrame:show();

                end;

                info.arg1 = k;
                UIDropDownMenu_AddButton(info, level);

            end

        end
    end
end

function StriLi.ItemHistory:initDropdownMenuSlave(_, level, _, itemFrame)
    local info = UIDropDownMenu_CreateInfo();

    if level == 1 then

        -- Outermost menu level
        info.disabled, info.text, info.hasArrow, info.func = false, StriLi.Lang.Commands.Print, false, function(_, _)
            local index;

            for k,v in pairs(self.contentFrame.children) do
                if v == itemFrame then
                    index = k;
                end
            end
            self:printRollsForItem(index);
        end;
        UIDropDownMenu_AddButton(info);

    end

end