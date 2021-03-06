local StriLi_RowHight=30;
local StriLi_RowXBaseOffset=35;
local StriLi_RowYBaseOffset=-35;

local StriLi_RowCount = 0;
local StriLi_RowFrames = {};
local StriLi_LableRow = nil;
local StriLi_RowStack = StriLi_newRowStack();
local StriLi_ADDONLOADED = false;

local StriLi_DropdownFrame = nil;

local StriLi_Timer = 0.0;
local StriLi_3 = true;
local StriLi_2 = true;
local StriLi_1 = true;

local StriLi_Main_i = 0;
local StriLi_Sec_i = 0;
local StriLi_Enchant_i = 0;

local StriLi_newRaidGroup = true;
local StriLi_ItemID = nil;

SLASH_STRILI1 = '/sl'

local function StriLi_Commands(msg, editbox)

  -- pattern matching that skips leading whitespace and whitespace between cmd and args
  -- any whitespace at end of args is retained

  local _, _, t, args = string.find(msg, "%s?(%w+)%s?(.*)")
  t=tonumber(t)
  
  if ( t == nil) then 
	print ("|cffFFFF00StriLiStrili: First argument must be a NUMBER|r");
	return;
  end
   
  if args == "[@mouseover]" then
	local itemName, itemLink = GameTooltip:GetItem();
	
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
	StriLi_ItemID = tonumber(Id);
	
	if itemLink == nil then return end
    SendChatMessage( itemLink,"RAID_WARNING");
	
  elseif args ~= "" then
	SendChatMessage(args ,"RAID_WARNING");
  end
  
  StriLi_StartListeningRolls(t);
  
end

SlashCmdList["STRILI"] = StriLi_Commands

CreateFrame("FRAME", "StriLi_MainFrame", UIParent, "StriLi_MainFrame_Template");

Strili_UPDATE_FRAME = CreateFrame("FRAME");

StriLi_ConfirmDialogFrame = CreateFrame("FRAME", "StriLi_ConfirmDialogFrame", StriLi_MainFrame, "StriLi_ConfirmDialogFrame_Template");
StriLi_TextInput_DialogFrame = CreateFrame("FRAME", "StriLi_TextInput_DialogFrame", StriLi_MainFrame, "StriLi_TextInputDialogFrame_Template");
StriLi_TextInput_DialogFrame_Frame_EditBox:SetMaxLetters(20);

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

function StriLi_StartListeningRolls(time_in_s)

	StriLi_Rolls = {["Main"]={}, ["Sec"]={}};
	StriLi_Rolls_Main = {};
	StriLi_Rolls_Sec = {};
	StriLi_Rolls_Enchant = {};
	
	local StriLi_Main_i = 0;
	local StriLi_Sec_i = 0;
	local StriLi_Enchant_i = 0;
	
	StriLi_Timer = time_in_s;

	StriLi_MainFrame:RegisterEvent("CHAT_MSG_SYSTEM");
	Strili_UPDATE_FRAME:SetScript("OnUpdate", function(self,arg1) StriLi_OnUpdate(self, arg1) end);
	
	StriLi_1=false;
	StriLi_2=false;
	StriLi_3=false;
	
end

function StriLi_StopListeningRolls()

	StriLi_MainFrame:UnregisterEvent("CHAT_MSG_SYSTEM");
	Strili_UPDATE_FRAME:SetScript("OnUpdate", nil);
	StriLi_SortRolls();
	
	for k,v in pairs(StriLi_Rolls) do 
		print("|cffFFFF00".."---"..k.."---|r");
		for k2,v2 in ipairs(v) do 
			print(v2["Name"].." | Striche: "..v2["Count"].." | Roll: "..v2["Roll"]);
		end
	end
	
end

function StriLi_OnUpdate(self, elapsed)

	if StriLi_Timer < 0.0 then
		SendChatMessage("---" ,"RAID_WARNING");
		StriLi_StopListeningRolls();
		return 
	elseif (not StriLi_1 and (StriLi_Timer < 1.0)) then
		StriLi_1 = true;
		SendChatMessage("1" ,"RAID_WARNING");
	elseif (not StriLi_2 and (StriLi_Timer < 2.0)) then
		StriLi_2 = true;
		SendChatMessage("2" ,"RAID_WARNING");
	elseif (not StriLi_3 and (StriLi_Timer < 3.0)) then
		StriLi_3 = true;
		SendChatMessage("3" ,"RAID_WARNING");
	end

	StriLi_Timer = StriLi_Timer - elapsed;

end

function StriLi_OnMasterChanged()
	
	if ((StriLi_Master == UnitName("player")) or (StriLi_Master == "")) then
		StriLi_ActivateButtons();
	else
		StriLi_DeactivateButtons();
	end
	
end

function StriLi_ActivateButtons()
	for i = 1, StriLi_RowCount-1, 1 do
	
		local Name, Reregister, Main, Sec, Token, Fail = StriLi_RowFrames[i].frame:GetChildren();
		
		local CB = Reregister:GetChildren();
		CB:Enable();
		
		local M_Button, P_Button = Main:GetChildren():GetChildren();
		M_Button:Enable(); P_Button:Enable();
		
		M_Button, P_Button = Sec:GetChildren():GetChildren();
		M_Button:Enable(); P_Button:Enable();
		
		M_Button, P_Button = Token:GetChildren():GetChildren();
		M_Button:Enable(); P_Button:Enable();
		
		M_Button, P_Button = Fail:GetChildren():GetChildren();
		M_Button:Enable(); P_Button:Enable();
		
	end
	
	StriLi_ResetButton:Enable();
	StriLi_LockRegButton:Enable();
	
end

function StriLi_DeactivateButtons()
	for i = 1, StriLi_RowCount-1, 1 do
	
		local Name, Reregister, Main, Sec, Token, Fail = StriLi_RowFrames[i].frame:GetChildren();
				
		local CB = Reregister:GetChildren();
		CB:Disable();
		
		local M_Button, P_Button = Main:GetChildren():GetChildren();
		M_Button:Disable(); P_Button:Disable();
		
		M_Button, P_Button = Sec:GetChildren():GetChildren();
		M_Button:Disable(); P_Button:Disable();
		
		M_Button, P_Button = Token:GetChildren():GetChildren();
		M_Button:Disable(); P_Button:Disable();
		
		M_Button, P_Button = Fail:GetChildren():GetChildren();
		M_Button:Disable(); P_Button:Disable();
		
	end
	
	StriLi_ResetButton:Disable();
	StriLi_LockRegButton:Disable();
	
end

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
	
	if (button ~= "RightButton") or (not MouseIsOver(self) or ((StriLi_Master ~= "") and (StriLi_Master ~= UnitName("player"))) ) then return end;
	
	StriLi_DropdownFrame = CreateFrame("Frame", "StriLi_DropdownFrame", self, "UIDropDownMenuTemplate")
	-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
	
	UIDropDownMenu_Initialize(StriLi_DropdownFrame, StriLi_InitDropDownMenu_PlayerNameFrame, "MENU")
	
	ToggleDropDownMenu(1, nil, StriLi_DropdownFrame, "cursor", 3, -3,nil,nil,0.2)
	
end

function StriLi_InitDropDownMenu_PlayerNameFrame(frame, level, menuList)

	local info = UIDropDownMenu_CreateInfo();

	if level == 1 then
	
		local pFrame = frame:GetParent();
		local _, fString = pFrame:GetRegions();
		local playerName = fString:GetText();
	
		-- Outermost menu level		
		info.text, info.hasArrow, info.menuList = "Zusammenlegen mit", true, "Players";
		UIDropDownMenu_AddButton(info);
		info.text, info.hasArrow, info.func, info.arg1 = "Ummeldung", false, StriLi_ReregisterRequest, playerName;
		UIDropDownMenu_AddButton(info);
		info.text, info.hasArrow, info.func, info.arg1 = "Zu Master ernennen", false, StriLi_SetMasterRequest, playerName;
		UIDropDownMenu_AddButton(info);
		
	elseif menuList == "Players" then
	
		local pFrame = frame:GetParent();
		local _, fString = pFrame:GetRegions();
		local playerName = fString:GetText();
		
		for k,v in pairs(StriLi_RaidMembers) do
			if (k ~= playerName) then
				info.text = k;
				info.colorCode = "|cff".. Strili_GetHexClassCollerCode(v[1])
				info.func = StriLi_CombineRaidmembersRequest;
				info.arg1 = playerName;
				info.arg2 = k;
				UIDropDownMenu_AddButton(info, level);
			end
		end 
	
	end
	
end

function StriLi_ReregisterRequest(self, arg1, arg2, checked)
	
	HideUIPanel(StriLi_DropdownFrame);
	
	local Name, Reregister, Main, Sec, Token, Fail = StriLi_GetFrameForChar(arg1):GetChildren();
	local ReregisterCB = Reregister:GetChildren();	
	
	if not checked then 
		StriLi_TextInput("Gib den Spec an auf den Umgemeldet wird: ", function(argList, text) StriLi_Reregister(argList, text); StriLi_SendDataChanged(argList[1], "Reregister", text); end, function() ReregisterCB:SetChecked(false) end, {arg1, arg2});
	else
		StriLi_RaidMembers[arg1]["Reregister"] = "";
		
		StriLi_SendDataChanged(arg1, "Reregister", "");
		
		Name:SetScript("OnEnter", 	nil);
		Name:SetScript("OnLeave", 	function() GameTooltip:Hide() end);
	end
	
end

function StriLi_SetMasterRequest(self, arg1, arg2, checked)
	
	HideUIPanel(StriLi_DropdownFrame);
	Strili_ConfirmSelection("Sind Sie sicher, dass Sie "..arg1.." zum Master ernennen wollen?", StriLi_SetMaster, nil, {arg1,arg2});
	
end

function StriLi_SetMaster(argList)

	local newMasterName = argList[1]; 
	
	local numOfMembers = GetNumRaidMembers();
	
	for i = 1, numOfMembers, 1 do 
		local name, rank = GetRaidRosterInfo(i);
		if (name == newMasterName) then
			if (rank > 0) then
				StriLi_Req_UserHasStriLi(newMasterName);
			else
				print("|cffFFFF00"..newMasterName.." Kann nicht zum Master ernannt werden. Rang zu niedrig|r");
			end
			break;
		end
	end
	
end

function StriLi_CombineRaidmembersRequest(self, arg1, arg2, checked)
		
	HideUIPanel(StriLi_DropdownFrame);
	Strili_ConfirmSelection("Sind Sie sicher, dass Sie "..arg1.." und "..arg2.." zusammenlegen wollen?", function(argList) StriLi_CombineRaidmembers(argList); StriLi_SendDataChanged(argList[1], argList[2], "Combine") end, nil, {arg1,arg2});
	
end

function StriLi_Reregister(argList, text)
	
	local PlayerName = argList[1];
	
	StriLi_RaidMembers[PlayerName]["Reregister"] = text;
	
	local Name, Reregister, Main, Sec, Token, Fail = StriLi_GetFrameForChar(PlayerName):GetChildren();
	local ReregisterCB = Reregister:GetChildren();
	
	if (text == "") then
		ReregisterCB:SetChecked(false);
		Name:SetScript("OnEnter", 	nil);
		Name:SetScript("OnLeave", 	function() GameTooltip:Hide() end);
	else
		ReregisterCB:SetChecked(true);
		Name:SetScript("OnEnter", 	function()
												GameTooltip_SetDefaultAnchor( GameTooltip, Name )
												GameTooltip:SetOwner(Name,"ANCHOR_NONE")
												GameTooltip:SetPoint("CENTER",Name,"CENTER",0,30)
												GameTooltip:SetText( text )
												GameTooltip:Show()
											end);
		Name:SetScript("OnLeave", 	function() GameTooltip:Hide() end );
	end
	
end

function StriLi_CombineRaidmembers(argList)

	local Main, Sec, Token, Fail = StriLi_RaidMembers[argList[2]]["Main"], StriLi_RaidMembers[argList[2]]["Sec"], StriLi_RaidMembers[argList[2]]["Token"], StriLi_RaidMembers[argList[2]]["Fail"];
	
	StriLi_RaidMembers[argList[1]]["Main"] = StriLi_RaidMembers[argList[1]]["Main"]+Main;
	StriLi_RaidMembers[argList[1]]["Sec"] = StriLi_RaidMembers[argList[1]]["Sec"]+Sec;
	StriLi_RaidMembers[argList[1]]["Token"] = StriLi_RaidMembers[argList[1]]["Token"]+Token;
	StriLi_RaidMembers[argList[1]]["Fail"] = StriLi_RaidMembers[argList[1]]["Fail"]+Fail;
	
	StriLi_RaidMembers[argList[2]] = nil;
	
	StriLi_ResetUI();

end

function Strili_ConfirmSelection(displayText, true_CBF, false_CBF, argList)

	StriLi_ConfirmDialogFrame_FontString:SetText(displayText);
	
	StriLi_ConfirmDialogFrame_ConfirmButton:SetScript("OnClick", function() StriLi_ConfirmDialogFrame:Hide(); if not (true_CBF == nil) then true_CBF(argList) end end);
	StriLi_ConfirmDialogFrame_CancleButton:SetScript("OnClick", function() StriLi_ConfirmDialogFrame:Hide(); if not (false_CBF == nil) then false_CBF(argList) end  end);
	
	StriLi_ConfirmDialogFrame:Show();

end

function StriLi_TextInput(displayText, true_CBF, false_CBF, argList)

	StriLi_TextInput_DialogFrame_FontString:SetText(displayText);
	StriLi_TextInput_DialogFrame_Frame_EditBox:SetText("");
	
	StriLi_TextInput_DialogFrame_ConfirmButton:SetScript("OnClick", function() StriLi_TextInput_DialogFrame:Hide(); if not (true_CBF == nil) then true_CBF(argList, StriLi_TextInput_DialogFrame_Frame_EditBox:GetText()) end end);
	StriLi_TextInput_DialogFrame_CancleButton:SetScript("OnClick", function() StriLi_TextInput_DialogFrame:Hide(); if not (false_CBF == nil) then false_CBF(argList, StriLi_TextInput_DialogFrame_Frame_EditBox:GetText()) end  end);
	
	StriLi_TextInput_DialogFrame:Show();

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
	
	StriLi_RowFrames[StriLi_RowCount] = StriLi_RowStack:pop();
	
	if (StriLi_RowFrames[StriLi_RowCount] == nil) then
	
		StriLi_RowFrames[StriLi_RowCount] = StriLi_newRow();
		StriLi_SetupNewRow(StriLi_RowFrames[StriLi_RowCount], CharName, CharData);
		
	else
		StriLi_ReworkRow(StriLi_RowFrames[StriLi_RowCount], CharName, CharData);
	end
	
	StriLi_RowFrames[StriLi_RowCount].frame:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
	StriLi_RowFrames[StriLi_RowCount].frame:Show();
	
	StriLi_RowCount = StriLi_RowCount + 1;

end

function StriLi_AddLabelRow()

	if StriLi_LableRow ~= nil then
		StriLi_RowFrames[StriLi_RowCount] = StriLi_LableRow;
	else
		
		StriLi_RowFrames[StriLi_RowCount] = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
		StriLi_RowFrames[StriLi_RowCount]:SetPoint("TOPLEFT", StriLi_MainFrame, "TOPLEFT", StriLi_RowXBaseOffset, StriLi_RowYBaseOffset - StriLi_RowCount*StriLi_RowHight);
		
		local Name, Reregister, Main, Sec, Token, Fail = StriLi_RowFrames[StriLi_RowCount]:GetChildren();
		Name:SetScript("OnMouseUp", nil);
		
		local Name2 = Name:CreateFontString("PlayerNameLable","ARTWORK", "GameFontNormal");
		local Reregister2 = Reregister:CreateFontString("ReregisterLable","ARTWORK", "GameFontNormal");
		local Main2 = Main:CreateFontString("MainLable","ARTWORK", "GameFontNormal");
		local Sec2 = Sec:CreateFontString("SecLable","ARTWORK", "GameFontNormal");
		local Token2 = Token:CreateFontString("TokenLabel","ARTWORK", "GameFontNormal");
		local Fail2 = Fail:CreateFontString("FailLable","ARTWORK", "GameFontNormal");
		
		
		Name2:SetPoint("CENTER", 0, 0);
		Reregister2:SetPoint("CENTER", 0, 0);
		Main2:SetPoint("CENTER", 0, 0);
		Sec2:SetPoint("CENTER", 0, 0);
		Token2:SetPoint("CENTER", 0, 0);
		Fail2:SetPoint("CENTER", 0, 0);
		
		Name2:SetText("Name");
		Reregister2:SetText("U");
		Main2:SetText("Main");
		Sec2:SetText("Sec");
		Token2:SetText("Token");
		Fail2:SetText("Fail");
		
		StriLi_LableRow = StriLi_RowFrames[StriLi_RowCount];

	end
	
	StriLi_RowCount = StriLi_RowCount + 1;
	
end

function StriLi_OnClickPlusButton(self)

	local parentFrameCounter = self:GetParent();
	local parentFrameCell = parentFrameCounter:GetParent();
	local parentFrameRow = parentFrameCell:GetParent();
	local Name, Reregisration, Main, Sec, Token, Fail  = parentFrameRow:GetChildren();

	local NameRegion1, NameRegion2 = Name:GetRegions();
	local text = NameRegion2:GetText();
	
	local count = 0;
	local even = true;
	
	if parentFrameCell == Main then
		StriLi_RaidMembers[text]["Main"] = StriLi_RaidMembers[text]["Main"] + 1;
		count = StriLi_RaidMembers[text]["Main"];
		StriLi_SendDataChanged(text, "Main", count);
		even=false;
	elseif parentFrameCell == Sec then
		StriLi_RaidMembers[text]["Sec"] = StriLi_RaidMembers[text]["Sec"] + 1;
		count = StriLi_RaidMembers[text]["Sec"];
		StriLi_SendDataChanged(text, "Sec", count);
	elseif parentFrameCell == Token then
		StriLi_RaidMembers[text]["Token"] = StriLi_RaidMembers[text]["Token"] + 1;
		count = StriLi_RaidMembers[text]["Token"];
		StriLi_SendDataChanged(text, "Token", count);
		even=false;
	elseif parentFrameCell == Fail then
		StriLi_RaidMembers[text]["Fail"] = StriLi_RaidMembers[text]["Fail"] + 1;
		count = StriLi_RaidMembers[text]["Fail"];
		StriLi_SendDataChanged(text, "Fail", count);
	end	
	
	local fontString = parentFrameCounter:GetRegions();
	
	fontString:SetText(tostring(count));
	StriLi_ColorCounterCell(parentFrameCell, count, even);
	
end

function StriLi_OnClickMinusButton(self)

	local parentFrameCounter = self:GetParent();
	local parentFrameCell = parentFrameCounter:GetParent();
	local parentFrameRow = parentFrameCell:GetParent();
	local Name, Reregisration, Main, Sec, Token, Fail  = parentFrameRow:GetChildren();

	local NameRegion1, NameRegion2 = Name:GetRegions();
	local text = NameRegion2:GetText();
	
	local count = 0;
	local even = true;
	
	if parentFrameCell == Main then
	
		if (StriLi_RaidMembers[text]["Main"] > 0) then 
			StriLi_RaidMembers[text]["Main"] = StriLi_RaidMembers[text]["Main"] - 1;
		end
		count = StriLi_RaidMembers[text]["Main"];
		even = false;
		StriLi_SendDataChanged(text, "Main", count);
		
	elseif parentFrameCell == Sec then
	
		if (StriLi_RaidMembers[text]["Sec"] > 0) then 
			StriLi_RaidMembers[text]["Sec"] = StriLi_RaidMembers[text]["Sec"] - 1;
		end
		count = StriLi_RaidMembers[text]["Sec"];
		StriLi_SendDataChanged(text, "Sec", count);
		
	elseif parentFrameCell == Token then
	
		if (StriLi_RaidMembers[text]["Token"] > 0) then 
			StriLi_RaidMembers[text]["Token"] = StriLi_RaidMembers[text]["Token"] - 1;
		end
		count = StriLi_RaidMembers[text]["Token"];
		even = false;
		StriLi_SendDataChanged(text, "Token", count);
		
	elseif parentFrameCell == Fail then
	
		if (StriLi_RaidMembers[text]["Fail"] > 0) then 
			StriLi_RaidMembers[text]["Fail"] = StriLi_RaidMembers[text]["Fail"] - 1;
		end
		count = StriLi_RaidMembers[text]["Fail"];
		StriLi_SendDataChanged(text, "Fail", count);
		
	end	
	
	local fontString = parentFrameCounter:GetRegions();
	
	fontString:SetText(tostring(count));
	StriLi_ColorCounterCell(parentFrameCell, count, even);
	
end

function StriLi_ColorCounterCell(cell, count, even)

	local R,G,B = 0,0,0;
	
	if (even) then
		if ( count >=4 ) then
			R, G, B = 204, 100, 100;
		elseif ( count == 3) then
			R, G, B = 204, 150, 100;
		elseif ( count == 2) then
			R, G, B = 204, 204, 0;
		elseif ( count == 1) then
			R, G, B = 180, 204, 180;
		elseif ( count == 0) then
			R, G, B = 204, 204, 204;
		end
	else
		if ( count >=4 ) then
			R, G, B = 255, 100, 100;
		elseif ( count == 3) then
			R, G, B = 255, 200, 160;
		elseif ( count == 2) then
			R, G, B = 255, 225, 0;
		elseif ( count == 1) then
			R, G, B = 220, 255, 220;
		elseif ( count == 0) then
			R, G, B = 255, 255, 255;
		end
	end
	
	cell:SetStatusBarColor(R/255,G/255,B/255,1);
	
end

function StriLi_OnClickResetButton(self)

	Strili_ConfirmSelection("Wirklich alle Daten zur??cksetzen?", function() StriLi_ConfirmReset(); StriLi_SendResetData() end, nil, self)
	
end

function StriLi_OnClickSyncButton(self)
	StriLi_Req_SyncData();
end

function StriLi_ConfirmReset(self)

	StriLi_newRaidGroup = false;

	StriLi_RaidMembers = {};
	StriLi_ResetUI();
	StriLi_On_PARTY_MEMBERS_CHANGED();

end

function StriLi_OnClickLockButton(self)

	for i = 1, StriLi_RowCount-1, 1 do
		local _, Reregister = StriLi_RowFrames[i].frame:GetChildren();
		local ReregisterCB = Reregister:GetChildren();
		ReregisterCB:Disable();
	end
	
	self:SetText("Unlock");
	self:SetScript("OnClick", function() StriLi_OnClickUnlockButton(self) end);

end

function StriLi_OnClickUnlockButton(self)

	for i = 1, StriLi_RowCount-1, 1 do
		local _, Reregister = StriLi_RowFrames[i].frame:GetChildren();
		Reregister = Reregister:GetChildren();
		Reregister:Enable();
	end
	
	self:SetText("Lock");
	self:SetScript("OnClick", function() StriLi_OnClickLockButton(self) end);

end

function StriLi_MainFrame_OnEvent(self, event, ...)

	if(event == "PARTY_MEMBERS_CHANGED") then
		StriLi_On_PARTY_MEMBERS_CHANGED(self);
	elseif ((event == "ADDON_LOADED") and (not StriLi_ADDONLOADED)) then
		print("|cffFFFF00StriLi loaded|r");
		StriLi_ADDONLOADED = true;
		StriLi_RefreshUI();
	elseif (event == "CHAT_MSG_SYSTEM") then
		local text = ...;
		StriLi_CHAT_MSG_SYSTEM(text);
	end
	

end

function StriLi_CHAT_MSG_SYSTEM(text)

	local playername, _next = string.match(text, "([^%s]+)%s?(.*)");
	local number, range = string.match(_next, "(%d+)%s?(.*)");
	number = tonumber(number);
	
	if range == "(1-100)" then
		StriLi_MainRoll2(playername, number);
	elseif range == "(1-99)" then 
		StriLi_SecRoll2(playername, number);
	end
	
	
end

function StriLi_MainRoll(playername, roll)
	if (StriLi_Rolls["Main"][playername] == nil) and (StriLi_Rolls["Sec"][playername] == nil) and (StriLi_Rolls["Enchant"][playername] == nil) then
		StriLi_Rolls["Main"][playername] = roll;
	end
end

function StriLi_SecRoll(playername, roll)
	if (StriLi_Rolls["Main"][playername] == nil) and (StriLi_Rolls["Sec"][playername] == nil) and (StriLi_Rolls["Enchant"][playername] == nil) then
		StriLi_Rolls["Sec"][playername] = roll;
	end
end

function StriLi_EnchantRoll(playername, roll)
	if (StriLi_Rolls["Main"][playername] == nil) and (StriLi_Rolls["Sec"][playername] == nil) and (StriLi_Rolls["Enchant"][playername] == nil) then
		StriLi_Rolls["Enchant"][playername] = roll;
	end
end

function StriLi_MainRoll2(playername, roll)
	
	if (StriLi_Rolls["Main"][playername] == nil) and (StriLi_Rolls["Sec"][playername] == nil) then
		if(StriLi_ItemIsNHToken()) then
				table.insert(StriLi_Rolls["Main"], {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Token"]});
				--StriLi_Rolls["Main"][StriLi_Sec_i] = {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Token"]};
		else
			table.insert(StriLi_Rolls["Main"], {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Main"]});
			--StriLi_Rolls["Main"][StriLi_Main_i] = {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Main"]};
		end
	end
	
end

function StriLi_SecRoll2(playername, roll)

	if (StriLi_Rolls["Main"][playername] == nil) and (StriLi_Rolls["Sec"][playername] == nil) then
		if(StriLi_ItemIsNHToken()) then
			table.insert(StriLi_Rolls["Sec"], {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Token"]});
			--StriLi_Rolls["Sec"][StriLi_Sec_i] = {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Token"]};
		else
			table.insert(StriLi_Rolls["Sec"], {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Sec"]});
			--StriLi_Rolls["Sec"][StriLi_Sec_i] = {["Roll"]=roll, ["Name"]=playername, ["Count"]=StriLi_RaidMembers[playername]["Sec"]};
		end
	end
	
end

function StriLi_SortCondition(a,b)
	
	if (a["Count"] == b["Count"]) then
		return (a["Roll"] >= b["Roll"]);
	else
		return (a["Count"] <= b["Count"]);
	end

end

function StriLi_SortRolls()

	table.sort(StriLi_Rolls["Main"], function(a,b) return StriLi_SortCondition(a,b) end);
	table.sort(StriLi_Rolls["Sec"], function(a,b) return StriLi_SortCondition(a,b) end);

end


function StriLi_On_PARTY_MEMBERS_CHANGED(self)

	local numOfMembers = GetNumRaidMembers();	
	
	if(numOfMembers < 1) then 
		StriLi_newRaidGroup = true;
		StriLi_Master = "";	
		StriLi_RefreshUI();
		return 
	end
	
	if(StriLi_newRaidGroup == true) then 
	
		StriLi_Master = "";	
		StriLi_Req_checkForMaster();
		
		StriLi_MainFrame:Show();
		
		StriLi_newRaidGroup = false;
	
	end
	
	for i = 1, numOfMembers, 1 do 
	
		local name = GetRaidRosterInfo(i);
		if(name == nil) then return end;
		local localizedClass, englishClass = UnitClass("raid"..tostring(i));
		StriLi_AddMember(name, englishClass);
		
	end
	
	if(not StriLi_MasterIsInRaid()) then
		StriLi_MasterExceptionHandling();
	end
	
	StriLi_RefreshUI();
	
end

function StriLi_MasterIsInRaid()

	if(StriLi_Master == "") then
		return false;
	end

	local numOfMembers = GetNumRaidMembers();
	
	for i = 1, numOfMembers, 1 do 
	
		local name = GetRaidRosterInfo(i);
		
		if(name == StriLi_Master) then
			return true;
		end
		
	end
	
	return false;
	
end

function StriLi_AddMember(CharName, CharClass)

	if (StriLi_RaidMembers[CharName] == nil) then
		StriLi_RaidMembers[CharName] = {CharClass, ["Main"]=0, ["Sec"]=0, ["Token"]=0, ["Fail"]=0, ["Reregister"]=""};
	end
	
end

function StriLi_MainFrame_OnLoad()

	StriLi_MainFrame:SetScript("OnEvent", StriLi_MainFrame_OnEvent);

	StriLi_AddLabelRow();	
	StriLi_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	StriLi_RefreshUI();
	
	Strili_UPDATE_FRAME_Communication:RegisterEvent("CHAT_MSG_ADDON");
	Strili_UPDATE_FRAME_Communication:SetScript("OnEvent", StriLi_Communication_OnEvent);
	
end

function StriLi_RefreshUI()

	for name, data in pairs(StriLi_RaidMembers) do
	
		if not StriLi_DoesFrameForCharExist(name) then
			StriLi_AddRow(name, data);
		end

	end

	StriLi_ResizeMainFrame();
	StriLi_OnMasterChanged();

end

function StriLi_ResetUI()
	
	StriLi_ClearRowFramesArray();
	StriLi_RowCount = 0;
	StriLi_AddLabelRow();
	StriLi_RefreshUI();

end

function StriLi_ClearRowFramesArray()

	for i=1, StriLi_RowCount-1, 1 do
	
		StriLi_RowFrames[i].frame:Hide();
		StriLi_RowStack:push(StriLi_RowFrames[i]);
		
	end

end

function StriLi_ResizeMainFrame()

	local SumRowFrameHeight = StriLi_RowCount * StriLi_RowHight;
	
	StriLi_MainFrame:SetHeight(SumRowFrameHeight - 2*StriLi_RowYBaseOffset);
	
end

function StriLi_DoesFrameForCharExist(CharName)
	
	if(StriLi_GetFrameForChar(CharName) == nil) then return false end;
	
	return true;

end

function StriLi_GetFrameForChar(CharName)
	
	if StriLi_RowCount < 1 then return nil end

	for i=1, StriLi_RowCount-1, 1 do
	
		local Name = StriLi_RowFrames[i].frame:GetChildren();
		local _, Name2 = Name:GetRegions();
		
		local text = Name2:GetText();
		
		
		if (text == CharName) then
			return StriLi_RowFrames[i].frame;
		end
	end
	
	return nil;

end

function StriLi_ItemIsNHToken()

	if ((StriLi_ItemID == 52027) or (StriLi_ItemID == 52026) or (StriLi_ItemID == 52025)) then
		return true;
	end
	
	return false;
	
end

function StriLi_DEBUG()

	StriLi_ResetUI();
	
end