StriLi.LootRules = {frame=CreateFrame("FRAME","StriLi_LootRulesFrame", UIParent, "StriLi_LootRulesFrame_Template"), text = "tescht"};

function StriLi.LootRules:init()
    self.frame.ScrollFrame.EditBox:SetText(self.text);

    self.frame:SetScript("OnMouseDown", function(frame)
        if (not frame.isMoving) and (frame.isLocked ~= 1) then
            frame:StartMoving();
            frame.isMoving = true;
        end
    end);
    self.frame:SetScript("OnMouseUp", function(frame)
        if (frame.isMoving) then
            frame:StopMovingOrSizing();
            frame.isMoving = false;
        end
    end);

end

function StriLi.LootRules:setText(text)
    self.text = text;
end

function StriLi.LootRules:getText()
    return self.text;
end

function StriLi.LootRules:OnClickSaveButton()
    self.text = self.frame.ScrollFrame.EditBox:GetText();
    self:hide();
end

function StriLi.LootRules:show()
    ShowUIPanel(self.frame);
end

function StriLi.LootRules:hide()
    HideUIPanel(self.frame);
end

function StriLi.LootRules:postToRaid()

    local _, _, line, next = string.find(self.text, "([^\n]*)\n?(.*)");

    while not ((line == "") and (next == "")) do
        SendChatMessage(line, "RAID");
        _, _, line, next = string.find(next, "([^\n]*)\n?(.*)");
    end

end