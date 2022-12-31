ConfirmDialogFrame = { frame = nil, fontString = nil, confirmButton = nil, cancelButton = nil };

function ConfirmDialogFrame:new(o, text, confirmFnc, cancelFnc)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    if o.frame == nil then
        o.frame = CreateFrame("FRAME", "ConfirmDialogFrame", UIParent, "StriLi_ConfirmDialogFrame_Template");
    end

    local regions = {o.frame:GetRegions()};
    o.fontString = regions[10];
    o.fontString:SetText(text);
    o.fontString:SetWidth(400);

    o.confirmButton, o.cancelButton = o.frame:GetChildren();

    o.confirmButton:SetScript("OnClick", function() if confirmFnc ~= nil then confirmFnc() end; o.frame:Hide() end);
    o.cancelButton:SetScript("OnClick", function() if cancelFnc ~= nil then cancelFnc() end; o.frame:Hide() end);

    return o;

end

function ConfirmDialogFrame:show()
    self.frame:Show();
    self.frame:Raise();
    self.frame:Raise();
    self.frame:Raise();
end

function ConfirmDialogFrame:hide()
    self.frame:Hide();
end