TextInputFrame = { frame = nil, confirm_function = nil, cancel_fnc = nil };

function TextInputFrame:new(o, text, confirm_fnc, cancel_fnc)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    if TextInputFrame.frame == nil then
        TextInputFrame.frame = CreateFrame("Frame", "StriLi_TextInputFrame", StriLi.MainFrame.frame, "StriLi_TextInputDialogFrame_Template");
    end

    self.confirm_function = confirm_fnc;
    self.cancel_fnc = cancel_fnc;

    StriLi_TextInputFrame_FontString:SetText(text);
    StriLi_TextInputFrame_Frame_EditBox:SetText("");
    StriLi_TextInputFrame_ConfirmButton:SetScript("OnClick", function()
        StriLi_TextInputFrame:Hide();
        if (self.confirm_function ~= nil) then
            self.confirm_function(StriLi_TextInputFrame_Frame_EditBox:GetText());
        end
    end);

    StriLi_TextInputFrame_CancleButton:SetScript("OnClick", function()
        StriLi_TextInputFrame:Hide();
        if (self.cancel_fnc ~= nil) then
            self.cancel_fnc(StriLi_TextInputFrame_Frame_EditBox:GetText());
        end
    end);

    return o;

end

function TextInputFrame:show()
    self.frame:Show();
    self.frame:Raise();
end