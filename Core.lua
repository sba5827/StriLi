local StriLi_RowHight=30;
local StriLi_RowXBaseOffset=35;
local StriLi_RowYBaseOffset=-35;

local StriLi_RowCount = 0;
local StriLi_RowFrames = {};
local StriLi_ADDONLOADED = false;

local loadEventFrame = CreateFrame("FRAME");
loadEventFrame:RegisterEvent("ADDON_LOADED");
loadEventFrame:SetScript("OnEvent", StriLi_MainFrame_OnEvent);

function StriLi_MMButton_OnClick(self)

	if ( StriLi_MainFrame:IsVisible() ) then
		HideUIPanel(StriLi_MainFrame);
	else
		ShowUIPanel(StriLi_MainFrame);
	end
	
end

function StriLi_StartMoving(Frame)

	if ( not Frame.isMoving ) and ( Frame.isLocked ~= 1 ) then
        Frame:StartMoving();
        Frame.isMoving = true;
    end
	
end

function StriLi_StopMoving(Frame)

    if ( Frame.isMoving ) then
        Frame:StopMovingOrSizing();
        Frame.isMoving = false;
    end
	
end

function StriLi_SetTextColorByClass(FontString, Class)

	if( Class == nil ) 				then return end
	
	if( Class == "WARRIOR" ) 		then FontString:SetTextColor(0.78,	0.61,	0.43, 1) end
	if( Class == "PALADIN" ) 		then FontString:SetTextColor(0.96,	0.55,	0.73, 1) end
	if( Class == "HUNTER" ) 		then FontString:SetTextColor(0.67,	0.83,	0.45, 1) end
	if( Class == "ROGUE" ) 			then FontString:SetTextColor(1.00,	0.96,	0.41, 1) end
	if( Class == "PRIEST" ) 		then FontString:SetTextColor(1.00,	1.00,	1.00, 1) end
	if( Class == "DEATHKNIGHT" ) 	then FontString:SetTextColor(0.77,	0.12,	0.23, 1) end
	if( Class == "SHAMAN" ) 		then FontString:SetTextColor(0.00,	0.44,	0.87, 1) end
	if( Class == "MAGE" ) 			then FontString:SetTextColor(0.25,	0.78,	0.92, 1) end
	if( Class == "WARLOCK" ) 		then FontString:SetTextColor(0.53,	0.53,	0.93, 1) end
	if( Class == "DRUID" ) 			then FontString:SetTextColor(1.00,	0.49,	0.04, 1) end

end

function StriLi_AddRow(CharName, CharData)
	
	CharClass = CharData[1];
	
	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local PlayerName = Name:CreateFontString("PlayerName"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	PlayerName:SetPoint("LEFT", 0, 0);
	PlayerName:SetPoint("RIGHT", 0, 0);
	PlayerName:SetText(CharName);
	
	StriLi_SetTextColorByClass(PlayerName, CharClass);
	
	local counterMain = CreateFrame("Frame", "CounterMain"..tostring(StriLi_RowCount), Main, "StriLi_Counter_Template");
	local counterSec = CreateFrame("Frame", "CounterSec"..tostring(StriLi_RowCount), Sec, "StriLi_Counter_Template");
	local counterToken = CreateFrame("Frame", "CounterToken"..tostring(StriLi_RowCount), Token, "StriLi_Counter_Template");
	local counterFail = CreateFrame("Frame", "CounterFail"..tostring(StriLi_RowCount), Fail, "StriLi_Counter_Template");
	
	local counterMainFontString = counterMain:GetRegions();
	local counterSecFontString = counterSec:GetRegions();
	local counterTokenFontString = counterToken:GetRegions();
	local counterFailFontString = counterFail:GetRegions();
	
	counterMainFontString:SetText(tostring(CharData["Main"]))
	counterSecFontString:SetText(tostring(CharData["Sec"]))
	counterTokenFontString:SetText(tostring(CharData["Token"]))
	counterFailFontString:SetText(tostring(CharData["Fail"]))
	
	StriLi_RowCount = StriLi_RowCount + 1;

end

function StriLi_AddLabelRow()

	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local Name2 = Name:CreateFontString("PlayerNameLable","ARTWORK", "GameFontNormal");
	local Main2 = Main:CreateFontString("MainLable","ARTWORK", "GameFontNormal");
	local Sec2 = Sec:CreateFontString("SecLable","ARTWORK", "GameFontNormal");
	local Token2 = Token:CreateFontString("TokenLabel","ARTWORK", "GameFontNormal");
	local Fail2 = Fail:CreateFontString("FailLable","ARTWORK", "GameFontNormal");
	Name2:SetPoint("CENTER", 0, 0);
	Main2:SetPoint("CENTER", 0, 0);
	Sec2:SetPoint("CENTER", 0, 0);
	Token2:SetPoint("CENTER", 0, 0);
	Fail2:SetPoint("CENTER", 0, 0);
	Name2:SetText("Name");
	Main2:SetText("Main");
	Sec2:SetText("Sec");
	Token2:SetText("Token");
	Fail2:SetText("Fail");
		
	StriLi_RowCount = StriLi_RowCount + 1;
	
end

function StriLi_OnClickPlusButton(self)

	local parentFrameCounter = self:GetParent();
	local parentFrameCell = parentFrameCounter:GetParent();
	local parentFrameRow = parentFrameCell:GetParent();
	local Name, Main, Sec, Token, Fail = parentFrameRow:GetChildren();

	local NameRegion1, NameRegion2 = Name:GetRegions();
	local text = NameRegion2:GetText();
	
	local count = 0;
	
	if parentFrameCell == Main then
		StriLi_RaidMembers[text]["Main"] = StriLi_RaidMembers[text]["Main"] + 1;
		count = StriLi_RaidMembers[text]["Main"];
	elseif parentFrameCell == Sec then
		StriLi_RaidMembers[text]["Sec"] = StriLi_RaidMembers[text]["Sec"] + 1;
		count = StriLi_RaidMembers[text]["Sec"];
	elseif parentFrameCell == Token then
		StriLi_RaidMembers[text]["Token"] = StriLi_RaidMembers[text]["Token"] + 1;
		count = StriLi_RaidMembers[text]["Token"];
	elseif parentFrameCell == Fail then
		StriLi_RaidMembers[text]["Fail"] = StriLi_RaidMembers[text]["Fail"] + 1;
		count = StriLi_RaidMembers[text]["Fail"];
	end	
	
	local fontString = parentFrameCounter:GetRegions();
	
	fontString:SetText(tostring(count));
	
end

function StriLi_OnClickMinusButton(self)

	local parentFrameCounter = self:GetParent();
	local parentFrameCell = parentFrameCounter:GetParent();
	local parentFrameRow = parentFrameCell:GetParent();
	local Name, Main, Sec, Token, Fail = parentFrameRow:GetChildren();

	local NameRegion1, NameRegion2 = Name:GetRegions();
	local text = NameRegion2:GetText();
	
	local count = 0;
	
	if parentFrameCell == Main then
	
		if (StriLi_RaidMembers[text]["Main"] > 0) then 
			StriLi_RaidMembers[text]["Main"] = StriLi_RaidMembers[text]["Main"] - 1;
		end
		count = StriLi_RaidMembers[text]["Main"];
		
	elseif parentFrameCell == Sec then
	
		if (StriLi_RaidMembers[text]["Sec"] > 0) then 
			StriLi_RaidMembers[text]["Sec"] = StriLi_RaidMembers[text]["Sec"] - 1;
		end
		count = StriLi_RaidMembers[text]["Sec"];
	elseif parentFrameCell == Token then
	
		if (StriLi_RaidMembers[text]["Token"] > 0) then 
			StriLi_RaidMembers[text]["Token"] = StriLi_RaidMembers[text]["Token"] - 1;
		end
		count = StriLi_RaidMembers[text]["Token"];
	elseif parentFrameCell == Fail then
	
		if (StriLi_RaidMembers[text]["Fail"] > 0) then 
			StriLi_RaidMembers[text]["Fail"] = StriLi_RaidMembers[text]["Fail"] - 1;
		end
		
		count = StriLi_RaidMembers[text]["Fail"];
	end	
	
	local fontString = parentFrameCounter:GetRegions();
	
	fontString:SetText(tostring(count));
	
end

function StriLi_OnClickResetButton(self)
	StriLi_RaidMembers = {};
	for i = 0, StriLi_RowCount-1, 1 do
		StriLi_RowFrames[i]:Hide();
	end
	StriLi_RowFrames = {};
	StriLi_RowCount = 0;
	StriLi_AddLabelRow();
	StriLi_On_PARTY_MEMBERS_CHANGED();
	StriLi_RefreshUI();
end

function StriLi_MainFrame_OnEvent(self, event)

	if(event == "PARTY_MEMBERS_CHANGED") then
		StriLi_On_PARTY_MEMBERS_CHANGED(self);
	elseif ((event == "ADDON_LOADED") and (not StriLi_ADDONLOADED)) then
		print("|cffFFFF00StriLi loaded|r");
		StriLi_ADDONLOADED = true;
		StriLi_RefreshUI();
	end

end

function StriLi_On_PARTY_MEMBERS_CHANGED(self)

	numOfMembers = GetNumRaidMembers();	
	
	if(numOfMembers < 1) then return end
	
	for i = 1, numOfMembers, 1 do 
		local name = GetRaidRosterInfo(i);
		local localizedClass, englishClass, classIndex = UnitClass("raid"..tostring(i));
		StriLi_AddMember(name, englishClass);
	end
	
	StriLi_RefreshUI();
	
end

function StriLi_AddMember(CharName, CharClass)

	if (StriLi_RaidMembers[CharName] == nil) then
		StriLi_RaidMembers[CharName] = {CharClass, ["Main"]=0, ["Sec"]=0, ["Token"]=0, ["Fail"]=0};
	end
	
end

function StriLi_MainFrame_OnLoad(self)

	StriLi_AddLabelRow();
	
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:SetScript("OnEvent", StriLi_MainFrame_OnEvent);
	
end

function StriLi_RefreshUI()

	for name, data in pairs(StriLi_RaidMembers) do
	
		if not StriLi_DoesFrameForCharExist(name) then
			StriLi_AddRow(name, data);
		end

	end

end

function StriLi_DoesFrameForCharExist(CharName)
	
	if StriLi_RowCount < 1 then return end

	for i=0, StriLi_RowCount-1, 1 do
	
		local Name, Main, Sec, Token, Fail = StriLi_RowFrames[i]:GetChildren();
		local DUMP, Name2 = Name:GetRegions();
		
		local text = Name2:GetText();
		
		
		if (text == CharName) then
			return true;
		end
	end
	
	return false;

end

function StriLi_DEBUG()

	--DEBUG CODE
	StriLi_AddRow("WARRIOR", "WARRIOR");
	StriLi_AddRow("PALADIN", "PALADIN");
	StriLi_AddRow("HUNTER", "HUNTER");
	StriLi_AddRow("ROGUE", "ROGUE");
	StriLi_AddRow("PRIEST", "PRIEST");
	StriLi_AddRow("DEATHKNIGHT", "DEATHKNIGHT");
	StriLi_AddRow("SHAMAN", "SHAMAN");
	StriLi_AddRow("MAGE", "MAGE");
	StriLi_AddRow("WARLOCK", "WARLOCK");
	StriLi_AddRow("DRUID", "DRUID");

end