local CHeroTrialBox = class("CHeroTrialBox", CBox)

function CHeroTrialBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Title = self:NewUI(1,CLabel)
    self.m_NoneWidget = self:NewUI(2, CWidget)
    self.m_CharWidget = self:NewUI(3, CWidget)
    self.m_ActorTex = self:NewUI(4, CActorTexture)
    self.m_SchSpr = self:NewUI(5, CSprite)
    self.m_StarGrid = self:NewUI(6, CGrid)
    self.m_Btn = self:NewUI(7, CButton)
    self.m_BtnL = self:NewUI(8, CLabel)
    self.m_LvL = self:NewUI(9, CLabel)
    self.m_NameL = self:NewUI(10, CLabel)
    self.m_ValL = self:NewUI(11, CLabel)
    self.m_ValNameL = self:NewUI(12, CLabel)
    self.m_TimeL = self:NewUI(13, CLabel)
    self.m_TitleSel = self:NewUI(14, CLabel)
    self.m_Bg = self:NewUI(15, CWidget)
    self.m_StarSpr = self:NewUI(16, CSprite)
    self.m_FightBtn = self:NewUI(17, CButton)
    self.m_FightBtnL = self:NewUI(18, CLabel)
    self.m_NoneTitleL = self:NewUI(19, CLabel)
    self.m_BgSelSpr = self:NewUI(20, CWidget)

    self:InitContent()
end

function CHeroTrialBox.InitContent(self)
    self.m_NoneWidget:SetActive(true)
    self.m_CharWidget:SetActive(false)
    self.m_Title:SetActive(false)
    self.m_TitleSel:SetActive(false)
    self.m_StarSpr:SetActive(false)
    self.m_BgSelSpr:SetActive(false)
    self.m_Btn:AddUIEvent("click", callback(self, "OnClickBtn"))
    self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFightBtn"))
end

function CHeroTrialBox.SetIdx(self, idx)
    local sWord
    if idx == 10 then
        sWord = "十"
    else
        sWord = string.number2text(idx)
    end
    local sTitle = string.format("第%s层守将", sWord)
    self.m_Title:SetText(sTitle)
    self.m_TitleSel:SetText(sTitle)
    self.m_NoneTitleL:SetText(sTitle)
    self.m_Idx = idx
    self.m_Title:SetActive(true)
end

function CHeroTrialBox.SetInfo(self, info)
    self.m_Info = info
    self:SetBtnState(info.status)
    self.m_ValNameL:SetText("评分:")
    self.m_ValL:SetText(info.score)
    local bHasTime = info.retTime and info.retTime > 0 or false
    if bHasTime then
        self.m_TimeL:SetText(string.format("剩余机会: %d/2", info.retTime))
    end
    self.m_TimeL:SetActive(bHasTime)
    local dBase = info.base_info
    if dBase then
        local dModel = table.copy(dBase.model_info)
        dModel.rendertexSize = 0.8
        dModel.horse = nil
        self.m_ActorTex:ChangeShape(dModel)
        local dSch = data.schooldata.DATA
        self.m_SchSpr:SetSpriteName(tostring(dSch[dBase.school].icon))
        self.m_LvL:SetText("LV:"..dBase.grade)
        self.m_NameL:SetText(dBase.name)
    end
    local dHeroTrial = DataTools.GetHuodongData("HeroTrial")
    if dHeroTrial then
        local iStar = dHeroTrial[self.m_Idx].star
        self:SetStars(iStar)
    end
    self.m_NoneWidget:SetActive(false)
    self.m_CharWidget:SetActive(true) 
end

function CHeroTrialBox.SetStars(self, iStar)
    for i=1, iStar do
        local oStar = self.m_StarGrid:GetChild(i)
        if not oStar then
            oStar = self.m_StarSpr:Clone()
            self.m_StarGrid:AddChild(oStar)
        end
        oStar:SetActive(true)
    end
end

function CHeroTrialBox.SetBtnState(self, iStatus)
    self.m_Status = iStatus
    local bFight = iStatus == 0
    self.m_Btn:SetActive(not bFight)
    self.m_FightBtn:SetActive(bFight)
    if iStatus == 1 then
        self.m_BtnL:SetText("领取奖励")
        self.m_BtnL:AddEffect("RedDot", 20, Vector2(-15, -15))
    elseif iStatus == 2 then
        self.m_BtnL:SetText("奖励已领")
        self.m_BtnL:DelEffect("RedDot")
    end
    self.m_Btn:SetBtnGrey(iStatus == 2)
    self.m_UseUp = false
    if bFight then
        local bHasTime = self.m_Info.retTime and self.m_Info.retTime > 0
        if bHasTime then
            return
        end
        self.m_UseUp = true
        local col = Color.RGBAToColor("ffffff82")
        local uiBtn = self.m_FightBtn.m_UIButton
        self.m_FightBtn:SetColor(col)
        self.m_FightBtn.m_ButtonScale.enabled = false
        local uiBtn = self.m_FightBtn.m_UIButton
        uiBtn.hover = col
        uiBtn.pressed = col
        uiBtn.defaultColor = col
    end
end

function CHeroTrialBox.SetClickState(self, bState)
    self.m_State = bState
    self.m_TitleSel:SetActive(bState)
    self.m_BgSelSpr:SetActive(bState)
end

function CHeroTrialBox.ShowEffect(self)
    -- printc("HeroTrialBox -------- ShowEffect")
end

function CHeroTrialBox.OnClickBtn(self)
    if self.m_Status == 1 then
        nethuodong.C2GSTrialGetReward(self.m_Idx)
    end
end

function CHeroTrialBox.OnClickFightBtn(self)
    if not self.m_Status then return end
    if self.m_UseUp then
        if self.m_Status ~= 2 then
            g_NotifyCtrl:FloatMsg("今日已无挑战机会，提升实力明日再来吧~")
        end
        return
    end
    if 0 == self.m_Status then
        nethuodong.C2GSTiralStartFight(self.m_Idx)
        CHeroTrialView:CloseView()
    end
end

return CHeroTrialBox