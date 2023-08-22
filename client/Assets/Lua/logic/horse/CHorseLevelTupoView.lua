local CHorseLevelTupoView = class("CHorseLevelTupoView", CViewBase)

function CHorseLevelTupoView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Horse/HorseLevelTupoView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
end

function CHorseLevelTupoView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Label = self:NewUI(2, CLabel)
    self.m_ConfirmBtn = self:NewUI(3, CButton)
    self.m_CancelBtn = self:NewUI(4, CButton)
    self.m_Box = self:NewUI(5, CBox)

    self:InitBox()

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancelBtn"))
   
     g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

    self:InitContent()

end

function CHorseLevelTupoView.OnClickItem(self)

    if  self.m_ItemId  then 
        g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
    end
 
end

function CHorseLevelTupoView.OnClickConfirmBtn(self)
    
    local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if itemCount < self.m_Cnt then 
        g_NotifyCtrl:FloatMsg(self.m_ItemData.name .. "不足")
        -- g_QuickGetCtrl:CheckLackItemInfo({
        --     itemlist = {{sid = self.m_ItemId, count = itemCount, amount = self.m_Cnt}},
        --     exchangeCb = function()
        --         netride.C2GSUpGradeRide(1)
        --     end
        -- })
        return
    end 
    g_HorseCtrl:C2GSBreakRideGrade()
    self:OnClose()

end

function CHorseLevelTupoView.OnClickCancelBtn(self)
    
    self:OnClose()

end

function CHorseLevelTupoView.InitContent(self)
   
    self.m_Label:SetText("坐骑必须完成等级突破才能升至" .. tostring(g_HorseCtrl.grade + 1) .. "级")
    self:RefreshItem()

end

function CHorseLevelTupoView.InitBox(self)
    
    self.m_Box.m_Icon = self.m_Box:NewUI(1, CSprite)
    self.m_Box.m_Name = self.m_Box:NewUI(2, CLabel)
    self.m_Box.m_Count = self.m_Box:NewUI(3, CLabel)
    self.m_Box.m_Icon:AddUIEvent("click", callback(self, "OnClickItem"))

end

function CHorseLevelTupoView.RefreshItem(self)

    local config = data.ridedata.UPGRADE[g_HorseCtrl.grade + 1]
    if config then 
        if next(config.break_cost) then 
            local cnt = config.break_cost[1].cnt
            local itemId = config.break_cost[1].itemid
            self.m_ItemData = DataTools.GetItemData(itemId, "OTHER")
            self.m_Box.m_Icon:SetSpriteName(tostring(self.m_ItemData.icon))
            self.m_Box.m_Name:SetText(self.m_ItemData.name)
            local itemCount = g_ItemCtrl:GetBagItemAmountBySid(itemId)
            self.m_Box.m_Count:SetText("数量:" .. tostring(itemCount) .. "/" .. tostring(cnt))
            self.m_ItemId = itemId
            self.m_Cnt = cnt
        end 
    end    

end

function CHorseLevelTupoView.OnCtrlEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Attr.Event.Change then

        self:RefreshItem()

    end

end

return CHorseLevelTupoView


