local CSummonItemBox = class("CSummonItemBox", CBox)

function CSummonItemBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_LockIdx = nil
    self.m_Info = nil
    self.m_Id = nil
    self:InitContent()
end

function CSummonItemBox.InitContent(self)
    self.m_IconSpr = self:NewUI(1, CSprite)
    self.m_BindSpr = self:NewUI(2, CSprite)
    self.m_FightSpr = self:NewUI(3, CSprite)
    self.m_GradeL = self:NewUI(4, CLabel)
    self.m_InfoWidget = self:NewUI(5, CWidget)
    self.m_LockSpr = self:NewUI(6, CSprite)
    self.m_SelSpr = self:NewUI(7, CSprite)
    self.m_QualitySpr = self:NewUI(8, CSprite)
    self.m_RareSpr = self:NewUI(9, CSprite)

    self.m_SelSpr:SetActive(false)
    self.m_BindSpr:SetActive(false)
end

function CSummonItemBox.SetInfo(self, info)
    local bNotEmpty = info and true or false
    self.m_Info = info
    self.m_InfoWidget:SetActive(bNotEmpty)
    if bNotEmpty then
        self:RefreshSummonItem(info)
        self.m_Id = info.id
    end
    self:CheckRedPoint()
    self.m_LockIdx = nil
    self.m_LockSpr:SetActive(false)
end

function CSummonItemBox.SetLock(self, iLock)
    self.m_InfoWidget:SetActive(false)
    self.m_LockSpr:SetActive(true)
    self.m_LockIdx = iLock
    self.m_Info = nil
    self.m_Id = nil
end

function CSummonItemBox.GetLockIdx(self)
    return self.m_LockIdx
end

function CSummonItemBox.RefreshSummonItem(self, info)
    self.m_IconSpr:SetSpriteName(tostring(info.shape))
    self.m_FightSpr:SetActive(info.fight and true or false)
    self.m_GradeL:SetText(info.grade .. "级")
    self.m_RareSpr:SetActive(false)
end

function CSummonItemBox.SetFight(self, bFight)
    self.m_FightSpr:SetActive(bFight)
end

function CSummonItemBox.CheckRedPoint(self)
    if not self.m_Info then
        self.m_IconSpr:DelEffect("RedDot")
        return
    end
    local bShow = g_SummonCtrl:IsSummonHasRedPoint(self.m_Info.id)
    self:ShowRed(bShow)
end

function CSummonItemBox.ShowRed(self, bShow)
    if not self.m_Info then return end
    local bRed = self.m_IconSpr.m_Effects.RedDot and true or false
    if bShow and not bRed then
        self.m_IconSpr:AddEffect("RedDot", 20, Vector2(-15, -17))
    elseif not bShow then
        if bRed then
            self.m_IconSpr:DelEffect("RedDot")
        end
        g_SummonCtrl:DelRedPointEffectRecord(self.m_Info.traceno)
    end
end

return CSummonItemBox