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
            function(this, _, _)
                StriLiOptions["AutoPromote"] = this:GetChecked();
            end);

    local fsAutoPromoteToRaidAsi  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsAutoPromoteToRaidAsi:SetPoint("TOPLEFT", 60, -25)
    fsAutoPromoteToRaidAsi:SetText(StriLi.Lang.Options.AutoPromote);
    
    local checkBoxTokenSecList = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate")
    checkBoxTokenSecList:SetPoint("TOPLEFT", 30, -50);
    
    if StriLiOptions["TokenSecList"] then checkBoxTokenSecList:SetChecked(true) end
    checkBoxTokenSecList:SetScript("OnClick",
            function(this, _, _)
                StriLiOptions["TokenSecList"] = this:GetChecked();
                RaidMembersDB:OnTokenListOptionChanged();
                StriLi.MainFrame:OnTokenListOptionChanged();
                collectgarbage("collect");
            end);

    local fsTokenSecList  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsTokenSecList:SetPoint("TOPLEFT", 60, -55)
    fsTokenSecList:SetText(StriLi.Lang.Options.TokenSec);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local checkBoxWhisperTallyMarks = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate")
    checkBoxWhisperTallyMarks:SetPoint("TOPLEFT", 30, -80);

    if StriLiOptions["WhisperTallyMarks"] then checkBoxWhisperTallyMarks:SetChecked(true) end
    checkBoxWhisperTallyMarks:SetScript("OnClick",
            function(this, _, _)
                StriLiOptions["WhisperTallyMarks"] = this:GetChecked();
            end);

    local fsWhisperTallyMarks  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsWhisperTallyMarks:SetPoint("TOPLEFT", 60, -85)
    fsWhisperTallyMarks:SetText(StriLi.Lang.Options.WhisperTallyMarks);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local checkBoxCorruptedVersion = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate")
    checkBoxCorruptedVersion:SetPoint("TOPLEFT", 30, -160);

    if StriLiOptions["ShowCorruptedVersions"] then checkBoxCorruptedVersion:SetChecked(true) end
    checkBoxCorruptedVersion:SetScript("OnClick",
            function(this, _, _)
                StriLiOptions["ShowCorruptedVersions"] = this:GetChecked();
            end);

    local fsCorruptedVersion  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsCorruptedVersion:SetPoint("TOPLEFT", 60, -165)
    fsCorruptedVersion:SetText(StriLi.Lang.Options.ShowCorruptedVersions);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local fsIgnoreGroup  = optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal")
    fsIgnoreGroup:SetPoint("TOPLEFT", 30, -115)
    fsIgnoreGroup:SetText(StriLi.Lang.Options.IgnoreGroup..": ");

    local checkBoxIgnoreGroup_table = {};
    local fsIgnoreGroup_table = {};

    for i = 1, 8 do
        table.insert(checkBoxIgnoreGroup_table, CreateFrame("CheckButton", nil, optionFrame, "ChatConfigCheckButtonTemplate"));
        table.insert(fsIgnoreGroup_table, optionFrame:CreateFontString("ARTWORK", nil, "GameFontNormal"));
        checkBoxIgnoreGroup_table[i]:SetPoint("TOPLEFT", 120+i*20, -125);
        checkBoxIgnoreGroup_table[i]:SetHitRectInsets(0, 0, 0, 0);

        if StriLiOptions["IgnoreGroup"..i] then checkBoxIgnoreGroup_table[i]:SetChecked(true) end
        checkBoxIgnoreGroup_table[i]:SetScript("OnClick",
                function(this, _, _)
                    StriLiOptions["IgnoreGroup"..i] = this:GetChecked();
                end);

        fsIgnoreGroup_table[i]:SetPoint("TOPLEFT", 127+i*20, -115)
        --fsIgnoreGroup_table[i]:SetText(StriLi.Lang.Options.fsIgnoreGroup);
        fsIgnoreGroup_table[i]:SetText(i);
    end

end