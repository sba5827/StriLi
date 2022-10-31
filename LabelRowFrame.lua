--[[
Class: LabelRowFrame

variables:
	frame
	frameName
	parentFrame
	Children
		.Name
		.Reregister
		.Main
		.Sec
		.Token
		.Fail
	Regions
		.NameFS
		.ReregisterFS
		.MainFS
		.SecFS
		.TokenFS
		.FailFS
	posIndex
	x_offset
	y_offset
	height

methods:
	--can be called-- 
	new
	hide
	show
	toggle
	
	--for local use only--	
	setColumnContent
	

--]]

LabelRowFrame = { frame = nil, frameName = nil, parentFrame = nil, posIndex = nil, Children = {}, Regions = {}, x_offset = 35, y_offset = -35, height = 30 }

function LabelRowFrame:new(o, frameName, parentFrame, posIndex)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    self.frameName = frameName;
    self.parentFrame = parentFrame;
    self.posIndex = posIndex;

    self.frame = CreateFrame("Frame", self.frameName, self.parentFrame, "StriLi_Row_Template");
    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", self.x_offset, self.y_offset - self.posIndex * self.height);

    self:setColumnContent();

    return o;

end

function LabelRowFrame:setColumnContent()

    self.Children.Name, self.Children.Reregister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.Fail = self.frame:GetChildren();

    self.Regions.NameFS = self.Children.Name:CreateFontString("PlayerNameLable", "ARTWORK", "GameFontNormal");
    self.Regions.ReregisterFS = self.Children.Reregister:CreateFontString("ReregisterLable", "ARTWORK", "GameFontNormal");
    self.Regions.MainFS = self.Children.Main:CreateFontString("MainLable", "ARTWORK", "GameFontNormal");
    self.Regions.SecFS = self.Children.Sec:CreateFontString("SecLable", "ARTWORK", "GameFontNormal");
    self.Regions.TokenFS = self.Children.Token:CreateFontString("TokenLabel", "ARTWORK", "GameFontNormal");
    self.Regions.FailFS = self.Children.Fail:CreateFontString("FailLable", "ARTWORK", "GameFontNormal");

    self.Regions.NameFS:SetPoint("CENTER", 0, 0);
    self.Regions.ReregisterFS:SetPoint("CENTER", 0, 0);
    self.Regions.MainFS:SetPoint("CENTER", 0, 0);
    self.Regions.SecFS:SetPoint("CENTER", 0, 0);
    self.Regions.TokenFS:SetPoint("CENTER", 0, 0);
    self.Regions.FailFS:SetPoint("CENTER", 0, 0);

    self.Regions.NameFS:SetText("Name");
    self.Regions.ReregisterFS:SetText("U");
    self.Regions.MainFS:SetText("Main");
    self.Regions.SecFS:SetText("Sec");
    self.Regions.TokenFS:SetText("Token");
    self.Regions.FailFS:SetText("Fail");

end

function LabelRowFrame:show()
    ShowUIPanel(self.frame);
end

function LabelRowFrame:hide()
    HideUIPanel(self.frame);
end

function LabelRowFrame:toggle()

    if (self.frame:IsVisible()) then
        self:hide();
    else
        self:show();
    end

end	