LabelRowFrame = { frame = nil, frameName = nil, parentFrame = nil, posIndex = nil, Children = {}, Regions = {}, x_offset = 35, y_offset = -35, height = 30 }

function LabelRowFrame:new(o, frameName, parentFrame, posIndex)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    self.frameName = frameName;
    self.parentFrame = parentFrame;
    self.posIndex = posIndex;

    local rowTemplateName = (StriLiOptions["TokenSecList"] and "StriLi_Row_Template_TokenSec" or "StriLi_Row_Template");
    self.frame = CreateFrame("Frame", self.frameName, self.parentFrame, rowTemplateName);
    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", self.x_offset, self.y_offset - self.posIndex * self.height);

    self:setColumnContent();

    return o;

end

function LabelRowFrame:setColumnContent()

    if StriLiOptions["TokenSecList"] then
        self.Children.Status, self.Children.Name, self.Children.ReRegister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.TokenSec, self.Children.Fail = self.frame:GetChildren();
    else
        self.Children.Status, self.Children.Name, self.Children.ReRegister, self.Children.Main, self.Children.Sec, self.Children.Token, self.Children.Fail = self.frame:GetChildren();
    end

    self.Regions.StatusFS = self.Children.Status:CreateFontString("PlayerStatusLable", "ARTWORK", "GameFontNormal");
    self.Regions.NameFS = self.Children.Name:CreateFontString("PlayerNameLable", "ARTWORK", "GameFontNormal");
    self.Regions.ReRegisterFS = self.Children.ReRegister:CreateFontString("ReRegisterLable", "ARTWORK", "GameFontNormal");
    self.Regions.MainFS = self.Children.Main:CreateFontString("MainLable", "ARTWORK", "GameFontNormal");
    self.Regions.SecFS = self.Children.Sec:CreateFontString("SecLable", "ARTWORK", "GameFontNormal");
    self.Regions.TokenFS = self.Children.Token:CreateFontString("TokenLabel", "ARTWORK", "GameFontNormal");
    if StriLiOptions["TokenSecList"] then
        self.Regions.TokenSecFS = self.Children.TokenSec:CreateFontString("TokenSecLabel", "ARTWORK", "GameFontNormal");
    end
    self.Regions.FailFS = self.Children.Fail:CreateFontString("FailLable", "ARTWORK", "GameFontNormal");

    self.Regions.StatusFS:SetPoint("CENTER", 0, 0);
    self.Regions.NameFS:SetPoint("CENTER", 0, 0);
    self.Regions.ReRegisterFS:SetPoint("CENTER", 0, 0);
    self.Regions.MainFS:SetPoint("CENTER", 0, 0);
    self.Regions.SecFS:SetPoint("CENTER", 0, 0);
    self.Regions.TokenFS:SetPoint("CENTER", 0, 0);
    if StriLiOptions["TokenSecList"] then
        self.Regions.TokenSecFS:SetPoint("CENTER", 0, 0);
    end
    self.Regions.FailFS:SetPoint("CENTER", 0, 0);

    self.Regions.StatusFS:SetText(StriLi.Lang.Labels.Status);
    self.Regions.NameFS:SetText(StriLi.Lang.Labels.Name);
    self.Regions.ReRegisterFS:SetText(StriLi.Lang.Labels.ReRegister);
    self.Regions.MainFS:SetText(StriLi.Lang.Labels.Main);
    self.Regions.SecFS:SetText(StriLi.Lang.Labels.Sec);
    self.Regions.TokenFS:SetText(StriLi.Lang.Labels.Token);
    if StriLiOptions["TokenSecList"] then
        self.Regions.TokenSecFS:SetText(StriLi.Lang.Labels.TokenSec);
    end
    self.Regions.FailFS:SetText(StriLi.Lang.Labels.Fail);

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