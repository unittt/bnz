local CRedPacketItemSendView = class("CRedPacketItemSendView", CViewBase)

function CRedPacketItemSendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketItemSendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketItemSendView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_DescInput = self:NewUI(2, CInput)
	self.m_MoneyBtn = self:NewUI(3, CWidget)
	self.m_MoneyValueLbl = self:NewUI(4, CLabel)
	self.m_ConvertLbl = self:NewUI(5, CLabel)
	self.m_NameLbl = self:NewUI(6, CLabel)
	self.m_NumBtn = self:NewUI(9, CWidget)
	self.m_NumValueLbl = self:NewUI(10, CLabel)
	self.m_OrgBtn = self:NewUI(11, CButton)
	self.m_WorldBtn = self:NewUI(12, CButton)
	self.m_SendBtn = self:NewUI(13, CButton)

	self.m_SelectSendChannel = define.RedPacket.Channel.World
	self.m_ItemId = nil

	self:InitContent()
end

function CRedPacketItemSendView.InitContent(self)
	self.m_OrgBtn:SetGroup(self:GetInstanceID())
	self.m_WorldBtn:SetGroup(self:GetInstanceID())
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_WorldBtn:AddUIEvent("click", callback(self, "OnClickSelectChannel", define.RedPacket.Channel.World))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickSelectChannel", define.RedPacket.Channel.Org))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSend"))
end

--#cur_1 元宝 #cur_2 绑定元宝 #cur_3 金币 #cur_4 银币
function CRedPacketItemSendView.RefreshUI(self, pbdata)
	self.m_ItemId = pbdata.id

	self.m_NameLbl:SetText(pbdata.name)
	self.m_MoneyValueLbl:SetText("#cur_1"..pbdata.goldcoin)
	self.m_ConvertLbl:SetText("#cur_3"..(pbdata.goldcoin*define.RedPacket.Convert.GoldCoinToGold)) --"将转换为:"..
	self.m_NumValueLbl:SetText(pbdata.count)

	self:CheckChannelUIState()
end

function CRedPacketItemSendView.CheckChannelUIState(self)
	if self.m_SelectSendChannel == define.RedPacket.Channel.World then
		self.m_WorldBtn:SetSelected(true)
	else
		self.m_OrgBtn:SetSelected(true)
	end
end

----------------以下是点击事件---------------

function CRedPacketItemSendView.OnClickSelectChannel(self, iChannel)
	self.m_SelectSendChannel = iChannel

	if iChannel == define.RedPacket.Channel.World then
	else
	end
end

function CRedPacketItemSendView.OnClickSend(self)
	if self.m_ItemId then
		netredpacket.C2GSUseRPItem(self.m_ItemId, self.m_SelectSendChannel)
	end
	self:CloseView()
end

return CRedPacketItemSendView