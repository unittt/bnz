local CRedPacketGetView = class("CRedPacketGetView", CViewBase)

function CRedPacketGetView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketGetView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketGetView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSp= self:NewUI(2, CSprite)
	self.m_NameLbl = self:NewUI(3, CLabel)
	self.m_DescLbl = self:NewUI(4, CLabel)
	self.m_MoneyLbl = self:NewUI(5, CLabel)
	self.m_GetPlayerBtn = self:NewUI(6, CButton)

	self.m_RedPacketGetData = {}

	self:InitContent()
end

function CRedPacketGetView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GetPlayerBtn:AddUIEvent("click", callback(self, "OnClickGetPlayer"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CRedPacketGetView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.GetRedPacketSuccess then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

function CRedPacketGetView.RefreshUI(self, pbdata)
	self.m_RedPacketGetData = {}
	for k,v in pairs(pbdata) do
		self.m_RedPacketGetData[k] = v
	end
	self.m_NameLbl:SetText(self.m_RedPacketGetData.ownername)
	self.m_DescLbl:SetText(self.m_RedPacketGetData.bless)
	self.m_MoneyLbl:SetText("恭喜你抢到了"..self.m_RedPacketGetData.robcash.."金币")
end

function CRedPacketGetView.OnClickGetPlayer(self)
	self:CloseView()
	netredpacket.C2GSQueryBasic(self.m_RedPacketGetData.id)
end

return CRedPacketGetView