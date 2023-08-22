local CHorseStudySkillView = class("CHorseStudySkillView", CViewBase)

function CHorseStudySkillView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Horse/HorseStudySkillView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
end

function CHorseStudySkillView.OnCreateView(self)

     self.m_CloseBtn = self:NewUI(1, CButton)
     self.m_SkillItem = self:NewUI(2, CBox)
     self.m_ResetBtn = self:NewUI(3, CButton)
     self.m_SaveSkillBtn = self:NewUI(4, CButton)
     self.m_ConsumeItem = self:NewUI(5, CBox)
     self.m_ItemGrid = self:NewUI(6, CGrid)
     self.m_CheckSkill = self:NewUI(7, CSprite)
     self.m_TipBox = self:NewUI(8, CSprite)

     self.m_SkillItem:SetActive(false)

     self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
     self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetBtn"))
     self.m_SaveSkillBtn:AddUIEvent("click", callback(self, "OnClickSaveSkillBtn"))
     self.m_CheckSkill:AddUIEvent("click", callback(self, "OnClickCheckSkillBtn"))
   
     g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
     g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

     self:InitContent()

end


function CHorseStudySkillView.InitContent(self)

    self:InitConsume()
    self:RefreshConsume()
    if not g_HorseCtrl.choose_skills or not next(g_HorseCtrl.choose_skills) then 
        g_HorseCtrl:C2GSRandomRideSkill()
    else
        self:RefreshItem()
    end 

end

function CHorseStudySkillView.InitSkillItem(self, oItem)
    
    oItem.name = oItem:NewUI(1, CLabel)
    oItem.skillType = oItem:NewUI(2, CLabel)
    oItem.des = oItem:NewUI(3, CLabel)
    oItem.collider = oItem:NewUI(4, CWidget)
    oItem.icon = oItem:NewUI(5, CSprite)
    return oItem

end

function CHorseStudySkillView.SetSkillItemData(self, oItem, data)
    
    local name = data.name
    local icon = data.icon
    local skillType = data.ride_type
    local des = data.desc
    oItem.icon:SpriteSkill(icon)
    oItem.name:SetText(name)
    oItem.des:SetText(des)
    if skillType == 0 then 
        oItem.skillType:SetText("主技能")
    else
        oItem.skillType:SetText("副技能")
    end 

    oItem.collider:AddUIEvent("click", callback(self, "OnSelect", data.id))

end

function CHorseStudySkillView.RefreshItem(self)

    if g_HorseCtrl.choose_skills and next(g_HorseCtrl.choose_skills) then 
        for k,v in ipairs(g_HorseCtrl.choose_skills) do
            if k <= 2 then 
                local item = self.m_ItemGrid:GetChild(k)
                if not item then 
                    item = self.m_SkillItem:Clone()
                    item:SetActive(true)
                    item = self:InitSkillItem(item)
                    self.m_ItemGrid:AddChild(item) 
                end 

                local config = data.ridedata.SKILL[v]
                if config then
                    self:SetSkillItemData(item, config)      
                end 
            end 
        end
    end 

end

function CHorseStudySkillView.InitConsume(self)
    
    self.m_ConsumeItem.Icon = self.m_ConsumeItem:NewUI(1, CSprite)
    self.m_ConsumeItem.Count = self.m_ConsumeItem:NewUI(2, CLabel)
    self.m_ConsumeItem.Icon:AddUIEvent("click", callback(self, "OnClickConsumeItem", self.m_ConsumeItem))

end

function CHorseStudySkillView.OnClickConsumeItem(self, item)
    
    if not item.id then 
        return
    end 

    local config = DataTools.GetItemData(item.id, "OTHER")

    g_WindowTipCtrl:SetWindowGainItemTip(item.id)

end

function CHorseStudySkillView.RefreshConsume(self)
    
    local config = data.ridedata.OTHER[1].random_cost[1]
    local id = config.sid
    local itemData = DataTools.GetItemData(id)
    if itemData then 
        local count = config.cnt
        local hadCount = g_ItemCtrl:GetBagItemAmountBySid(id)
        self.m_ConsumeItem.Icon:SetSpriteName(itemData.icon)
        if hadCount < count then 
            self.m_ConsumeItem.Count:SetText("[af302a]" .. tostring(hadCount) .. "[-][1d8e00]/" .. tostring(count) .. "[-]")
        else
            self.m_ConsumeItem.Count:SetText("[1d8e00]" .. tostring(hadCount) .. "/" .. tostring(count) .. "[-]")
        end 
        
        self.m_ConsumeItem.id = id
    end 

end

function CHorseStudySkillView.SelectSkillItem(self)
    
    local LearnSk = g_HorseCtrl.learn_sk

    for k, v in ipairs(self.m_ItemGrid:GetChildList()) do 

        if  v.m_Id == LearnSk then 
            v:ForceSelected(true)
            v.m_Mask:ForceSelected(true)
        end 

    end 

end

function CHorseStudySkillView.OnResetBtn(self)

    local config = data.ridedata.OTHER[1].random_cost[1]
    local id = config.sid
    local itemData = DataTools.GetItemData(id)
    if itemData then 
        local count = config.cnt
        local hadCount = g_ItemCtrl:GetBagItemAmountBySid(id)
        if hadCount < count then 
            -- g_NotifyCtrl:FloatMsg(itemData.name .. "不足！")
            g_QuickGetCtrl:CheckLackItemInfo({
                itemlist = {{sid = id, count = hadCount, amount = count}},
                exchangeCb = function()
                    netride.C2GSRandomRideSkill(1)
                end
            })
            return
        end 
    end 

    g_HorseCtrl:C2GSRandomRideSkill()

end

function CHorseStudySkillView.OnSelect(self, id)

    self.m_SelectSkillId = id

end

function CHorseStudySkillView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID ==define.Horse.Event.ChooseSkills then
        self:RefreshItem()
        self:RefreshConsume()
    elseif oCtrl.m_EventID == define.Horse.Event.LearnSk then 
        self:RefreshConsume()
    end 
end

function CHorseStudySkillView.OnCtrlItemEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
        self:RefreshConsume()
    end

end

function CHorseStudySkillView.OnClickCheckSkillBtn(self)
    
    CHorseSkillStoreView:ShowView()

end

function CHorseStudySkillView.OnClickSaveSkillBtn(self)

    if self.m_SelectSkillId then 
        g_HorseCtrl:C2GSLearnRideSkill(self.m_SelectSkillId)
        self:OnClose()
    else
        g_NotifyCtrl:FloatMsg("请选择一个技能进行保存")
        self.m_TipBox:SetActive(true)
        Utils.AddTimer(function ()
            if not Utils.IsNil(self) then 
                self.m_TipBox:SetActive(false)
            end 
        end, 0, 1)
    end 
    
end


return CHorseStudySkillView


