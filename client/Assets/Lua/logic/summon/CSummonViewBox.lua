local CSummonViewBox = class("CSummonViewBox", CBox)

function CSummonViewBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self:InitContent()
end

function CSummonViewBox.InitContent(self)
    self.m_SummonName = self:NewUI(1, CLabel)
    self.m_SummonGrade = self:NewUI(2, CLabel)
    self.m_SummonTypeBtn = self:NewUI(3, CSprite)
    self.m_SummonModelTexture = self:NewUI(4, CActorTexture)
    self.m_SummonIsCombat = self:NewUI(5, CSprite, false)
    self.m_SummonScore = self:NewUI(6, CLabel)
    self.m_SummonSumScore = self:NewUI(7, CLabel)
    self.m_SummonTypeBtn2 = self:NewUI(8, CSprite)
    self.m_LockSpr = self:NewUI(9, CSprite)
    self.m_LockL = self:NewUI(10, CLabel)
    self.m_LockL:SetActive(false)
    self.m_LockSpr:AddUIEvent("press", callback(self, "OnPressLock"))
    self.m_LockSpr:SetLongPressTime(0.3)
end

function CSummonViewBox.SetInfo(self, info)
    if not info then return end
    local iSummonId = info.id
    self.m_SummonId  = iSummonId
    local iSummonType = info.type
    local modelInfo = table.copy(info.model_info)
    modelInfo.rendertexSize = 1.2--modelInfo.rendertexSize or 0.8
    modelInfo.pos = Vector3(0, -0.85, 3)
    local bFight = iSummonId == g_SummonCtrl.m_FightId
    local dType = SummonDataTool.GetTypeInfo(iSummonType)
    local dRace = SummonDataTool.GetRaceInfo(info.race)
    local dScore = SummonDataTool.GetScoreInfoByRank(info.rank)

    self.m_SummonModelTexture:ChangeShape(modelInfo)
    self.m_SummonName:SetText(info.name)
    self.m_SummonGrade:SetText(info.grade.."级")
    -- type
    local bLong = iSummonType == 7 or iSummonType == 8
    local oTypeSpr = bLong and self.m_SummonTypeBtn2 or self.m_SummonTypeBtn
    self.m_SummonTypeBtn:SetActive(not bLong)
    self.m_SummonTypeBtn2:SetActive(bLong)
    oTypeSpr:SetSpriteName(dType.icon)
    self.m_LockSpr:SetActive(1==info.key)

    self.m_SummonSumScore:SetText(string.format("(%d)", info.summon_score))
    self:RefreshIsFight(bFight)
    if dScore then
        self.m_SummonScore:SetText(dScore.label)
    end
end

function CSummonViewBox.RefreshIsFight(self, state)
    local bFight = state or g_SummonCtrl.m_FightId == self.m_SummonId
    self.m_SummonIsCombat:SetActive(bFight)
end

function CSummonViewBox.OnPressLock(self, oBtn, bPress)
    self.m_LockL:SetActive(bPress)
end

return CSummonViewBox