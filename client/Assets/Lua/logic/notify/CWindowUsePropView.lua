local CWindowUsePropView = class("CWindowUsePropView", CViewBase)

function CWindowUsePropView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowUsePropView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CWindowUsePropView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_TitleLable = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_EnterBtn = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_BackGroundSprite = self:NewUI(6, CSprite)
	self.m_Amount = self:NewUI(7, CLabel)

	self.m_PropName = ""
	self.m_Sid = 0
	self.m_PropNumList = 0
	self.m_BtnCallBack = nil

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_EnterBtn:AddUIEvent("click", callback(self, "OnUseProp"))
end

function CWindowUsePropView.OnItemCtrlEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid)
		if iAmount >= 1 then
			self.m_Amount:SetText("[0fff32]"..iAmount)
			self.m_Amount:SetEffectColor(Color.RGBAToColor("003C41"))
		else
			self.m_Amount:SetText("[ffb398]"..iAmount)
			self.m_Amount:SetEffectColor(Color.RGBAToColor("cd0000"))
		end
	end
end

function CWindowUsePropView.OnUseProp(self)
	if g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid) == 0  then
		g_NotifyCtrl:FloatMsg(self.m_PropName .. "不足!!")
		return
	end

	if self.m_BtnCallBack then
		self.m_BtnCallBack()
	end
	self:CloseView()
end

function CWindowUsePropView.SetWinInfo(self, data)
	self.m_Sid = data.sid
	local itemData = DataTools.GetItemData(data.sid)
	self.m_PropName = itemData.name
	
	self.m_BtnCallBack = data.callback
	self.m_Icon:SpriteItemShape(itemData.icon)
	self.m_Icon:AddUIEvent("click", callback(self, "OnTipsView"))
	self.m_TitleLable:SetText(data.title or "提示")
	self.m_NameLabel:SetText(self.m_PropName or "")
	self.m_EnterBtn:SetText(data.btnname or "确定")

	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid)
	if iAmount >= 1 then
		self.m_Amount:SetText("[0fff32]"..iAmount)
		self.m_Amount:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_Amount:SetText("[ffb398]"..iAmount)
		self.m_Amount:SetEffectColor(Color.RGBAToColor("cd0000"))
	end
end

function CWindowUsePropView.OnTipsView(self)
	-- body
	-- CQuickGetTipView:ShowView(function (oView)
	-- 	-- body
	-- 	oView:InitItemInfo(self.m_Sid)
	-- end)
	--TODO:临时替换旧的跳转
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_Sid)
end

return CWindowUsePropView