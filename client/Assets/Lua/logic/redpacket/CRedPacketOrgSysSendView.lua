local CRedPacketOrgSysSendView = class("CRedPacketOrgSysSendView", CViewBase)

function CRedPacketOrgSysSendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketOrgSysSendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketOrgSysSendView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescInput = self:NewUI(2, CSprite)
	self.m_MoneyBtn = self:NewUI(3, CWidget)
	self.m_MoneyValueLbl = self:NewUI(4, CLabel)
	self.m_ConvertLbl = self:NewUI(5, CLabel)
	self.m_SubBtn = self:NewUI(6, CButton)
	self.m_AddBtn = self:NewUI(7, CButton)
	self.m_RandomBtn = self:NewUI(8, CButton)
	self.m_NumBtn = self:NewUI(9, CWidget)
	self.m_NumValueLbl = self:NewUI(10, CLabel)
	self.m_SendBtn = self:NewUI(11, CButton)
	self.m_TagLbl = self:NewUI(12, CLabel)
	self.m_BlessLbl = self:NewUI(13, CLabel)
	self.m_SelectBtn = self:NewUI(14, CButton)
	self.m_AddValueLbl = self:NewUI(15, CLabel)


	self.m_SysIndex = 1
	self.m_SysData = nil --todo
	self.m_CurMoney = 0
	g_RedPacketCtrl.m_SysAddMoney = 0
	self.m_AddMoney = 0
	
	self:InitContent()
end

function CRedPacketOrgSysSendView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MoneyBtn:AddUIEvent("click", callback(self, "OnClickChangeMoney"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSend"))
	self.m_SelectBtn:AddUIEvent("click", callback(self, "OnClickChangeMoney"))
	self.m_DescInput:AddUIEvent("change", callback(self, "OnInputChange"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

end

function CRedPacketOrgSysSendView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.SysMoneyAdd then
		self:RefreshUI(self.m_SysData, self.m_SysIndex)
	end
end

--#cur_1 元宝 #cur_2 绑定元宝 #cur_3 金币 #cur_4 银币
function CRedPacketOrgSysSendView.RefreshUI(self, oData, index)
	self.m_SysIndex = index
	self.m_SysData = oData
	self.m_SysConfig = data.redpacketdata.SYSREDPACKET[oData]
	local convertBase = 0
	local iconStr = "#cur_3"
	if g_RedPacketCtrl:GetConvertType(self.m_SysConfig.cashtype) == 1 then
		convertBase = define.RedPacket.Convert.GoldCoinToGold
		iconStr = "#cur_3"
	else
		convertBase = g_RedPacketCtrl:GetGoldIconToSilverBase()
		iconStr = "#cur_4"
	end
	self.m_CurMoney = self.m_SysConfig.goldcoin + g_RedPacketCtrl.m_SysAddMoney

	self.m_DescText = self.m_SysConfig.bless
	self.m_BlessLbl:SetText(self.m_DescText)
	
	self.m_MoneyValueLbl:SetText(self.m_CurMoney)
	self.m_TagLbl:SetText("#cur_1")
	if self.m_AddMoney > 0 then
		self.m_AddValueLbl:SetText("+"..self.m_AddMoney)
	end
	local totalMoney = self.m_CurMoney + self.m_AddMoney
	self.m_ConvertLbl:SetText((iconStr..totalMoney*convertBase)) --"将转换为:"..
	self.m_NumValueLbl:SetText(self.m_SysConfig.count)
end

----------------以下是点击事件---------------

function CRedPacketOrgSysSendView.OnClickChangeMoney(self)
	CRedPacketSelectMoneyView:ShowView(function (oView)
		local oAddList = {}
		for k,v in ipairs(data.redpacketdata.GLOBAL[1].sel_money) do
			table.insert(oAddList, v*self.m_SysConfig.goldcoin)
		end
		oView:RefreshUI(oAddList, "红包增加金额", function (oMoney)
			self.m_AddMoney = oMoney
		end)
	end)
end

function CRedPacketOrgSysSendView.OnClickSend(self)
	if g_MaskWordCtrl:IsContainMaskWord(self.m_DescText) then
		g_NotifyCtrl:FloatMsg(data.redpacketdata.TEXT[define.RedPacket.Text.LimitTip].content)
		return
	end
	netredpacket.C2GSActiveSendSYS(self.m_SysIndex, self.m_AddMoney, self.m_DescText)
	self:CloseView()
end

function CRedPacketOrgSysSendView.OnInputChange(self)
    if self.m_DescInput.m_UIInput then
		self.m_DescText = self.m_DescInput.m_UIInput.value
	end
end

return CRedPacketOrgSysSendView