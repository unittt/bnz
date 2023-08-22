local CFriendFilterView = class("CFriendFilterView", CViewBase)

function CFriendFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Friend/FriendFilterView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CFriendFilterView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SaveBtn = self:NewUI(2, CButton)
	self.m_RefuseOtherWidget = self:NewUI(3, CWidget)
	self.m_AddFriendVertWidget = self:NewUI(4, CWidget)
	self.m_RefuseMsgWidget = self:NewUI(5, CWidget)

	local tOn_OffData = g_SystemSettingsCtrl.m_OnOff 

	self.m_RefuseOtherWidget:SetSelected(tOn_OffData[7])
	self.m_AddFriendVertWidget:SetSelected(tOn_OffData[8])
	self.m_RefuseMsgWidget:SetSelected(tOn_OffData[9])
	
	self:InitContent()
end

function CFriendFilterView.InitContent(self)	
	self.m_RefuseOtherWidget:AddUIEvent("click", callback(self, "OnSaveRefuseOtherModeCheckSprite"))
	self.m_AddFriendVertWidget:AddUIEvent("click", callback(self, "OnSaveAddFriendVertModeCheckSprite"))
	self.m_RefuseMsgWidget:AddUIEvent("click", callback(self, "OnSaveRefuseMsgModeCheckSprite"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnClickSave"))
end

function CFriendFilterView.OnSaveRefuseOtherModeCheckSprite(self)
	
end

function CFriendFilterView.OnSaveAddFriendVertModeCheckSprite(self)
	
end

function CFriendFilterView.OnSaveRefuseMsgModeCheckSprite(self)
	
end

function CFriendFilterView.OnClickSave(self)
	g_SystemSettingsCtrl:SaveLocalOnOffSettings(7, self.m_RefuseOtherWidget:GetSelected())
	g_SystemSettingsCtrl:SaveLocalOnOffSettings(8, self.m_AddFriendVertWidget:GetSelected())
	g_SystemSettingsCtrl:SaveLocalOnOffSettings(9, self.m_RefuseMsgWidget:GetSelected())
	g_SystemSettingsCtrl:C2GSSysConfig()
	self:OnClose()
end

return CFriendFilterView