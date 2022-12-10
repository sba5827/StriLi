--[[
Class: ---

--]]

SLASH_STRILI1 = '/sl'

SlashCmdList["STRILI"] = function(msg, _)

    -- pattern matching that skips leading whitespace and whitespace between cmd and args
    -- any whitespace at end of args is retained

    local _, _, t, args = string.find(msg, "%s?(%w+)%s?(.*)");
	
	local inRaid = (GetNumRaidMembers() > 0);

    if ( tonumber(t) == nil) then
        if ( t == "c" ) then
            if not StriLi.AutoRollAnalyser:getRollInProgress() then
                print("|cffFFFF00StriLi: No roll to cancel in progress.|r");
                return;
            elseif not inRaid then
                print("|cffFFFF00StriLi: Invalide command. You're not in a Raid.|r");
                return;
            elseif StriLi_GetPlayerRank(UnitName("player")) < 1 then
                print("|cffFFFF00StriLi: No permission. Your Rank is to low.|r");
                return;
            end

            print("|cffFFFF00StriLi: Roll canceled.|r");
            StriLi.AutoRollAnalyser:cancelRoll();
            return;

        elseif (t == "h") or (t == "help")then

            print("|cffFFFF00StriLi: Available commands: \n/sl h\n/sl help\n/sl <time in s> <Item>\n/sl <time in s> [@mouseover]\n/sl c\n/sl macro\n/sl post all\n/sl post itemless|r");
            return;

        elseif t == "makro" or t == "macro" or t == "m" then

            local copyMacroBox = CreateFrame("FRAME", "StriLi_MakroFrame", UIParent, "StriLi_CopyVersionFrame_Template");
            local editBox = copyMacroBox:GetChildren():GetChildren();
            StriLi_MakroFrame_FontString:SetText("");
            editBox:SetText("/sl <time in s> [@mouseover]");
            editBox:HighlightText();
            copyMacroBox:Show();

            return;

        elseif t == "post" then

            if args == "all" then
                RaidMembersDB:postAllDataToRaid();
            elseif args == "itemless"then
                RaidMembersDB:postNamesOfUnluckyPlayers();
            end

            return;

        else

            print ("|cffFFFF00StriLi: First argument must be a NUMBER|r");
            return;

        end
    end

	if not inRaid then
		print("|cffFFFF00StriLi: Invalide command. You're not in a Raid.|r");
		return;
    elseif StriLi_GetPlayerRank(UnitName("player")) < 1 then
        print("|cffFFFF00StriLi: No permission. Your Rank is to low.|r");
        return;
    end

    if StriLi.AutoRollAnalyser:getRollInProgress() then
        print ("|cffFFFF00StriLi: You have already a roll in progress. To cancel a current roll type '/sl c'.|r");
        return;
    end

    if args == "[@mouseover]" then
        local _, itemLink = GameTooltip:GetItem();

        local _, _, _, _, Id, _, _, _, _, _,
        _, _, _, _ = string.find(itemLink,
                "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

        if itemLink == nil then return end

        StriLi.AutoRollAnalyser:setItemID(tonumber(Id));
        StriLi.AutoRollAnalyser:setItem(itemLink);

    elseif args ~= "" then

        local firstChar = string.sub(args, 1, 1);

        if firstChar == "|" then
            local _, _, _, _, Id, _, _, _, _, _,
            _, _, _, _ = string.find(args,
                    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

            StriLi.AutoRollAnalyser:setItemID(tonumber(Id));

        else
            StriLi.AutoRollAnalyser:setItemID(0); --setting item id to 0 skips the item check
        end

        StriLi.AutoRollAnalyser:setItem(args)

    end

    StriLi.AutoRollAnalyser:setTimeForRolls(tonumber(t));
    StriLi.AutoRollAnalyser:start();

end
