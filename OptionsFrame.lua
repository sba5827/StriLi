function StriLi_OptionFrame_init()
    local panel = CreateFrame("FRAME");
    panel.name = "StriLi";
    InterfaceOptions_AddCategory(panel);

    -- Create the scrolling parent frame and size it to fit inside the texture
    local optionFrame = CreateFrame("FRAME", nil, panel)
    optionFrame:SetPoint("TOPLEFT", 3, -4)
    optionFrame:SetPoint("BOTTOMRIGHT", -27, 4)

    -- Add widgets to the scrolling child frame as desired
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
    fsAutoPromoteToRaidAsi:SetText("Auto promote StriLi master to raid assist.");
end