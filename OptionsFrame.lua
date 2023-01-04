function StriLi_OptionFrame_init()
    local panel = CreateFrame("FRAME");
    panel.name = "StriLi";
    InterfaceOptions_AddCategory(panel);

    -- Create the parent frame and size it to fit inside the texture
    local optionFrame = CreateFrame("FRAME", nil, panel)
    optionFrame:SetPoint("TOPLEFT", 3, -4)
    optionFrame:SetPoint("BOTTOMRIGHT", -27, 4)

    local title = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP")
    title:SetText("StriLi")

    local checkBoxAutoPromoteToRaidAsi = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate")
    checkBoxAutoPromoteToRaidAsi:SetPoint("TOPLEFT", 30, -20)
    
    if StriLiOptions["AutoPromote"] then checkBoxAutoPromoteToRaidAsi:SetChecked(true) end
    checkBoxAutoPromoteToRaidAsi:SetScript("OnClick",
            function(this, button, down)
                StriLiOptions["AutoPromote"] = this:GetChecked();
            end);

    local fsAutoPromoteToRaidAsi  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsAutoPromoteToRaidAsi:SetPoint("TOPLEFT", 60, -25)
    fsAutoPromoteToRaidAsi:SetText(StriLi.Lang.Options.AutoPromote);
    
    local checkBoxTokenSecList = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate")
    checkBoxTokenSecList:SetPoint("TOPLEFT", 30, -50);
    
    if StriLiOptions["TokenSecList"] then checkBoxTokenSecList:SetChecked(true) end
    checkBoxTokenSecList:SetScript("OnClick",
            function(this, button, down)
                StriLiOptions["TokenSecList"] = this:GetChecked();
                RaidMembersDB:OnTokenListOptionChanged();
                StriLi.MainFrame:OnTokenListOptionChanged();
                collectgarbage("collect");
            end);

    local fsTokenSecList  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsTokenSecList:SetPoint("TOPLEFT", 60, -55)
    fsTokenSecList:SetText(StriLi.Lang.Options.TokenSec);
end