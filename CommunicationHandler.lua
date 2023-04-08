--[[
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

function StriLi.CommunicationHandler:On_CHAT_MSG_ADDON(prefix, message, distribution_type, sender)

    --DEBUG
    --if string.sub(arg1, 1, 2) == "SL" then
    --    print("On_CHAT_MSG_ADDON: "..arg1.." "..arg2.." "..arg3.." "..arg4);
    --end

    if sender == UnitName("player") then return end

    if prefix == "SL_RQ_CFM" then
        self:On_Request_CheckForMaster();
    elseif prefix == "SL_RS_CFM" then
        self:On_Respond_CheckForMaster(message);
    elseif prefix == "SL_MC" then
        self:On_MasterChanged(message, sender);
    elseif prefix == "SL_DC" then
        self:On_DataChanged(message, sender);
    elseif prefix == "SL_RD" then
        self:On_ResetData(sender);
    elseif prefix == "SL_RQ_SD" then
        self:On_Request_SyncData(sender);
    elseif prefix == "SL_RQ_UHS" then
        self:On_Request_UserHasStriLi(message);
    elseif prefix == "SL_RS_UHS" then
        self:On_Respond_UserHasStriLi(sender);
    elseif prefix == "SL_VC" then
        self:On_VersionCheck(message);
    elseif prefix == "SL_IHA" then
        self:On_ItemHistoryAdd(message, sender);
    elseif prefix == "SL_IHC" then
        self:On_ItemHistoryChanged(message, sender);
    elseif prefix == "SL_IHR" then
        self:On_ItemHistoryRemove(message, sender);
    end

end

function StriLi.CommunicationHandler:On_Request_CheckForMaster()

    if StriLi.master:get() == UnitName("player") then
        SendAddonMessage("SL_RS_CFM", StriLi.master:get(), "RAID");
    end

end

function StriLi.CommunicationHandler:On_Respond_CheckForMaster(transmittedMaster)

    if self.waitingForRespond == "SL_RS_CFM" then

        StriLi.master:set(transmittedMaster);
        self.timerFrame:SetScript("OnUpdate", nil);
        self.checkForMaster_cbf(StriLi.master:get()); -- master check done callback
        self:stopWaitingForRespondAndSendNextQueuedRequest();

    end

end

function StriLi.CommunicationHandler:checkForMaster(cbf, time)

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.checkForMaster,{cbf,time});
        return; -- Can't check for Master, already waiting for some Respond
    end

    if time == nil then
        time = respondTimeToExpire;
    end

    self.checkForMaster_cbf = cbf;

    self.waitingForRespond = "SL_RS_CFM";
    self.time = time;
    
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)

        if self.waitingForRespond ~= "SL_RS_CFM" then
            self.timerFrame:SetScript("OnUpdate", nil);
            self.checkForMaster_cbf(StriLi.master:get());
        end

        self.time = self.time - elapsed;
        if self.time < 0.0 then
            -- Respond time exceeded
            StriLi.master:set("");
            self.timerFrame:SetScript("OnUpdate", nil);
            self.checkForMaster_cbf(StriLi.master:get()); -- master check done callback
            self:stopWaitingForRespondAndSendNextQueuedRequest();
        end

    end);

    SendAddonMessage("SL_RQ_CFM", "", "RAID");

end

function StriLi.CommunicationHandler:On_MasterChanged(newMaster, sender)

    if (StriLi.master:get() == sender) or (StriLi.master:get() == "") then
        StriLi.master:set(newMaster);
        if newMaster ~= "" then
            StriLi.MainFrame.rows[sender]:UpdateName("•"..sender);
            StriLi.MainFrame.rows[newMaster]:UpdateName("®"..newMaster);
        end
        if self.waitingForRespond == "SL_RS_CFM" then
            self:stopWaitingForRespondAndSendNextQueuedRequest();
        end
    end

end

function StriLi.CommunicationHandler:sendMasterChanged(newMaster)

    if (StriLi.master:get() == UnitName("player")) or (StriLi.master:get() == "") then
        SendAddonMessage("SL_MC", newMaster, "RAID");
        return true;
    end

    return false;

end

function StriLi.CommunicationHandler:On_DataChanged(msgString, sender)

    local _next, name, data, arg;

    name, _next = string.match(msgString, CONSTS.nextWordPatern);
    data, arg = string.match(_next, CONSTS.nextWordPatern);

    if (StriLi.master:get() ~= sender) and not self.requestedSyncAsMaster then
        return;
    end

    if not RaidMembersDB:checkForMember(name) then
        StriLi.EventHandler:addNewPlayers();
        if not RaidMembersDB:checkForMember(name) then
            return  --error("Failed to find Member "..name.." in Raid. Sender has send invalid data.")
        end
    end

    if (data == "Reregister") then
        RaidMembersDB:get(name)[data]:set(arg);
    elseif (arg == "Combine") then
        if not StriLi.MainFrame:removePlayer(data, true) then
            error(StriLi.Lang.ErrorMsg.CombineMembers1.." "..name.." "..StriLi.Lang.ErrorMsg.CombineMembers2.." "..data.." "..StriLi.Lang.ErrorMsg.CombineMembers3)
        end
    elseif (data == "Remove") then
        StriLi.MainFrame:removePlayer(name, false);
    else
        RaidMembersDB:get(name)[data]:set(tonumber(arg));
    end

end

function StriLi.CommunicationHandler:sendDataChanged(name, counterName, counterData, masterIsRequesting)
    if ((StriLi.master:get() == UnitName("player")) or masterIsRequesting) and not StriLi.startup then
        SendAddonMessage("SL_DC", name.." "..counterName.." "..counterData, "RAID");
    end
end

function StriLi.CommunicationHandler:sendMembersCombined(mem1Name, mem2Name)
    if StriLi.master:get() == UnitName("player") then
        SendAddonMessage("SL_DC", mem1Name.." "..mem2Name.." ".."Combine", "RAID");
    end
end

function StriLi.CommunicationHandler:sendMemberRemoved(name)
    if StriLi.master:get() == UnitName("player") then
        SendAddonMessage("SL_DC", name.." ".."Remove".." non", "RAID");
    end
end

function StriLi.CommunicationHandler:On_ResetData(sender)
    if StriLi.master:get() == sender and not (sender == UnitName("player")) then
        StriLi.MainFrame:resetData();
    end
end

function StriLi.CommunicationHandler:sendResetData()
    if (StriLi.master:get() == UnitName("player")) then
        SendAddonMessage("SL_RD", "", "RAID");
    end
end

function StriLi.CommunicationHandler:On_Request_SyncData(sender)

    if ((StriLi.master:get() ~= sender) and (StriLi.master:get() ~= UnitName("player"))) then
        return;
    end

    for name, data in pairs(RaidMembersDB.raidMembers) do

        self:sendDataChanged(name, "Main", data["Main"]:get(), true);
        self:sendDataChanged(name, "Sec", data["Sec"]:get(), true);
        self:sendDataChanged(name, "Token", data["Token"]:get(), true);
        self:sendDataChanged(name, "Fail", data["Fail"]:get(), true);
        self:sendDataChanged(name, "Reregister", data["Reregister"]:get(), true);

    end

    for index, itemLink in pairs(StriLi.ItemHistory.items) do
        self:Send_ItemHistoryAdd(itemLink, StriLi.ItemHistory.players[index], StriLi.ItemHistory.playerClasses[index], StriLi.ItemHistory.rollTypes[index], StriLi.ItemHistory.rolls[index], index, true);
    end

end

function StriLi.CommunicationHandler:sendSycRequest()

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.sendSycRequest,nil);
        return;
    end

    if StriLi.master:get() == UnitName("player") then
        self.requestedSyncAsMaster = true;
        self.time = 2.0;
        self.waitingForRespond = "SL_RQ_SD"
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
            self.time = self.time - elapsed;

            if self.time < 0.0 then
                self.requestedSyncAsMaster = false;
                self.timerFrame:SetScript("OnUpdate", nil);
                self:stopWaitingForRespondAndSendNextQueuedRequest();
            end


        end);
    end

    SendAddonMessage("SL_RQ_SD", "", "RAID");

end

function StriLi.CommunicationHandler:On_Request_UserHasStriLi(nameOfRequestedPlayer)
    if nameOfRequestedPlayer == UnitName("player") then
        SendAddonMessage("SL_RS_UHS", "", "RAID");
    end
end

function StriLi.CommunicationHandler:On_Respond_UserHasStriLi(nameOfRespondingPlayer)

    if (nameOfRespondingPlayer == self.requestedPlayer) and (self.waitingForRespond == "SL_RS_UHS") then

        self.timerFrame:SetScript("OnUpdate", nil);
        self.requestedPlayer = "";
        self.checkUserHasStriLi_cbf(true);
        self:stopWaitingForRespondAndSendNextQueuedRequest();

    end

end

function StriLi.CommunicationHandler:checkIfUserHasStriLi(name, cbf)

    if name == UnitName("player") then return end;

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
            self:stopWaitingForRespondAndSendNextQueuedRequest();

        end

    end);
    SendAddonMessage("SL_RQ_UHS", name, "RAID");

    return true;

end

function StriLi.CommunicationHandler:On_VersionCheck(transmittedVersion)
    if tonumber(StriLi_LatestVersion) < tonumber(transmittedVersion) then
        StriLi_LatestVersion = tonumber(transmittedVersion);
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

function StriLi.CommunicationHandler:On_ItemHistoryAdd(arguments, sender)

    if (StriLi.master:get() ~= sender and StriLi.master:get() ~= "") and not self.requestedSyncAsMaster then return end

    local itemLink, _next = string.match(arguments, "([^%]]+)%s?(.*)");
    local _, _next = string.match(_next, CONSTS.nextWordPatern);
    local player, _next = string.match(_next, CONSTS.nextWordPatern);
    local playerClass, _next = string.match(_next, CONSTS.nextWordPatern);
    local rollType, _next = string.match(_next, CONSTS.nextWordPatern);
    local roll, _next = string.match(_next, CONSTS.nextWordPatern);
    local rollNum = tonumber(roll);
    local index, _next = string.match(_next, CONSTS.nextWordPatern);
    local indexNum = tonumber(index);

    if rollNum ~= nil then
        roll = rollNum;
    end

    StriLi.ItemHistory:add(itemLink.."]|h|r", player, playerClass, rollType, roll, indexNum);

end

function StriLi.CommunicationHandler:On_ItemHistoryChanged(arguments, sender)

    if (StriLi.master:get() ~= sender  and StriLi.master:get() ~= "") then return end

    local itemLink, _next = string.match(arguments, "([^%]]+)%s?(.*)");
    local _, _next = string.match(_next, CONSTS.nextWordPatern);
    local player, _next = string.match(_next, CONSTS.nextWordPatern);
    local playerClass, _next = string.match(_next, CONSTS.nextWordPatern);
    local rollType, _next = string.match(_next, CONSTS.nextWordPatern);
    local roll, _next = string.match(_next, CONSTS.nextWordPatern);
    local rollNum = tonumber(roll)
    local index, _next = string.match(_next, CONSTS.nextWordPatern);

    if rollNum ~= nil then
        roll = rollNum;
    end

    StriLi.ItemHistory:On_ItemHistoryChanged(itemLink.."]|h|r", player, playerClass, rollType, roll, tonumber(index));

end

function StriLi.CommunicationHandler:On_ItemHistoryRemove(arguments, sender)

    if (StriLi.master:get() ~= sender and StriLi.master:get() ~= "") then return end

    local index, _next = string.match(arguments, CONSTS.nextWordPatern);

    index = tonumber(index);

    assert(index);

    StriLi.ItemHistory:remove(index);

end

function StriLi.CommunicationHandler:Send_ItemHistoryAdd(itemLink, player, playerClass, rollType, roll, index, forced)
    if StriLi.master:get() ~= UnitName("player") and not forced then return end;
    SendAddonMessage("SL_IHA", tostring(itemLink).." "..tostring(player).." "..tostring(playerClass).." "..tostring(rollType).." "..tostring(roll).." "..tostring(index), "RAID");
end

function StriLi.CommunicationHandler:Send_ItemHistoryChanged(itemLink, player, playerClass, rollType, roll, index)
    if StriLi.master:get() ~= UnitName("player") then return end;
    SendAddonMessage("SL_IHC", tostring(itemLink).." "..tostring(player).." "..tostring(playerClass).." "..tostring(rollType).." "..tostring(roll).." "..tostring(index), "RAID");
end

function StriLi.CommunicationHandler:Send_ItemHistoryRemove(index)
    if StriLi.master:get() ~= UnitName("player") then return end;
    SendAddonMessage("SL_IHR", tostring(index), "RAID");
end

function StriLi.CommunicationHandler:addToQueue(queuedRequest, arguments)
    table.insert(self.requestQueue,{[1]=queuedRequest,[2]=arguments});
end

function StriLi.CommunicationHandler:stopWaitingForRespondAndSendNextQueuedRequest()

    self.waitingForRespond = "";

    local next = table.remove(self.requestQueue);

    if next == nil then
        return;
    end

    local queuedRequest, arguments = next[1], next[2];

    if queuedRequest == StriLi.CommunicationHandler.checkForMaster then
        StriLi.CommunicationHandler:checkForMaster(arguments[1],arguments[2])
    elseif queuedRequest == StriLi.CommunicationHandler.sendSycRequest then
        StriLi.CommunicationHandler:sendSycRequest()
    elseif queuedRequest == StriLi.CommunicationHandler.checkIfUserHasStriLi then
        StriLi.CommunicationHandler:checkIfUserHasStriLi(arguments[1],arguments[2])
    end

end