local CHorseAddExpView = class("CHorseAddExpView", CViewBase)
function CHorseAddExpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseAddExpView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
    self.m_ItemId = 11099
end

function CHorseAddExpView.OnCreateView(self)
	self.m_ExpSlider = self:NewUI(1, CSlider)
    self.m_Grade = self:NewUI(2, CLabel)
    self.m_ItemIcon = self:NewUI(3, CSprite)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self.m_UseBtn = self:NewUI(5, CButton)
    self.m_ExpLabel = self:NewUI(6, CLabel)
 --   self.m_UpgradeHint = self:NewUI(7, CLabel)
    self.m_ItemCount = self:NewUI(8, CLabel)
    self.m_Count = self:NewUI(9, CLabel)
    self:InitContent()
end

function CHorseAddExpView.InitContent(self)
    self.m_UseBtn:AddUIEvent("click", callback(self, "OnUse"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ItemIcon:AddUIEvent("click", function ()
        g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
    end)
    g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self:SetInfo()
end

function CHorseAddExpView.SetInfo(self)


    local nextExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade + 1)
    local needExp = 0
    if nextExp then
        local curGradeExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade)
        local curExp = g_HorseCtrl.exp
        needExp = nextExp
        self.m_ExpSlider:SetValue(curExp/needExp)
        self.m_ExpLabel:SetText(curExp.."/"..needExp)
    else
        self.m_ExpSlider:SetValue(1)
        self.m_ExpLabel:SetText(g_HorseCtrl.exp)
    end


    self.m_Grade:SetText("等级："..g_HorseCtrl.grade)
    local itemData = DataTools.GetItemData(self.m_ItemId)
    self.m_ItemIcon:SetSpriteName(tostring(itemData.icon))
    --self.m_UpgradeHint:SetText("升级坐骑需要消耗"..itemData.name)
    local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    self.m_ItemCount:SetText(itemCount)

    self.m_Count:SetText("数量:" .. tostring(itemCount) .. "/" .. tostring(1))

end

function CHorseAddExpView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange then
		self:SetInfo()
	end
end

function CHorseAddExpView.OnUse(self)
    self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if self.BagItemCount <= 0 then
        local itemData = DataTools.GetItemData(self.m_ItemId)
        g_NotifyCtrl:FloatMsg(itemData.name.."不足！")
        return
    end
    g_HorseCtrl:C2GSUpGradeRide()
end

return CHorseAddExpView