local CSummonCompoundItemBox = class("CSummonCompoundItemBox", CBox)

function CSummonCompoundItemBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_IsFight = false
    self:InitContent()
end

function CSummonCompoundItemBox.InitContent(self)
    self.m_QualitySpr = self:NewUI(1, CSprite)
    self.m_NameL = self:NewUI(2, CLabel)
    self.m_RankL = self:NewUI(4, CLabel)
    self.m_ScoreL = self:NewUI(5, CLabel)
    self.m_TypeSpr = self:NewUI(6, CSprite)
    self.m_BindSpr = self:NewUI(7, CSprite)
    self.m_IconSpr = self:NewUI(8, CSprite)
    self.m_GradeL = self:NewUI(9, CLabel)
    self.m_EmptyWidget = self:NewUI(10, CWidget)
    self.m_InfoWidget = self:NewUI(11, CWidget)
    self.m_SkCntL = self:NewUI(12, CLabel)
    self.m_LockSpr = self:NewUI(13, CSprite)
    self.m_FightSpr = self:NewUI(14, CSprite)
    self.m_LockL = self:NewUI(15, CLabel)

    self.m_LockL:SetActive(false)
    self.m_LockSpr:AddUIEvent("press", callback(self, "OnPressLock"))
    self.m_LockSpr:SetLongPressTime(0.3)
end

function CSummonCompoundItemBox.SetInfo(self, info)
    self.m_Info = info
    local bHasInfo = info and true or false
    if bHasInfo then
        self.m_IsFight = info.id == g_SummonCtrl.m_FightId
        local dScore = SummonDataTool.GetScoreInfoByRank(info.rank)
        local dType = SummonDataTool.GetTypeInfo(info.type)
        local iSkCnt = #info.talent + #info.skill
        self.m_IconSpr:SetSpriteName(info.model_info.shape)
        self.m_NameL:SetText(info.name)
        self.m_RankL:SetText(dScore.label)
        self.m_ScoreL:SetText(info.summon_score)
        if info.type == 8 or info.type == 7 then
            self.m_TypeSpr:SetSize(32, 104)
        else
            self.m_TypeSpr:SetSize(36, 82)
        end
        self.m_TypeSpr:SetSpriteName(dType.icon)
        self.m_SkCntL:SetText(iSkCnt.."个技能")
        self.m_GradeL:SetText(info.grade.."级")
        self.m_LockSpr:SetActive(1==info.key)
        self.m_FightSpr:SetActive(self.m_IsFight)
    end
    self.m_EmptyWidget:SetActive(not bHasInfo)
    self.m_InfoWidget:SetActive(bHasInfo)
end

function CSummonCompoundItemBox.OnPressLock(self, oBtn, bPress)
    self.m_LockL:SetActive(bPress)
end

return CSummonCompoundItemBox