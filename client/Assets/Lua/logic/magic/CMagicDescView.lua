local CMagicDescView = class("CMagicDescView", CViewBase)

function CMagicDescView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarDescView.prefab", cb)

	-- self.m_ExtendClose = "ClickOut"
end

function CMagicDescView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
    self.m_IconSpr = self:NewUI(3, CSprite)
    self.m_LvL = self:NewUI(4, CLabel)
    self.m_CostL = self:NewUI(5, CLabel)
    self.m_Bg = self:NewUI(6, CWidget)
end

function CMagicDescView.SetMagic(self, iMagicID, bHero)
	local dMagic = DataTools.GetMagicData(iMagicID)
	self.m_NameLabel:SetText(dMagic.name)
	self.m_DescLabel:SetText(dMagic.desc)
    self.m_IconSpr:SpriteSkill(dMagic.skill_icon)  

    if dMagic.magic_type == "fabao" then
        if string.len(dMagic.zhengqi) > 0 then
            self.m_CostL:SetText("消耗: "..dMagic.zhengqi.."真气")
        else
            self.m_CostL:SetText("")
        end
        local iLv = g_SkillCtrl:GetFaBaoSkillLv()
        if iLv > 0 then
            self.m_LvL:SetText("等级:"..iLv)
        else
            self.m_LvL:SetText("")
        end
        return
    end

    -- set cost
    local dCost = g_SkillCtrl:GetMagicCost(iMagicID)
    local sCost = "消耗:"
    local dName = {
        hp = "气血",
        mp = "法力",
        aura = "灵气",
        sp = "怒气",
    }
    local iCnt = 1
    for k, v in pairs(dCost) do
        if iCnt == 1 then
            sCost = string.format("%s%d%s", sCost, v, dName[k])
        else
            sCost = string.format("%s+%d%s", sCost, v, dName[k])
        end
        iCnt = iCnt + 1
    end
    
    if iCnt == 1 then
        sCost = sCost .. "0"
    end
    self.m_CostL:SetText(sCost)

    if iMagicID == 8501 then --同甘共苦技能没有等级
        self.m_LvL:SetActive(false)
        return
    end

    local iLv = g_SkillCtrl:GetMagicLv(iMagicID, bHero)
    self.m_LvL:SetText("等级:"..iLv)
end

function CMagicDescView.RegisterTouch(self, obj)
    g_UITouchCtrl:TouchOutDetect(obj, callback(self, "OnClose"))
end

function CMagicDescView.OnClose(self)
    self:CloseView()
end

return CMagicDescView