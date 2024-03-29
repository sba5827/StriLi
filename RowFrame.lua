RowFrame = { x_offset = 35, y_offset = -35, height = 30 }

RowFrameStatus_t = {
    StriLiMaster = 0,
    StriLiAssist = 1,
    HasStriLi = 2,
    None = 3,
};

function RowFrame:new(o, frameName, parentFrame, posIndex, raidMember)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    o.frameName = frameName;
    o.parentFrame = parentFrame;
    o.posIndex = posIndex;
    o.raidMember = raidMember;

    o.Children = {};
    o.Regions = {};

    local rowTemplateName = (StriLiOptions["TokenSecList"] and "StriLi_Row_Template_TokenSec" or "StriLi_Row_Template");
    o.frame = CreateFrame("Frame", o.frameName, o.parentFrame, rowTemplateName);
    o.frame:SetPoint("TOPLEFT", o.parentFrame, "TOPLEFT", o.x_offset, o.y_offset - o.posIndex * o.height);

    o:setColumnContent(o.raidMember[1], o.raidMember[2]);

    if not StriLi_isPlayerMaster() and StriLi.master:get() ~= "" and not RaidMembersDB:isMemberAssist(UnitName("player")) then
        o:disableButtons();
    end

    return o;

end

function RowFrame:reInit(_, _, _, posIndex, raidMember)

    self:setPosIndex(posIndex);
    self.raidMember = raidMember;

    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", self.x_offset, self.y_offset - self.posIndex * self.height);

    if self.raidMember[2]["IsStriLiAssist"]:get() then
        self:setStatus(RowFrameStatus_t.StriLiAssist);

    else
        self:setStatus(RowFrameStatus_t.None);

    end

    StriLi_SetTextColorByClass(self.Regions.NameFS, raidMember[2][1]);
    self:UpdateName(raidMember[1]);
    self:UpdateMainCounter(self.raidMember[2]["Main"]:get());
    self:UpdateSecCounter(self.raidMember[2]["Sec"]:get());
    self:UpdateTokenCounter(self.raidMember[2]["Token"]:get());
    self:UpdateTokenSecCounter(self.raidMember[2]["TokenSec"]:get());
    self:UpdateFailCounter(self.raidMember[2]["Fail"]:get());
    self:UpdateReRegister(self.raidMember[2]["ReRegister"]:get());

    self:linkCounter(self.raidMember[2]);

    if not StriLi_isPlayerMaster() and StriLi.master:get() ~= "" and not RaidMembersDB:isMemberAssist(UnitName("player")) then
        self:disableButtons();
    end

    return self;

end

function RowFrame:setColumnContent(charName, charData)

    if StriLiOptions["TokenSecList"] then
        self.Children.Status, self.Children.Name, self.Children.ReRegister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.TokenSec, self.Children.Fail = self.frame:GetChildren();
    else
        self.Children.Status, self.Children.Name, self.Children.ReRegister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.Fail = self.frame:GetChildren();
    end
    self.Children.Status:EnableMouse(true);
    self.Children.Name:EnableMouse(true);
    self.Children.Name:SetScript("OnMouseUp", function(frame, button)
        self:OnMouseUp(frame, button);
    end);

    -- Setting up PlayerStatus
    self.Regions.StatusFS = self.Children.Status:CreateFontString("PlayerStatus" .. tostring(self.posIndex), "ARTWORK", "GameFontNormal");
    self.Regions.StatusFS:SetPoint("LEFT", 0, 0);
    self.Regions.StatusFS:SetPoint("RIGHT", 0, 0);
    self.Regions.StatusFS:SetText("");

    -- Setting Player name
    self.Regions.NameFS = self.Children.Name:CreateFontString("PlayerName" .. tostring(self.posIndex), "ARTWORK", "GameFontNormal");
    self.Regions.NameFS:SetPoint("LEFT", 0, 0);
    self.Regions.NameFS:SetPoint("RIGHT", 0, 0);
    self.Regions.NameFS:SetText(charName);

    StriLi_SetTextColorByClass(self.Regions.NameFS, charData[1]);

    -- Creating Checkbox. Tooltip added if Re-registered
    self.Regions.ReRegisterCB = CreateFrame("CheckButton", "ReRegisterCheckButton" .. tostring(self.posIndex), self.Children.ReRegister, "ChatConfigCheckButtonTemplate");
    self.Regions.ReRegisterCB:SetPoint("CENTER", 0, 0);
    self.Regions.ReRegisterCB:SetHitRectInsets(0, 0, 0, 0);
    self:UpdateReRegister(charData["ReRegister"]:get());

    self.Regions.ReRegisterCB:SetScript("OnClick", function()
        self:ReRegisterRequest(false);
    end)

    charData["ReRegister"]:registerObserver(self);

    -- Creating counters and initializing them
    self.Regions.MainCounter = CreateFrame("Frame", "CounterMain" .. tostring(self.posIndex), self.Children.Main, "StriLi_Counter_Template2");
    self.Regions.SecCounter = CreateFrame("Frame", "CounterSec" .. tostring(self.posIndex), self.Children.Sec, "StriLi_Counter_Template2");
    self.Regions.TokenCounter = CreateFrame("Frame", "CounterToken" .. tostring(self.posIndex), self.Children.Token, "StriLi_Counter_Template2");
    if StriLiOptions["TokenSecList"] then
        self.Regions.TokenSecCounter = CreateFrame("Frame", "CounterTokenSec" .. tostring(self.posIndex), self.Children.TokenSec, "StriLi_Counter_Template2");
    end
    self.Regions.FailCounter = CreateFrame("Frame", "CounterFail" .. tostring(self.posIndex), self.Children.Fail, "StriLi_Counter_Template2");

    self:linkCounter(charData);

    self.Regions.MainCounterFS = self.Regions.MainCounter:GetRegions();
    self.Regions.SecCounterFS = self.Regions.SecCounter:GetRegions();
    self.Regions.TokenCounterFS = self.Regions.TokenCounter:GetRegions();
    if StriLiOptions["TokenSecList"] then
        self.Regions.TokenSecCounterFS = self.Regions.TokenSecCounter:GetRegions();
    end
    self.Regions.FailCounterFS = self.Regions.FailCounter:GetRegions();

    self:UpdateMainCounter(charData["Main"]:get());
    self:UpdateSecCounter(charData["Sec"]:get());
    self:UpdateTokenCounter(charData["Token"]:get());
    if StriLiOptions["TokenSecList"] then
        self:UpdateTokenSecCounter(charData["TokenSec"]:get());
    end
    self:UpdateFailCounter(charData["Fail"]:get());

end

function RowFrame:linkCounter(charData)
    
    local aTable;
    if StriLiOptions["TokenSecList"] then
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["TokenSec"] = self.Regions.TokenSecCounter, ["Fail"] = self.Regions.FailCounter };
    else
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };
    end
    
    for key, _ in pairs(aTable) do

        local plusButton, minusButton = aTable[key]:GetChildren();
        plusButton:SetScript("OnClick", function()
            charData[key]:add(1)
        end);
        minusButton:SetScript("OnClick", function()
            if (charData[key]:get() > 0) then
                charData[key]:sub(1)
            end
        end);

        charData[key]:registerObserver(self);

    end

    charData["IsStriLiAssist"]:registerObserver(self);

end

function RowFrame:unlinkCounters()

    local aTable;
    if StriLiOptions["TokenSecList"] then
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["TokenSec"] = self.Regions.TokenSecCounter, ["Fail"] = self.Regions.FailCounter };
    else
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };
    end

    for key, counter in pairs(aTable) do

        local plusButton, minusButton = counter:GetChildren();
        plusButton:SetScript("OnClick", nil);
        minusButton:SetScript("OnClick", nil);

        self.raidMember[2][key]:unregisterObserver(self);

    end

    self.raidMember[2]["ReRegister"]:unregisterObserver(self);

end

function RowFrame:UpdateName(name)
    self.Regions.NameFS:SetText(tostring(name));
end

function RowFrame:UpdateMainCounter(count)
    self.Regions.MainCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Main, count, false);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "Main", count, false);
    end
end

function RowFrame:UpdateSecCounter(count)
    self.Regions.SecCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Sec, count, true);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "Sec", count, false);
    end
end

function RowFrame:UpdateTokenCounter(count)
    self.Regions.TokenCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Token, count, false);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "Token", count, false);
    end
end

function RowFrame:UpdateTokenSecCounter(count)
    if self.Regions.TokenSecCounterFS then
        self.Regions.TokenSecCounterFS:SetText(tostring(count));
        StriLi_ColorCounterCell(self.Children.TokenSec, count, true);
        if not StriLi.CommunicationHandler.requestedSyncAsMaster then
            StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "TokenSec", count, false);
        end
    end
end

function RowFrame:UpdateFailCounter(count)
    self.Regions.FailCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Fail, count, not StriLiOptions["TokenSecList"]);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "Fail", count, false);
    end
end

function RowFrame:UpdateReRegister(reRegister)

    if (reRegister ~= "") then
        self.Regions.ReRegisterCB:SetChecked(true);
        self.Children.Name:SetScript("OnEnter", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, self.Children.Name)
            GameTooltip:SetOwner(self.Children.Name, "ANCHOR_NONE")
            GameTooltip:SetPoint("CENTER", self.Children.Name, "CENTER", 0, 30)
            GameTooltip:SetText(reRegister)
            GameTooltip:Show()
        end);
        self.Children.Name:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end);
    else
        self.Regions.ReRegisterCB:SetChecked(false);
        self.Children.Name:SetScript("OnEnter", nil);
        self.Children.Name:SetScript("OnLeave", nil);
    end

    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''):gsub('%¬', ''), "ReRegister", reRegister, false);
    end
end

function RowFrame:redraw()
    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", self.x_offset, self.y_offset - self.posIndex * self.height);
    StriLi_SetTextColorByClass(self.Regions.NameFS, self.raidMember[2][1]);
end

function RowFrame:setPosIndex(index)
    self.posIndex = index;
    self:redraw();
end

function RowFrame:OnValueChanged(sender)

    if sender == self.raidMember[2]["Main"] then
        self:UpdateMainCounter(self.raidMember[2]["Main"]:get());

    elseif sender == self.raidMember[2]["Sec"] then
        self:UpdateSecCounter(self.raidMember[2]["Sec"]:get());

    elseif sender == self.raidMember[2]["Token"] then
        self:UpdateTokenCounter(self.raidMember[2]["Token"]:get());
    
    elseif sender == self.raidMember[2]["TokenSec"] and StriLiOptions["TokenSecList"] then
        self:UpdateTokenSecCounter(self.raidMember[2]["TokenSec"]:get());

    elseif sender == self.raidMember[2]["Fail"] then
        self:UpdateFailCounter(self.raidMember[2]["Fail"]:get());

    elseif sender == self.raidMember[2]["ReRegister"] then
        self:UpdateReRegister(self.raidMember[2]["ReRegister"]:get());

    elseif sender == self.raidMember[2]["IsStriLiAssist"] then
        if self.raidMember[2]["IsStriLiAssist"]:get() then

            self:setStatus(RowFrameStatus_t.StriLiAssist);
        elseif UnitName("player") ~= self.raidMember[1] then
            StriLi.CommunicationHandler:checkIfUserHasStriLi(self.raidMember[1], function(hasStriLi)
                if hasStriLi and StriLi.master:get() ~= self.raidMember[1] then

                    self:setStatus(RowFrameStatus_t.HasStriLi);
                elseif hasStriLi and StriLi.master:get() == self.raidMember[1] then

                    self:setStatus(RowFrameStatus_t.StriLiMaster);
                else

                    self:setStatus(RowFrameStatus_t.None);
                end
            end)
        else

            self:setStatus(RowFrameStatus_t.HasStriLi);
        end

    end

    StriLi.MainFrame:sortRowFrames();

end

function RowFrame.ReRegisterRequest(self, overwrite)

    if self.Regions.ReRegisterCB:GetChecked() or overwrite then

        local reRegisterInputFrame = TextInputFrame:new(nil, StriLi.Lang.Confirm.ReRegisterRequest..": ", function(input)
            self.raidMember[2]["ReRegister"]:set(input);
        end, function(_)
            
        end);

        reRegisterInputFrame:show();

    else
        self.raidMember[2]["ReRegister"]:set("");
    end

end

function RowFrame:show()
    ShowUIPanel(self.frame);
end

function RowFrame:hide()
    HideUIPanel(self.frame);
end

function RowFrame:toggle()

    if (self.frame:IsVisible()) then
        self:hide();
    else
        self:show();
    end

end

function RowFrame:getName()
    return self.Regions.NameFS:GetText();
end
function RowFrame:getY_offset()
    return self.y_offset;
end
function RowFrame:getX_offset()
    return self.x_offset;
end
function RowFrame:getHeight()
    return self.height;
end

function RowFrame:OnMouseUp(frame, button)

    if (button ~= "RightButton")
            or not MouseIsOver(frame)
            or ((StriLi.master:get() ~= "")
                and (not StriLi_isPlayerMaster())
                and (not RaidMembersDB:isMemberAssist(UnitName("player")))) then
        return;
    end

    StriLi.dropdownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", frame, "UIDropDownMenuTemplate");
    -- Bind an initializer function to the dropdown

    UIDropDownMenu_Initialize(StriLi.dropdownFrame, function(_frame, _level, _menuList)
        self:initDropdownMenu(_frame, _level, _menuList)
    end, "MENU");

    ToggleDropDownMenu(1, nil, StriLi.dropdownFrame, "cursor", 3, -3, nil, nil, 0.2);

end

function RowFrame:initDropdownMenu(frame, level, menuList)

    local bAssist = RaidMembersDB:isMemberAssist(UnitName("player")) and not StriLi_isPlayerMaster();

    local info = UIDropDownMenu_CreateInfo();

    local pFrame = frame:GetParent();
    local _, fString = pFrame:GetRegions();
    local playerName = fString:GetText():gsub('%®', ''):gsub('%•', ''):gsub('%¬', '');

    if level == 1 then

        -- Outermost menu level
        info.text, info.hasArrow, info.menuList, info.disabled = StriLi.Lang.Commands.CombineMembers, true, "Players", bAssist;
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.disabled, info.func = StriLi.Lang.Commands.ReRegister, false, false, function()
            self:ReRegisterRequest(true)
        end;
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.disabled, info.func = StriLi.Lang.Commands.SetMaster, false, bAssist, function()

            StriLi.dropdownFrame:Hide();

            if StriLi.confirmFrame ~= nil then
                StriLi.confirmFrame:hide();
            end

            StriLi.confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..playerName.." "..StriLi.Lang.Confirm.SetMaster,
            function()
                StriLi_SetMaster(playerName);
            end,
            nil);

            StriLi.confirmFrame:show();

        end;
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.disabled, info.func = StriLi.Lang.Commands.Remove, false, bAssist, function()

            StriLi.dropdownFrame:Hide();

            local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..playerName.." "..StriLi.Lang.Confirm.Remove,
                    function()
                        if self.removeFnc(playerName) then
                            StriLi.CommunicationHandler:sendMemberRemoved(playerName);
                        end
                    end,
                    nil);

            confirmFrame:show();

        end;
        UIDropDownMenu_AddButton(info);

        if not RaidMembersDB:isMemberAssist(self.raidMember[1]) then
            info.text, info.hasArrow, info.disabled, info.func = StriLi.Lang.Commands.SetAssist, false, bAssist, function()

                StriLi.dropdownFrame:Hide();

                local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..playerName.." "..StriLi.Lang.Confirm.SetAssist,
                        function()
                            StriLi_SetAssist(playerName);
                        end,
                        nil);

                confirmFrame:show();

            end;
        else
            info.text, info.hasArrow, info.disabled, info.func = StriLi.Lang.Commands.UnsetAssist, false, bAssist, function()

                StriLi.dropdownFrame:Hide();

                local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..playerName.." "..StriLi.Lang.Confirm.UnsetAssist,
                        function()
                            RaidMembersDB:unsetMemberAsAssist(playerName);
                            StriLi.CommunicationHandler:Send_demoteMemberAsStriLiAssist(playerName);
                        end,
                        nil);

                confirmFrame:show();

            end;
        end

        if self.raidMember[1] == StriLi.master:get() then
            info.disabled = true;
        end

        UIDropDownMenu_AddButton(info);

    elseif menuList == "Players" then
        for k, v in pairs(RaidMembersDB.raidMembers) do

            if (k ~= playerName) then

                info.disabled = bAssist;
                info.text = k;
                info.colorCode = "|cff" .. StriLi_GetHexClassColorCode(v[1]);
                info.func = function(_, arg1, arg2)

                    StriLi.dropdownFrame:Hide()

                    local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..arg1.." "..StriLi.Lang.Confirm.Combine1.." "..arg2.." "..StriLi.Lang.Confirm.Combine2.." ("..arg1.." "..StriLi.Lang.Confirm.Combine3,
                            function()
                                self.combineFnc(arg1, arg2);
                                StriLi.CommunicationHandler:sendMembersCombined(arg1, arg2);
                            end,
                            nil);

                    confirmFrame:show();

                end;
                info.arg1 = playerName;
                info.arg2 = k;
                UIDropDownMenu_AddButton(info, level);

            end
        end
    end
end

function RowFrame:toggleReRegisterLock()

    if self.Regions.ReRegisterCB:IsEnabled() == 1 then
        self.Regions.ReRegisterCB:Disable();
    else
        self.Regions.ReRegisterCB:Enable();
    end

    return self.Regions.ReRegisterCB:IsEnabled();

end

function RowFrame:setCombineFunction(fnc)

    self.combineFnc = fnc;

end

function RowFrame:setRemoveFunction(fnc)
    self.removeFnc = fnc;
end

function RowFrame:enableButtons()

    local aTable;
    if StriLiOptions["TokenSecList"] then
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["TokenSec"] = self.Regions.TokenSecCounter, ["Fail"] = self.Regions.FailCounter };
    else
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };
    end
    
    for key, _ in pairs(aTable) do

        local plusButton, minusButton = aTable[key]:GetChildren();
        plusButton:Enable();
        minusButton:Enable();

    end

    if StriLi.MainFrame.children.lockButton:GetText() == StriLi.Lang.Labels.Lock then
        self.Regions.ReRegisterCB:Enable();
    end

end

function RowFrame:disableButtons()

    local aTable;
    if StriLiOptions["TokenSecList"] then
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["TokenSec"] = self.Regions.TokenSecCounter, ["Fail"] = self.Regions.FailCounter };
    else
        aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };
    end
    
    for key, _ in pairs(aTable) do

        local plusButton, minusButton = aTable[key]:GetChildren();
        plusButton:Disable();
        minusButton:Disable();

    end

    self.Regions.ReRegisterCB:Disable();

end

function RowFrame:setStatus(status)

    local toolTippText;

    if status == RowFrameStatus_t.HasStriLi then
        self.Regions.StatusFS:SetText("S");
        toolTippText = StriLi.Lang.Tooltip.hasStriLi;
    elseif status == RowFrameStatus_t.StriLiAssist then
        self.Regions.StatusFS:SetText("A");
        toolTippText = StriLi.Lang.Tooltip.assist;
    elseif status == RowFrameStatus_t.StriLiMaster then
        self.Regions.StatusFS:SetText("M");
        toolTippText = StriLi.Lang.Tooltip.master;
    else
        self.Regions.StatusFS:SetText("");
        toolTippText = nil;
    end

    self.Children.Status:SetScript("OnEnter", function()
        if toolTippText then
            GameTooltip:SetOwner(self.Children.Status, "ANCHOR_TOP")
            GameTooltip:AddLine(toolTippText)
            GameTooltip:Show()
        end
    end)

    self.Children.Status:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

end