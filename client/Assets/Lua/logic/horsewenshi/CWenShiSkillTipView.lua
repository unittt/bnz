local CWenShiSkillTipView = class("CWenShiSkillTipView", CViewBase)

function CWenShiSkillTipView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiSkillTipView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    --self.m_ExtendClose = "ClickOut"

end

function CWenShiSkillTipView.OnCreateView(self)

    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Name = self:NewUI(2, CLabel)
   -- self.m_Lv = self:NewUI(3, CLabel)
    self.m_Type = self:NewUI(4, CLabel)
    self.m_Des = self:NewUI(5, CLabel)
    self.m_Grid = self:NewUI(6, CGrid)
    self.m_ConditionItem = self:NewUI(7, CSprite)
    self.m_Quality = self:NewUI(8, CSprite)

    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose")) 
    -- self.m_Dismount:AddUIEvent("click", callback(self, "OnClickDetail"))
    -- self.m_ChangeBtn:AddUIEvent("click", callback(self, "OnClickChange"))  

end


function CWenShiSkillTipView.SetInfo(self, skillInfo)

    self.m_Icon:SpriteSkill(skillInfo.icon)
    self.m_Name:SetText(skillInfo.name)
    self.m_Type:SetText(skillInfo.type)
    self.m_Des:SetText(skillInfo.des)
    local skillId = skillInfo.id
    local conditionList = g_WenShiCtrl:GetWenShiSkillCondition(skillId)
    for k, v in pairs(conditionList) do 
        local item = self.m_Grid:GetChild(k)
        if not item then 
            item = self.m_ConditionItem:Clone()
            item:SetActive(true)
            self.m_Grid:AddChild(item)
        end 
        item:SetActive(true)
        local icon = g_WenShiCtrl:GetWenShiIcon(v)
        item:SpriteItemShape(icon)
    end 

    local quality = skillInfo.quality
    if quality then 
        self.m_Quality:SetItemQuality(quality)
    end 
   
end

return CWenShiSkillTipView