--[[
Class: ---

--]]

SLASH_STRILI1 = '/sl'

SlashCmdList["STRILI"] = function(msg, _)

    -- pattern matching that skips leading whitespace and whitespace between cmd and args
    -- any whitespace at end of args is retained

    local _, _, t, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if ( tonumber(t) == nil) then
        if ( t == "c" )then
            if not StriLi.AutoRollAnalyser:getRollInProgress() then
                print("|cffFFFF00StriLiNo roll to cancel in progress.|r");
                return;
            end

            print("|cffFFFF00StriLiRoll canceled.|r");
            StriLi.AutoRollAnalyser:cancelRoll();
            return;

        else

            print ("|cffFFFF00StriLiStrili: First argument must be a NUMBER|r");
            return;

        end
    end

    if StriLi.AutoRollAnalyser:getRollInProgress() then
        print ("|cffFFFF00StriLiYou have already a roll in progress. To cancel a current roll type '/sl c'.|r");
        return;
    end

    if args == "[@mouseover]" then
        local _, itemLink = GameTooltip:GetItem();

        local _, _, _, _, Id, _, _, _, _, _,
        _, _, _, _ = string.find(itemLink,
                "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

        if itemLink == nil then return end

        StriLi.AutoRollAnalyser:setItemID(tonumber(Id));
        StriLi.AutoRollAnalyser:setItem(itemLink)

    elseif args ~= "" then

        local firstChar = string.sub(args, 1, 1)

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