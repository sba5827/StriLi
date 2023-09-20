local NH_MarkOfSanctification_t = {
    Vanquisher = 52025,
    Protector = 52026,
    Conqueror = 52027
};

StriLi.AutoRollAnalyser = { itemID = nil, timerFrame = CreateFrame("Frame"), time = 0.0, rolls = {}, rollInProgress = false, item = "" };

function StriLi.AutoRollAnalyser:setItemID(ID)
    if self.rollInProgress then return end;
    assert(type(ID) == "number", StriLi.Lang.ErrorMsg.ExpectNumAsItemID)
    self.itemID = ID;
end

function StriLi.AutoRollAnalyser:setTimeForRolls(time)
    if self.rollInProgress then return end;
    assert(type(time) == "number", StriLi.Lang.ErrorMsg.ExpectNumAsTime)
    self.time = time;
end

function StriLi.AutoRollAnalyser:setItem(item)
    if self.rollInProgress then return end;
    self.item = item;
end

function StriLi.AutoRollAnalyser:getRollInProgress()
    return self.rollInProgress;
end

function StriLi.AutoRollAnalyser:start()

    if self.rollInProgress then return end;

    SendChatMessage(StriLi.Lang.Rolls.StartRoll1..self.item..StriLi.Lang.Rolls.StartRoll2..self.time..StriLi.Lang.Rolls.StartRoll3, "RAID_WARNING");

    self.rollInProgress = true;

    self.rolls = {["Main"] = {}, ["Sec"] = {}};
    self.playerRolled = {};
    self.warn3Done = false;
    self.warn2Done = false;
    self.warn1Done = false;

    StriLi.EventHandler:enable_CHAT_MSG_SYSTEM_event(function(text)
        self:On_CHAT_MSG_SYSTEM(text);
    end);

    self.timerFrame:SetScript("OnUpdate", function(_, elapsedTime)
        self.time = self.time - elapsedTime;

        if self.time < 0.0 then
            SendChatMessage("---", "RAID_WARNING");
            self:finalize();
        elseif self.time < 1.0 and not self.warn1Done then
            SendChatMessage("1", "RAID_WARNING");
            self.warn1Done = true;
        elseif self.time < 2.0 and not self.warn2Done then
            SendChatMessage("2", "RAID_WARNING");
            self.warn2Done = true;
        elseif self.time < 3.0 and not self.warn3Done then
            SendChatMessage("3", "RAID_WARNING");
            self.warn3Done = true;
        end

    end)

end

function StriLi.AutoRollAnalyser:finalize()

    StriLi.EventHandler:disable_CHAT_MSG_SYSTEM_event();
    self.timerFrame:SetScript("OnUpdate", nil);

    self:sortRolls();
    self:shoutWinner();
    self:shoutRolls();
    self:increaseWinnerCountAndExpandItemHistory();

    self.rollInProgress = false;

end

function StriLi.AutoRollAnalyser:cancelRoll()
    if self.rollInProgress then
        StriLi.EventHandler:disable_CHAT_MSG_SYSTEM_event();
        self.timerFrame:SetScript("OnUpdate", nil);
        self.rollInProgress = false;
    end
end

function StriLi.AutoRollAnalyser:On_CHAT_MSG_SYSTEM(text)

    local player_name, _next = string.match(text, CONSTS.nextWordPatern);
    local number, range = string.match(_next, "(%d+)%s?(.*)");
    number = tonumber(number);

    if range == "(1-100)" then
        self:registerRoll("Main", player_name, number);
    elseif range == "(1-99)" then
        self:registerRoll("Sec", player_name, number);
    end

end

function StriLi.AutoRollAnalyser:registerRoll(rollType, player_name, number)

    if not RaidMembersDB:checkForMember(player_name) then return end --if player in ignored list

    if self.playerRolled[player_name] == nil then

        self.playerRolled[player_name] = true;

        if self:isNHToken() then
            local countToGet = ((rollType == "Main" or not StriLiOptions["TokenSecList"]) and "Token" or "TokenSec");
            table.insert(self.rolls[rollType], { ["Roll"]=number, ["Name"]= player_name, ["Count"]=RaidMembersDB:get(player_name)[countToGet]:get(), ["Fail"]=RaidMembersDB:get(player_name)["Fail"]:get()});
        else
            table.insert(self.rolls[rollType], { ["Roll"]=number, ["Name"]= player_name, ["Count"]=RaidMembersDB:get(player_name)[rollType]:get(), ["Fail"]=RaidMembersDB:get(player_name)["Fail"]:get()});
        end

    end

end

function StriLi.AutoRollAnalyser:isNHToken()

    if (self.itemID == NH_MarkOfSanctification_t.Conqueror) or (self.itemID == NH_MarkOfSanctification_t.Protector) or (self.itemID == NH_MarkOfSanctification_t.Vanquisher) then
        return true;
    end

    return false;

end

function StriLi.AutoRollAnalyser:sortRolls()

    local function condition(a,b)

        if ((a["Count"]+a["Fail"]) == (b["Count"]+b["Fail"])) then
            return (a["Roll"] > b["Roll"]);
        else
            return ((a["Count"]+a["Fail"]) < (b["Count"]+b["Fail"]));
        end

    end

    table.sort(self.rolls["Main"], condition);
    table.sort(self.rolls["Sec"], condition);

end

function StriLi.AutoRollAnalyser:shoutWinner()
    local rollType;

    if self.rolls["Main"][1] == nil and self.rolls["Sec"][1] == nil then
        return;
    elseif self.rolls["Main"][1] == nil then
        rollType = "Sec";
    else
        rollType = "Main";
    end

    SendChatMessage(string.format(StriLi.Lang.Rolls.Winner, self.rolls[rollType][1]["Name"], self.item), "RAID");

end

function StriLi.AutoRollAnalyser:shoutRolls()
	
	SendChatMessage("---"..StriLi.Lang.TallyMarkTypes.Main.."---", "RAID");
	for _,v2 in ipairs(self.rolls["Main"]) do
		local s = v2["Name"].." || "..StriLi.Lang.Rolls.TallyMarks..": "..v2["Count"].." || "..StriLi.Lang.Rolls.Fails..": "..v2["Fail"].." || "..StriLi.Lang.Rolls.Roll..": "..v2["Roll"];
		SendChatMessage(s, "RAID");
	end
	
	SendChatMessage("---"..StriLi.Lang.TallyMarkTypes.Sec.."---", "RAID");
	for _,v2 in ipairs(self.rolls["Sec"]) do
		local s = v2["Name"].." || "..StriLi.Lang.Rolls.TallyMarks..": "..v2["Count"].." || "..StriLi.Lang.Rolls.Fails..": "..v2["Fail"].." || "..StriLi.Lang.Rolls.Roll..": "..v2["Roll"];
		SendChatMessage(s, "RAID");
	end

end

function StriLi.AutoRollAnalyser:increaseWinnerCountAndExpandItemHistory()

    local rollType, winnerName, counterToIncrease, raidMember;

    if self.rolls["Main"][1] == nil and self.rolls["Sec"][1] == nil then
        return;
    elseif self.rolls["Main"][1] == nil then
        rollType = "Sec";
    else
        rollType = "Main";
    end

    winnerName = self.rolls[rollType][1]["Name"];

    if self:isNHToken() then
        if rollType == "Main" or not StriLiOptions["TokenSecList"] then
            counterToIncrease = "Token";
        else
            counterToIncrease = "TokenSec";
        end
    else
        counterToIncrease = rollType;
    end

    raidMember = RaidMembersDB:get(winnerName);
    raidMember[counterToIncrease]:add(1);

    local rollsToSave = {["Main"]={}, ["Sec"]={}};

    local i = 1;

    while self.rolls["Main"][i] do
        table.insert(rollsToSave["Main"], {["Roll"] = self.rolls["Main"][i]["Roll"], ["Name"] = self.rolls["Main"][i]["Name"]});
        i = i+1;
    end

    i = 1;

    while self.rolls["Sec"][i] do
        table.insert(rollsToSave["Sec"], {["Roll"] = self.rolls["Sec"][i]["Roll"], ["Name"] = self.rolls["Sec"][i]["Name"]});
        i = i+1;
    end

    StriLi.ItemHistory:add(self.item, winnerName, raidMember[1], counterToIncrease, self.rolls[rollType][1]["Roll"], nil, rollsToSave);
    StriLi.CommunicationHandler:Send_ItemHistoryAdd(self.item, winnerName, raidMember[1], counterToIncrease, self.rolls[rollType][1]["Roll"], nil, false, rollsToSave);

end