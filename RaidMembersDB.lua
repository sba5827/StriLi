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
        ["Main"] = ObservableNumber:new(),
        ["Sec"] = ObservableNumber:new(),
        ["Token"] = ObservableNumber:new(),
        ["TokenSec"] = ObservableNumber:new(),
        ["Fail"] = ObservableNumber:new(),
        ["Reregister"] = ObservableString:new();
    };

    self.size = self.size + 1;

end

function RaidMembersDB:get(name)

    if self:checkForMember(name) then
        return self.raidMembers[name];
    end

    error(string.format(StriLi.Lang.ErrorMsg.RaidMemNotInDB, name));

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
                print (CONSTS.StriLi.msgColorStringStart.."StriLi: "..StriLi.Lang.ErrorMsg.RemoveOnlineRaidmember.."|r");
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
                 ["TokenSec"] = v["TokenSec"]:get(),
                 ["Fail"] = v["Fail"]:get(),
                 ["Reregister"] = v["Reregister"]:get()
        }
    end

    return t;

end

function RaidMembersDB:initFromRawData(rawData)

    for i, v in pairs(rawData) do

        self.raidMembers[i] = {
            [1] = v[1],
            ["Main"] = ObservableNumber:new(),
            ["Sec"] = ObservableNumber:new(),
            ["Token"] = ObservableNumber:new(),
            ["TokenSec"] = ObservableNumber:new(),
            ["Fail"] = ObservableNumber:new(),
            ["Reregister"] = ObservableString:new();
        };

        self.raidMembers[i]["Main"]:set(v["Main"]);
        self.raidMembers[i]["Sec"]:set(v["Sec"]);
        self.raidMembers[i]["Token"]:set(v["Token"]);
        self.raidMembers[i]["TokenSec"]:set(v["TokenSec"]);
        self.raidMembers[i]["Fail"]:set(v["Fail"]);
        self.raidMembers[i]["Reregister"]:set(v["Reregister"]);

        self.size = self.size + 1;

    end

end

function RaidMembersDB:postAllDataToRaid()
    for name, v in pairs(self.raidMembers) do
        SendChatMessage(name.." || "..StriLi.Lang.TallyMarkTypes.Main..": "..v["Main"]:get().." "..StriLi.Lang.TallyMarkTypes.Sec..": "..v["Sec"]:get().." "..StriLi.Lang.TallyMarkTypes.Token..": "..v["Token"]:get().." "..StriLi.Lang.TallyMarkTypes.TokenSec..": "..v["TokenSec"]:get().." "..StriLi.Lang.TallyMarkTypes.Fail..": "..v["Fail"]:get(), "RAID");
    end
end

function RaidMembersDB:postNamesOfUnluckyPlayers()

    local playerNamesString = CONSTS.msgColorStringStart.."StriLi: "..StriLi.Lang.Commands.PlayersGotLoot..": "

    for name, v in pairs(self.raidMembers) do
        if v["Main"]:get() == 0 and v["Sec"]:get() == 0 and v["Token"]:get() == 0 and v["TokenSec"]:get() == 0 then
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
        mem1["TokenSec"]:add(mem2["TokenSec"]:get());
        mem1["Fail"]:add(mem2["Fail"]:get());

        return true;

    end

    return false;

end

function RaidMembersDB:getSize()
    return self.size;
end

function RaidMembersDB:OnTokenListOptionChanged()
    if (UnitName("player") == StriLi.master:get()) or StriLi.master:get() == "" then
        if not StriLiOptions["TokenSecList"] then
            for name, v in pairs(self.raidMembers) do
                v["Token"]:add(v["TokenSec"]:get());
                v["TokenSec"]:set(0);
                StriLi.CommunicationHandler:sendDataChanged(name, "TokenSec", 0, false);
                --StriLi.ItemHistory:
            end
        end
    end
end