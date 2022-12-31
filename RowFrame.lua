RowFrame = { x_offset = 35, y_offset = -35, height = 30 }

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

    o.frame = CreateFrame("Frame", o.frameName, o.parentFrame, "StriLi_Row_Template");
    o.frame:SetPoint("TOPLEFT", o.parentFrame, "TOPLEFT", o.x_offset, o.y_offset - o.posIndex * o.height);

    o:setColumnContent(o.raidMember[1], o.raidMember[2]);

    if StriLi.master:get() ~= UnitName("player") and StriLi.master:get() ~= "" then
        o:disableButtons();
    end

    return o;

end

function RowFrame:reInit(_, _, _, posIndex, raidMember)

    self:setPosIndex(posIndex);
    self.raidMember = raidMember;

    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", self.x_offset, self.y_offset - self.posIndex * self.height);

    self:UpdateName(self.raidMember[1]);
    StriLi_SetTextColorByClass(self.Regions.NameFS, raidMember[2][1]);
    self:UpdateMainCounter(self.raidMember[2]["Main"]:get());
    self:UpdateSecCounter(self.raidMember[2]["Sec"]:get());
    self:UpdateTokenCounter(self.raidMember[2]["Token"]:get());
    self:UpdateFailCounter(self.raidMember[2]["Fail"]:get());
    self:UpdateReregister(self.raidMember[2]["Reregister"]);

    self:linkCounter(self.raidMember[2]);

    if StriLi.master:get() ~= UnitName("player") and StriLi.master:get() ~= "" then
        self:disableButtons();
    end

    return self;

end

function RowFrame:setColumnContent(charName, charData)

    self.Children.Name, self.Children.Reregister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.Fail = self.frame:GetChildren();

    self.Children.Name:EnableMouse(true);
    self.Children.Name:SetScript("OnMouseUp", function(frame, button)
        self:OnMouseUp(frame, button);
    end);

    -- Setting Playername
    self.Regions.NameFS = self.Children.Name:CreateFontString("PlayerName" .. tostring(self.posIndex), "ARTWORK", "GameFontNormal");
    self.Regions.NameFS:SetPoint("LEFT", 0, 0);
    self.Regions.NameFS:SetPoint("RIGHT", 0, 0);
    self.Regions.NameFS:SetText(charName);

    StriLi_SetTextColorByClass(self.Regions.NameFS, charData[1]);

    -- Creating Checkbox. Tooltip added if Re-registered
    self.Regions.ReregisterCB = CreateFrame("CheckButton", "ReRegisterCheckButton" .. tostring(self.posIndex), self.Children.Reregister, "ChatConfigCheckButtonTemplate");
    self.Regions.ReregisterCB:SetPoint("CENTER", 0, 0);
    self.Regions.ReregisterCB:SetHitRectInsets(0, 0, 0, 0);
    if (charData["Reregister"] ~= "") then
        self.Regions.ReregisterCB:SetChecked(true);
        self.Children.Name:SetScript("OnEnter", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, self.Children.Name)
            GameTooltip:SetOwner(self.Children.Name, "ANCHOR_NONE")
            GameTooltip:SetPoint("CENTER", self.Children.Name, "CENTER", 0, 30)
            GameTooltip:SetText(charData["Reregister"])
            GameTooltip:Show()
        end);
        self.Children.Name:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end);
    end
    self.Regions.ReregisterCB:SetScript("OnClick", function()
        self:ReregisterRequest(false);
    end)

    -- Creating counters and initializing them
    self.Regions.MainCounter = CreateFrame("Frame", "CounterMain" .. tostring(self.posIndex), self.Children.Main, "StriLi_Counter_Template2");
    self.Regions.SecCounter = CreateFrame("Frame", "CounterSec" .. tostring(self.posIndex), self.Children.Sec, "StriLi_Counter_Template2");
    self.Regions.TokenCounter = CreateFrame("Frame", "CounterToken" .. tostring(self.posIndex), self.Children.Token, "StriLi_Counter_Template2");
    self.Regions.FailCounter = CreateFrame("Frame", "CounterFail" .. tostring(self.posIndex), self.Children.Fail, "StriLi_Counter_Template2");

    self:linkCounter(charData);

    self.Regions.MainCounterFS = self.Regions.MainCounter:GetRegions();
    self.Regions.SecCounterFS = self.Regions.SecCounter:GetRegions();
    self.Regions.TokenCounterFS = self.Regions.TokenCounter:GetRegions();
    self.Regions.FailCounterFS = self.Regions.FailCounter:GetRegions();

    self:UpdateMainCounter(charData["Main"]:get());
    self:UpdateSecCounter(charData["Sec"]:get());
    self:UpdateTokenCounter(charData["Token"]:get());
    self:UpdateFailCounter(charData["Fail"]:get());

end

function RowFrame:linkCounter(charData)

    local aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };

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

end

function RowFrame:unlinkCounters()

    local aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };

    for key, counter in pairs(aTable) do

        local plusButton, minusButton = counter:GetChildren();
        plusButton:SetScript("OnClick", nil);
        minusButton:SetScript("OnClick", nil);

        self.raidMember[2][key]:unregisterObserver(self);

    end

end

function RowFrame:UpdateName(name)
    self.Regions.NameFS:SetText(tostring(name));
end

function RowFrame:UpdateMainCounter(count)
    self.Regions.MainCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Main, count, false);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''), "Main", count, false);
    end
end

function RowFrame:UpdateSecCounter(count)
    self.Regions.SecCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Sec, count, true);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''), "Sec", count, false);
    end
end

function RowFrame:UpdateTokenCounter(count)
    self.Regions.TokenCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Token, count, false);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''), "Token", count, false);
    end
end

function RowFrame:UpdateFailCounter(count)
    self.Regions.FailCounterFS:SetText(tostring(count));
    StriLi_ColorCounterCell(self.Children.Fail, count, true);
    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''), "Fail", count, false);
    end
end

function RowFrame:UpdateReregister(reregister)

    if (reregister ~= "") then
        self.Regions.ReregisterCB:SetChecked(true);
        self.Children.Name:SetScript("OnEnter", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, self.Children.Name)
            GameTooltip:SetOwner(self.Children.Name, "ANCHOR_NONE")
            GameTooltip:SetPoint("CENTER", self.Children.Name, "CENTER", 0, 30)
            GameTooltip:SetText(self.raidMember[2]["Reregister"])
            GameTooltip:Show()
        end);
        self.Children.Name:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end);
    else
        self.Regions.ReregisterCB:SetChecked(false);
        self.Children.Name:SetScript("OnEnter", nil);
        self.Children.Name:SetScript("OnLeave", nil);
    end

    if not StriLi.CommunicationHandler.requestedSyncAsMaster then
        StriLi.CommunicationHandler:sendDataChanged(self:getName():gsub('%®', ''):gsub('%•', ''), "Reregister", reregister, false);
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

    elseif sender == self.raidMember[2]["Fail"] then
        self:UpdateFailCounter(self.raidMember[2]["Fail"]:get());

    end

    StriLi.MainFrame:sortRowFrames();

end

function RowFrame.ReregisterRequest(self, overwrite)

    if self.Regions.ReregisterCB:GetChecked() or overwrite then

        local reregisterInputFrame = TextInputFrame:new(nil, StriLi.Lang.Confirm.ReregisterRequest..": ", function(input)
            self.raidMember[2]["Reregister"] = input;
            self:UpdateReregister(input);
        end, function(_)
            self:UpdateReregister(self.raidMember[2]["Reregister"]);
        end);

        reregisterInputFrame:show();

    else
        self.raidMember[2]["Reregister"] = "";
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

    if (button ~= "RightButton") or (not MouseIsOver(frame) or ((StriLi.master:get() ~= "") and (StriLi.master:get() ~= UnitName("player")))) then
        return
    end ;

    StriLi.dropdownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", frame, "UIDropDownMenuTemplate");
    -- Bind an initializer function to the dropdown;

    UIDropDownMenu_Initialize(StriLi.dropdownFrame, function(_frame, _level, _menuList)
        self:initDropdownMenu(_frame, _level, _menuList)
    end, "MENU");

    ToggleDropDownMenu(1, nil, StriLi.dropdownFrame, "cursor", 3, -3, nil, nil, 0.2);

end

function RowFrame:initDropdownMenu(frame, level, menuList)

    local info = UIDropDownMenu_CreateInfo();

    local pFrame = frame:GetParent();
    local _, fString = pFrame:GetRegions();
    local playerName = fString:GetText():gsub('%®', ''):gsub('%•', '');

    if level == 1 then

        -- Outermost menu level
        info.text, info.hasArrow, info.menuList = StriLi.Lang.Commands.CombineMembers, true, "Players";
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.func, info.self = StriLi.Lang.Commands.Reregister, false, function()
            self:ReregisterRequest(true)
        end;
        UIDropDownMenu_AddButton(info);
        info.text, info.hasArrow, info.func = StriLi.Lang.Commands.SetMaster, false, function()

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
        info.text, info.hasArrow, info.func = StriLi.Lang.Commands.Remove, false, function()

            StriLi.dropdownFrame:Hide();

            local confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.AreYouSureTo.." "..playerName.." "..StriLi.Lang.Confirm.Remove,
                    function()
                        self.removeFnc(playerName);
                        StriLi.CommunicationHandler:sendMemberRemoved(playerName);
                    end,
                    nil);

            confirmFrame:show();

        end;
        UIDropDownMenu_AddButton(info);

    elseif menuList == "Players" then
        for k, v in pairs(RaidMembersDB.raidMembers) do

            if (k ~= playerName) then

                info.text = k;
                info.colorCode = "|cff" .. Strili_GetHexClassColorCode(v[1]);
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

function RowFrame:toggleReregisterLock()

    if self.Regions.ReregisterCB:IsEnabled() == 1 then
        self.Regions.ReregisterCB:Disable();
    else
        self.Regions.ReregisterCB:Enable();
    end

    return self.Regions.ReregisterCB:IsEnabled();

end

function RowFrame:setCombineFunction(fnc)

    self.combineFnc = fnc;

end

function RowFrame:setRemoveFunction(fnc)
    self.removeFnc = fnc;
end

function RowFrame:enableButtons()

    local aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };

    for key, _ in pairs(aTable) do

        local plusButton, minusButton = aTable[key]:GetChildren();
        plusButton:Enable();
        minusButton:Enable();

    end

    if StriLi.MainFrame.children.lockButton:GetText() == StriLi.Lang.Labels.Lock then
        self.Regions.ReregisterCB:Enable();
    end

end

function RowFrame:disableButtons()

    local aTable = { ["Main"] = self.Regions.MainCounter, ["Sec"] = self.Regions.SecCounter, ["Token"] = self.Regions.TokenCounter, ["Fail"] = self.Regions.FailCounter };

    for key, _ in pairs(aTable) do

        local plusButton, minusButton = aTable[key]:GetChildren();
        plusButton:Disable();
        minusButton:Disable();

    end

    self.Regions.ReregisterCB:Disable();

end