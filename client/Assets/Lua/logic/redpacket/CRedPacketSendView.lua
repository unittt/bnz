local CRedPacketSendView = class("CRedPacketSendView", CViewBase)

function CRedPacketSendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketSendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketSendView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescInput = self:NewUI(2, CInput)
	self.m_MoneyBtn = self:NewUI(3, CWidget)
	self.m_MoneyValueLbl = self:NewUI(4, CLabel)
	self.m_ConvertLbl = self:NewUI(5, CLabel)
	self.m_SubBtn = self:NewUI(6, CButton)
	self.m_AddBtn = self:NewUI(7, CButton)
	self.m_RandomBtn = self:NewUI(8, CButton)
	self.m_NumBtn = self:NewUI(9, CWidget)
	self.m_NumValueLbl = self:NewUI(10, CLabel)
	self.m_OrgBtn = self:NewUI(11, CButton)
	self.m_WorldBtn = self:NewUI(12, CButton)
	self.m_SendBtn = self:NewUI(13, CButton)
	self.m_TagLbl = self:NewUI(14, CLabel)
	self.m_SelectMoneyBtn = self:NewUI(15, CButton)
	self.m_TitleLbl = self:NewUI(16, CLabel)

	self.m_DescText = data.redpacketdata.TEXT[define.RedPacket.Text.DefaultName].content
	self.m_CurNum = 0
	self.m_CurMaxNum = 0
	self.m_CurMinNum = 0
	self.m_CurMoney = 0

	self:InitContent()
end

function CRedPacketSendView.InitContent(self)
	-- g_RedPacketCtrl.m_SelectSendChannel = define.RedPacket.Channel.World

	self.m_OrgBtn:SetGroup(self:GetInstanceID())
	self.m_WorldBtn:SetGroup(self:GetInstanceID())
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_WorldBtn:AddUIEvent("click", callback(self, "OnClickSelectChannel", define.RedPacket.Channel.World))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickSelectChannel", define.RedPacket.Channel.Org))	
	self.m_SubBtn:AddUIEvent("click", callback(self, "OnClickSubNum"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddNum"))
	self.m_RandomBtn:AddUIEvent("click", callback(self, "OnClickRandomNum"))
	self.m_MoneyBtn:AddUIEvent("click", callback(self, "OnClickChangeMoney"))
	self.m_SelectMoneyBtn:AddUIEvent("click", callback(self, "OnClickChangeMoney"))
	-- self.m_NumBtn:AddUIEvent("click", callback(self, "OnClickChangeNum"))
	self.m_DescInput:AddUIEvent("change", callback(self, "OnInputChange"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSend"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self:RefreshUI()
end

function CRedPacketSendView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.SysMoneyAdd then
		self.m_MoneyValueLbl:SetText(self.m_CurMoney)
		self.m_TagLbl:SetText("#cur_2")
		self.m_ConvertLbl:SetText(("#cur_3"..self.m_CurMoney*define.RedPacket.Convert.GoldCoinToGold)) --"将转换为:"..

		self:SetMinAndMaxNumByMoney(self.m_CurMoney)
		self:CheckNumUIState()
	end
end

--#cur_1 元宝 #cur_2 绑定元宝 #cur_3 金币 #cur_4 银币
function CRedPacketSendView.RefreshUI(self)
	-- self.m_CurNum = data.redpacketdata.PERSONNUM[1].min
	-- self.m_CurMaxNum = data.redpacketdata.PERSONNUM[1].max
	-- self.m_CurMinNum = data.redpacketdata.PERSONNUM[1].min
	self.m_CurMoney = data.redpacketdata.PERSONNUM[1].range

	self.m_MoneyValueLbl:SetText(self.m_CurMoney)
	self.m_TagLbl:SetText("#cur_2")
	self.m_ConvertLbl:SetText(("#cur_3"..self.m_CurMoney*define.RedPacket.Convert.GoldCoinToGold)) --"将转换为:"..
	self:SetMinAndMaxNumByMoney(self.m_CurMoney)
	self:CheckNumUIState()

	self:CheckChannelUIState()

	self:CheckSendRedPacketType()
end

function CRedPacketSendView.CheckNumUIState(self)
	if self.m_CurNum >= self.m_CurMaxNum then
		self.m_CurNum = self.m_CurMaxNum

		self.m_AddBtn:SetGrey(true)
		self.m_AddBtn:GetComponent(classtype.BoxCollider).enabled = false
	else
		self.m_AddBtn:SetGrey(false)
		self.m_AddBtn:GetComponent(classtype.BoxCollider).enabled = true
	end
	if self.m_CurNum <= self.m_CurMinNum then
		self.m_CurNum = self.m_CurMinNum

		self.m_SubBtn:SetGrey(true)
		self.m_SubBtn:GetComponent(classtype.BoxCollider).enabled = false
	else
		self.m_SubBtn:SetGrey(false)
		self.m_SubBtn:GetComponent(classtype.BoxCollider).enabled = true
	end
	self.m_NumValueLbl:SetText(self.m_CurNum)
end

function CRedPacketSendView.CheckChannelUIState(self)
	if g_RedPacketCtrl.m_SelectSendChannel == define.RedPacket.Channel.World then
		self.m_WorldBtn:SetSelected(true)
	else
		self.m_OrgBtn:SetSelected(true)
	end
end

function CRedPacketSendView.GetPersonsumConfig(self, idx)
	return data.redpacketdata.PERSONNUM[idx]
end

function CRedPacketSendView.SetMinAndMaxNumByMoney(self, money)
	if money > data.redpacketdata.PERSONNUM[#data.redpacketdata.PERSONNUM].range then
		self.m_CurMinNum = data.redpacketdata.PERSONNUM[#data.redpacketdata.PERSONNUM].min
		self.m_CurMaxNum = data.redpacketdata.PERSONNUM[#data.redpacketdata.PERSONNUM].max
		self.m_CurNum = self.m_CurMinNum
	else
		local minRange = 0
		local maxRange = 0
		for k,v in ipairs(data.redpacketdata.PERSONNUM) do
			if k == 1 then
				minRange = 0
				maxRange = v.range
				if money >= minRange and money <= maxRange then
					self.m_CurMinNum = v.min
					self.m_CurMaxNum = v.max
					self.m_CurNum = self.m_CurMinNum
					break
				end
			else
				minRange = data.redpacketdata.PERSONNUM[k-1].range + 1
				maxRange = v.range
				if money >= minRange and money <= maxRange then
					self.m_CurMinNum = v.min
					self.m_CurMaxNum = v.max
					self.m_CurNum = self.m_CurMinNum
					break
				end
			end
		end
	end
end

function CRedPacketSendView.CheckSendRedPacketType(self)
	if g_RedPacketCtrl.m_SelectSendChannel == define.RedPacket.Channel.World then
		self.m_TitleLbl:SetText("世界红包")
	else
		self.m_TitleLbl:SetText("帮派红包")
	end
end

----------------以下是点击事件---------------

function CRedPacketSendView.OnClickSelectChannel(self, iChannel)
	g_RedPacketCtrl.m_SelectSendChannel = iChannel

	if iChannel == define.RedPacket.Channel.World then
	else
	end
end

function CRedPacketSendView.OnClickSubNum(self)
	self.m_CurNum = self.m_CurNum - 1
	self:CheckNumUIState()
end

function CRedPacketSendView.OnClickAddNum(self)
	self.m_CurNum = self.m_CurNum + 1
	self:CheckNumUIState()
end

function CRedPacketSendView.OnClickRandomNum(self)
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	self.m_CurNum = math.random(self.m_CurMinNum, self.m_CurMaxNum)
	self:CheckNumUIState()
end

function CRedPacketSendView.OnClickChangeMoney(self)
	CRedPacketSelectMoneyView:ShowView(function (oView)
		local list = {}
		for k,v in ipairs(data.redpacketdata.PERSONNUM) do
			table.insert(list, v.range)
		end
		oView:RefreshUI(list, "红包金额", function (oMoney)
			if Utils.IsNil(self) then
				return
			end
			self.m_CurMoney = oMoney
			self:SetMinAndMaxNumByMoney(self.m_CurMoney)
			self:CheckNumUIState()
		end)
	end)
end

function CRedPacketSendView.OnClickChangeNum(self)
	local function keycallback(oView)
		self.m_CurNum = oView:GetNumber()
		self:CheckNumUIState()
	end
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_NumValueLbl, keycallback, nil, nil, self.m_CurMinNum, self.m_CurMaxNum)
	end)
end

function CRedPacketSendView.OnInputChange(self)
	self.m_DescText = self.m_DescInput.m_UIInput.value
end

function CRedPacketSendView.OnClickSend(self)
	if g_MaskWordCtrl:IsContainMaskWord(self.m_DescText) then
		g_NotifyCtrl:FloatMsg(data.redpacketdata.TEXT[define.RedPacket.Text.LimitTip].content)
		return
	end
	netredpacket.C2GSSendRP(self.m_DescText, self.m_CurMoney, self.m_CurNum, g_RedPacketCtrl.m_SelectSendChannel)
	self:CloseView()
end

return CRedPacketSendView