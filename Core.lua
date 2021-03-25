local StriLi_RowHight=30;
local StriLi_RowXBaseOffset=35;
local StriLi_RowYBaseOffset=-35;

local StriLi_RowCount = 0;
local StriLi_RowFrames = {};
local StriLi_ADDONLOADED = false;

local StriLi_MemberToInspect_unitID = "";
local StriLi_MemberToInspect_raidNumber = 0;
local StriLi_Pendend_MembersToInspect = true;
local StriLi_WatingForSpeccInformation = false;

local StriLi_NotifyInspect_isValid = false;

StriLi_MainFrame = CreateFrame("FRAME", "StriLi_MainFrame", UIParent, "StriLi_MainFrame_Template");
StriLi_MainFrame:RegisterEvent("INSPECT_TALENT_READY");
StriLi_MainFrame:SetScript("OnEvent", StriLi_MainFrame_OnEvent);

---------------------------------------------------------------------------------------------------------------------------------------
local StriLi = LibStub("AceAddon-3.0"):NewAddon("StriLi", "AceConsole-3.0")
local StriLiLDB = LibStub("LibDataBroker-1.1"):NewDataObject("StriLi!", {
    type = "data source",
    text = "StriLi!",
    icon = "Interface\\AddOns\\StriLi\\StriLiIcon",
    OnClick = function()StriLi_MMButton_OnClick() end,
})
local icon = LibStub("LibDBIcon-1.0")
 
function StriLi:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("StriLiDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    });
    icon:Register("StriLi!", StriLiLDB, self.db.profile.minimap);
	StriLi_MainFrame_OnEvent(nil,"ADDON_LOADED");
	StriLi_MainFrame_OnLoad();
	
end

---------------------------------------------------------------------------------------------------------------------------------------


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
	CharSpecc = CharData["Specc"];
	
	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail, Specc = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local PlayerName = Name:CreateFontString("PlayerName"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	PlayerName:SetPoint("LEFT", 0, 0);
	PlayerName:SetPoint("RIGHT", 0, 0);
	PlayerName:SetText(CharName);
	
	local SpeccFontText = Specc:CreateFontString("SpeccFontText"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	SpeccFontText:SetPoint("LEFT", 0, 0);
	SpeccFontText:SetPoint("RIGHT", 0, 0);
	SpeccFontText:SetText(CharSpecc);
	
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
	
	local Name, Main, Sec, Token, Fail, Specc = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local Name2 = Name:CreateFontString("PlayerNameLable","ARTWORK", "GameFontNormal");
	local Main2 = Main:CreateFontString("MainLable","ARTWORK", "GameFontNormal");
	local Sec2 = Sec:CreateFontString("SecLable","ARTWORK", "GameFontNormal");
	local Token2 = Token:CreateFontString("TokenLabel","ARTWORK", "GameFontNormal");
	local Fail2 = Fail:CreateFontString("FailLable","ARTWORK", "GameFontNormal");
	local Specc2 = Specc:CreateFontString("SpeccLable","ARTWORK", "GameFontNormal");
	
	
	Name2:SetPoint("CENTER", 0, 0);
	Main2:SetPoint("CENTER", 0, 0);
	Sec2:SetPoint("CENTER", 0, 0);
	Token2:SetPoint("CENTER", 0, 0);
	Fail2:SetPoint("CENTER", 0, 0);
	Specc2:SetPoint("CENTER", 0, 0);
	
	Name2:SetText("Name");
	Main2:SetText("Main");
	Sec2:SetText("Sec");
	Token2:SetText("Token");
	Fail2:SetText("Fail");
	Specc2:SetText("Specc");
		
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
		hooksecurefunc("NotifyInspect", StriLi_NotifyInspect);
		StriLi_RefreshUI();
	elseif (event == "INSPECT_TALENT_READY") then
		--print("|cffFFFF00Inspecting|r");
		StriLi_InspectPlayer();
	end
	

end

function StriLi_On_PARTY_MEMBERS_CHANGED(self)

	local numOfMembers = GetNumRaidMembers();	
	
	if(numOfMembers < 1) then return end
	
	for i = 1, numOfMembers, 1 do 
		local name = GetRaidRosterInfo(i);
		local localizedClass, englishClass, classIndex = UnitClass("raid"..tostring(i));
		StriLi_AddMember(name, englishClass);
	end
	
	StriLi_GetPendingSpeccs();
	
	StriLi_RefreshUI();
	
end

function StriLi_AddMember(CharName, CharClass)

	if (StriLi_RaidMembers[CharName] == nil) then
		StriLi_RaidMembers[CharName] = {CharClass, ["Main"]=0, ["Sec"]=0, ["Token"]=0, ["Fail"]=0, ["Specc"]=''};
		StriLi_Pendend_MembersToInspect = true;
	end
	
end

function StriLi_MainFrame_OnLoad()

	StriLi_AddLabelRow();
	
	StriLi_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	StriLi_MainFrame:SetScript("OnEvent", StriLi_MainFrame_OnEvent);
	
	StriLi_RefreshUI();
	
end

function StriLi_RefreshUI()

	for name, data in pairs(StriLi_RaidMembers) do
	
		if not StriLi_DoesFrameForCharExist(name) then
			StriLi_AddRow(name, data);
		else	
			StriLi_UpdateSpecc(name, data["Specc"]);
		end

	end

	StriLi_ResizeMainFrame();

end

function StriLi_ResizeMainFrame()

	local SumRowFrameHeight = StriLi_RowCount * StriLi_RowHight;
	
	StriLi_MainFrame:SetHeight(SumRowFrameHeight - 2*StriLi_RowYBaseOffset);
	
end

function StriLi_DoesFrameForCharExist(CharName)
	
	if StriLi_RowCount < 1 then return false end

	for i=0, StriLi_RowCount-1, 1 do
	
		local Name = StriLi_RowFrames[i]:GetChildren();
		local DUMP, Name2 = Name:GetRegions();
		
		local text = Name2:GetText();
		
		
		if (text == CharName) then
			return true;
		end
	end
	
	return false;

end

function StriLi_UpdateSpecc(CharName, CharSpecc)

	if StriLi_RowCount < 1 then return end

	for i=0, StriLi_RowCount-1, 1 do
	
		local Name, _, _, _, _, Specc = StriLi_RowFrames[i]:GetChildren();
		local DUMP, Name2 = Name:GetRegions();
		
		local text = Name2:GetText();
		
		
		if (text == CharName) then
			local _, Specc2 = Specc:GetRegions();
			Specc2:SetText(CharSpecc);
		end
	end

end

function StriLi_GetActiveSpecc(PlayerName)

	if (StriLi_WatingForSpeccInformation) then return false end;
	
	local numOfMembers = GetNumRaidMembers();	
	local playerFound = false;
	
	local index = 0;
	
	for i = 1, numOfMembers, 1 do 
	
		local name = GetRaidRosterInfo(i);
		
		if (name == PlayerName) then 
			playerFound = true;
			index = i;
			break; 
		end;
		
	end
	
	if (not playerFound) then
		return false;
	end
	
	
	StriLi_MemberToInspect_raidNumber = index
	
	StriLi_MemberToInspect_unitID = "raid"..tostring(index);
	
	if( UnitIsConnected(StriLi_MemberToInspect_unitID) and UnitExists(StriLi_MemberToInspect_unitID) and UnitIsVisible(StriLi_MemberToInspect_unitID) and UnitIsFriend(StriLi_MemberToInspect_unitID, "player") and CanInspect(StriLi_MemberToInspect_unitID) and UnitName(StriLi_MemberToInspect_unitID) ~= UNKNOWN ) then
	
		StriLi_WatingForSpeccInformation = true;
		
		NotifyInspect(StriLi_MemberToInspect_unitID);
		return true;
		
	end
	
	return false;
	
end

function StriLi_InspectPlayer()

	if (not StriLi_NotifyInspect_isValid) then 
	
		if StriLi_Pendend_MembersToInspect then
			StriLi_GetPendingSpeccs();
		end
		
		return 
	
	end
	
	local activeTalentGroup = GetActiveTalentGroup(true)
	
	local name1, _, pointsSpent1 = GetTalentTabInfo(1, true, false, activeTalentGroup);	
	local name2, _, pointsSpent2 = GetTalentTabInfo(2, true, false, activeTalentGroup);
	local name3, _, pointsSpent3 = GetTalentTabInfo(3, true, false, activeTalentGroup);
	
	local sepcc;
	
	if (pointsSpent1 > pointsSpent2) and (pointsSpent1 > pointsSpent3) then
		sepcc = name1;
	elseif (pointsSpent2 > pointsSpent1) and (pointsSpent2 > pointsSpent3) then
		sepcc = name2;
	else
		sepcc = name3;
	end
	
	local name = GetRaidRosterInfo(StriLi_MemberToInspect_raidNumber);
	
	StriLi_RaidMembers[name]["Specc"] = sepcc;
	StriLi_RefreshUI();
		
	StriLi_WatingForSpeccInformation = false;
	
	if StriLi_Pendend_MembersToInspect then
		StriLi_GetPendingSpeccs();
	end
	
end

function StriLi_NotifyInspect(unitID)
	
	if (unitID ~= StriLi_MemberToInspect_unitID) then 
	
		StriLi_NotifyInspect_isValid = false;
		
	else
	
		StriLi_NotifyInspect_isValid = true;
		
	end

end

function StriLi_GetPendingSpeccs()

	local numRaidMem = GetNumRaidMembers();
	
	for j = 1, numRaidMem, 1 do
	
		local name = GetRaidRosterInfo(j);
		
		if (StriLi_RaidMembers[name] ~= nil) then
		
			if (StriLi_RaidMembers[name]["Specc"] == "") then 
				StriLi_GetActiveSpecc(name);
				return;
			end
			
		end
	end
	
	StriLi_Pendend_MembersToInspect = false;
	
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