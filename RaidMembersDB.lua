--[[
Class: RaidMembersDB

variables:
    raidMembers -- gets initialized in StriLi_initAddon for error prevention
    size

methods:
    checkForMember
    add
    get
    remove
    getRawData
    initFromRawData
    combineMembers
    getSize

--]]
--[[
	Dependencies:
		- observableNumber
--]]

RaidMembersDB = { raidMembers = {}, size = 0 };

function RaidMembersDB:checkForMember(name)

    if self.raidMembers[name] == nil then
        return false;
    end

    return true;

end

function RaidMembersDB:add(name, class)

    if self.raidMembers[name] ~= nil then
        error("Player " .. name .. " is already in DB");
        return ;
    end

    self.raidMembers[name] = {
        [1] = class,
        ["Main"] = ObservableNumber:new(nil),
        ["Sec"] = ObservableNumber:new(nil),
        ["Token"] = ObservableNumber:new(nil),
        ["Fail"] = ObservableNumber:new(nil),
        ["Reregister"] = ""
    };

    self.size = self.size + 1;

end

function RaidMembersDB:get(name)

    if self:checkForMember(name) then
        return self.raidMembers[name];
    end

    error("Raidmember " .. name .. " does not exist in DB.");

end

function RaidMembersDB:remove(name, forced)

    if not forced then
        local raidMemberIndex = StriLi_GetRaidIndexOfPlayer(raidMemberName);

        if raidMemberIndex > 40 then
            error("WTF?!");
        end

        if raidMemberIndex ~= 0 then
            local _, _, _, _, _, _, _, online = GetRaidRosterInfo(raidMemberIndex);

            if online then
                print ("|cffFFFF00StriLi: You can't remove online raidmembers from StriLi.|r");
                return false;
            end
        end
    end

    if self.raidMembers[name] ~= nil then
        self.raidMembers[name] = nil;
        self.size = self.size - 1;
    end

    return true;

end

function RaidMembersDB:getRawData()

    local t = {}

    for i, v in pairs(self.raidMembers) do
        t[i] = { [1] = v[1],
                 ["Main"] = v["Main"]:get(),
                 ["Sec"] = v["Sec"]:get(),
                 ["Token"] = v["Token"]:get(),
                 ["Fail"] = v["Fail"]:get(),
                 ["Reregister"] = v["Reregister"]
        }
    end

    return t;

end

function RaidMembersDB:initFromRawData(rawData)

    for i, v in pairs(rawData) do

        self.raidMembers[i] = {
            [1] = v[1],
            ["Main"] = ObservableNumber:new(nil),
            ["Sec"] = ObservableNumber:new(nil),
            ["Token"] = ObservableNumber:new(nil),
            ["Fail"] = ObservableNumber:new(nil),
            ["Reregister"] = v["Reregister"];
        };

        self.raidMembers[i]["Main"]:set(v["Main"]);
        self.raidMembers[i]["Sec"]:set(v["Sec"]);
        self.raidMembers[i]["Token"]:set(v["Token"]);
        self.raidMembers[i]["Fail"]:set(v["Fail"]);

        self.size = self.size + 1;

    end

end

function RaidMembersDB:postAllDataToRaid()
    for name, v in pairs(self.raidMembers) do
        SendChatMessage(name.." || Main: "..v["Main"]:get().." Sec: "..v["Sec"]:get().." Token: "..v["Token"]:get().." Fail: "..v["Main"]:get(), "RAID");
    end
end

function RaidMembersDB:postNamesOfUnluckyPlayers()

    local playerNamesString = "|cffFFFF00StriLi: Players that got no Loot: "

    for name, v in pairs(self.raidMembers) do
        if v["Main"]:get() == 0 and v["Sec"]:get() == 0 and v["Token"]:get() == 0 then
            playerNamesString = playerNamesString..name..", ";
        end
    end

    playerNamesString = playerNamesString:sub(1, -3);

    print(playerNamesString.."|r");

end

function RaidMembersDB:combineMembers(memName1, memName2)

    if memName1 == memName2 or not self:checkForMember(memName1) or not self:checkForMember(memName2) then
        return false;
    end

    local mem1, mem2 = self:get(memName1), self:get(memName2);

    if self:remove(memName2, false) then

        mem1["Main"]:add(mem2["Main"]:get());
        mem1["Sec"]:add(mem2["Sec"]:get());
        mem1["Token"]:add(mem2["Token"]:get());
        mem1["Fail"]:add(mem2["Fail"]:get());

        return true;

    end

    return false;

end

function RaidMembersDB:getSize()
    return self.size;
end