local CEcononmyAuctionPart = class("CEcononmyAuctionPart", CPageBase)

function CEcononmyAuctionPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CEcononmyAuctionPart.OnInitPage(self)
	self.m_AuctionItemListBox = self:NewUI(1, CEcononmyAuctionItemListBox)
	self.m_BidBtn = self:NewUI(2, CButton)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_BidCheckBox = {
		[define.Econonmy.AuctionBid.Auto] = self:NewUI(4, CWidget),
		[define.Econonmy.AuctionBid.NonAuto] = self:NewUI(5, CWidget),
	}
	self.m_MarkupBox = self:NewUI(6, CCurrencyBox)
	self.m_TimesBox = self:NewUI(7, CAmountSettingBox)
	self.m_CostBox = self:NewUI(8, CCurrencyBox)
	self.m_OwnCurrencyBox = self:NewUI(9, CCurrencyBox)

	g_EcononmyCtrl.m_IsOpenAuctionUI = true
	self.m_MarkupPrice = 0
	self.m_AuctionInfo = nil
	self:InitContent()
end

function CEcononmyAuctionPart.InitContent(self)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTipsView"))
	self.m_BidBtn:AddUIEvent("click", callback(self, "OnClickBid"))
	self.m_BidCheckBox[1]:AddUIEvent("click", callback(self, "OnSwitchBidType", define.Econonmy.AuctionBid.Auto))
	self.m_BidCheckBox[2]:AddUIEvent("click", callback(self, "OnSwitchBidType", define.Econonmy.AuctionBid.NonAuto))
	self.m_AuctionItemListBox:SetClickCallback(callback(self, "OnItemChange"))
	self.m_TimesBox:SetCallback(callback(self, "OnValueChange"))

	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CEcononmyAuctionPart.OnShowPage(self)
	netauction.C2GSOpenAuction(0, 0, 1)
	g_EcononmyCtrl:RefreshAuctionNotify(false)
end

function CEcononmyAuctionPart.OnCtrlEvent(self, oCtrl)
	-- TODO:test
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionItemList then
		self:RefreshAuctionItemList()
	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionItem then
		self:RefreshAuctionItem(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionPrice then
		self:RefreshAuctionItem(oCtrl.m_EventData, true)
	end
end

function CEcononmyAuctionPart.RefreshAuctionItemList(self)
	self.m_AuctionItemListBox:RefreshAll()
end

function CEcononmyAuctionPart.RefreshAuctionItem(self, dAuctionInfo, bRefreshPrice)
	if not dAuctionInfo then
		return
	end
	self.m_AuctionItemListBox:UpdateAuctionItemById(dAuctionInfo.id, dAuctionInfo, bRefreshPrice)
end

function CEcononmyAuctionPart.RefreshAll(self)
	self:RefreshMoneyType()
	self:RefreshBidSetting()
end

function CEcononmyAuctionPart.RefreshMoneyType(self)
	local iMoneyType = self.m_AuctionInfo and self.m_AuctionInfo.money_type or define.Currency.Type.Gold
	self.m_MarkupBox:SetCurrencyType(iMoneyType, true)
	self.m_CostBox:SetCurrencyType(iMoneyType, true)
	self.m_OwnCurrencyBox:SetCurrencyType(iMoneyType)
end

function CEcononmyAuctionPart.RefreshBidSetting(self)
	if not self.m_AuctionInfo then
		self.m_MarkupBox:SetCurrencyCount(0)
		self.m_TimesBox:SetValue(0)
		self.m_TimesBox:SetAmountRange(0, 0)
		self.m_CostBox:SetCurrencyCount(0)
		self.m_OwnCurrencyBox:SetWarningValue(-1)
		return
	end

	if not g_EcononmyCtrl:IsInAuctionTime(self.m_AuctionInfo) or 
		g_EcononmyCtrl:IsUseProxy(self.m_AuctionInfo) then
		self:OnSwitchBidType(define.Econonmy.AuctionBid.Auto)
	else
		self:OnSwitchBidType(define.Econonmy.AuctionBid.NonAuto)
	end
	self.m_MarkupBox:SetCurrencyCount(self.m_MarkupPrice)
	if self.m_RefreshPrice then
		self.m_RefreshPrice = false
		self:RefreshCost(self.m_TimesBox:GetValue())
	else
		self.m_TimesBox:SetValue(1)
		self.m_TimesBox:SetAmountRange(1, 999999)
		self:RefreshCost(1)
	end
end

function CEcononmyAuctionPart.RefreshCost(self, iTimes)
	if not self.m_AuctionInfo then
		return
	end
	local iAutionPrice = self.m_AuctionInfo.price
	local iCostPrice = iAutionPrice + self.m_MarkupPrice * iTimes
	self.m_CostBox:SetCurrencyCount(iCostPrice)
	self.m_OwnCurrencyBox:SetWarningValue(iCostPrice)
end

--------------------------------UI Click Event or Listener--------------------------------------
function CEcononmyAuctionPart.OnValueChange(self, iValue)
	self:RefreshCost(iValue)
end

function CEcononmyAuctionPart.OnItemChange(self, oBox, bRefreshPrice)
	self.m_AuctionInfo = oBox and oBox.m_AuctionInfo or nil
	self.m_MarkupPrice = oBox and oBox.m_MarkupPrice or 0
	self.m_AuctionItemName = oBox and oBox.m_Name or ""
	self.m_RefreshPrice = bRefreshPrice
	self:RefreshAll()
end

function CEcononmyAuctionPart.OnClickBid(self)
	local dText = data.auctiondata.TEXT
	if not self.m_AuctionInfo then
		g_NotifyCtrl:FloatMsg(dText[8003].content)
		return
	end
	local iPrice = self.m_CostBox:GetCurrencyCount()
	if self.m_CostBox.m_CurrencyType == define.Currency.Type.Gold then
		if iPrice > g_AttrCtrl.gold then
			g_NotifyCtrl:FloatMsg("金币不足，请购买")
			self.m_CostBox:OpenCurrencyView()
			return
		end
	else
		if iPrice > g_AttrCtrl.goldcoin then
			g_NotifyCtrl:FloatMsg("元宝不足，请购买")
			self.m_CostBox:OpenCurrencyView()
			return
		end
	end
	
	--TODO:请求拍卖或申请代理
	self:ShowAuctionComfirmWindow()
end

function CEcononmyAuctionPart.OnSwitchBidType(self, iType)
	if not self.m_AuctionInfo then
		return
	end
	local bSwichNon = iType == define.Econonmy.AuctionBid.NonAuto
	if bSwichNon then
		if not g_EcononmyCtrl:IsInAuctionTime(self.m_AuctionInfo) then
			g_NotifyCtrl:FloatMsg("开始拍卖前只能设置自动出价")
			self:OnSwitchBidType(define.Econonmy.AuctionBid.Auto)
			return
		elseif g_EcononmyCtrl:IsUseProxy(self.m_AuctionInfo) then
			g_NotifyCtrl:FloatMsg("已经设置自动出价")
			self:OnSwitchBidType(define.Econonmy.AuctionBid.Auto)
			return
		end
	end
	self.m_BidCheckBox[iType]:ForceSelected(true)
	self.m_CurBidType = iType
end

function CEcononmyAuctionPart.ShowTipsView(self)
	local id = define.Instruction.Config.Auction
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CEcononmyAuctionPart.ShowAuctionComfirmWindow(self)
	local cointype = {
		[define.Currency.Type.GoldCoin] = "#cur_1", 
		[define.Currency.Type.Gold] = "#cur_3"}

	local iPrice = self.m_CostBox:GetCurrencyCount()
	local sContent = data.auctiondata.TEXT[8002].content
	local sMsg = string.gsub(sContent, "#item", self.m_AuctionItemName)
	sMsg = string.gsub(sMsg, "#amount", cointype[self.m_AuctionInfo.money_type]..iPrice)
	local windowConfirmInfo = {
		msg				= sMsg,
		okCallback		= function ()
			local iAutionId = self.m_AuctionInfo.id
			if self.m_CurBidType == define.Econonmy.AuctionBid.Auto then
				netauction.C2GSSetProxyPrice(iAutionId, iPrice)
			else
				netauction.C2GSAuctionBid(iAutionId, iPrice)
			end
		end,
		okStr			= "确定",
		cancelStr		= "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end
return CEcononmyAuctionPart