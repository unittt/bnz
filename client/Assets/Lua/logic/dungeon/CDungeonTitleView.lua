local CDungeonTitleView = class("CDungeonTitleView", CViewBase)

function CDungeonTitleView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Dungeon/DungeonTitleView.prefab", cb)
    self.m_DepthType = "BeyondGuide"
    self.m_DelayTimer = nil
    self.m_Delay = 1.5
end

function CDungeonTitleView.OnCreateView(self)
    self.m_ContainWidget = self:NewUI(1, CWidget)
    self.m_OrderSpr = self:NewUI(2, CSprite)
    self.m_TextSpr = self:NewUI(3, CSprite)

    self.m_Tween = self.m_ContainWidget:GetComponent(classtype.TweenAlpha)
    self.m_Time = self.m_Tween.delay + self.m_Tween.duration
    self.m_ContainWidget:SetActive(false)
end

function CDungeonTitleView.SetInfo(self, idx, sName)
    local lOrderSpr = {
        "h7_yi",
        "h7_er",
        "h7_san",
        "h7_si",
        "h7_wu",
        "h7_liu",
        "h7_qi",
    }
    if idx > #lOrderSpr then
        self:CloseView()
    else
        self.m_OrderSpr:SetSpriteName(lOrderSpr[idx])
        local dDungeon = DataTools.GetDungeonData(1)
        if dDungeon then
            self.m_TextSpr:SetSpriteName(sName)--dDungeon.title_spr[idx])
            self:StartPlay()
        end
    end
end

function CDungeonTitleView.StartPlay(self)
    if self.m_DelayTimer then
        Utils.DelTimer(self.m_DelayTimer)
        self.m_DelayTimer = nil
    end
    self.m_DelayTimer = Utils.AddTimer(callback(self, "TimeCheck"), self.m_Time, self.m_Delay)
end

function CDungeonTitleView.TimeCheck(self)
    if not self.m_Playing then
        self.m_ContainWidget:SetActive(true)
        self.m_Tween:ResetToBeginning()
        self.m_Tween:PlayForward()
        self.m_Playing = true
        return true
    else
        self:CloseView()
        return false
    end
end

return CDungeonTitleView