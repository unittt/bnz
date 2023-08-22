local CRedPacketOrgPart = class("CRedPacketOrgPart", CPageBase)

function CRedPacketOrgPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TipsBtn = self:NewUI(1, CButton)
	self.m_HistroyBtn = self:NewUI(2, CButton)
	self.m_SendBtn = self:NewUI(3, CButton)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_Grid = self:NewUI(5, CGrid)
	self.m_BoxClone = self:NewUI(6, CBox)
	self.m_EmptyGo = self:NewUI(7, CObject)
	self.m_EmptyLbl = self:NewUI(8, CLabel)
	self.m_SysScrollView = self:NewUI(9, CScrollView)
	self.m_SysGrid = self:NewUI(10, CGrid)
	self.m_SysClone = self:NewUI(11, CBox)
	self:InitContent()
end

function CRedPacketOrgPart.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_SysClone:SetActive(false)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	self.m_HistroyBtn:AddUIEvent("click", callback(self, "OnClickHistroy"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSend"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CRedPacketOrgPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.RefreshOrgRedPacket then
		self:RefreshUI(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.RedPacket.Event.RefreshMainUI then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.RedPacket.Event.DeleteRedPacket then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.RedPacket.Event.UpdateSysRedPacket then
		self:SetSysRedPacketList()
	end
end

function CRedPacketOrgPart.RefreshUI(self, pbdata)
	if next(g_RedPacketCtrl.m_RedPacketViewList) then
		self.m_EmptyGo:SetActive(false)
		self.m_ScrollView:SetActive(true)
	else
		self.m_EmptyGo:SetActive(true)
		local isSelfHasOrg = (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0)
		if not isSelfHasOrg then
			self.m_EmptyLbl:SetText("加入帮派后才能领取帮派红包！快去加入帮派吧！")
		else
			self.m_EmptyLbl:SetText(data.redpacketdata.TEXT[define.RedPacket.Text.NoOrgRedPacket].content)
		end
		self.m_ScrollView:SetActive(false)
	end

	self:SetRedPacketList()
	self:SetSysRedPacketList()
end

function CRedPacketOrgPart.SetRedPacketList(self)
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

function CRedPacketOrgPart.SetRedPacketBox(self, oRedPacket, oData)
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

function CRedPacketOrgPart.SetSysRedPacketList(self)
	local optionCount = #g_RedPacketCtrl.m_RedPacketOrgSysList
	local GridList = self.m_SysGrid:GetChildList() or {}
	local oRedPacket
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRedPacket = self.m_SysClone:Clone(false)
				-- self.m_SysGrid:AddChild(oOptionBtn)
			else
				oRedPacket = GridList[i]
			end
			self:SetSysRedPacketBox(oRedPacket, g_RedPacketCtrl.m_RedPacketOrgSysList[i], i)
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

	self.m_SysGrid:Reposition()
	self.m_SysScrollView:ResetPosition()
end

function CRedPacketOrgPart.SetSysRedPacketBox(self, oRedPacket, oData, index)
	oRedPacket:SetActive(true)
	oRedPacket.m_NameLbl = oRedPacket:NewUI(1, CLabel)
	oRedPacket.m_ValueLbl = oRedPacket:NewUI(2, CLabel)

	local config = data.redpacketdata.SYSREDPACKET[oData]
	oRedPacket.m_NameLbl:SetText(string.gettitle(config.name, 12, "..."))
	local convertBase = 0
	local iconStr = "#cur_3"
	if g_RedPacketCtrl:GetConvertType(config.cashtype) == 1 then
		convertBase = define.RedPacket.Convert.GoldCoinToGold
		iconStr = "#cur_3"
	else
		convertBase = g_RedPacketCtrl:GetGoldIconToSilverBase()
		iconStr = "#cur_4"
	end
	oRedPacket.m_ValueLbl:SetText("#cur_1"..config.goldcoin)--(iconStr..config.goldcoin*convertBase)

	oRedPacket:AddUIEvent("click", callback(self, "OnClickSysRedPacket", oData, index))

	self.m_SysGrid:AddChild(oRedPacket)
	self.m_SysGrid:Reposition()
end

----------------以下是点击事件-----------------

function CRedPacketOrgPart.OnClickTips(self)
	local zId = define.Instruction.Config.RedPacket
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CRedPacketOrgPart.OnClickHistroy(self)
	netredpacket.C2GSQueryHistory()
end

function CRedPacketOrgPart.OnClickSend(self)
	-- g_RedPacketCtrl.m_SelectSendChannel = define.RedPacket.Channel.Org
	-- CRedPacketSendView:ShowView()
	CRedPacketMainView:CloseView()
	COrgInfoView:CloseView()
	CRedPacketSendSelectView:ShowView()
end

--oData.valid 1 可领取
function CRedPacketOrgPart.OnClickGetRedPacket(self, oData)
	if oData.valid == 1 then
		netredpacket.C2GSRobRP(oData.id)
	else
		netredpacket.C2GSQueryBasic(oData.id)
	end
end

function CRedPacketOrgPart.OnClickSysRedPacket(self, oData, index)
	CRedPacketOrgSysSendView:ShowView(function (oView)
		oView:RefreshUI(oData, index)
	end)
end

return CRedPacketOrgPart