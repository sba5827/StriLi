Strili_UPDATE_FRAME_Communication = CreateFrame("FRAME");
StriLi_TimeForCB_Communication = 0.0;

function StriLi_StopListeningIn_S(time_in_s)
	StriLi_TimeForCB_Communication = time_in_s;
	Strili_UPDATE_FRAME_Communication:SetScript("OnUpdate", function(self,arg1) StriLi_OnUpdate_Communication(self, arg1); end);
end

function StriLi_OnUpdate_Communication(self, elapsed)

	if(self.TimeSinceLastUpdate==nil) then
		self.TimeSinceLastUpdate = elapsed;
	else
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	end
	
	if (self.TimeSinceLastUpdate > StriLi_TimeForCB_Communication) then
		Strili_UPDATE_FRAME_Communication:SetScript("OnUpdate", nil);
		StriLi_Finalize_Resp_CheckForMaster();
	end
	
end

function StriLi_Req_checkForMaster()

	SendAddonMessage("SL_RQ_CFM", "", "RAID");
	StriLi_StopListeningIn_S(2.0);
	
end

function StriLi_SendDataChanged(name, data, arg)
	SendAddonMessage("SL_DC", UnitName("player").." "..name.." "..data.." "..arg, "RAID");
end

function StriLi_Resp_CheckForMaster()
	
	if (StriLi_Master ~= "") then
		SendAddonMessage("SL_RS_CFM", StriLi_Master, "RAID");
	end
	
end

function StriLi_SendResetData()
	SendAddonMessage("SL_RD", "", "RAID");
end

function StriLi_On_DataChanged(data)

	local SenderName, _next = string.match(data, "([^%s]+)%s?(.*)");
	local name, _next = string.match(_next, "([^%s]+)%s?(.*)");
	local data, arg = string.match(_next, "([^%s]+)%s?(.*)");

	
	if(SenderName == UnitName("player")) then return end

	if(data == "Reregister") then
		StiLi_ReregisterChanged(name, arg);
	elseif(arg == "Combine") then
		StriLi_CombinedChars(name, data);
	else
		StiLi_DataChanged(name, data, arg);
	end
	
end

function StiLi_ReregisterChanged(name, Specc)
	StriLi_Reregister({name}, Specc)
end

function StiLi_DataChanged(name, data, count)

	count = tonumber(count);

	local Frame = StriLi_GetFrameForChar(name);
	
	if(Frame == nil) then print("UnexpectedBehavior");return; end;
	
	local Name, Reregisration, Main, Sec, Token, Fail = Frame:GetChildren();

	local NameRegion1, NameRegion2 = Name:GetRegions();
	local text = NameRegion2:GetText();
	
	StriLi_RaidMembers[text][data] = count;
	
	local fontString = nil;
	
	if(data == "Main") then
		fontString = Main:GetChildren():GetRegions();
		StriLi_ColorCounterCell(Main, count, false);
	elseif(data == "Sec") then
		fontString = Sec:GetChildren():GetRegions();
		StriLi_ColorCounterCell(Sec, count, true);
	elseif(data == "Token") then
		fontString = Token:GetChildren():GetRegions();
		StriLi_ColorCounterCell(Token, count, false);
	elseif(data == "Fail") then
		fontString = Fail:GetChildren():GetRegions();
		StriLi_ColorCounterCell(Fail, count, true);
	end
	
	
	fontString:SetText(tostring(count));
	
end

function StriLi_CombinedChars(p1, p2)
	StriLi_CombineRaidmembers({p1,p2});
end

function StriLi_Communication_OnEvent(self, event, ...)
	
	if (event ~= "CHAT_MSG_ADDON")then return end
	
	if(arg1 == "SL_RQ_CFM") then
		StriLi_Resp_CheckForMaster();
	elseif (arg1 == "SL_RS_CFM") then
		StriLi_On_Resp_CheckForMaster(arg2);
	elseif (arg1 == "SL_DC") then
		StriLi_On_DataChanged(arg2);
	elseif (arg1 == "SL_RD") then
		StriLi_ConfirmReset();
	end
	
end

function StriLi_On_Resp_CheckForMaster(arg2)
	StriLi_Master = arg2;
	StriLi_OnMasterChanged();
end

function StriLi_Finalize_Resp_CheckForMaster()

	if (StriLi_Master == "") then
	
		local numOfMembers = GetNumRaidMembers();
		local pName = UnitName("player");
		
		for i = 1, numOfMembers, 1 do 
			local name, rank = GetRaidRosterInfo(i);
			if (name == pName) then
				if (rank > 0) then
					StriLi_Master = pName;
					StriLi_OnMasterChanged();
				end
				break;
			end
		end
		
	end
	print(StriLi_Master);
	StriLi_Resp_CheckForMaster();
end