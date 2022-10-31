--[[
Obj: StriLi.MainFrame

variables:
	frame
	children
	    .syncButton
	    .resetButton
	    .lockButton
	labelRow
	rows
	unusedRowFrameStack
	rowCount

methods:
	--can be called-- 
	init
	show
	hide
	toggle
	addPlayer
	removePlayer
	combineMembers
	OnClickLockButton
	OnClickSyncButton
	OnClickResetButton
	resetData
	OnMasterChanged
	
	--for local use only--
	setupLabelRow
	resize
	reIndexFrames

--]]

--[[
	Dependencies:
		- RowFrame
		- LabelRowFrame
		- InfiniteStack
		
--]]

StriLi = LibStub("AceAddon-3.0"):NewAddon("StriLi", "AceConsole-3.0");
StriLi.MainFrame = { frame = nil, labelRow = nil, rows = {}, children = {}, unusedRowFrameStack = nil, rowCount = 0 }

function StriLi.MainFrame:init()

    if self.frame == nil then
        self.frame = CreateFrame("FRAME", "StriLi_MainFrame", UIParent, "StriLi_MainFrame_Template");
    end
    if self.labelRow == nil then
        self:setupLabelRow();
    end
    if self.unusedRowFrameStack == nil then
        self.unusedRowFrameStack = InfiniteStack:new(nil, RowFrame);    -- InfiniteStack creates a new object based on the class passed to it as the second parameter, if no elements are left in the stack.
    end

    self.children.resetButton, self.children.syncButton, self.children.lockButton = self.frame:GetChildren();

    self.children.resetButton:SetScript("OnClick", function()
        self:OnClickResetButton()
    end);
    self.children.syncButton:SetScript("OnClick", function()
        self:OnClickSyncButton()
    end);
    self.children.lockButton:SetScript("OnClick", function()
        self:OnClickLockButton()
    end);

    self.frame:SetScript("OnMouseDown", function(frame)
        if (not frame.isMoving) and (frame.isLocked ~= 1) then
            frame:StartMoving();
            frame.isMoving = true;
        end
    end);
    self.frame:SetScript("OnMouseUp", function(frame)
        if (frame.isMoving) then
            frame:StopMovingOrSizing();
            frame.isMoving = false;
        end
    end);

    for charName, charData in pairs(RaidMembersDB.raidMembers) do
        self:addPlayer({ charName, charData });
    end

   self:OnMasterChanged();

end

function StriLi.MainFrame:show()
    ShowUIPanel(self.frame);
end

function StriLi.MainFrame:hide()
    HideUIPanel(self.frame);
end

function StriLi.MainFrame:toggle()

    if (self.frame:IsVisible()) then
        self:hide();
    else
        self:show();
    end

end

function StriLi.MainFrame:setupLabelRow()

    if self.labelRow == nil then
        self.labelRow = LabelRowFrame:new(nil, "LabelRow", self.frame, 0);
        self.labelRow:show();

        self:resize();
    end

end

function StriLi.MainFrame:addPlayer(raidMember)

    self.rows[raidMember[1]] = self.unusedRowFrameStack:pop(nil, "StriLi_RowFrame" .. tostring(self.rowCount), self.frame, self.rowCount + 1, raidMember);
    self.rows[raidMember[1]]:show();
    self.rows[raidMember[1]]:setCombineFunction(function(memName1, memName2) self:combineMembers(memName1, memName2) end);

    self.rowCount = self.rowCount + 1;

    self:resize();

end

function StriLi.MainFrame:removePlayer(raidMemberName)

    if self.rows[raidMemberName] ~= nil then

        RaidMembersDB:remove(raidMemberName);

        self.unusedRowFrameStack:push(self.rows[raidMemberName])
        self.rows[raidMemberName]:hide();
        self.rows[raidMemberName]:unlinkCounters();
        self.rows[raidMemberName] = nil;
        self.rowCount = self.rowCount - 1;

        self:reIndexFrames();

        self:resize();

        return true;

    end

    return false;

end

function StriLi.MainFrame:resize()

    local SumRowFrameHeight = (self.rowCount + 1) * RowFrame:getHeight();
    self.frame:SetHeight(SumRowFrameHeight - 2 * RowFrame:getY_offset());

end

function StriLi.MainFrame:reIndexFrames()

    local i = 1;

    for _, frame in pairs(self.rows) do

        frame:setPosIndex(i)
        i = i + 1;

    end

end

function StriLi.MainFrame:combineMembers(memName1, memName2)

    if self.rows[memName1] == nil or self.rows[memName2] == nil or memName1 == memName2 then
        return false;
    end

    if RaidMembersDB:combineMembers(memName1, memName2) then
        self:removePlayer(memName2);
    end

    return true;

end

function StriLi.MainFrame:OnClickSyncButton()
    StriLi.CommunicationHandler:sendSycRequest();
end

function StriLi.MainFrame:OnClickResetButton()

    local confirmFrame = ConfirmDialogFrame:new(nil, "Bist du sicher, das du alle Daten zurücksetzen willst?",
            function()
                StriLi.CommunicationHandler:sendResetData();
                self:resetData();
            end,
            nil);

    confirmFrame:show();

end

function StriLi.MainFrame:OnClickLockButton()

    local enabled = 1;

    for _, rowFrame in pairs(self.rows) do

        enabled = rowFrame:toggleReregisterLock();

    end

    if enabled == 1 then
        self.children.lockButton:SetText("Lock");
    else
        self.children.lockButton:SetText("Unlock");
    end

end

function StriLi.MainFrame:resetData()
    for player, _ in pairs(self.rows) do
        self:removePlayer(player);
    end
    StriLi.EventHandler:addNewPlayers();
end

function StriLi.MainFrame:OnMasterChanged()

    if StriLi.master ~= UnitName("player") and StriLi.master ~= "" then

        for _, rowFrame in pairs(self.rows) do
            rowFrame:disableButtons();
        end

        self.children.resetButton:Disable();
        self.children.lockButton:Disable();

    else

        for _, rowFrame in pairs(self.rows) do
            rowFrame:enableButtons();
        end

        self.children.resetButton:Enable();
        self.children.lockButton:Enable();

    end

end