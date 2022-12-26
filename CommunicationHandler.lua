--[[
Class: StriLi.CommunicationHandler

variables:
    waitingForRespond
    time
    timerFrame
    checkForMaster_cbf
    checkUserHasStriLi_cbf
    requestedSyncAsMaster

methods:
    requestedSyncAsMaster
    On_Request_CheckForMaster
    On_Respond_CheckForMaster
    On_MasterChanged
    sendMasterChanged
    On_DataChanged
    sendDataChanged
    checkForMaster
    On_ResetData
    sendResetData
    On_Request_SyncData
    sendSycRequest
    On_Request_UserHasStriLi
    On_Respond_UserHasStriLi
    checkIfUserHasStriLi
    On_VersionCheck
    ShoutVersion

CommunicationStrings:
    Setup of Strings:
    SL = StriLi -> Prefix
    RQ = Request -> Command-type Prefix
    RS = Respond -> Command-type Prefix
    _ = Separator

    Commands:

    SL_RQ_CFM   -> CFM = Check for Master
    SL_RS_CFM
    SL_MC       -> MC = Master Changed
    SL_DC       -> DC = Data Changed
    SL_RD       -> RD = Reset Data
    SL_RQ_SD    -> SD = Synchronize Data
    SL_RQ_UHS   -> UHS = User Has StriLi
    SL_RS_UHS
    SL_VC       -> VC = Version Check

--]]


local respondTimeToExpire = 0.5
StriLi.CommunicationHandler = { waitingForRespond = "",
                                time = 0.0,
                                timerFrame = CreateFrame("Frame"),
                                checkForMaster_cbf = nil,
                                checkUserHasStriLi_cbf = nil,
                                requestedSyncAsMaster = false,
                                requestQueue = {}
};

function StriLi.CommunicationHandler:On_CHAT_MSG_ADDON(...)

    if arg1 == "SL_RQ_CFM" then
        self:On_Request_CheckForMaster();
    elseif arg1 == "SL_RS_CFM" then
        self:On_Respond_CheckForMaster(arg2);
    elseif arg1 == "SL_MC" then
        self:On_MasterChanged(arg2);
    elseif arg1 == "SL_DC" then
        self:On_DataChanged(arg2);
    elseif arg1 == "SL_RD" then
        self:On_ResetData(arg2);
    elseif arg1 == "SL_RQ_SD" then
        self:On_Request_SyncData(arg2);
    elseif arg1 == "SL_RQ_UHS" then
        self:On_Request_UserHasStriLi(arg2);
    elseif arg1 == "SL_RS_UHS" then
        self:On_Respond_UserHasStriLi(arg2);
    elseif arg1 == "SL_VC" then
        self:On_VersionCheck(arg2);
    elseif arg1 == "SL_IHA" then
        self:On_ItemHistoryAdd(arg2);
    end

end

function StriLi.CommunicationHandler:On_Request_CheckForMaster()

    if (StriLi.master ~= "") and (StriLi.master == UnitName("player")) then
        SendAddonMessage("SL_RS_CFM", StriLi.master, "RAID");
    end

end

function StriLi.CommunicationHandler:On_Respond_CheckForMaster(transmittedMaster)

    if self.waitingForRespond == "SL_RS_CFM" then

        StriLi.master = transmittedMaster;
        self.timerFrame:SetScript("OnUpdate", nil);
        self.checkForMaster_cbf(StriLi.master); -- master check done callback
        self:respondReceived();

    end

end

function StriLi.CommunicationHandler:checkForMaster(cbf, time)

    if time == nil then
        time = respondTimeToExpire;
    end

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.checkForMaster,{cbf,time});
        return; -- Can't check for Master, already waiting for some Respond
    end

    self.checkForMaster_cbf = cbf;

    self.waitingForRespond = "SL_RS_CFM";
    self.time = time;
    
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)

        if waitingForRespond ~= "SL_RS_CFM" then
            self.timerFrame:SetScript("OnUpdate", nil);
            self.checkForMaster_cbf(StriLi.master);
        end

        self.time = self.time - elapsed;
        if self.time < 0.0 then
            -- Respond time exceeded
            StriLi.master = "";
            self.timerFrame:SetScript("OnUpdate", nil);
            self.checkForMaster_cbf(StriLi.master); -- master check done callback
            self:respondReceived();
        end

    end);

    SendAddonMessage("SL_RQ_CFM", "", "RAID");

end

function StriLi.CommunicationHandler:On_MasterChanged(msgString)

    local sender, newMaster = string.match(msgString, CONSTS.nextWordPatern);

    if (sender == StriLi.master) or (StriLi.master == "") then
        StriLi.master = newMaster;
        if newMaster ~= "" then
            StriLi.MainFrame:OnMasterChanged();
            StriLi.MainFrame.rows[sender]:UpdateName("•"..sender);
            StriLi.MainFrame.rows[newMaster]:UpdateName("®"..newMaster);
        end
        if self.waitingForRespond == "SL_RS_CFM" then
            self:respondReceived();
        end
    end

end

function StriLi.CommunicationHandler:sendMasterChanged(newMaster)

    if (StriLi.master == UnitName("player")) or (StriLi.master == "") then
        SendAddonMessage("SL_MC", UnitName("player") .. " " .. newMaster, "RAID");
        return true;
    end

    return false;

end

function StriLi.CommunicationHandler:On_DataChanged(msgString)

    local SenderName, _next, name, data, arg;

    SenderName, _next = string.match(msgString, CONSTS.nextWordPatern);
    name, _next = string.match(_next, CONSTS.nextWordPatern);
    data, arg = string.match(_next, CONSTS.nextWordPatern);

    if ((SenderName == UnitName("player")) or (SenderName ~= StriLi.master)) and not self.requestedSyncAsMaster then
        return ;
    end

    if not RaidMembersDB:checkForMember(name) then
        StriLi.EventHandler:addNewPlayers();
        if not RaidMembersDB:checkForMember(name) then
            return  --error("Failed to find Member "..name.." in Raid. Sender has send invalid data.")
        end
    end

    if (data == "Reregister") then
        StriLi.MainFrame.rows[name]:UpdateReregister(arg); --todo: for consistency Reregister should be an observable String.
        RaidMembersDB:get(name)["Reregister"] = arg;
    elseif (arg == "Combine") then
        if not StriLi.MainFrame:combineMembers(name, data) then
            error(StriLi.Lang.ErrorMsg.CombineMembers1.." "..name.." "..StriLi.Lang.ErrorMsg.CombineMembers2.." "..data.." "..StriLi.Lang.ErrorMsg.CombineMembers3)
        end
    elseif (data == "Remove") then
        StriLi.MainFrame:removePlayer(name, false);
    else
        RaidMembersDB:get(name)[data]:set(tonumber(arg));
    end

end

function StriLi.CommunicationHandler:sendDataChanged(name, counterName, counterData, masterIsRequesting)

    if (StriLi.master == UnitName("player")) or masterIsRequesting then
        SendAddonMessage("SL_DC", UnitName("player") .. " " .. name .. " " .. counterName .. " " .. counterData, "RAID");
    end

end

function StriLi.CommunicationHandler:sendMembersCombined(mem1Name, mem2Name)

    if StriLi.master == UnitName("player") then
        SendAddonMessage("SL_DC", UnitName("player") .. " " .. mem1Name .. " " .. mem2Name .. " " .. "Combine", "RAID");
    end

end

function StriLi.CommunicationHandler:sendMemberRemoved(name)

    if StriLi.master == UnitName("player") then
        SendAddonMessage("SL_DC", UnitName("player") .. " " .. name .. " " .. "Remove" .. " non", "RAID");
    end

end

function StriLi.CommunicationHandler:On_ResetData(sender)
    if sender == StriLi.master and not (sender == UnitName("player")) then
        StriLi.MainFrame:resetData();
    end
end

function StriLi.CommunicationHandler:sendResetData()
    if (UnitName("player") == StriLi.master) then
        SendAddonMessage("SL_RD", UnitName("player"), "RAID");
    end
end

function StriLi.CommunicationHandler:On_Request_SyncData(sender)

    if ((sender ~= StriLi.master) and (StriLi.master ~= UnitName("player")) or (sender == UnitName("player"))) then
        return ;
    end

    for name, data in pairs(RaidMembersDB.raidMembers) do

        self:sendDataChanged(name, "Main", data["Main"]:get(), true);
        self:sendDataChanged(name, "Sec", data["Sec"]:get(), true);
        self:sendDataChanged(name, "Token", data["Token"]:get(), true);
        self:sendDataChanged(name, "Fail", data["Fail"]:get(), true);
        self:sendDataChanged(name, "Reregister", data["Reregister"], true);

    end

end

function StriLi.CommunicationHandler:sendSycRequest()

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.sendSycRequest,nil);
        return;
    end

    if StriLi.master == UnitName("player") then
        self.requestedSyncAsMaster = true;
        self.time = 3.0;
        self.waitingForRespond = "SL_RQ_SD"
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
            self.time = self.time - elapsed;

            if self.time < 0.0 then
                self.requestedSyncAsMaster = false;
                self.timerFrame:SetScript("OnUpdate", nil);
                self:respondReceived();
            end


        end);
    end

    SendAddonMessage("SL_RQ_SD", UnitName("player"), "RAID");

end

function StriLi.CommunicationHandler:On_Request_UserHasStriLi(nameOfRequestedPlayer)
    if nameOfRequestedPlayer == UnitName("player") then
        SendAddonMessage("SL_RS_UHS", UnitName("player"), "RAID");
    end
end

function StriLi.CommunicationHandler:On_Respond_UserHasStriLi(nameOfRespondingPlayer)

    if (nameOfRespondingPlayer == self.requestedPlayer) and (self.waitingForRespond == "SL_RS_UHS") then

        self.timerFrame:SetScript("OnUpdate", nil);
        self.requestedPlayer = "";
        self.checkUserHasStriLi_cbf(true);
        self:respondReceived();

    end

end

function StriLi.CommunicationHandler:checkIfUserHasStriLi(name, cbf)

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.checkIfUserHasStriLi,{[1]=name, [2]=cbf});
        return;
    end

    self.requestedPlayer = name;
    self.waitingForRespond = "SL_RS_UHS";
    self.checkUserHasStriLi_cbf = cbf;
    self.time = respondTimeToExpire;
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)

        self.time = self.time - elapsed;
        if self.time < 0.0 then
            -- Respond time exceeded

            self.timerFrame:SetScript("OnUpdate", nil);
            self.requestedPlayer = "";
            self.checkUserHasStriLi_cbf(false);
            self:respondReceived();

        end

    end);
    SendAddonMessage("SL_RQ_UHS", name, "RAID");

    return true;

end

function StriLi.CommunicationHandler:On_VersionCheck(transmittedVersion)
    if tonumber(StriLi_LatestVersion) < tonumber(transmittedVersion) then
        StriLi_LatestVersion = transmittedVersion;
    end
end

function StriLi.CommunicationHandler:ShoutVersion()

    if GetNumRaidMembers() > 1 then

        local _, instanceType = IsInInstance()

        if instanceType == "pvp" then
            SendAddonMessage("SL_VC", tostring(StriLi_LatestVersion), "BATTLEGROUND");
        else
            SendAddonMessage("SL_VC", tostring(StriLi_LatestVersion), "RAID");
        end

    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage("SL_VC", tostring(StriLi_LatestVersion), "PARTY");
    end

    if IsInGuild() then
        SendAddonMessage("SL_VC", tostring(StriLi_LatestVersion), "GUILD");
    end

end

function StriLi.CommunicationHandler:On_ItemHistoryAdd(arguments)

    local sender, _next = string.match(arguments, CONSTS.nextWordPatern);
    if sender == UnitName("player") or (sender ~= StriLi.master and StriLi.master ~= "") then return end
    local itemLink, _next = string.match(_next, "([^%]]+)%s?(.*)");
    local _, _next = string.match(_next, CONSTS.nextWordPatern);
    local player, _next = string.match(_next, CONSTS.nextWordPatern);
    local playerClass, _next = string.match(_next, CONSTS.nextWordPatern);
    local rollType, _next = string.match(_next, CONSTS.nextWordPatern);
    local roll, _next = string.match(_next, CONSTS.nextWordPatern);

    StriLi.ItemHistory:add(itemLink.."]|h|r", player, playerClass, rollType, roll);

end

function StriLi.CommunicationHandler:Send_ItemHistoryAdd(itemLink, player, playerClass, rollType, roll)
    SendAddonMessage("SL_IHA", UnitName("player").." "..tostring(itemLink).." "..tostring(player).." "..tostring(playerClass).." "..tostring(rollType).." "..tostring(roll), "RAID");
end

function StriLi.CommunicationHandler:addToQueue(queuedRequest, arguments)
    table.insert(self.requestQueue,{[1]=queuedRequest,[2]=arguments});
end

function StriLi.CommunicationHandler:respondReceived()

    self.waitingForRespond = "";

    local next = table.remove(self.requestQueue);

    if next == nil then
        return
    end

    if next[1] == StriLi.CommunicationHandler.checkForMaster then
        StriLi.CommunicationHandler:checkForMaster(next[2][1],next[2][2])
    elseif next[1] == StriLi.CommunicationHandler.sendSycRequest then
        StriLi.CommunicationHandler:sendSycRequest()
    elseif next[1] == StriLi.CommunicationHandler.checkIfUserHasStriLi then
        StriLi.CommunicationHandler:checkIfUserHasStriLi(next[2][1],next[2][2])
    end

end