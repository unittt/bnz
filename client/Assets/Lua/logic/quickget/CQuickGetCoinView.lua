local CQuickGetCoinView = class("CQuickGetCoinView", CViewBase)

function CQuickGetCoinView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/QuickGet/QuickGetCoinView.prefab", cb)
	self.m_CoinData = nil
	self.m_LackCoinList = {}
	self.m_CostCash = nil
	self.m_ExtendClose = "Pierce" --ClickOut, Black, Shelter
	self.m_DepthType = "Dialog"
end

function CQuickGetCoinView.OnCreateView(self)
	-- body
	self.m_SureBtn     = self:NewUI(1, CButton)
	self.m_ExchangeLab = self:NewUI(2, CLabel)
	self.m_DesLabel    = self:NewUI(3, CLabel)
	self.m_CoinSpr     = self:NewUI(4, CSprite)
	self.m_AmountLab   = self:NewUI(5, CLabel)
	self.m_TipsLab     = self:NewUI(6, CLabel)
	self.m_CloseBtn    = self:NewUI(7, CButton)
	self.m_TipInfo     = self:NewUI(8, CWidget)
	self:InitContent()
end

function CQuickGetCoinView.InitContent(self)
	self.m_SureBtn:AddUIEvent("click", callback(self, "SendMsg"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipInfo:AddUIEvent("click", callback(self, "OnTip"))
end

--服务器计算兑换消耗
function CQuickGetCoinView.SetInfo(self, info)
	
	local moneyId = info.moneyId
	local goldcoin = info.goldcoin
	local moneyvalue = info.moneyvalue
	local exchangemoneyvalue = info.exchangemoneyvalue
	local cb = info.cb
	local itemdata = DataTools.GetItemData(moneyId)
	self.m_DesLabel:SetText(itemdata.name.."不足，还差")
	self.m_CoinSpr:SetSpriteName(itemdata.icon)
	self.m_AmountLab:SetText(moneyvalue)
	self.m_TipsLab:SetText("是否使用".. tostring(goldcoin) .."元宝代替(额外兑换的".. tostring(exchangemoneyvalue - moneyvalue) .. itemdata.name .."会自动返还)")
	self.m_ExchangeLab:SetText("使用元宝#cur_2".. tostring(goldcoin))
	self.SendMsg = function ( ... )
		if cb then 
			cb()
		end
		self:OnClose() 
	end

end

function CQuickGetCoinView.InitCoinInfo(self, itemlist)
	self.m_CoinData = itemlist[1]
	table.remove(itemlist, 1)
	self.m_LackCoinList = itemlist
	local exratio = data.storedata.EXCHANGEMONEY[3]
	local itemdata = DataTools.GetItemData(self.m_CoinData.sid)
	self.m_DesLabel:SetText(itemdata.name.."不足，还差")
	self.m_CoinSpr:SetSpriteName(itemdata.icon)
	local value = self.m_CoinData.amount - self.m_CoinData.count
	self.m_AmountLab:SetText(value)

	local str = nil
	if self.m_CoinData.sid == 1001 then --金币
		str = string.gsub(exratio.gold, "value", 1) 
	elseif  self.m_CoinData.sid == 1002 then--银币
		str = string.gsub(exratio.silver, "SLV", g_AttrCtrl.server_grade) 
		str = string.gsub(str, "value", 1)
	elseif self.m_CoinData.sid == 1003 then --元宝
		str = "1"
	elseif self.m_CoinData.sid == 1004 then --绑定元宝
		str = "1"
	end
	local func = loadstring("return " .. str)
	local divisor =  func() --比例
	local quotient = math.ceil(value / divisor)
	local remainder = quotient*divisor - value
	self.m_CostCash = quotient
	if self.m_CoinData.sid~=1003 then
		self.m_TipsLab:SetText("是否使用"..quotient.."元宝代替(额外兑换的"..remainder..itemdata.name.."会自动返还)")
		if g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin >=  self.m_CostCash then
			self.m_ExchangeLab:SetText("使用元宝#cur_2"..self.m_CostCash)
		else
			self.m_ExchangeLab:SetText("使用元宝#cur_2#R"..self.m_CostCash.."#n")
		end
	else
		self:QuickGetCB()
		self:CloseView()
	end
end

function CQuickGetCoinView.SendMsg(self)
 	if self.m_CoinData.sid ~= 1003 then
 		if g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin <  self.m_CostCash then
			self:QuickGetCB()
			self:OnClose()
			return
 		end
 		local type = nil
 		if self.m_CoinData.sid == 1001 then
 			type = 1
 		elseif self.m_CoinData.sid == 1002 then
 			type = 2
 		end
		g_QuickGetCtrl:C2GSExchangeCash(type, self.m_CostCash)
		if self.m_ExchangeCallback then
			self.m_ExchangeCallback()
		end
		self:OnClose()
	else
		self:QuickGetCB()
		return
	end
end



function CQuickGetCoinView.QuickGetCB(self)
	g_QuickGetCtrl:OnShowNotEnoughGoldCoin()
	self:CloseView()
end

function CQuickGetCoinView.OnClose(self)
	if next(self.m_LackCoinList) then
		self:InitCoinInfo(self.m_LackCoinList)
	else
		g_QuickGetCtrl.m_IsLackItem = false
		self:CloseView()
	end
end

function CQuickGetCoinView.SetExchangeCallback(self, cb)
	-- body
	self.m_ExchangeCallback = cb
end

function CQuickGetCoinView.OnTip(self)
	local Id = define.Instruction.Config.QuickExChange
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
			 title = data.instructiondata.DESC[Id].title,
		 	 desc = data.instructiondata.DESC[Id].desc
			}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end

end

return CQuickGetCoinView