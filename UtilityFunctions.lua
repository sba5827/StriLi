function protect(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function(t, key, value)
            error("attempting to change constant " ..
                    tostring(key) .. " to " .. tostring(value), 2)
        end
    })
end

CONSTS = protect({
    itemLinkPatern = "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?",
    nextWordPatern = "([^%s]+)%s?(.*)",
    nextLinePatern = "([^\n]*)\n?(.*)",
    msgColorStringStart = "|cffFFFF00",
    msgColorStringEnd = "|r",
});

function StriLi_isPlayerMaster()
    return StriLi.master:get() == UnitName("player");
end

function StriLi_SetMaster(arg1)

    local newMasterName = arg1;

    local numOfMembers = GetNumRaidMembers();

    local found = false;

    for i = 1, numOfMembers, 1 do
        local name, rank = GetRaidRosterInfo(i);
        if (name == newMasterName) then
            found = true;

            if (rank > 0) or StriLiOptions["AutoPromote"] then
                StriLi_tryToSetNewMaster(newMasterName);
            else
                print(CONSTS.msgColorStringStart..newMasterName.." "..StriLi.Lang.ErrorMsg.SetMasterNotPossible.." "..StriLi.Lang.ErrorMsg.RankToLow.."|r");
            end
            break;
        end
    end

    if not found then
        print(CONSTS.msgColorStringStart..newMasterName.." "..StriLi.Lang.ErrorMsg.SetMasterNotPossible.." "..newMasterName.." "..StriLi.Lang.ErrorMsg.PlayerNotInRaid.."|r");
    end

end

function StriLi_tryToSetNewMaster(newMasterName)

    if StriLi_isPlayerMaster() then

        StriLi.CommunicationHandler:checkIfUserHasStriLi(newMasterName, function(userHasStriLi)
            if userHasStriLi then
                if StriLi.CommunicationHandler:sendMasterChanged(newMasterName) then
                    if StriLiOptions["AutoPromote"] then PromoteToAssistant(newMasterName) end
                    StriLi.master:set(newMasterName);
                    if newMasterName ~= "" then
                        if RaidMembersDB:isMemberAssist(UnitName("player")) then

                            StriLi.MainFrame.rows[UnitName("player")]:setStatus(RowFrameStatus_t.StriLiAssist);
                        else

                            StriLi.MainFrame.rows[UnitName("player")]:setStatus(RowFrameStatus_t.HasStriLi);
                        end

                        StriLi.MainFrame.rows[newMasterName]:setStatus(RowFrameStatus_t.StriLiMaster);
                    end
                end
            else
                print(CONSTS.msgColorStringStart..newMasterName.." "..StriLi.Lang.ErrorMsg.SetMasterNotPossible.." "..StriLi.Lang.ErrorMsg.PossibleCauses..":\n - "
                        ..newMasterName.." "..StriLi.Lang.ErrorMsg.Cause1.."\n - "
                        ..newMasterName.." "..StriLi.Lang.ErrorMsg.Cause2.."\n - "
                        ..StriLi.Lang.ErrorMsg.Cause3.."\n - "
                        ..newMasterName.." "..StriLi.Lang.ErrorMsg.Cause4.."\n - "
                        ..newMasterName.." "..StriLi.Lang.ErrorMsg.Cause5.."|r");
            end

        end);

    end

end

function StriLi_SetAssist(name)

    local numOfMembers = GetNumRaidMembers();

    local found = false;

    for i = 1, numOfMembers, 1 do
        local _name, _ = GetRaidRosterInfo(i);
        if (_name == name) then
            found = true;
            StriLi_tryToSetAssist(name);
            break;
        end
    end

    if not found then
        print(CONSTS.msgColorStringStart..name.." "..StriLi.Lang.ErrorMsg.SetAssistNotPossible.." "..name.." "..StriLi.Lang.ErrorMsg.PlayerNotInRaid.."|r");
    end

end

function StriLi_tryToSetAssist(name)

    if StriLi_isPlayerMaster() then

        StriLi.CommunicationHandler:checkIfUserHasStriLi(name, function(userHasStriLi)
            if userHasStriLi then
                if StriLi.CommunicationHandler:Send_promoteMemberToStriLiAssist(name) then
                    RaidMembersDB:setMemberAsAssist(name);
                    if name ~= "" then

                        StriLi.MainFrame.rows[name]:setStatus(RowFrameStatus_t.StriLiAssist);
                    end
                end
            else
                print(CONSTS.msgColorStringStart..name.." "..StriLi.Lang.ErrorMsg.SetAssistNotPossible.." "..StriLi.Lang.ErrorMsg.PossibleCauses..":\n - "
                        ..name.." "..StriLi.Lang.ErrorMsg.Cause1.."\n - "
                        ..name.." "..StriLi.Lang.ErrorMsg.Cause2.."\n - "
                        ..StriLi.Lang.ErrorMsg.Cause3.."\n - "
                        ..name.." "..StriLi.Lang.ErrorMsg.Cause4.."\n - "
                        ..name.." "..StriLi.Lang.ErrorMsg.Cause5.."|r");
            end

        end);

    end

end

function StriLi_GetPlayerRank(playerName)

    for i = 1, GetNumRaidMembers(), 1 do
        local name, rank = GetRaidRosterInfo(i);
        if (name == playerName) then
            return rank;
        end
    end

end

function StriLi_GetRaidIndexOfPlayer(playerName)

    for i = 1, GetNumRaidMembers(), 1 do
        local name = GetRaidRosterInfo(i);
        if (name == playerName) then
            return i
        end
    end

    return 0;

end

function StriLi_SetTextColorByClass(FontString, Class)

    if    ( Class == nil ) 				then return end

    if 	  ( Class == "WARRIOR" ) 		then FontString:SetTextColor(0.78,	0.61,	0.43, 1)
    elseif( Class == "PALADIN" ) 		then FontString:SetTextColor(0.96,	0.55,	0.73, 1)
    elseif( Class == "HUNTER" ) 		then FontString:SetTextColor(0.67,	0.83,	0.45, 1)
    elseif( Class == "ROGUE" ) 			then FontString:SetTextColor(1.00,	0.96,	0.41, 1)
    elseif( Class == "PRIEST" ) 		then FontString:SetTextColor(1.00,	1.00,	1.00, 1)
    elseif( Class == "DEATHKNIGHT" ) 	then FontString:SetTextColor(0.77,	0.12,	0.23, 1)
    elseif( Class == "SHAMAN" ) 		then FontString:SetTextColor(0.00,	0.44,	0.87, 1)
    elseif( Class == "MAGE" ) 			then FontString:SetTextColor(0.25,	0.78,	0.92, 1)
    elseif( Class == "WARLOCK" ) 		then FontString:SetTextColor(0.53,	0.53,	0.93, 1)
    elseif( Class == "DRUID" ) 			then FontString:SetTextColor(1.00,	0.49,	0.04, 1)
    end

end

function Strili_GetHexClassColorCode(Class) -- Returns RRGGBB

    if( Class == "WARRIOR" ) 		then return "C69B6D" end
    if( Class == "PALADIN" ) 		then return "F48CBA" end
    if( Class == "HUNTER" ) 		then return "AAD372" end
    if( Class == "ROGUE" ) 			then return "FFF468" end
    if( Class == "PRIEST" ) 		then return "FFFFFF" end
    if( Class == "DEATHKNIGHT" ) 	then return "C41E3A" end
    if( Class == "SHAMAN" ) 		then return "0070DD" end
    if( Class == "MAGE" ) 			then return "3FC7EB" end
    if( Class == "WARLOCK" ) 		then return "8788EE" end
    if( Class == "DRUID" ) 			then return "FF7C0A" end

end

function StriLi_GetClassIndex(Class)

    if( Class == "WARRIOR" ) 		then return 1 end
    if( Class == "PALADIN" ) 		then return 2 end
    if( Class == "HUNTER" ) 		then return 3 end
    if( Class == "ROGUE" ) 			then return 4 end
    if( Class == "PRIEST" ) 		then return 5 end
    if( Class == "DEATHKNIGHT" ) 	then return 6 end
    if( Class == "SHAMAN" ) 		then return 7 end
    if( Class == "MAGE" ) 			then return 8 end
    if( Class == "WARLOCK" ) 		then return 9 end
    if( Class == "DRUID" ) 			then return 10 end

    return 0;
end

function StriLi_ColorCounterCell(cell, count, even)

    local R,G,B = 0,0,0;

    if (even) then
        if ( count >=4 ) then
            R, G, B = 204, 100, 100;
        elseif ( count == 3) then
            R, G, B = 204, 150, 100;
        elseif ( count == 2) then
            R, G, B = 204, 204, 0;
        elseif ( count == 1) then
            R, G, B = 180, 204, 180;
        elseif ( count == 0) then
            R, G, B = 204, 204, 204;
        end
    else
        if ( count >=4 ) then
            R, G, B = 255, 100, 100;
        elseif ( count == 3) then
            R, G, B = 255, 200, 160;
        elseif ( count == 2) then
            R, G, B = 255, 225, 0;
        elseif ( count == 1) then
            R, G, B = 220, 255, 220;
        elseif ( count == 0) then
            R, G, B = 255, 255, 255;
        end
    end

    cell:SetStatusBarColor(R/255,G/255,B/255,1);

end


function StriLi_initAddon()

    StriLi.InitLang()

    local addonVersion = tonumber(GetAddOnMetadata("StriLi", "Version"));

    if StriLi_LatestVersion ~= nil then
        --Secure that StriLi_LatestVersion will never be a String.
        StriLi_LatestVersion = tonumber(StriLi_LatestVersion);
    end

    if StriLi_LatestVersion == nil then
        StriLi_LatestVersion = addonVersion;
    elseif StriLi_LatestVersion < addonVersion then
        StriLi_LatestVersion = addonVersion;
    end
    if StriLi_Master == nil then
        StriLi.master = ObservableString:new();
        StriLi.master:set("");
    else
        StriLi.master = ObservableString:new();
        StriLi.master:set(StriLi_Master);
    end
    if StriLi_newRaidGroup == nil then
        StriLi_newRaidGroup = true;
    end
    if StriLi_RaidMembersDB_members == nil then
        StriLi_RaidMembersDB_members ={};
    end
    if StriLi_ItemHistory == nil then
        StriLi_ItemHistory = {};
    end
    if StriLi_RulesTxt == nil then
        StriLi_RulesTxt = "";
    end
    if StriLiOptions == nil then
        StriLiOptions = {
            ["AutoPromote"] = false,
            ["TokenSecList"] = false,
        };
    end

    StriLi.LootRules:setText(StriLi_RulesTxt);

    RaidMembersDB:initFromRawData(StriLi_RaidMembersDB_members);

    StriLi.CommunicationHandler:ShoutVersion();

end

function StriLi_finalizeAddon()
    StriLi_RaidMembersDB_members = RaidMembersDB:getRawData();
    StriLi_Master = StriLi.master:get();
    StriLi_ItemHistory = StriLi.ItemHistory:getRawData();
    StriLi_RulesTxt = StriLi.LootRules:getText();
    StriLi.MainFrame.frame:SetUserPlaced(false);
    StriLi.ItemHistory.frame:SetUserPlaced(false);
end

---removes the first occurring 'value'
function table.removeByValue(list, value)
    for i, v in pairs(list) do
        if v == value then
            return table.remove(list,i);
        end
    end
end

function delayedFunctionCall(delay_s, functionToCall)
    local timerFrame = CreateFrame("Frame");
    local time = delay_s;

    timerFrame:SetScript("OnUpdate", function(_, elapsedTime)
        time = time - elapsedTime;
        if time < 0.0 then
            functionToCall();
            timerFrame:SetScript("OnUpdate", nil);
        end
    end)
end