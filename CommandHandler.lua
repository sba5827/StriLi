SLASH_STRILI1 = '/sl'

SlashCmdList["STRILI"] = function(msg, _)

    -- pattern matching that skips leading whitespace and whitespace between cmd and args
    -- any whitespace at end of args is retained


    local startIndex, endIndex, t, args = string.find(msg, "%s*(%w+)%s*(.*)");
	
	local inRaid = (GetNumRaidMembers() > 0);
    if startIndex == nil then
        StriLi.MainFrame:toggle();
    else
        if ( tonumber(t) == nil) then

            t = string.lower(t);
            args = string.lower(args);

            if ( t == "c" ) then
                if not StriLi.AutoRollAnalyser:getRollInProgress() then
                    print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Rolls.NoRollToCancel.."|r");
                    return;
                elseif not inRaid then
                    print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.InvalideNotInRaid.."|r");
                    return;
                end

                StriLi.AutoRollAnalyser:cancelRoll();
                print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Rolls.RollCanceled.."|r");
                return;

            elseif (t == "h") or (t == "help")then

                print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.AvailableCommands..":|r");
                print(CONSTS.msgColorStringStart.."/sl h|r");
                print(CONSTS.msgColorStringStart.."/sl help|r");
                print(CONSTS.msgColorStringStart.."/sl <"..StriLi.Lang.Commands.TimeInSec.."> <Item>|r");
                print(CONSTS.msgColorStringStart.."/sl <"..StriLi.Lang.Commands.TimeInSec.."> [@mouseover]|r");
                print(CONSTS.msgColorStringStart.."/sl m|r");
                print(CONSTS.msgColorStringStart.."/sl makro|r");
                print(CONSTS.msgColorStringStart.."/sl macro|r");
                print(CONSTS.msgColorStringStart.."/sl rules|r");
                print(CONSTS.msgColorStringStart.."/sl post all|r");
                print(CONSTS.msgColorStringStart.."/sl post itemless|r");
                print(CONSTS.msgColorStringStart.."/sl post rules|r");
                return;

            elseif t == "makro" or t == "macro" or t == "m" then

                local copyMacroBox = CreateFrame("FRAME", "StriLi_MakroFrame", UIParent, "StriLi_CopyVersionFrame_Template");
                local editBox = copyMacroBox:GetChildren():GetChildren();
                StriLi_MakroFrame_FontString:SetText(StriLi.Lang.XML.CopyMacro);
                editBox:SetText("/sl <"..StriLi.Lang.Commands.TimeInSec.."> [@mouseover]");
                editBox:HighlightText();
                copyMacroBox:Show();
                editBox:SetScript("OnEscapePressed", function() copyMacroBox:Hide() end);

                return;

            elseif t == "post" then

                if args == "all" then
                    if inRaid then
                        RaidMembersDB:postAllDataToRaid();
                    elseif inRaid then
                        print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.InvalideNotInRaid.."|r");
                        return;
                    end
                elseif args == "itemless" then
                    RaidMembersDB:postNamesOfUnluckyPlayers();
                elseif args == "rules" then

                    if not inRaid then
                        print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.InvalideNotInRaid.."|r");
                        return;
                    elseif StriLi_GetPlayerRank(UnitName("player")) < 1 then
                        print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.NoPermRankToLow.."|r");
                        return;
                    end
                    StriLi.LootRules:postToRaid();
                    return;

                end

                return;

            elseif t == "rules" then
                StriLi.LootRules:show();
                return;
            else

                print (CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.FirstArgNum.."|r");
                return;

            end
        end

        if not inRaid then
            print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.InvalideNotInRaid.."|r");
            return;
        elseif not StriLi_isPlayerMaster() then
            print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.YourNotMaster.."|r");
            return;
        elseif StriLi_GetPlayerRank(UnitName("player")) < 1 then
            print(CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Commands.NoPermRankToLow.."|r");
            return;
        end

        if StriLi.AutoRollAnalyser:getRollInProgress() then
            print (CONSTS.striLiMsgFlag..CONSTS.msgColorStringStart..StriLi.Lang.Rolls.RollAlreadyInProgress.." '/sl c'.|r");
            return;
        end

        if string.lower(args) == "[@mouseover]" then
            local _, itemLink = GameTooltip:GetItem();

            local _, _, _, _, Id = string.find(itemLink, CONSTS.itemLinkPatern)

            if itemLink == nil then return end

            StriLi.AutoRollAnalyser:setItemID(tonumber(Id));
            StriLi.AutoRollAnalyser:setItem(itemLink);

        elseif args ~= "" then

            local firstChar = string.sub(args, 1, 1);

            if firstChar == "|" then
                local _, _, _, _, Id = string.find(args, CONSTS.itemLinkPatern)

                StriLi.AutoRollAnalyser:setItemID(tonumber(Id));

            else
                StriLi.AutoRollAnalyser:setItemID(0); --setting item id to 0 skips the item check
            end

            StriLi.AutoRollAnalyser:setItem(args)

        end

        StriLi.AutoRollAnalyser:setTimeForRolls(tonumber(t));
        StriLi.AutoRollAnalyser:start();

    end

end
