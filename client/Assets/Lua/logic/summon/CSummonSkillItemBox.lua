local CSummonSkillItemBox = class("CSummonSkillItemBox", CBox)

function CSummonSkillItemBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self:InitContent(self)
end

function CSummonSkillItemBox.InitContent(self)
    self.m_IconSpr = self:NewUI(1,CSprite)
    self.m_TalentSpr = self:NewUI(2, CSprite)
    self.m_BindSpr = self:NewUI(3, CSprite)
    self.m_SureSpr = self:NewUI(4, CSprite)
    self.m_InfoWidget = self:NewUI(5, CWidget)
    self.m_EquipSpr = self:NewUI(6, CSprite)
    self.m_QualitySpr = self:NewUI(7, CSprite)

    self.m_EquipSpr:SetSpriteName("h7_hufu")
    self.m_EquipSpr:SetLocalPos(Vector3.New(-13,12,0))
    self:AddUIEvent("click",callback(self, "OnClickSkillItem"))
end

function CSummonSkillItemBox.SetInfo(self, info, bOpera)
    local bNotEmpty = info and true or false
    self.m_InfoWidget:SetActive(bNotEmpty)
    if bNotEmpty then
        local dConfig = SummonDataTool.GetSummonSkillInfo(info.sk)
        local spriteInfo = dConfig.iconlv
        self.m_IconSpr:SpriteSkill(spriteInfo[1].icon)
        self.m_IconSpr:SetActive(true)
        self.m_SureSpr:SetActive(info.sure or false)
        self.m_EquipSpr:SetActive(info.equip or false)
        local iQuality = dConfig.quality
        iQuality = iQuality == 0 and 2 or iQuality
        self.m_QualitySpr:SetItemQuality(iQuality)
        local bind = false
        if info.bind and info.bind == 1 then
            bind = true
            self.m_SureSpr:SetActive(false)
        end
        if info.wenshi then
            self.m_TalentSpr:SetSpriteName("h7_tongyu_bq")
            self.m_TalentSpr:SetActive(true)
        else
            self.m_TalentSpr:SetActive(info.talent or false)
        end
        self.m_BindSpr:SetActive(bind)
        info.canOpera = bOpera
    end
    self.m_Info = info
end

--显示技能Tips
function CSummonSkillItemBox.OnClickSkillItem(self)
    if not self.m_Info then
        return
    end 
    CSummonSkillItemTipsView:ShowView(function (oView)
        oView:SetData(self.m_Info, self:GetPos(), nil, nil)  
    end)
end

return CSummonSkillItemBox