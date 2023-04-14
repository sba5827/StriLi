-- SortType_t is used as an Enumeration;
local SortType_t = { NAME_ASCENDING = 1,
                     NAME_DESCENDING = 2,
                     MAIN_ASCENDING = 3,
                     MAIN_DESCENDING = 4,
                     SEC_ASCENDING = 5,
                     SEC_DESCENDING = 6,
                     TOKEN_ASCENDING = 7,
                     TOKEN_DESCENDING = 8,
                     TOKENSEC_ASCENDING = 9,
                     TOKENSEC_DESCENDING = 10,
                     FAIL_ASCENDING = 11,
                     FAIL_DESCENDING = 12,
                     CLASS_ASCENDING = 13,
                     CLASS_DESCENDING = 14};

StriLi.MainFrame = { frame = nil, labelRow = nil, rows = {}, children = {}, unusedRowFrameStack = nil, rowCount = 0,  sortType = ObservableNumber:new(nil), nameTable = {}, sortIgnore = false};

function StriLi.MainFrame:init()

    if self.frame == nil then
        self.frame = CreateFrame("FRAME", "StriLi_MainFrame", UIParent, "StriLi_MainFrame_Template");
    end

    self:adaptWidth();

    tinsert(UISpecialFrames, "StriLi_MainFrame"); --making MainFrame closeable with esc-key

    self.frame.FontString:SetText("StriLi "..GetAddOnMetadata("StriLi", "Version"));
    self.frame.FontString:SetTextColor(0,0.9,1.0);

    if self.labelRow == nil then
        self:setupLabelRow();
    end
    if self.unusedRowFrameStack == nil then
        self.unusedRowFrameStack = InfiniteStack:new(nil, RowFrame);    -- InfiniteStack creates a new object based on the class passed to it as the second parameter, if no elements are left in the stack.
    end

    self.children.resetButton, self.children.syncButton, self.children.lockButton, self.children.sortButton, self.children.itemHistoryButton = self.frame:GetChildren();

    self.children.resetButton:SetScript("OnClick", function()
        self:OnClickResetButton();
    end);
    self.children.syncButton:SetScript("OnClick", function()
        self:OnClickSyncButton();
    end);
    self.children.lockButton:SetScript("OnClick", function()
        self:OnClickLockButton();
    end);
    self.children.sortButton:SetScript("OnClick", function()
        self:OnClickSortButton();
    end);
    self.children.itemHistoryButton:SetScript("OnClick", function()
        self:OnClickItemHistoryButton();
    end)

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

    self.sortType:registerObserver(self);
    StriLi.master:registerObserver(self);

    for charName, charData in pairs(RaidMembersDB.raidMembers) do
        self:addPlayer({ charName, charData });
    end

    self.sortType:set(SortType_t.CLASS_ASCENDING);

    self:OnMasterOrAssistChanged();

end

function StriLi.MainFrame:show()
    ShowUIPanel(self.frame);
end

function StriLi.MainFrame:hide()
    HideUIPanel(self.frame);
end

function StriLi.MainFrame:toggle()

    if (self.frame:IsVisible()) then
        self:hide();
    else
        self:show();
    end

end

function StriLi.MainFrame:adaptWidth()
    if StriLiOptions["TokenSecList"] then
        self.frame:SetWidth(625);
    else
        self.frame:SetWidth(540);
    end
end

function StriLi.MainFrame:setupLabelRow()

    if self.labelRow == nil then

        self.labelRow = LabelRowFrame:new(nil, "LabelRow", self.frame, 0);

        self.labelRow.Children.Name:SetScript("OnMouseUp", function()
            if self.sortType:get() == SortType_t.NAME_ASCENDING then
                self.sortType:set(SortType_t.NAME_DESCENDING);
            else
                self.sortType:set(SortType_t.NAME_ASCENDING);
            end
        end);
        self.labelRow.Children.Main:SetScript("OnMouseUp", function()
            if self.sortType:get() == SortType_t.MAIN_ASCENDING then
                self.sortType:set(SortType_t.MAIN_DESCENDING);
            else
                self.sortType:set(SortType_t.MAIN_ASCENDING);
            end
        end);
        self.labelRow.Children.Sec:SetScript("OnMouseUp", function()
            if self.sortType:get() == SortType_t.SEC_ASCENDING then
                self.sortType:set(SortType_t.SEC_DESCENDING);
            else
                self.sortType:set(SortType_t.SEC_ASCENDING);
            end
        end);
        self.labelRow.Children.Token:SetScript("OnMouseUp", function()
            if self.sortType:get() == SortType_t.TOKEN_ASCENDING then
                self.sortType:set(SortType_t.TOKEN_DESCENDING);
            else
                self.sortType:set(SortType_t.TOKEN_ASCENDING);
            end
        end);
        if StriLiOptions["TokenSecList"] then
            self.labelRow.Children.TokenSec:SetScript("OnMouseUp", function()
                if self.sortType:get() == SortType_t.TOKENSEC_ASCENDING then
                    self.sortType:set(SortType_t.TOKENSEC_DESCENDING);
                else
                    self.sortType:set(SortType_t.TOKENSEC_ASCENDING);
                end
            end);
        end
        self.labelRow.Children.Fail:SetScript("OnMouseUp", function()
            if self.sortType:get() == SortType_t.FAIL_ASCENDING then
                self.sortType:set(SortType_t.FAIL_DESCENDING);
            else
                self.sortType:set(SortType_t.FAIL_ASCENDING);
            end
        end);

        self.labelRow.Children.Name:EnableMouse(true);
        self.labelRow.Children.Main:EnableMouse(true);
        self.labelRow.Children.Sec:EnableMouse(true);
        self.labelRow.Children.Token:EnableMouse(true);
        if StriLiOptions["TokenSecList"] then
            self.labelRow.Children.TokenSec:EnableMouse(true);
        end
        self.labelRow.Children.Fail:EnableMouse(true);


        self.labelRow:show();

        self:resize();

    end

end

function StriLi.MainFrame:addPlayer(raidMember)

    if raidMember[1] == UnitName("player") then
        raidMember[2]["IsStriLiAssist"]:registerObserver(self);
    end
    
    self.rows[raidMember[1]] = self.unusedRowFrameStack:pop(nil, "StriLi_RowFrame" .. tostring(self.rowCount), self.frame, self.rowCount + 1, raidMember);
    self.rowCount = self.rowCount + 1;
    self.rows[raidMember[1]]:setCombineFunction(function(memName1, memName2) self:combineMembers(memName1, memName2) end);
    self.rows[raidMember[1]]:setRemoveFunction(function(n) self:removePlayer(n, false) end);

    table.insert(self.nameTable,raidMember[1]);
    self:sortRowFrames();

    self:resize();
    self.rows[raidMember[1]]:show();

    if raidMember[1] == StriLi.master:get() then

        self.rows[raidMember[1]]:UpdateName("®"..raidMember[1]);

    else

        if UnitName("player") == raidMember[1] and RaidMembersDB:isMemberAssist(UnitName("player")) then
            self.rows[raidMember[1]]:UpdateName("¬"..raidMember[1]);
        elseif UnitName("player") == raidMember[1] then
            self.rows[raidMember[1]]:UpdateName("•"..raidMember[1]);
        else
            StriLi.CommunicationHandler:checkIfUserHasStriLi(raidMember[1], function(userHasStriLi)
                if userHasStriLi and RaidMembersDB:isMemberAssist(raidMember[1]) then
                    self.rows[raidMember[1]]:UpdateName("¬"..raidMember[1]);
                elseif userHasStriLi then
                    self.rows[raidMember[1]]:UpdateName("•"..raidMember[1]);
                end
            end);
        end

    end

end

function StriLi.MainFrame:removePlayer(raidMemberName, forced)

    if not forced then
        local raidMemberIndex = StriLi_GetRaidIndexOfPlayer(raidMemberName);

        if raidMemberIndex > 40 then
            error("WTF?!");
        end

        if raidMemberIndex ~= 0 then
            local _, _, _, _, _, _, _, online = GetRaidRosterInfo(raidMemberIndex);

            if online then
                print (CONSTS.msgColorStringStart.."StriLi: "..StriLi.Lang.ErrorMsg.RemoveOnlineRaidmember.."|r");
                return;
            end
        end
    end

    if self.rows[raidMemberName] ~= nil then

        if RaidMembersDB:checkForMember(UnitName("player")) then
            RaidMembersDB:get(UnitName("player"))["IsStriLiAssist"]:unregisterObserver(self);
        end

        RaidMembersDB:remove(raidMemberName, forced);

        table.removeByValue(self.nameTable, raidMemberName);

        self.unusedRowFrameStack:push(self.rows[raidMemberName])
        self.rows[raidMemberName]:hide();
        self.rows[raidMemberName]:unlinkCounters();
        self.rows[raidMemberName] = nil;
        self.rowCount = self.rowCount - 1;

        self:reIndexFrames();

        self:resize();

        return true;

    end

    return false;

end

function StriLi.MainFrame:resize()

    local SumRowFrameHeight = (self.rowCount + 1) * RowFrame:getHeight();
    self.frame:SetHeight(SumRowFrameHeight - 2 * RowFrame:getY_offset());

end

function StriLi.MainFrame:reIndexFrames()

    for i, name in pairs(self.nameTable) do
        self.rows[name]:setPosIndex(i)
    end

end

function StriLi.MainFrame:OnValueChanged(sender)

    if sender == self.sortType then
        self:sortRowFrames();
    elseif sender == StriLi.master then
        self:OnMasterOrAssistChanged();
    elseif sender == RaidMembersDB:get(UnitName("player"))["IsStriLiAssist"] then
        self:OnMasterOrAssistChanged();
    else
        error("WTF?!");
    end

end

function StriLi.MainFrame:combineMembers(memName1, memName2)

    if self.rows[memName1] == nil or self.rows[memName2] == nil or memName1 == memName2 then
        return false;
    end

    self.sortIgnore = true;

    if RaidMembersDB:combineMembers(memName1, memName2) then
        self:removePlayer(memName2, false);
    end

    self.sortIgnore = false;

    return true;

end

function StriLi.MainFrame:OnClickSyncButton()

    if StriLi_isPlayerMaster() then
        if StriLi.confirmFrame ~= nil then
            StriLi.confirmFrame:hide();
        end

        StriLi.confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.SyncDataConfirm,
                function()
                    StriLi.ItemHistory:reset();
                    StriLi.CommunicationHandler:sendSycRequest();
                end,
                nil);

        StriLi.confirmFrame:show();
    else
        StriLi.ItemHistory:reset();
        StriLi.CommunicationHandler:sendSycRequest();
    end

end

function StriLi.MainFrame:OnClickResetButton()

    if StriLi.confirmFrame ~= nil then
        StriLi.confirmFrame:hide();
    end

    StriLi.confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.ResetDataConfirm,
            function()
                StriLi.CommunicationHandler:sendResetData();
                self:resetData();
            end,
            nil);

    StriLi.confirmFrame:show();

end

function StriLi.MainFrame:OnClickLockButton()

    local enabled = 1;

    for _, rowFrame in pairs(self.rows) do

        enabled = rowFrame:toggleReregisterLock();

    end

    if enabled == 1 then
        self.children.lockButton:SetText(StriLi.Lang.Labels.Lock);
    else
        self.children.lockButton:SetText(StriLi.Lang.Labels.Unlock);
    end

end

function StriLi.MainFrame:OnClickSortButton()

    self.SortDropDownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", self.children.sortButton, "UIDropDownMenuTemplate");
    -- Bind an initializer function to the dropdown;

    UIDropDownMenu_Initialize(self.SortDropDownFrame, function(_frame, _level, _menuList)
        self:initDropdownMenu(_frame, _level, _menuList)
    end, "MENU");

    ToggleDropDownMenu(1, nil, self.SortDropDownFrame, "cursor", 3, -3, nil, nil, 0.2);

end

function StriLi.MainFrame:OnClickItemHistoryButton()

    if (StriLi.ItemHistory.frame:IsVisible()) then
        HideUIPanel(StriLi.ItemHistory.frame);
    else
        ShowUIPanel(StriLi.ItemHistory.frame);
    end

end

function StriLi.MainFrame:initDropdownMenu(frame, level, menuList)

    local info = UIDropDownMenu_CreateInfo();

    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Name.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.NAME_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Name.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.NAME_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Main.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.MAIN_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Main.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.MAIN_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Sec.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.SEC_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Sec.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.SEC_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Token.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.TOKEN_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Token.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.TOKEN_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    if StriLiOptions["TokenSecList"] then
        info.text, info.hasArrow, info.func = StriLi.Lang.Labels.TokenSec.." "..StriLi.Lang.Labels.Ascending, false, function()
            self.sortType:set(SortType_t.TOKENSEC_ASCENDING);
        end;
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.func = StriLi.Lang.Labels.TokenSec.." "..StriLi.Lang.Labels.Descending, false, function()
            self.sortType:set(SortType_t.TOKENSEC_DESCENDING);
        end;
        UIDropDownMenu_AddButton(info);
    end
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Fail.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.FAIL_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Fail.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.FAIL_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Class.." "..StriLi.Lang.Labels.Ascending, false, function()
        self.sortType:set(SortType_t.CLASS_ASCENDING);
    end;
    UIDropDownMenu_AddButton(info);
    info.text, info.hasArrow, info.func = StriLi.Lang.Labels.Class.." "..StriLi.Lang.Labels.Descending, false, function()
        self.sortType:set(SortType_t.CLASS_DESCENDING);
    end;
    UIDropDownMenu_AddButton(info);
end

function StriLi.MainFrame:resetData()
    for player, _ in pairs(self.rows) do
        self:removePlayer(player, true);
    end

    StriLi.ItemHistory:reset();

    StriLi.EventHandler:addNewPlayers();

    StriLi.MainFrame:OnMasterOrAssistChanged();
end

function StriLi.MainFrame:OnMasterOrAssistChanged()

    if not StriLi_isPlayerMaster() and StriLi.master:get() ~= "" and not RaidMembersDB:isMemberAssist(UnitName("player")) then

        for _, rowFrame in pairs(self.rows) do
            rowFrame:disableButtons();
        end

        self.children.resetButton:Disable();
        self.children.lockButton:Disable();

    else

        for _, rowFrame in pairs(self.rows) do
            rowFrame:enableButtons();
        end

        if StriLi_isPlayerMaster() or StriLi.master:get() == "" then
            self.children.resetButton:Enable();
        else
            self.children.resetButton:Disable();
        end
        self.children.lockButton:Enable();

    end

end

function StriLi.MainFrame:sortRowFrames()

    if self.sortIgnore then return; end

    self.labelRow.Regions.NameFS:SetText(StriLi.Lang.Labels.Name);
    self.labelRow.Regions.MainFS:SetText(StriLi.Lang.Labels.Main);
    self.labelRow.Regions.SecFS:SetText(StriLi.Lang.Labels.Sec);
    if StriLiOptions["TokenSecList"] then
        self.labelRow.Regions.TokenSecFS:SetText(StriLi.Lang.Labels.TokenSec);
    end
    self.labelRow.Regions.TokenFS:SetText(StriLi.Lang.Labels.Token);
    self.labelRow.Regions.FailFS:SetText(StriLi.Lang.Labels.Fail);

    if      self.sortType:get() == SortType_t.NAME_ASCENDING      then
        self:sortByName(false);
        self.labelRow.Regions.NameFS:SetText(StriLi.Lang.Labels.Name..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.NAME_DESCENDING     then
        self:sortByName(true);
        self.labelRow.Regions.NameFS:SetText(StriLi.Lang.Labels.Name..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.MAIN_ASCENDING      then
        self:sortByCounter(true,"Main");
        self.labelRow.Regions.MainFS:SetText(StriLi.Lang.Labels.Main..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.MAIN_DESCENDING     then
        self:sortByCounter(false, "Main");
        self.labelRow.Regions.MainFS:SetText(StriLi.Lang.Labels.Main..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.SEC_ASCENDING       then
        self:sortByCounter(true,"Sec");
        self.labelRow.Regions.SecFS:SetText(StriLi.Lang.Labels.Sec..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.SEC_DESCENDING      then
        self:sortByCounter(false, "Sec");
        self.labelRow.Regions.SecFS:SetText(StriLi.Lang.Labels.Sec..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.TOKEN_ASCENDING     then
        self:sortByCounter(true,"Token");
        self.labelRow.Regions.TokenFS:SetText(StriLi.Lang.Labels.Token..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.TOKEN_DESCENDING    then
        self:sortByCounter(false, "Token");
        self.labelRow.Regions.TokenFS:SetText(StriLi.Lang.Labels.Token..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.TOKENSEC_ASCENDING     then
        self:sortByCounter(true,"TokenSec");
        self.labelRow.Regions.TokenSecFS:SetText(StriLi.Lang.Labels.TokenSec..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.TOKENSEC_DESCENDING    then
        self:sortByCounter(false, "TokenSec");
        self.labelRow.Regions.TokenSecFS:SetText(StriLi.Lang.Labels.TokenSec..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.FAIL_ASCENDING      then
        self:sortByCounter(true,"Fail");
        self.labelRow.Regions.FailFS:SetText(StriLi.Lang.Labels.Fail..StriLi.Lang.Labels.Ascending);

    elseif  self.sortType:get() == SortType_t.FAIL_DESCENDING     then
        self:sortByCounter(false, "Fail");
        self.labelRow.Regions.FailFS:SetText(StriLi.Lang.Labels.Fail..StriLi.Lang.Labels.Descending);

    elseif  self.sortType:get() == SortType_t.CLASS_ASCENDING     then
        self:sortByClass(true);

    elseif  self.sortType:get() == SortType_t.CLASS_DESCENDING    then
        self:sortByClass(false);

    end

    self:reIndexFrames();

end

function StriLi.MainFrame:sortByName(invertedOrder)

    local cmpFnc;

    if invertedOrder then
        cmpFnc = function(a, b)
            return string.lower(a) > string.lower(b)
        end
    else
        cmpFnc = function(a, b)
            return string.lower(a) < string.lower(b)
        end
    end

    table.sort(self.nameTable,cmpFnc);

end

function StriLi.MainFrame:sortByCounter(invertedOrder, counter)

    local cmpFnc;

    if invertedOrder then
        cmpFnc = function(a, b)
            if RaidMembersDB:get(a)[counter]:get() == RaidMembersDB:get(b)[counter]:get() then
                return string.lower(a) > string.lower(b);
            else
                return RaidMembersDB:get(a)[counter]:get() > RaidMembersDB:get(b)[counter]:get();
            end
        end
    else
        cmpFnc = function(a, b)
            if RaidMembersDB:get(a)[counter]:get() == RaidMembersDB:get(b)[counter]:get() then
                return string.lower(a) < string.lower(b);
            else
                return RaidMembersDB:get(a)[counter]:get() < RaidMembersDB:get(b)[counter]:get();
            end
        end
    end

    table.sort(self.nameTable,cmpFnc);

end

function StriLi.MainFrame:sortByClass(invertedOrder)

    local cmpFnc;

    if invertedOrder then
        cmpFnc = function(a, b)
            if RaidMembersDB:get(a)[1] == RaidMembersDB:get(b)[1] then
                return string.lower(a) > string.lower(b);
            else
                return StriLi_GetClassIndex(RaidMembersDB:get(a)[1]) > StriLi_GetClassIndex(RaidMembersDB:get(b)[1]);
            end
        end
    else
        cmpFnc = function(a, b)
            if RaidMembersDB:get(a)[1] == RaidMembersDB:get(b)[1] then
                return string.lower(a) < string.lower(b);
            else
                return StriLi_GetClassIndex(RaidMembersDB:get(a)[1]) < StriLi_GetClassIndex(RaidMembersDB:get(b)[1]);
            end
        end
    end

    table.sort(self.nameTable,cmpFnc);

end

function StriLi.MainFrame:OnTokenListOptionChanged()

    self.labelRow:hide();

    self.labelRow = nil;
    self.unusedRowFrameStack:dumpRemainingElements();

    for player, frame in pairs(self.rows) do
        frame:hide();
        frame:unlinkCounters();
        self.rows[player] = nil;
        table.remove(self.nameTable);
    end

    self.rowCount = 0;

    self:init();

end