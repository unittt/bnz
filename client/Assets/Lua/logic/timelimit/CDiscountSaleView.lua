local CDiscountSaleView = class("CDiscountSaleView", CViewBase)

function CDiscountSaleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Timelimit/DiscountSaleView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CDiscountSaleView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SaleScroll = self:NewUI(2, CScrollView)
	self.m_SaleGrid = self:NewUI(3, CGrid)
	self.m_GoodsBoxClone = self:NewUI(4, CBox)
	self.m_TipsBtn = self:NewUI(5, CButton)

	self:InitContent()
end

function CDiscountSaleView.InitContent(self)
	self.m_GoodsBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTipsView"))
	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimeLimitCtrlEvent"))

	self:RefreshAll(true)
end

function CDiscountSaleView.OnTimeLimitCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshDiscountSale then
		self:RefreshAll(false)
	end
end

function CDiscountSaleView.RefreshAll(self, bResetScrll)
	self:RefreshSaleGrid(bResetScrll)
end

function CDiscountSaleView.RefreshSaleGrid(self, bResetScrll)
	local list = data.huodongdata.DISCOUNT_GOODS
	local oSelBox = nil
	for i,dData in ipairs(list) do
		local oBox = self.m_SaleGrid:GetChild(i)
		local dInfo = g_TimelimitCtrl.m_DiscountSaleInfo[i]
		if not oBox then
			oBox = self:CreateGoodsBox()
			self.m_SaleGrid:AddChild(oBox)
		end
		self:RefreshGoodsBox(oBox, dInfo, dData, i)
		if oBox.m_RemainTime and oBox.m_RemainTime > 1 then
			oSelBox = oBox
		end
	end
	self.m_SaleGrid:Reposition()
	if bResetScrll and oSelBox ~= nil then
		UITools.MoveToTarget(self.m_SaleScroll, oSelBox)
	end
end

function CDiscountSaleView.CreateGoodsBox(self)
	local oBox = self.m_GoodsBoxClone:Clone()
	oBox.m_GetSpr = oBox:NewUI(1, CSprite)
	oBox.m_DayL = oBox:NewUI(2, CLabel)
	oBox.m_OvertimeL = oBox:NewUI(3, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(4, CGrid)
	oBox.m_ItemBoxClone = oBox:NewUI(5, CBox)
	oBox.m_BuyBtn = oBox:NewUI(6, CButton)
	oBox.m_UnableBuyBtn = oBox:NewUI(7, CButton)
	oBox.m_RealPriceL = oBox:NewUI(8, CLabel)

	oBox.m_ItemBoxClone:SetActive(false)
	return oBox
end

function CDiscountSaleView.RefreshGoodsBox(self, oBox, dInfo, dData, iDay)
	oBox:SetActive(true)
	-- 过期 已购   再期 未到
	local bInDiscount, iRemainTime, iOpenLeftTime = g_TimelimitCtrl:IsInDiscountTime(iDay)
	local bIsSale = dInfo.status == 1
	local bIsWaitingUnLock = bInDiscount and iRemainTime == 0
	local bIsWaitingBuy = not bIsSale and bInDiscount and iRemainTime > 0
	local bIsOverTime = not bIsSale and not bInDiscount

	oBox.m_RemainTime = iRemainTime + 1
	oBox.m_OpenLeftTime = iOpenLeftTime + 1
	oBox.m_DayL:SetText(string.format("第%s重", string.number2text(iDay)))
	-- oBox.m_DaySpr:SetGrey(not bInDiscount or bIsSale)

	oBox.m_OvertimeL:SetActive(bIsWaitingBuy or iOpenLeftTime > 0)
	oBox.m_BuyBtn:SetActive(bIsWaitingBuy)
	oBox.m_RealPriceL:SetActive(bIsWaitingBuy)
	oBox.m_UnableBuyBtn:SetActive(not bIsWaitingBuy)
	--TODO:缺已过期的美术资源，先隐藏
	-- oBox.m_GetSpr:SetActive(bIsSale)
	oBox.m_GetSpr:SetActive(false)

	if bIsWaitingUnLock then
		oBox.m_UnableBuyBtn:SetText("购买")
	elseif bIsOverTime then
		oBox.m_UnableBuyBtn:SetText("已过期")
	else
		oBox.m_UnableBuyBtn:SetText("已购买")
	end

	if bIsWaitingBuy then
		oBox.m_RealPriceL:SetText("原价："..dData.price.."#cur_2")
		oBox.m_BuyBtn:SetText(dData.discount_price.."#cur_2购买")
		oBox.m_OvertimeL:SetText(g_TimeCtrl:GetLeftTime(iRemainTime, true).."后过期")
		self:RefreshRemainTime(oBox)
	end

	if iOpenLeftTime > 0 then
		self:RefreshRemainTime(oBox, true)
	end

	self:RefreshItemGrid(oBox, dData, bIsOverTime, bIsSale)

	oBox.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuy", iDay, bIsOverTime, bIsWaitingUnLock, bIsSale, dData.discount_price))
	oBox.m_UnableBuyBtn:AddUIEvent("click", callback(self, "OnClickBuy", iDay, bIsOverTime, bIsWaitingUnLock, bIsSale))
end

function CDiscountSaleView.RefreshItemGrid(self, oBox, dData, bIsOverTime, bIsSale)
	local oItemGrid = oBox.m_ItemGrid
	for i,v in ipairs(dData.goods_show) do
		local oItemBox = oItemGrid:GetChild(i)
		if not oItemBox then
			oItemBox = self:CreateItemBox(oBox.m_ItemBoxClone)
			oItemGrid:AddChild(oItemBox)
		end
		self:RefreshItemBox(oItemBox, v.sid, v.num, bIsSale, bIsOverTime)
	end
	oItemGrid:Reposition()
end

function CDiscountSaleView.CreateItemBox(self, oBox)
	local oItemBox = oBox:Clone()
	oItemBox.m_IconSpr = oItemBox:NewUI(1, CSprite)
	oItemBox.m_CountL = oItemBox:NewUI(2, CLabel)
	oItemBox.m_QualitySpr = oItemBox:NewUI(3, CSprite)
	oItemBox.m_GainSpr = oItemBox:NewUI(4, CSprite)
	oItemBox:SetActive(true)
	return oItemBox
end

function CDiscountSaleView.RefreshItemBox(self, oItemBox, iItemId, iCount, bIsSale, bIsOverTime)
	local dItem = DataTools.GetItemData(iItemId)
	oItemBox.m_QualitySpr:SetItemQuality(dItem.quality)
	oItemBox.m_IconSpr:SpriteItemShape(dItem.icon)
	oItemBox.m_CountL:SetText(iCount)
	oItemBox.m_GainSpr:SetActive(bIsSale)
	oItemBox.m_IconSpr:SetGrey(bIsOverTime or bIsSale)
	oItemBox:AddUIEvent("click", callback(self, "ShowItemTips", iItemId, oItemBox))
end

function CDiscountSaleView.RefreshRemainTime(self, oBox, bIsWaitingUnLock)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local function update()
		if bIsWaitingUnLock then
			printc(oBox.m_OpenLeftTime)
			if oBox.m_OpenLeftTime < 0 then
				self:RefreshAll(false)
				return false
			end
			oBox.m_OpenLeftTime = oBox.m_OpenLeftTime - 1
			if oBox.m_OpenLeftTime >= 0 then
				oBox.m_OvertimeL:SetText(g_TimeCtrl:GetLeftTime(oBox.m_OpenLeftTime, true).."后开启")
			end
			return true
		end
		if oBox.m_RemainTime < 0 then
			self:RefreshAll(false)
			return false
		end
		oBox.m_RemainTime = oBox.m_RemainTime - 1
		if oBox.m_RemainTime >= 0 then
			oBox.m_OvertimeL:SetText(g_TimeCtrl:GetLeftTime(oBox.m_RemainTime, true).."后过期")
		end
		return true
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CDiscountSaleView.OnClickBuy(self, iDay, bIsOverTime, bIsWaitingUnLock, bIsSale, iPrice)
	local dText = data.huodongdata.DISCOUNT_TEXT
	if bIsOverTime then
		g_NotifyCtrl:FloatMsg(dText[1001].content)
		return
	elseif bIsSale then
		g_NotifyCtrl:FloatMsg(dText[1003].content)
		return
	elseif bIsWaitingUnLock then
		g_NotifyCtrl:FloatMsg(dText[1004].content)
		return
	end
	if g_AttrCtrl:GetGoldCoin() < iPrice then
		CNpcShopMainView:ShowView(function (oView )
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
		end )
		return
	end

	local sMsg = "是否消耗"..iPrice.."#cur_2购买优惠大礼包？"
	local windowConfirmInfo = {
		msg				= sMsg,
		okCallback		= function ()
			nethuodong.C2GSBuyDiscountSale(iDay)
		end,
		okStr			= "确定",
		cancelStr		= "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CDiscountSaleView.ShowTipsView(self)
	local id = define.Instruction.Config.DiscountSale
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CDiscountSaleView.ShowItemTips(self, iItemId, oBox)
	g_WindowTipCtrl:SetWindowItemTip(iItemId , {widget = oBox})
end

function CDiscountSaleView.CloseView(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	CViewBase.CloseView(self)
end
return CDiscountSaleView