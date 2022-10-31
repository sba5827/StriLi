--[[
Class: ---

variables:

methods:

--]]

SLASH_STRILI1 = '/sl'

SlashCmdList["STRILI"] = function(msg, editBox)

    -- pattern matching that skips leading whitespace and whitespace between cmd and args
    -- any whitespace at end of args is retained

    local _, _, t, args = string.find(msg, "%s?(%w+)%s?(.*)")
    t=tonumber(t)

    if ( t == nil) then
        print ("|cffFFFF00StriLiStrili: First argument must be a NUMBER|r");
        return;
    end

    if args == "[@mouseover]" then
        local itemName, itemLink = GameTooltip:GetItem();

        local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
        Suffix, Unique, LinkLvl, Name = string.find(itemLink,
                "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

        if itemLink == nil then return end

        StriLi.AutoRollAnalyser:setItemID(tonumber(Id));
        StriLi.AutoRollAnalyser:setItem(itemLink)

    elseif args ~= "" then

        local firstChar = string.sub(args, 1, 1)

        if firstChar == "|" then
            local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
            Suffix, Unique, LinkLvl, Name = string.find(args,
                    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

            StriLi.AutoRollAnalyser:setItemID(tonumber(Id));

        else
            StriLi.AutoRollAnalyser:setItemID(0); --setting item id to 0 skips the item check
        end

        StriLi.AutoRollAnalyser:setItem(args)

    end

    StriLi.AutoRollAnalyser:setTimeForRolls(t);
    StriLi.AutoRollAnalyser:start();

end