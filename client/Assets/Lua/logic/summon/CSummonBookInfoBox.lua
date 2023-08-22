local CSummonBookInfoBox = class("CSummonBookInfoBox", CBox)

function CSummonBookInfoBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self:InitContent()
end

function CSummonBookInfoBox.InitContent(self)
    self.m_SummonTexture = self:NewUI(1, CActorTexture)
    self.m_SummonType = self:NewUI(2, CSprite)
    self.m_SummonName = self:NewUI(3, CLabel)
    self.m_GetGrade = self:NewUI(4, CLabel)
    self.m_SummonTypeSpr2 = self:NewUI(5, CSprite)
end

function CSummonBookInfoBox.SetInfo(self, summonInfo)
    local model_info =  table.copy(summonInfo)
    model_info.rendertexSize = 1.25
    model_info.pos = Vector3(0, -0.75, 3)
    self.m_SummonTexture:ChangeShape(model_info)
    -- type
    local iType = summonInfo.type
    local bLong = iType == 7 or iType == 8
    local oTypeSpr = bLong and self.m_SummonTypeSpr2 or self.m_SummonType
    self.m_SummonType:SetActive(not bLong)
    self.m_SummonTypeSpr2:SetActive(bLong)
    oTypeSpr:SetSpriteName(data.summondata.SUMMTYPE[iType].icon)

    self.m_SummonName:SetText(summonInfo.name)
    self.m_GetGrade:SetText("人物"..summonInfo.carry.."级可携带")
    if g_AttrCtrl.grade < summonInfo.carry then
        self.m_GetGrade:SetColor(Color.red)
    else
        self.m_GetGrade:SetColor(Color.New(99/255, 67/255, 44/255, 1))
    end
end

return CSummonBookInfoBox