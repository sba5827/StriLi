--[[
Class: AutoRollAnalyser

variables:

methods:

--]]

StriLi.AutoRollAnalyser = { itemID = nil, timerFrame = CreateFrame("Frame"), time = 0.0, rolls = {}, rollInProgress = false, item = "" };

function StriLi.AutoRollAnalyser:setItemID(ID)
    assert(type(ID) == "number", "Expected number as ItemID!")
    self.itemID = ID;
end

function StriLi.AutoRollAnalyser:setTimeForRolls(time)
    assert(type(time) == "number", "Expected number as time!")
    self.time = time;
end

function StriLi.AutoRollAnalyser:setItem(item)
    self.item = item;
end

function StriLi.AutoRollAnalyser:start()

    if self.rollInProgress then return end;

    SendChatMessage("Es wird um das Item "..self.item.." gewürfelt. Du hast "..self.time.." Sekunden zeit.", "RAID_WARNING");

    self.rollInProgress = true;

    self.rolls = {["Main"] = {}, ["Sec"] = {}};
    self.playerRolled = {};
    self.warn3Done = false;
    self.warn2Done = false;
    self.warn1Done = false;

    StriLi.EventHandler:enable_CHAT_MSG_SYSTEM_event(function(text)
        self:On_CHAT_MSG_SYSTEM(text)
    end);

    self.timerFrame:SetScript("OnUpdate", function(this, elapsedTime)
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
    self:shoutRolls();
    self:increaseWinnerCount();

    self.rollInProgress = false;

end

function StriLi.AutoRollAnalyser:On_CHAT_MSG_SYSTEM(text)

    local playername, _next = string.match(text, "([^%s]+)%s?(.*)");
    local number, range = string.match(_next, "(%d+)%s?(.*)");
    number = tonumber(number);

    if range == "(1-100)" then
        self:registerRoll("Main", playername, number);
    elseif range == "(1-99)" then
        self:registerRoll("Sec", playername, number);
    end

end

function StriLi.AutoRollAnalyser:registerRoll(rollType, playername, number)

    if self.playerRolled[playername] == nil then

        self.playerRolled[playername] = true;

        if self:isNHToken() then
            table.insert(self.rolls[rollType], {["Roll"]=number, ["Name"]=playername, ["Count"]=RaidMembersDB:get(playername)["Token"]:get()});
        else
            table.insert(self.rolls[rollType], {["Roll"]=number, ["Name"]=playername, ["Count"]=RaidMembersDB:get(playername)[rollType]:get()});
        end

    end

end

function StriLi.AutoRollAnalyser:isNHToken()

    if (self.itemID == 52027) or (self.itemID == 52026) or (self.itemID == 52025) then
        return true;
    end

    return false;

end

function StriLi.AutoRollAnalyser:sortRolls()

    local function condition(a,b)

        if (a["Count"] == b["Count"]) then
            return (a["Roll"] >= b["Roll"]);
        else
            return (a["Count"] <= b["Count"]);
        end

    end

    table.sort(self.rolls["Main"], condition);
    table.sort(self.rolls["Sec"], condition);

end

function StriLi.AutoRollAnalyser:shoutRolls()

    for k,v in pairs(self.rolls) do
        SendChatMessage("---"..k.."---", "RAID");
        for k2,v2 in ipairs(v) do
            s = v2["Name"].." || Striche: "..v2["Count"].." || Roll: "..v2["Roll"];
            SendChatMessage(s, "RAID");
        end
    end

end

function StriLi.AutoRollAnalyser:increaseWinnerCount()

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
        counterToIncrease = "Token"
    else
        counterToIncrease = rollType
    end

    raidMember = RaidMembersDB:get(winnerName);
    raidMember[counterToIncrease]:add(1);

end