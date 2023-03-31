StriLi.EventHandler = { frame = nil };

function StriLi.EventHandler:init()

    if self.frame == nil then
        self.frame = CreateFrame("FRAME");
    end

    self.frame:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end);
    self.frame:RegisterEvent("ADDON_LOADED");
    self.frame:RegisterEvent("PLAYER_LOGOUT");
    self.frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
    self.frame:RegisterEvent("CHAT_MSG_ADDON");

end

function StriLi.EventHandler:OnEvent(event, ...)

    if event == "ADDON_LOADED" and arg1 == "StriLi" then
        print("|cff00ffffStriLi "..StriLi.Lang.version.." " .. GetAddOnMetadata("StriLi", "Version") .. " "..StriLi.Lang.loaded.."|r");
        StriLi_initAddon();
        StriLi.MainFrame:init();
        StriLi.ItemHistory:initFromRawData(StriLi_ItemHistory);
        StriLi.LootRules:init();
        StriLi_OptionFrame_init();
        if tonumber(StriLi_LatestVersion) > tonumber(GetAddOnMetadata("StriLi", "Version")) then
            local versionFrame = CreateFrame("FRAME", "StriLi_VersionFrame", UIParent, "StriLi_CopyVersionFrame_Template");
            local editBox = versionFrame:GetChildren():GetChildren();
            StriLi_VersionFrame_FontString:SetText();
            editBox:SetText("https://github.com/sba5827/StriLi");
            editBox:HighlightText();
            versionFrame:Show();
            editBox:SetScript("OnEscapePressed", function(self) versionFrame:Hide() end);
        end
    elseif event == "PARTY_MEMBERS_CHANGED" then
        self:OnPartyMembersChanged();
    elseif event == "PLAYER_LOGOUT" then
        StriLi_finalizeAddon(); -- Ensures that all important data will be saved
    elseif event == "CHAT_MSG_SYSTEM" then
        self.chatMsgSystem_cbFnc(...);
    elseif event == "CHAT_MSG_ADDON" then
        StriLi.CommunicationHandler:On_CHAT_MSG_ADDON(...);
    end

end

function StriLi.EventHandler:OnPartyMembersChanged()

    local numOfMembers = GetNumRaidMembers();

    if numOfMembers < 1 and not StriLi_newRaidGroup then
        self:OnRaidLeft();
    elseif numOfMembers < 1 and StriLi_newRaidGroup then
        -- just entered or left a Group no Raid
        if not (StriLi.master:get() == "") then
            StriLi.master:set("");
        end
    elseif numOfMembers > 1 and StriLi_newRaidGroup then
        self:OnJoiningNewRaidgoup();
    elseif numOfMembers > 1 then
        self:addNewPlayers();
    end

    StriLi.CommunicationHandler:ShoutVersion();
    StriLi.CommunicationHandler:sendMasterChanged(StriLi.master:get());

end

function StriLi.EventHandler:OnRaidLeft()

    if StriLi.confirmFrame ~= nil then
        StriLi.confirmFrame:hide();
    end

    StriLi.confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.RaidLeftResetData,
            function()
                StriLi.MainFrame:resetData();
            end,
            nil);

    StriLi.confirmFrame:show();

    StriLi_newRaidGroup = true;
    StriLi.master:set("");

end

function StriLi.EventHandler:OnJoiningNewRaidgoup()

    StriLi.CommunicationHandler:checkForMaster(function(master)

        local _, rank = GetRaidRosterInfo(UnitInRaid("player")+1);

        if master == "" and rank > 0 then

            local newMaster = UnitName("player");
            if StriLi.CommunicationHandler:sendMasterChanged(newMaster) then
                StriLi.master:set(newMaster);
            else
                error(StriLi.Lang.ErrorMsg.MasterInitFail);
            end

        else
            StriLi.master:set(master);
        end

    end);

    StriLi_newRaidGroup = false;

    if RaidMembersDB:getSize() > 0 then

        if StriLi.confirmFrame ~= nil then
            StriLi.confirmFrame:hide();
        end

        StriLi.confirmFrame = ConfirmDialogFrame:new(nil, StriLi.Lang.Confirm.NewRaidResetData,
                function()

                    for player, _ in pairs(StriLi.MainFrame.rows) do
                        StriLi.MainFrame:removePlayer(player, true);
                    end

                    self:addNewPlayers();
                    StriLi.CommunicationHandler:sendSycRequest();

                end,
                function()
                    self:addNewPlayers();
                    StriLi.CommunicationHandler:sendSycRequest();
                end);

        StriLi.confirmFrame:show();
    else
        self:addNewPlayers();
        StriLi.CommunicationHandler:sendSycRequest();
    end

end

function StriLi.EventHandler:enable_CHAT_MSG_SYSTEM_event(cbFnc)
    self.frame:RegisterEvent("CHAT_MSG_SYSTEM");
    self.chatMsgSystem_cbFnc = cbFnc;
end

function StriLi.EventHandler:disable_CHAT_MSG_SYSTEM_event()
    self.frame:UnregisterEvent("CHAT_MSG_SYSTEM");
    self.chatMsgSystem_cbFnc = nil;
end

function StriLi.EventHandler:addNewPlayers()

    local numOfMembers = GetNumRaidMembers();
    local masterIsInRaid = false;

    for i = 1, numOfMembers do

        local name = GetRaidRosterInfo(i);
        if (name == nil) then
            return ;
        end

        if StriLi.master:get() == name then
            masterIsInRaid = true;
        end

        local _, englishClass = UnitClass("raid" .. tostring(i));
        local existingMember = RaidMembersDB:checkForMember(name);

        if not existingMember then
            RaidMembersDB:add(name, englishClass);
            StriLi.MainFrame:addPlayer({ name, RaidMembersDB:get(name) });
        end

        StriLi.CommunicationHandler:checkIfUserHasStriLi(name, function(userHasStriLi)
            if userHasStriLi and not (StriLi.master:get() == name) then
                StriLi.MainFrame.rows[name]:UpdateName("•"..name);
            end
        end);

    end

    if not masterIsInRaid then

        if StriLi.MainFrame.rows[StriLi.master:get()] ~= nil then
            StriLi.MainFrame.rows[StriLi.master:get()]:UpdateName(StriLi.master:get());
        end

        StriLi.master:set("");

        local _t = math.random()*10;
        
        self.frame:SetScript("OnUpdate",function(_, elapsed)
            _t = _t -elapsed;

            if _t < 0.0 then

                StriLi.CommunicationHandler:checkForMaster(function(master)

                    if UnitInRaid("player") == nil then return end;

                    masterIsInRaid = false;

                    for i = 1, numOfMembers do

                        local name = GetRaidRosterInfo(i);
                        if (name == nil) then
                            return ;
                        end

                        if name == master then
                            masterIsInRaid = true;
                        end

                    end

                    local _, rank = GetRaidRosterInfo(UnitInRaid("player")+1)

                    if not masterIsInRaid  and rank > 0 then

                        local newMaster = UnitName("player");
                        if StriLi.CommunicationHandler:sendMasterChanged(newMaster) then
                            StriLi.master:set(newMaster);
                        else
                            error(StriLi.Lang.ErrorMsg.MasterInitFail);
                        end

                    else
                        StriLi.master:set(master);
                    end

                end);

                self.frame:SetScript("OnUpdate", nil);

            end

        end)

    end

end