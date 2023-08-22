local CHorseSkillForgetBox = class("CHorseSkillForgetBox", CBox)

function CHorseSkillForgetBox.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_CloseBtn = self:NewUI(2, CSprite)
    self.m_Name = self:NewUI(3, CLabel)
    self.m_Count = self:NewUI(4, CLabel)
    self.m_ConfirmBtn = self:NewUI(5, CSprite)
    self.m_CancelBtn = self:NewUI(6, CSprite)

    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose")) 
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose")) 
    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnForget")) 
    self.m_Icon:AddUIEvent("click", callback(self, "OnClickItem")) 

    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent")) 

end

function CHorseSkillForgetBox.SetInfo(self, id, cb)

    self.m_Cb = cb

    self.m_Id = id

    self.m_ForgetItemId = data.ridedata.OTHER[1].random_cost[1].sid
    self.m_Cnt = data.ridedata.OTHER[1].random_cost[1].cnt

    local level = g_HorseCtrl:GetSkillLevel(id)
    self.m_Cnt = self.m_Cnt * level

    self:RefreshItem()

end

function CHorseSkillForgetBox.RefreshItem(self)

    if not self.m_ForgetItemId then 
        return
    end 
    
    local itemData = DataTools.GetItemData(self.m_ForgetItemId, "OTHER")

    self.m_Icon:SetSpriteName(tostring(itemData.icon))
    self.m_Name:SetText(itemData.name)
    local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ForgetItemId)
    self.m_Count:SetText("数量:" .. tostring(itemCount) .. "/" .. tostring(self.m_Cnt))

end

function CHorseSkillForgetBox.OnForget(self)
    
    local bagCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ForgetItemId)
    if bagCount < self.m_Cnt then
        local itemData = DataTools.GetItemData(self.m_ForgetItemId)
        g_NotifyCtrl:FloatMsg(itemData.name.."不足！")
        return
    end
    
    g_HorseCtrl:C2GSForgetRideSkill(self.m_Id, 1)
    if self.m_Cb then 
        self.m_Cb()
        self:SetActive(false)
    end 

end

function CHorseSkillForgetBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then

         self:RefreshItem()

    end
end


function CHorseSkillForgetBox.OnClose(self)
    
    self:SetActive(false)

end

function CHorseSkillForgetBox.OnClickItem(self)
    
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ForgetItemId)

end

return CHorseSkillForgetBox