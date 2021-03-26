local StriLi_RowHight=30;
local StriLi_RowXBaseOffset=35;
local StriLi_RowYBaseOffset=-35;

local StriLi_RowCount = 0;
local StriLi_RowFrames = {};
local StriLi_ADDONLOADED = false;

local StriLi_MemberToInspect_unitID = "";
local StriLi_MemberToInspect_raidNumber = 0;
local StriLi_Pendend_MembersToInspect = true;
local StriLi_WatingForSpecInformation = false;

local StriLi_NotifyInspect_isValid = false;

StriLi_MainFrame = CreateFrame("FRAME", "StriLi_MainFrame", UIParent, "StriLi_MainFrame_Template");
StriLi_MainFrame:RegisterEvent("INSPECT_TALENT_READY");
StriLi_MainFrame:SetScript("OnEvent", StriLi_MainFrame_OnEvent);

---------------------------------------------------------Minimap Icon---------------------------------------------------------
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
	StriLi_MainFrame_OnLoad(); 
	StriLi_MainFrame_OnEvent(nil,"ADDON_LOADED");                                                                                                                                                                            

end                                                                                                                           

------------------------------------------------------------------------------------------------------------------------------


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

function StriLi_OnMouseUp_NameFrame(self, button)
	
	if (button ~= "RightButton") or (not MouseIsOver(self)) then return end;
	
	local dropDown = CreateFrame("Frame", "StriLi_ContextMenu", self, "UIDropDownMenuTemplate")
	-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
	
	UIDropDownMenu_Initialize(dropDown, StriLi_InitDropDownMenu_PlayerNameFrame, "MENU")
	
	ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3)
	
end

function StriLi_InitDropDownMenu_PlayerNameFrame(frame, level, menuList)

	local info = UIDropDownMenu_CreateInfo();

	if level == 1 then
	
		-- Outermost menu level		
		info.text, info.hasArrow, info.menuList = "Same as", true, "Players";
		UIDropDownMenu_AddButton(info);
		
	elseif menuList == "Players" then
	
		local pFrame = frame:GetParent();
		local _, fString = pFrame:GetRegions();
		local playerName = fString:GetText();
		
		for k,v in pairs(StriLi_RaidMembers) do
			if (k ~= playerName) then
				info.text = k;
				info.colorCode = "|cff".. Strili_GetHexClassCollerCode(v[1])
				info.func = StriLi_CombineRaidmembers;
				info.arg1 = playerName;
				info.arg2 = k;
				UIDropDownMenu_AddButton(info, level);
			end
		end 
	
	end
	
end

function StriLi_CombineRaidmembers(self, arg1, arg2, checked)
	
	print ("Combining "..arg1.." and "..arg2);
	
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

function Strili_GetHexClassCollerCode(Class) -- Returns RRGGBB

	if( Class == "WARRIOR" ) 		then return "C69B6D" end
	if( Class == "PALADIN" ) 		then return "F48CBA" end
	if( Class == "HUNTER" ) 		then return "AAD372" end
	if( Class == "ROGUE" ) 			then return "FFF468" end
	if( Class == "PRIEST" ) 		then return "FFFFFF" end
	if( Class == "DEATHKNIGHT" ) 	then return "C41E3A" end
	if( Class == "SHAMAN" ) 		then return "0070DD" end
	if( Class == "MAGE" ) 			then return "3FC7EB" end
	if( Class == "WARLOCK" ) 		then return "8788EE" end
	if( Class == "DRUID" ) 			then return "FF7C0A" end
	
end

function StriLi_AddRow(CharName, CharData)
	
	CharClass = CharData[1];
	CharSpec = CharData["Spec"];
	
	StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	
	local Name, Main, Sec, Token, Fail, Spec = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	
	local PlayerName = Name:CreateFontString("PlayerName"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	PlayerName:SetPoint("LEFT", 0, 0);
	PlayerName:SetPoint("RIGHT", 0, 0);
	PlayerName:SetText(CharName);
	
	local SpecFontText = Spec:CreateFontString("SpecFontText"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	SpecFontText:SetPoint("LEFT", 0, 0);
	SpecFontText:SetPoint("RIGHT", 0, 0);
	SpecFontText:SetText(CharSpec);
	
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
	
	local Name, Main, Sec, Token, Fail, Spec = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
	Name:SetScript("OnMouseUp", nil);
	
	local Name2 = Name:CreateFontString("PlayerNameLable","ARTWORK", "GameFontNormal");
	local Main2 = Main:CreateFontString("MainLable","ARTWORK", "GameFontNormal");
	local Sec2 = Sec:CreateFontString("SecLable","ARTWORK", "GameFontNormal");
	local Token2 = Token:CreateFontString("TokenLabel","ARTWORK", "GameFontNormal");
	local Fail2 = Fail:CreateFontString("FailLable","ARTWORK", "GameFontNormal");
	local Spec2 = Spec:CreateFontString("SpecLable","ARTWORK", "GameFontNormal");
	
	
	Name2:SetPoint("CENTER", 0, 0);
	Main2:SetPoint("CENTER", 0, 0);
	Sec2:SetPoint("CENTER", 0, 0);
	Token2:SetPoint("CENTER", 0, 0);
	Fail2:SetPoint("CENTER", 0, 0);
	Spec2:SetPoint("CENTER", 0, 0);
	
	Name2:SetText("Name");
	Main2:SetText("Main");
	Sec2:SetText("Sec");
	Token2:SetText("Token");
	Fail2:SetText("Fail");
	Spec2:SetText("Spec");
		
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
	
	StriLi_GetPendingSpecs();
	
	StriLi_RefreshUI();
	
end

function StriLi_AddMember(CharName, CharClass)

	if (StriLi_RaidMembers[CharName] == nil) then
		StriLi_RaidMembers[CharName] = {CharClass, ["Main"]=0, ["Sec"]=0, ["Token"]=0, ["Fail"]=0, ["Spec"]=''};
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
			StriLi_UpdateSpec(name, data["Spec"]);
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

function StriLi_UpdateSpec(CharName, CharSpec)

	if StriLi_RowCount < 1 then return end

	for i=0, StriLi_RowCount-1, 1 do
	
		local Name, _, _, _, _, Spec = StriLi_RowFrames[i]:GetChildren();
		local DUMP, Name2 = Name:GetRegions();
		
		local text = Name2:GetText();
		
		
		if (text == CharName) then
			local _, Spec2 = Spec:GetRegions();
			Spec2:SetText(CharSpec);
		end
	end

end

function StriLi_GetActiveSpec(PlayerName)

	if (StriLi_WatingForSpecInformation) then return false end;
	
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
	
		StriLi_WatingForSpecInformation = true;
		
		NotifyInspect(StriLi_MemberToInspect_unitID);
		return true;
		
	end
	
	return false;
	
end

function StriLi_InspectPlayer()

	if (not StriLi_NotifyInspect_isValid) then 
	
		if StriLi_Pendend_MembersToInspect then
			StriLi_GetPendingSpecs();
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
	
	StriLi_RaidMembers[name]["Spec"] = sepcc;
	StriLi_RefreshUI();
		
	StriLi_WatingForSpecInformation = false;
	
	if StriLi_Pendend_MembersToInspect then
		StriLi_GetPendingSpecs();
	end
	
end

function StriLi_NotifyInspect(unitID)
	
	if (unitID ~= StriLi_MemberToInspect_unitID) then 
	
		StriLi_NotifyInspect_isValid = false;
		
	else
	
		StriLi_NotifyInspect_isValid = true;
		
	end

end

function StriLi_GetPendingSpecs()

	local numRaidMem = GetNumRaidMembers();
	
	for j = 1, numRaidMem, 1 do
	
		local name = GetRaidRosterInfo(j);
		
		if (StriLi_RaidMembers[name] ~= nil) then
		
			if (StriLi_RaidMembers[name]["Spec"] == "") then 
				StriLi_GetActiveSpec(name);
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