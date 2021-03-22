local StriLi_RowHight=30;
local StriLi_RowXBaseOffset=35;
local StriLi_RowYBaseOffset=-35;

local StriLi_RowCount = 0;
local StriLi_RowFrames = {};

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

function StriLi_AddRow(CharName, CharClass)
	
	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local PlayerName = Name:CreateFontString("PlayerName"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	PlayerName:SetPoint("LEFT", 0, 0);
	PlayerName:SetPoint("RIGHT", 0, 0);
	PlayerName:SetText(CharName);
	
	StriLi_SetTextColorByClass(PlayerName, CharClass);
	
	CreateFrame("Frame", "CounterMain"..tostring(StriLi_RowCount), Main, "StriLi_Counter_Template");
	CreateFrame("Frame", "CounterSec"..tostring(StriLi_RowCount), Sec, "StriLi_Counter_Template");
	CreateFrame("Frame", "CounterToken"..tostring(StriLi_RowCount), Token, "StriLi_Counter_Template");
	CreateFrame("Frame", "CounterFail"..tostring(StriLi_RowCount), Fail, "StriLi_Counter_Template");
	
	StriLi_RowCount = StriLi_RowCount + 1;

end

function StriLi_AddLabelRow()

	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	Name = Name:CreateFontString("PlayerNameLable","ARTWORK", "GameFontNormal");
	Main = Main:CreateFontString("MainLable","ARTWORK", "GameFontNormal");
	Sec = Sec:CreateFontString("SecLable","ARTWORK", "GameFontNormal");
	Token = Token:CreateFontString("TokenLabel","ARTWORK", "GameFontNormal");
	Fail = Fail:CreateFontString("FailLable","ARTWORK", "GameFontNormal");
	Name:SetPoint("CENTER", 0, 0);
	Main:SetPoint("CENTER", 0, 0);
	Sec:SetPoint("CENTER", 0, 0);
	Token:SetPoint("CENTER", 0, 0);
	Fail:SetPoint("CENTER", 0, 0);
	Name:SetText("Name");
	Main:SetText("Main");
	Sec:SetText("Sec");
	Token:SetText("Token");
	Fail:SetText("Fail");
		
	StriLi_RowCount = StriLi_RowCount + 1;
	
end

function StriLi_OnClickPlusButton(self)

	local parent = self:GetParent();
	local fontString = parent:GetRegions();
	
	local oldText = fontString:GetText();
	local count = tonumber(oldText);
	
	count = count+1;
	
	fontString:SetText(tostring(count));
	
end

function StriLi_OnClickMinusButton(self)

	local parent = self:GetParent();
	local fontString = parent:GetRegions();
	
	local oldText = fontString:GetText();
	local count = tonumber(oldText);
	
	if (count>0) then
		count = count-1;
	end
	
	fontString:SetText(tostring(count));
	
end

function StriLi_MainFrame_OnLoad()
	
	local playerName = UnitName("player");
	local localizedClass, englishClass, classIndex = UnitClass("player");
	StriLi_AddLabelRow();
	StriLi_AddRow( playerName, englishClass);
	
	StriLi_DEBUG();
	
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