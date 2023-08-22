local CDanceWindowView = class("CDanceWindowView", CViewBase)

function CDanceWindowView.ctor(self,cb)
    CViewBase.ctor(self, "UI/Activity/DanceWindow.prefab",cb)
    
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
    self.m_DanceId = 1016
end

function CDanceWindowView.OnCreateView(self)
    -- self.m_Title = self:NewUI(1, CLabel)
    self.m_Content = self:NewUI(2, CLabel)
    self.m_IconSpr = self:NewUI(3, CSprite)
    self.m_Count = self:NewUI(4, CLabel)
    self.m_AttendNum = self:NewUI(5, CLabel)
    self.m_OKBtn = self:NewUI(6, CButton)
    self.m_CancelBtn = self:NewUI(7, CButton)
    self.m_HasNumLbl = self:NewUI(8, CLabel)
    self.m_CostNumLbl = self:NewUI(9, CLabel)

    self:InitContent()
end

function CDanceWindowView.InitContent(self)
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_OKBtn:AddUIEvent("click", callback(self, "OnOk"))
    self.m_IconSpr:AddUIEvent("click", callback(self, "OnClickIcon"))

    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

    self:RefreshUI()
end

function CDanceWindowView.OnCtrlItemEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
        self:RefreshUI()
    end
end

function CDanceWindowView.RefreshUI(self)
    local dancingData = data.dancedata.CONDITION[1]
    local itemNum = g_ItemCtrl:GetBagItemAmountBySid(dancingData.cost.itemid)
    self.m_Content:SetText("[244B4E]是否消耗[-]\n[244B4E]1个[-][63432c]舞会邀请函[-][244B4E]来进行跳舞[-]")
    self.m_Count:SetText(itemNum.."/"..dancingData.cost.amount)
    self.m_CostNumLbl:SetText("/"..dancingData.cost.amount)
    if itemNum >= 1 then
        self.m_HasNumLbl:SetText("[0fff32]"..itemNum)
        self.m_HasNumLbl:SetEffectColor(Color.RGBAToColor("003C41"))
    else
        self.m_HasNumLbl:SetText("[ffb398]"..itemNum)
        self.m_HasNumLbl:SetEffectColor(Color.RGBAToColor("cd0000"))
    end
    self.m_IconSpr:SetSpriteName(DataTools.GetItemData(dancingData.cost.itemid).icon)
    self.m_AttendNum:SetText("今日还可参与次数："..g_DancingCtrl.m_AttendNum.."/"..dancingData.limitcnt)
end

function CDanceWindowView.OnOk(self)
    g_DancingCtrl:AttendDancing()
    self:CloseView()
end

function CDanceWindowView.OnClickIcon(self)
    g_WindowTipCtrl:SetWindowGainItemTip(data.dancedata.CONDITION[1].cost.itemid, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_IconSpr, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

return CDanceWindowView