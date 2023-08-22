local CSummonStudyItemBox = class("CSummonStudyItemBox", CBox)

function CSummonStudyItemBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Info = nil
    self:InitContent()
end

function CSummonStudyItemBox.InitContent(self)
    self.m_ItemSpr = self:NewUI(1, CSprite)
    self.m_AddSpr = self:NewUI(2, CSprite)
    self.m_IconSpr = self:NewUI(3, CSprite)
    self.m_QualitySpr = self:NewUI(4, CSprite)
    self.m_CntL = self:NewUI(5, CLabel)
    self.m_NameL = self:NewUI(6, CLabel)
    self.m_BuyL = self:NewUI(7, CLabel)
    self.m_PriceL = self:NewUI(8, CLabel)
    self.m_DescL = self:NewUI(9, CLabel)
    self.m_ExistSpr = self:NewUI(10, CSprite)

    -- self.m_QualitySpr:SetActive(false)
    self.m_AddSpr:SetActive(false)
    self.m_CntL:SetActive(false)
    self.m_BuyL:SetActive(false)
end

function CSummonStudyItemBox.SetInfo(self, info)
    self.m_Info = info
    self.m_NameL:SetActive(true)
    self.m_IconSpr:SetActive(true)
    self.m_PriceL:SetActive(not self.isBag)
    self.m_DescL:SetActive(true)
    self.m_ExistSpr:SetActive(info.isExist)
    -- self.m_CntL:SetActive(self.isBag or false)
    if self.isBag then
        self.m_CntL:SetText(info.amount)
    else
        self.m_PriceL:SetText(info.price)
    end
    if info.id == 30000 then
        local dItem = DataTools.GetItemData(info.id, "SUMMSKILL")
        if dItem then
            self.m_IconSpr:SpriteItemShape(dItem.icon)
            self.m_NameL:SetText(dItem.name)
            self.m_QualitySpr:SetItemQuality(dItem.quality)
            self.m_DescL:SetText(dItem.description)
        end
    elseif info.skid then
        local dSkill = SummonDataTool.GetSummonSkillInfo(info.skid)
        if dSkill then
            local icon = dSkill.iconlv[1].icon
            self.m_IconSpr:SpriteSkill(icon)
            self.m_NameL:SetText(dSkill.name)
            self.m_DescL:SetText(dSkill.short_des)
            local iQuality = dSkill.quality
            if iQuality == 0 then
                iQuality = 2
            end
            self.m_QualitySpr:SetItemQuality(iQuality)
        end
    end
end

return CSummonStudyItemBox