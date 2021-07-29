StriLi_Template_Counter = "StriLi_Counter_Template2"

function StriLi_newRow()
	
	local o = {};
	
	o.frame = CreateFrame("Frame", "StriLi_Row"..tostring(StriLi_RowCount), StriLi_MainFrame, "StriLi_Row_Template");
	o.next = nil;
	
	function o:setNext(n)
		o.next = n;
	end
	
	return o;
	
end

function StriLi_newRowStack()
	
	local o = {};
	
	o.stack = nil
	
	function o:pop()
		
		if (o.stack == nil) then
			return nil;
		end
		
		local ret_val = o.stack;
		o.stack = o.stack.next;
		ret_val:setNext(nil);
		
		return ret_val;
		
	end
	
	function o:push(p)
	
		local n = o.stack;
		
		o.stack = p;
		o.stack:setNext(n);
		
	end
	
	return o;

end

function StriLi_SetupNewRow(Row, CharName, CharData)

	CharClass = CharData[1];

	local Name, Reregister, Main, Sec, Token, Fail = Row.frame:GetChildren();
	
	--Seting Playername
	local PlayerName = Name:CreateFontString("PlayerName"..tostring(StriLi_RowCount),"ARTWORK", "GameFontNormal");
	PlayerName:SetPoint("LEFT", 0, 0);
	PlayerName:SetPoint("RIGHT", 0, 0);
	PlayerName:SetText(CharName);
	
	StriLi_SetTextColorByClass(PlayerName, CharClass);
	
	-- Creating Checkbox. Toolotip added if Reregistered
	local ReregisterCB = CreateFrame("CheckButton", "ReRegisterCheckButton"..tostring(StriLi_RowCount), Reregister, "ChatConfigCheckButtonTemplate");
	ReregisterCB:SetPoint("CENTER", 0, 0);
	ReregisterCB:SetHitRectInsets(0, 0, 0, 0);
	if(CharData["Reregister"] ~= "") then 
		ReregisterCB:SetChecked(true);
		Name:SetScript("OnEnter", 	function()
												GameTooltip_SetDefaultAnchor( GameTooltip, Name )
												GameTooltip:SetOwner(Name,"ANCHOR_NONE")
												GameTooltip:SetPoint("CENTER",Name,"CENTER",0,30)
												GameTooltip:SetText( CharData["Reregister"] )
												GameTooltip:Show()
											end);
		Name:SetScript("OnLeave", 	function() GameTooltip:Hide() end );
	end
	ReregisterCB:SetScript("OnClick", function(self) if(self:IsEnabled()) then StriLi_ReregisterRequest(self, CharName, nil, not self:GetChecked()) end end)
	
	local counterMain = CreateFrame("Frame", "CounterMain"..tostring(StriLi_RowCount), Main, StriLi_Template_Counter);
	local counterSec = CreateFrame("Frame", "CounterSec"..tostring(StriLi_RowCount), Sec, StriLi_Template_Counter);
	local counterToken = CreateFrame("Frame", "CounterToken"..tostring(StriLi_RowCount), Token, StriLi_Template_Counter);
	local counterFail = CreateFrame("Frame", "CounterFail"..tostring(StriLi_RowCount), Fail, StriLi_Template_Counter);
	
	local counterMainFontString = counterMain:GetRegions();
	local counterSecFontString = counterSec:GetRegions();
	local counterTokenFontString = counterToken:GetRegions();
	local counterFailFontString = counterFail:GetRegions();
	
	counterMainFontString:SetText(tostring(CharData["Main"]))
	StriLi_ColorCounterCell(Main, CharData["Main"], false);
	
	counterSecFontString:SetText(tostring(CharData["Sec"]))
	StriLi_ColorCounterCell(Sec, CharData["Sec"], true);
	
	counterTokenFontString:SetText(tostring(CharData["Token"]))
	StriLi_ColorCounterCell(Token, CharData["Token"], false);
	
	counterFailFontString:SetText(tostring(CharData["Fail"]))
	StriLi_ColorCounterCell(Fail, CharData["Fail"], true);
	
end

function StriLi_ReworkRow(Row, CharName, CharData)

	CharClass = CharData[1];

	local Name, Reregister, Main, Sec, Token, Fail = Row.frame:GetChildren();
	
	--Seting Playername
	local _, PlayerName = Name:GetRegions();
	PlayerName:SetText(CharName);
	
	StriLi_SetTextColorByClass(PlayerName, CharClass);
	
	-- Creating Checkbox. Toolotip added if Reregistered
	local ReregisterCB = Reregister:GetChildren();
	if(CharData["Reregister"] ~= "") then 
		ReregisterCB:SetChecked(true);
		Name:SetScript("OnEnter", 	function()
												GameTooltip_SetDefaultAnchor( GameTooltip, Name )
												GameTooltip:SetOwner(Name,"ANCHOR_NONE")
												GameTooltip:SetPoint("CENTER",Name,"CENTER",0,30)
												GameTooltip:SetText( CharData["Reregister"] )
												GameTooltip:Show()
											end);
		Name:SetScript("OnLeave", 	function() GameTooltip:Hide() end );
	end
	ReregisterCB:SetScript("OnClick", function(self) if(self:IsEnabled()) then StriLi_ReregisterRequest(self, CharName, nil, not self:GetChecked()) end end)
	
	local counterMain = Main:GetChildren();
	local counterSec = Sec:GetChildren();
	local counterToken = Token:GetChildren();
	local counterFail = Fail:GetChildren();
	
	local counterMainFontString = counterMain:GetRegions();
	local counterSecFontString = counterSec:GetRegions();
	local counterTokenFontString = counterToken:GetRegions();
	local counterFailFontString = counterFail:GetRegions();
	
	counterMainFontString:SetText(tostring(CharData["Main"]))
	StriLi_ColorCounterCell(Main, CharData["Main"], false);
	
	counterSecFontString:SetText(tostring(CharData["Sec"]))
	StriLi_ColorCounterCell(Sec, CharData["Sec"], true);
	
	counterTokenFontString:SetText(tostring(CharData["Token"]))
	StriLi_ColorCounterCell(Token, CharData["Token"], false);
	
	counterFailFontString:SetText(tostring(CharData["Fail"]))
	StriLi_ColorCounterCell(Fail, CharData["Fail"], true);
	
end