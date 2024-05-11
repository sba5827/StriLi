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
    SL_PMA      -> PMA = Promote Member as Assist
    SL_DMA      -> DMA = Demote Member as Assist
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

function StriLi.CommunicationHandler:On_CHAT_MSG_ADDON(prefix, message, _, sender)

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
        self:On_VersionCheck(message, sender);
    elseif prefix == "SL_IHA" then
        self:On_ItemHistoryAdd(message, sender);
    elseif prefix == "SL_IHC" then
        self:On_ItemHistoryChanged(message, sender);
    elseif prefix == "SL_IHR" then
        self:On_ItemHistoryRemove(message, sender);
    elseif prefix == "SL_PMA" then
        self:On_promoteMemberToStriLiAssist(message, sender);
    elseif prefix == "SL_DMA" then
        self:On_demoteMemberAsStriLiAssist(message, sender);
    end

end

function StriLi.CommunicationHandler:On_Request_CheckForMaster()

    if StriLi_isPlayerMaster() then
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

            StriLi.MainFrame.rows[sender]:setStatus(RowFrameStatus_t.HasStriLi);

            StriLi.MainFrame.rows[newMaster]:setStatus(RowFrameStatus_t.StriLiMaster);
        end
        if self.waitingForRespond == "SL_RS_CFM" then
            self:stopWaitingForRespondAndSendNextQueuedRequest();
        end
    end

end

function StriLi.CommunicationHandler:sendMasterChanged(newMaster)

    if (StriLi_isPlayerMaster()) or (StriLi.master:get() == "") then
        if RaidMembersDB:isMemberAssist(newMaster) then
            self:Send_demoteMemberAsStriLiAssist(newMaster);
            RaidMembersDB:unsetMemberAsAssist(newMaster);
        end
        SendAddonMessage("SL_MC", newMaster, "RAID");
        return true;
    end

    return false;

end

function StriLi.CommunicationHandler:On_DataChanged(msgString, sender)

    if (StriLi.master:get() ~= sender) and not self.requestedSyncAsMaster and not (RaidMembersDB:isMemberAssist(sender) and StriLi_isPlayerMaster()) then
        return;
    end

    local assistChange = RaidMembersDB:isMemberAssist(sender) and not (StriLi.master:get() == sender);

    local _next, name, data, arg;

    name, _next = string.match(msgString, CONSTS.nextWordPatern);
    data, arg = string.match(_next, CONSTS.nextWordPatern);

    if not RaidMembersDB:checkForMember(name) and not assistChange then
        StriLi.EventHandler:addNewPlayers();
        if not RaidMembersDB:checkForMember(name) then
            return;  --error("Failed to find Member "..name.." in Raid. Sender has send invalid data.")
        end
    elseif not RaidMembersDB:checkForMember(name) and assistChange then
        return;
    end

    StriLi.communicationTriggeredDataChange = true;
    if (data == "ReRegister") then
        RaidMembersDB:get(name)[data]:set(arg);
        StriLi.communicationTriggeredDataChange = false;
    elseif (arg == "Combine") and not assistChange then
        if not StriLi.MainFrame:removePlayer(data, true) then
            error(StriLi.Lang.ErrorMsg.CombineMembers1.." "..name.." "..StriLi.Lang.ErrorMsg.CombineMembers2.." "..data.." "..StriLi.Lang.ErrorMsg.CombineMembers3)
        end
    elseif (data == "Remove") and not assistChange then
        StriLi.MainFrame:removePlayer(name, false);
    else
        RaidMembersDB:get(name)[data]:set(tonumber(arg));
        StriLi.communicationTriggeredDataChange = false;
        if assistChange then
            self:sendDataChanged(name, data, arg, false);
        end
    end


end

function StriLi.CommunicationHandler:sendDataChanged(name, counterName, counterData, masterIsRequesting)
    if ((StriLi_isPlayerMaster()) or masterIsRequesting or RaidMembersDB:isMemberAssist(UnitName("player"))) and not StriLi.startup and not StriLi.communicationTriggeredDataChange then
        SendAddonMessage("SL_DC", name.." "..counterName.." "..counterData, "RAID");
    end
end

function StriLi.CommunicationHandler:sendMembersCombined(mem1Name, mem2Name)
    if StriLi_isPlayerMaster() then
        SendAddonMessage("SL_DC", mem1Name.." "..mem2Name.." ".."Combine", "RAID");
    end
end

function StriLi.CommunicationHandler:sendMemberRemoved(name)
    if StriLi_isPlayerMaster() then
        SendAddonMessage("SL_DC", name.." ".."Remove".." non", "RAID");
    end
end

function StriLi.CommunicationHandler:On_ResetData(sender)
    if StriLi.master:get() == sender and not (sender == UnitName("player")) then
        StriLi.MainFrame:resetData();
    end
end

function StriLi.CommunicationHandler:sendResetData()
    if (StriLi_isPlayerMaster()) then
        SendAddonMessage("SL_RD", "", "RAID");
    end
end

function StriLi.CommunicationHandler:On_Request_SyncData(sender)

    if ((StriLi.master:get() ~= sender) and (not StriLi_isPlayerMaster())) then
        return;
    end

    for name, data in pairs(RaidMembersDB.raidMembers) do

        self:sendDataChanged(name, "Main", data["Main"]:get(), true);
        self:sendDataChanged(name, "Sec", data["Sec"]:get(), true);
        self:sendDataChanged(name, "Token", data["Token"]:get(), true);
        self:sendDataChanged(name, "Fail", data["Fail"]:get(), true);
        self:sendDataChanged(name, "ReRegister", data["ReRegister"]:get(), true);

    end

    for index, itemLink in pairs(StriLi.ItemHistory.items) do
        self:Send_ItemHistoryAdd(itemLink, StriLi.ItemHistory.players[index], StriLi.ItemHistory.playerClasses[index], StriLi.ItemHistory.rollTypes[index], StriLi.ItemHistory.rolls[index], index, true, StriLi.ItemHistory.allRolls[index]);
    end

end

function StriLi.CommunicationHandler:sendSycRequest()

    if self.waitingForRespond ~= "" then
        self:addToQueue(StriLi.CommunicationHandler.sendSycRequest,nil);
        return;
    end

    if StriLi_isPlayerMaster() then
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

function StriLi.CommunicationHandler:On_VersionCheck(transmittedVersion, sender)

    local vEncrypt = StriLi_StringToVersionEncrypt(transmittedVersion);

    if StriLi_isEncryptedVersionValid(vEncrypt) then

        if tonumber(StriLi_VersionEncryptToNumber(StriLi_LatestVersionEncrypt)) < StriLi_VersionEncryptToNumber(vEncrypt) then
            StriLi_LatestVersionEncrypt = vEncrypt;
        end
    elseif StriLiOptions["ShowCorruptedVersions"] then
        print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart.."Received corrupted version from: "..sender..CONSTS.msgColorStringEnd);
    end
end

function StriLi.CommunicationHandler:ShoutVersion()

    if not StriLi_isEncryptedVersionValid(StriLi_LatestVersionEncrypt) then return end;

    if GetNumRaidMembers() > 1 then

        local _, instanceType = IsInInstance()

        if instanceType == "pvp" then
            SendAddonMessage("SL_VC", StriLi_VersionEncryptToString(StriLi_LatestVersionEncrypt), "BATTLEGROUND");
        else
            SendAddonMessage("SL_VC", StriLi_VersionEncryptToString(StriLi_LatestVersionEncrypt), "RAID");
        end

    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage("SL_VC", StriLi_VersionEncryptToString(StriLi_LatestVersionEncrypt), "PARTY");
    end

    if IsInGuild() then
        SendAddonMessage("SL_VC", StriLi_VersionEncryptToString(StriLi_LatestVersionEncrypt), "GUILD");
    end

end

function StriLi.CommunicationHandler:On_ItemHistoryAdd(arguments, sender)

    if (StriLi.master:get() ~= sender and StriLi.master:get() ~= "") and not self.requestedSyncAsMaster then return end

    local player, playerClass, rollType, roll, rollNum, index;

    local itemLink, _next = string.match(arguments, "([^%]]+)%s?(.*)");
    _, _next = string.match(_next, CONSTS.nextWordPatern);
    player, _next = string.match(_next, CONSTS.nextWordPatern);
    playerClass, _next = string.match(_next, CONSTS.nextWordPatern);
    rollType, _next = string.match(_next, CONSTS.nextWordPatern);
    roll, _next = string.match(_next, CONSTS.nextWordPatern);
    rollNum = tonumber(roll);
    index, _next = string.match(_next, CONSTS.nextWordPatern);
    local indexNum = tonumber(index);
    local allRolls = {["Main"]={}, ["Sec"]={}};

    local isMain, isRoll = true, true;
    local stringRoll, stringName = "", "";

    for aString in string.gmatch(_next, "[^_]+") do
        if aString == "Main" then
            isMain = true;
        elseif aString == "Sec" then
            isMain = false;
        else
            isRoll = not isRoll;
            if isRoll then
                stringRoll = aString;
                if isMain then
                    table.insert(allRolls["Main"], {["Roll"] = stringRoll, ["Name"] = stringName});
                else
                    table.insert(allRolls["Sec"], {["Roll"] = stringRoll, ["Name"] = stringName});
                end
            else
                stringName = aString;
            end
        end
    end

    if rollNum ~= nil then
        roll = rollNum;
    end

    StriLi.ItemHistory:add(itemLink.."]|h|r", player, playerClass, rollType, roll, indexNum, allRolls);

end

function StriLi.CommunicationHandler:On_ItemHistoryChanged(arguments, sender)

    if (StriLi.master:get() ~= sender  and StriLi.master:get() ~= "" and not (RaidMembersDB:isMemberAssist(sender) and StriLi_isPlayerMaster())) then return end

    local player, playerClass, rollType, roll, rollNum, index

    local itemLink, _next = string.match(arguments, "([^%]]+)%s?(.*)");
    _, _next = string.match(_next, CONSTS.nextWordPatern);
    player, _next = string.match(_next, CONSTS.nextWordPatern);
    playerClass, _next = string.match(_next, CONSTS.nextWordPatern);
    rollType, _next = string.match(_next, CONSTS.nextWordPatern);
    roll, _next = string.match(_next, CONSTS.nextWordPatern);
    rollNum = tonumber(roll)
    index, _next = string.match(_next, CONSTS.nextWordPatern);

    if rollNum ~= nil then
        roll = rollNum;
    end

    StriLi.ItemHistory:On_ItemHistoryChanged(itemLink.."]|h|r", player, playerClass, rollType, roll, tonumber(index));

    if RaidMembersDB:isMemberAssist(sender) and (StriLi_isPlayerMaster()) then
        self:Send_ItemHistoryChanged(itemLink.."]|h|r", player, playerClass, rollType, roll, index);
    end

end

function StriLi.CommunicationHandler:On_ItemHistoryRemove(arguments, sender)

    if (StriLi.master:get() ~= sender and StriLi.master:get() ~= "") then return end

    local index, _ = string.match(arguments, CONSTS.nextWordPatern);

    index = tonumber(index);

    assert(index);

    StriLi.ItemHistory:remove(index);

end

function StriLi.CommunicationHandler:Send_ItemHistoryAdd(itemLink, player, playerClass, rollType, roll, index, forced, allRolls)
    if not StriLi_isPlayerMaster() and not forced then return end;
    local s = "";

    for k, v in pairs(allRolls) do
        s = s..k.."_";
        for _, v2 in pairs(v) do
            s = s..v2["Name"].."_"..v2["Roll"].."_"
        end
    end

    SendAddonMessage("SL_IHA", tostring(itemLink).." "..tostring(player).." "..tostring(playerClass).." "..tostring(rollType).." "..tostring(roll).." "..tostring(index).." "..s, "RAID");
end

function StriLi.CommunicationHandler:Send_ItemHistoryChanged(itemLink, player, playerClass, rollType, roll, index)
    if (not StriLi_isPlayerMaster()) and not RaidMembersDB:isMemberAssist(UnitName("player")) then return end;
    SendAddonMessage("SL_IHC", tostring(itemLink).." "..tostring(player).." "..tostring(playerClass).." "..tostring(rollType).." "..tostring(roll).." "..tostring(index), "RAID");
end

function StriLi.CommunicationHandler:Send_ItemHistoryRemove(index)
    if not StriLi_isPlayerMaster() then return end;
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

function StriLi.CommunicationHandler:Send_promoteMemberToStriLiAssist(name)
    if not StriLi_isPlayerMaster() then return false end;
    SendAddonMessage("SL_PMA", name, "RAID");

    return true;
end

function StriLi.CommunicationHandler:Send_demoteMemberAsStriLiAssist(name)
    if not StriLi_isPlayerMaster() then return false end;
    SendAddonMessage("SL_DMA", name, "RAID");

    return true;
end

function StriLi.CommunicationHandler:On_promoteMemberToStriLiAssist(memberName, sender)
    if StriLi.master:get() ~= sender then return end;
    RaidMembersDB:setMemberAsAssist(memberName);
end

function StriLi.CommunicationHandler:On_demoteMemberAsStriLiAssist(memberName, sender)
    if StriLi.master:get() ~= sender then return end;
    RaidMembersDB:unsetMemberAsAssist(memberName);
end
