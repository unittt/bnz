local CContDayBox = class("CContDayBox", CBox)

function CContDayBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_GetBtn = self:NewUI(1, CButton)
    self.m_GotSpr = self:NewUI(2, CSprite)
    self.m_SelSpr = self:NewUI(3, CSprite)
    self.m_IconSpr = self:NewUI(4, CSprite)
    self.m_TitleL = self:NewUI(5, CLabel)
    self:InitContent()
end

function CContDayBox.InitContent(self)
    self.m_SelCb = nil
    self.m_ClkBtnCb = nil
    self.m_Day = 0
    self.m_CurDay = 0
    self.m_Status = 0
    self.m_TextGrayCol = Color.RGBAToColor("5C6163FF")
    self.m_TextCol = Color.RGBAToColor("FFF9E3FF")
    self.m_GetBtn.m_IgnoreCheckEffect = true
    self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickGetBtn"))
    self.m_IconSpr:AddUIEvent("click", callback(self, "OnSelected"))
end

function CContDayBox.SetDay(self, iDay)
    self.m_Day = iDay
    self.m_TitleL:SetText(string.format("第%d天", iDay))
end

function CContDayBox.SetCurDay(self, iDay)
    self.m_CurDay = iDay
    self:RefreshBtn()
end

function CContDayBox.SetInfo(self, dInfo)
    self.m_Status = dInfo.status
    self.m_DisableText = dInfo.disableText or "未达成"
    self.m_DisableSpr = dInfo.disableSpr or "h7_an_2"
    self:RefreshBtn()
end

function CContDayBox.RefreshBtn(self)
    self.m_IconSpr:SetColor(Color.white)
    if self.m_Day > self.m_CurDay then
        self.m_GetBtn:SetText("未开启")
        self.m_GetBtn:SetSpriteName("h7_an_4")
        self.m_GetBtn:SetTextColor(self.m_TextGrayCol)
    else
        local iStatus = self.m_Status
        local bGot = iStatus == 3
        self.m_GetBtn.m_ChildLabel:SetActive(not bGot)
        self.m_GotSpr:SetActive(bGot)
        self.m_GetBtn:SetEnabled(iStatus ~= 4 and not bGot)
        if iStatus == 2 then
            self.m_GetBtn:AddEffect("RedDot", 22, Vector2(-15,-15))
            self.m_GetBtn:SetText("领 取")
            self.m_GetBtn:SetSpriteName("h7_an_2")
            self.m_GetBtn:SetTextColor(self.m_TextCol)
        else
            self.m_GetBtn:DelEffect("RedDot")
            if bGot then
                self.m_GetBtn:SetSpriteName("h7_an_5")
                self.m_IconSpr:SetColor(Color.RGBAToColor("BCBCBCFF"))
            elseif iStatus == 1 then
                self.m_GetBtn:SetText(self.m_DisableText)                
                self.m_GetBtn:SetSpriteName(self.m_DisableSpr)
                if self.m_DisableSpr == "h7_an_2" then
                    self.m_GetBtn:SetTextColor(self.m_TextCol)
                else
                    self.m_GetBtn:SetTextColor(self.m_TextGrayCol)
                end
            elseif iStatus == 4 then
                self.m_GetBtn:SetText("已过时")
                self.m_GetBtn:SetSpriteName("h7_an_5")
                self.m_GetBtn:SetTextColor(self.m_TextGrayCol)
                self.m_IconSpr:SetColor(Color.RGBAToColor("BCBCBCFF"))
            end
        end
    end
end

function CContDayBox.GetStatus(self, iStatus)
    return self.m_Status
end

function CContDayBox.SetSelState(self, bSel)
    self.m_SelSpr:SetActive(bSel)
end

function CContDayBox.SetSelCallback(self, cb)
    self.m_SelCb = cb
end

function CContDayBox.SetClkBtnCallback(self, cb)
    self.m_ClkBtnCb = cb
end

function CContDayBox.OnClickGetBtn(self)
    if self.m_ClkBtnCb then
        self.m_ClkBtnCb(self.m_Status, self.m_Day)
    end
    self:OnSelected()
end

function CContDayBox.OnSelected(self)
    if self.m_SelCb then
        self.m_SelCb(self.m_Day)
    end
    self:SetSelState(true)
end

return CContDayBox