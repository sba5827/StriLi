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



StriLi.CommunicationHandler = { waitingForRespond = "",
                                time = 0.0,
                                timerFrame = CreateFrame("Frame"),
                                checkForMaster_cbf = nil,
                                checkUserHasStriLi_cbf = nil,
                                requestedSyncAsMaster = false };

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
    end

end

function StriLi.CommunicationHandler:On_Request_CheckForMaster()

    if StriLi.master ~= "" and StriLi.master == UnitName("player") then
        SendAddonMessage("SL_RS_CFM", StriLi.master, "RAID");
    end

end

function StriLi.CommunicationHandler:On_Respond_CheckForMaster(transmittedMaster)

    if self.waitingForRespond == "SL_RS_CFM" then

        --print(transmittedMaster)

        StriLi.master = transmittedMaster;
        self.waitingForRespond = "";
        self.timerFrame:SetScript("OnUpdate", nil);
        self.checkForMaster_cbf(StriLi.master); -- master check done callback

    end

end

function StriLi.CommunicationHandler:checkForMaster(cbf)

    if self.waitingForRespond ~= "" then
        return false; -- Can't check for Master, already waiting for some Respond
    end

    self.checkForMaster_cbf = cbf;

    self.waitingForRespond = "SL_RS_CFM";
    self.time = 2.0;
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)

        self.time = self.time - elapsed;
        if self.time < 0.0 then
            -- Respond time exceeded
            StriLi.master = "";
            self.waitingForRespond = "";
            self.timerFrame:SetScript("OnUpdate", nil);
            self.checkForMaster_cbf(StriLi.master); -- master check done callback
        end

    end);

    SendAddonMessage("SL_RQ_CFM", "", "RAID");

    return true; -- Check for master in progress

end

function StriLi.CommunicationHandler:On_MasterChanged(msgString)

    local sender, newMaster = string.match(msgString, "([^%s]+)%s?(.*)");

    if sender == StriLi.master or StriLi.master == "" then
        StriLi.master = newMaster;
        if newMaster ~= "" then
            StriLi.MainFrame:OnMasterChanged();
        end
    end

end

function StriLi.CommunicationHandler:sendMasterChanged(newMaster)

    if StriLi.master == UnitName("player") or StriLi.master == "" then
        SendAddonMessage("SL_MC", UnitName("player") .. " " .. newMaster, "RAID");
        return true;
    end

    return false;

end

function StriLi.CommunicationHandler:On_DataChanged(msgString)

    local SenderName, _next, name, data, arg;

    SenderName, _next = string.match(msgString, "([^%s]+)%s?(.*)");
    name, _next = string.match(_next, "([^%s]+)%s?(.*)");
    data, arg = string.match(_next, "([^%s]+)%s?(.*)");

    if ((SenderName == UnitName("player")) or SenderName ~= StriLi.master) and not self.requestedSyncAsMaster then
        return ;
    end

    if not RaidMembersDB:checkForMember(name) then
        StriLi.EventHandler:OnPartyMembersChanged();
        if not RaidMembersDB:checkForMember(name) then error("Failed to find Member "..name.." in Raid. Sender has send invalid data.") end
    end

    if (data == "Reregister") then
        StriLi.MainFrame.rows[name]:UpdateReregister(arg); --todo: for consistency Reregister should be an observable String.
        RaidMembersDB:get(name)["Reregister"] = arg;
    elseif (arg == "Combine") then
        if not StriLi.MainFrame:combineMembers(name, data) then
            error("Combine of members " .. name .. " and " .. data .. " failed, while receiving Data Changed Msg.")
        end
    else
        RaidMembersDB:get(name)[data]:set(tonumber(arg));
    end

end

function StriLi.CommunicationHandler:sendDataChanged(name, counterName, counterData, masterIsRequesting)

    if StriLi.master == UnitName("player") or masterIsRequesting then
        SendAddonMessage("SL_DC", UnitName("player") .. " " .. name .. " " .. counterName .. " " .. counterData, "RAID");
    end

end

function StriLi.CommunicationHandler:sendMembersCombined(mem1Name, mem2Name)

    if StriLi.master == UnitName("player") then
        SendAddonMessage("SL_DC", UnitName("player") .. " " .. mem1Name .. " " .. mem2Name .. " " .. "Combine", "RAID");
    end

end

function StriLi.CommunicationHandler:On_ResetData(sender)
    if sender == StriLi.master and not sender == UnitName("player") then
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

    if StriLi.master == UnitName("player") then
        self.requestedSyncAsMaster = true;
        self.time = 5.0;
        self.waitingForRespond = "SL_RQ_SD"
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
            self.time = self.time - elapsed;

            if self.time < 0.0 then
                self.waitingForRespond = "";
                self.requestedSyncAsMaster = false;
                self.timerFrame:SetScript("OnUpdate", nil);
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

    if nameOfRespondingPlayer == self.requestedPlayer and self.waitingForRespond == "SL_RS_UHS" then

        self.timerFrame:SetScript("OnUpdate", nil);
        self.requestedPlayer = "";
        self.waitingForRespond = "";
        self.checkUserHasStriLi_cbf(true);

    end

end

function StriLi.CommunicationHandler:checkIfUserHasStriLi(name, cbf)

    if self.waitingForRespond ~= "" then
        return false; -- cant check if user has StriLi while other checks are in progress
    end

    self.requestedPlayer = name;
    self.waitingForRespond = "SL_RS_UHS";
    self.checkUserHasStriLi_cbf = cbf;
    self.time = 2.0;
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)

        self.time = self.time - elapsed;
        if self.time < 0.0 then
            -- Respond time exceeded

            self.timerFrame:SetScript("OnUpdate", nil);
            self.requestedPlayer = "";
            self.waitingForRespond = "";
            self.checkUserHasStriLi_cbf(false);

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