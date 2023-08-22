local CRedPacketWorldPart = class("CRedPacketWorldPart", CPageBase)

function CRedPacketWorldPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TipsBtn = self:NewUI(1, CButton)
	self.m_HistroyBtn = self:NewUI(2, CButton)
	self.m_SendBtn = self:NewUI(3, CButton)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_Grid = self:NewUI(5, CGrid)
	self.m_BoxClone = self:NewUI(6, CBox)
	self.m_EmptyGo = self:NewUI(7, CObject)
	self.m_EmptyLbl = self:NewUI(8, CLabel)
	self:InitContent()
end

function CRedPacketWorldPart.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	self.m_HistroyBtn:AddUIEvent("click", callback(self, "OnClickHistroy"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSend"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CRedPacketWorldPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.RefreshWorldRedPacket then
		self:RefreshUI(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.RedPacket.Event.RefreshMainUI then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.RedPacket.Event.DeleteRedPacket then
		self:RefreshUI()
	end
end

function CRedPacketWorldPart.RefreshUI(self, pbdata)
	if next(g_RedPacketCtrl.m_RedPacketViewList) then
		self.m_EmptyGo:SetActive(false)
		self.m_ScrollView:SetActive(true)
	else
		self.m_EmptyGo:SetActive(true)
		self.m_EmptyLbl:SetText(data.redpacketdata.TEXT[define.RedPacket.Text.NoWorldRedPacket].content)
		self.m_ScrollView:SetActive(false)
	end

	self:SetRedPacketList()
end

function CRedPacketWorldPart.SetRedPacketList(self)
	local optionCount = #g_RedPacketCtrl.m_RedPacketViewList
	local GridList = self.m_Grid:GetChildList() or {}
	local oRedPacket
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRedPacket = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oRedPacket = GridList[i]
			end
			self:SetRedPacketBox(oRedPacket, g_RedPacketCtrl.m_RedPacketViewList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Grid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CRedPacketWorldPart.SetRedPacketBox(self, oRedPacket, oData)
	oRedPacket:SetActive(true)
	oRedPacket.m_FrontBg = oRedPacket:NewUI(1, CSprite)
	oRedPacket.m_TitleLbl = oRedPacket:NewUI(2, CLabel)
	oRedPacket.m_DoneSp = oRedPacket:NewUI(3, CSprite)
	oRedPacket.m_NameLbl = oRedPacket:NewUI(4, CLabel)
	oRedPacket.m_FrontBg:SetActive(false)
	oRedPacket.m_TitleLbl:SetActive(false)
	oRedPacket.m_DoneSp:SetActive(false)

	oRedPacket.m_TitleLbl:SetText(oData.bless)
	oRedPacket.m_NameLbl:SetText(oData.ownername)

	if oData.valid == 1 then
	else
		oRedPacket.m_FrontBg:SetActive(true)
		oRedPacket.m_TitleLbl:SetActive(true)
		oRedPacket.m_NameLbl:SetText("")
	end

	--1-未抢光　2-已抢光
	if oData.finish == 2 then
		oRedPacket.m_FrontBg:SetActive(true)
		oRedPacket.m_TitleLbl:SetActive(true)
		oRedPacket.m_DoneSp:SetActive(true)
		oRedPacket.m_NameLbl:SetText("")
	end
	oRedPacket:AddUIEvent("click", callback(self, "OnClickGetRedPacket", oData))

	self.m_Grid:AddChild(oRedPacket)
	self.m_Grid:Reposition()
end

function CRedPacketWorldPart.OnClickTips(self)
	local zId = define.Instruction.Config.RedPacket
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CRedPacketWorldPart.OnClickHistroy(self)
	netredpacket.C2GSQueryHistory()
end

function CRedPacketWorldPart.OnClickSend(self)
	-- g_RedPacketCtrl.m_SelectSendChannel = define.RedPacket.Channel.World
	-- CRedPacketSendView:ShowView()
	CRedPacketMainView:CloseView()
	COrgInfoView:CloseView()
	CRedPacketSendSelectView:ShowView()
end

--valid 1-可领取　2-不能领取
function CRedPacketWorldPart.OnClickGetRedPacket(self, oData)
	if oData.valid == 1 then
		netredpacket.C2GSRobRP(oData.id)
	else
		netredpacket.C2GSQueryBasic(oData.id)
	end
end

return CRedPacketWorldPart