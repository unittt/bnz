local CTongYuSummonTipView = class("CTongYuSummonTipView", CViewBase)

function CTongYuSummonTipView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/TongYuSummonTipView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    --self.m_ExtendClose = "ClickOut"

end

function CTongYuSummonTipView.OnCreateView(self)

    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Flag = self:NewUI(2, CSprite)
    self.m_SummonName = self:NewUI(3, CLabel)
    self.m_RideName = self:NewUI(4, CLabel)
    self.m_TongYuState = self:NewUI(5, CLabel)
    self.m_Grid = self:NewUI(6, CGrid)
    self.m_SkillItem = self:NewUI(7, CBox)
    self.m_DetailBtn = self:NewUI(8, CSprite)
    self.m_ChangeBtn = self:NewUI(9, CSprite)
    self.m_Lv = self:NewUI(10, CLabel)
    self.m_SubSkillTip = self:NewUI(11, CTongYuSummonSkillTip)

    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose")) 
    self.m_DetailBtn:AddUIEvent("click", callback(self, "OnClickDetail"))
    self.m_ChangeBtn:AddUIEvent("click", callback(self, "OnClickChange"))  

end


function CTongYuSummonTipView.SetInfo(self, id, rideData, pos)

    --获取宠物技能信息 name rideid lv skill
    self.m_RideData = rideData
    local summonInfo = g_SummonCtrl:GetSummon(id)
    self.m_SummonInfo = summonInfo
    self.m_SummonId = summonInfo.id
    local summonName = summonInfo.name
    local lv = summonInfo.grade
    local skillList = summonInfo.skill
    local talent = summonInfo.talent

    self.m_CurPos = pos

    local info = data.summondata.INFO[summonInfo.typeid]
    if info then 
        self.m_Icon:SetSpriteName(info.shape)
    end 

    self.m_Flag:SetActive(summonInfo.id == g_SummonCtrl.m_FightId)

    self.m_SummonName:SetText(summonName)
    self.m_Lv:SetText(lv)

    local rideId = summonInfo.bind_ride
    local rideInfo = data.ridedata.RIDEINFO[rideId]
    if rideId then 
        if rideInfo then 
            self.m_RideName:SetText(rideInfo.name)
            self.m_RideName:SetActive(true)
             self.m_TongYuState:SetText("统御中")
        end 
    else
        self.m_RideName:SetActive(false)
        self.m_TongYuState:SetText("未统御")
    end 

    local allSkill = {}

    if next(talent) then 
        for k, v in ipairs(talent) do 
            if v.sk then 
                table.insert(allSkill, {sk = v.sk, isTalent = true})
            end 
        end 
    end 

    local wenshiSkillId, valid = g_WenShiCtrl:GetWenShiSkillId(rideId)

    for k, v in ipairs(skillList) do 
        table.insert(allSkill, v)
    end

    if valid then 
        table.insert(allSkill, {sk = wenshiSkillId})
    end

    self.m_Grid:HideAllChilds()

    for k, v in ipairs(allSkill) do 
        local skillItem = self.m_Grid:GetChild(k)
        if not skillItem then 
            skillItem = self.m_SkillItem:Clone()
            skillItem:SetActive(true)
            self.m_Grid:AddChild(skillItem)
        end 
        skillItem:SetActive(true)
        skillItem.icon = skillItem:NewUI(1, CSprite)
        skillItem.quality = skillItem:NewUI(2, CSprite)
        skillItem.box = skillItem:NewUI(3, CWidget)
        skillItem.flag = skillItem:NewUI(4, CSprite)
        skillItem.box:AddUIEvent("click", callback(self, "OnClickSkillItem", v.sk))
        skillItem.box:SetGroup(self.m_Grid:GetInstanceID())
        local summonSkillInfo = data.summondata.SKILL[v.sk]
        if summonSkillInfo then 
            skillItem.icon:SpriteSkill(summonSkillInfo.iconlv[1].icon)
            local quality = summonSkillInfo.quality
            skillItem.quality:SetItemQuality(quality)
        end
        local isTalent = v.isTalent
        skillItem.flag:SetActive(isTalent)
    
    end 

end


function CTongYuSummonTipView.OnClickSkillItem(self, Id)

    self.m_SubSkillTip:SetActive(true)
    self.m_SubSkillTip:SetInfo(Id)

end

function CTongYuSummonTipView.OnClickDetail(self)
    
    CSummonLinkView:ShowView(function ( oView )
        oView:SetSummon(self.m_SummonInfo)
    end)

end

function CTongYuSummonTipView.OnClickChange(self)
    
    CHorseTongYuMainView:ShowView(function (oView)
        oView:OpenTongYuOpPart(self.m_RideData.id, self.m_CurPos)
    end)

end

return CTongYuSummonTipView