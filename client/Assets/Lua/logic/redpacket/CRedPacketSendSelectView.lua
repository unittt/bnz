local CRedPacketSendSelectView = class("CRedPacketSendSelectView", CViewBase)

function CRedPacketSendSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketSendSelectView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketSendSelectView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_WorldBtn = self:NewUI(2, CWidget)
	self.m_OrgBtn = self:NewUI(3, CWidget)

	self:InitContent()
end

function CRedPacketSendSelectView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_WorldBtn:AddUIEvent("click", callback(self, "OnClickWorldSend"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickOrgSend"))
end

function CRedPacketSendSelectView.OnClickWorldSend(self)
	g_RedPacketCtrl.m_SelectSendChannel = define.RedPacket.Channel.World
	CRedPacketSendView:ShowView()
	self:CloseView()
end

function CRedPacketSendSelectView.OnClickOrgSend(self)
	g_RedPacketCtrl.m_SelectSendChannel = define.RedPacket.Channel.Org
	CRedPacketSendView:ShowView()
	self:CloseView()
end

return CRedPacketSendSelectView