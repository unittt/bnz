local CTradeVolumSubView = class("CTradeVolumSubView", CViewBase)

function CTradeVolumSubView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/TradeVolumeSubView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CTradeVolumSubView.OnCreateView(self)
	self.m_TradeVolumView = self:NewUI(1, CObject)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_TypeLabel = self:NewUI(4, CLabel)
	self.m_HaveCountLabel = self:NewUI(5, CLabel)
	self.m_WealthLabel = self:NewUI(6, CLabel)
	self.m_TotalPriceLabel = self:NewUI(7, CLabel)
	self.m_CountLabel = self:NewUI(8, CLabel)
	self.m_IncreaseBtn = self:NewUI(9, CButton)
	self.m_CutBackBtn = self:NewUI(10, CButton)
	self.m_EnterBtn = self:NewUI(11, CButton)
	self.m_EnterLabel = self:NewUI(12, CLabel)
	self.m_MaxBtn = self:NewUI(13, CButton)
	self.m_DescLabel = self:NewUI(14, CLabel)
	self.m_CloseBtn = self:NewUI(15, CButton)
	self.m_CountSprite = self:NewUI(16, CSprite)
	self.m_ViewDesLabel = self:NewUI(17, CLabel)

	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnReFreshCount", "Max"))

	self.m_EnterBtn:AddUIEvent("click", callback(self, "OnEnterBtnCB"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_CountSprite:AddUIEvent("click", callback(self, "OpenKeyboard"))

	CUIEventHandler.SetRepeatDelta(self, 10)

	self.m_IncreaseBtn:AddUIEvent("repeatpress", callback(self, "LongPressCB", "Add"))
	self.m_CutBackBtn:AddUIEvent("repeatpress", callback(self, "LongPressCB", "Reduce"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlBuyEvent"))
    -- g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CTradeVolumSubView.SetTradeVolumSubView(self, itemdata)
	self.m_ItemData = itemdata
	self.m_ExcelData = DataTools.GetItemData(self.m_ItemData.sid)
	self.m_Price = self.m_ExcelData.buyPrice
	self.m_MaxValue = 99
	self.m_MinValue = 1
	self.m_BuyCnt = itemdata.sugAmount or self.m_MinValue
	self:SetItemInfo()
end

function CTradeVolumSubView.SetItemInfo(self)
	self.m_Icon:SpriteItemShape(tostring(self.m_ExcelData.icon))			
	local sName = string.format(data.colorinfodata.ITEM[self.m_ExcelData.quality].color, self.m_ExcelData.name)--datauser.colordata.ITEM.Quality[self.m_ExcelData.quality]..self.m_ExcelData.name.."[-]"					
	self.m_NameLabel:SetRichText(sName, nil, nil, true)
	--local sType = self:GetItemType(tonumber(self.m_ExcelData.itemType[1]))
	local sIntroduction = self.m_ExcelData.introduction
	self.m_TypeLabel:SetText(sIntroduction)--("类型: "..sType.."\n"..sIntroduction)
	self.m_HaveCountLabel:SetText("当前拥有数量:"..self.m_ItemData.amount)
	local sMsg = self.m_ItemData.msg or ""
	self.m_ViewDesLabel:SetColor(Color.white)
	self.m_ViewDesLabel:SetText(string.gsub(sMsg, "#item", self.m_ExcelData.name))
	self.m_WealthLabel:SetText(g_AttrCtrl:GetGoldCoin())
	self.m_TotalPriceLabel:SetText(tostring(self.m_BuyCnt * self.m_Price))
	self.m_CountLabel:SetText(tostring(self.m_BuyCnt))
	self.m_EnterLabel:SetText("确定")
	self.m_DescLabel:SetText(g_ItemCtrl:GetItemDesc(self.m_ExcelData.id))
end

function CTradeVolumSubView.LongPressCB(self, sType, oBtn, bPrees)
	if bPrees then
		self:OnReFreshCount(sType)
	end
end

--刷新数量
function CTradeVolumSubView.OnReFreshCount(self, sType)	
	if sType == "Add" then
		if self.m_BuyCnt >= self.m_MaxValue then
			g_NotifyCtrl:FloatMsg("不能再多了")
			self.m_BuyCnt = self.m_MaxValue
		else
			self.m_BuyCnt = self.m_BuyCnt + 1
		end
	elseif sType == "Reduce" then
		if self.m_BuyCnt > self.m_MinValue then
			self.m_BuyCnt = self.m_BuyCnt - 1
		else
			g_NotifyCtrl:FloatMsg("不能再少了")
			self.m_BuyCnt = self.m_MinValue
		end
	elseif sType == "Max" then
		local iTotalCoin = g_AttrCtrl:GetGoldCoin()
		if self.m_BuyCnt*self.m_Price >= iTotalCoin then
			g_NotifyCtrl:FloatMsg("已经最大了")
		elseif self.m_Price == 0 then
			self.m_BuyCnt = self.m_MinValue
		else
			local iCalcCnt = math.floor(iTotalCoin/self.m_Price)
			iCalcCnt = iCalcCnt > self.m_MinValue and iCalcCnt or self.m_MinValue
			iCalcCnt = iCalcCnt < self.m_MaxValue and iCalcCnt or self.m_MaxValue
			self.m_BuyCnt = iCalcCnt
		end
	end
	self:SetCountInfo()
end

--购买后刷新界面
function CTradeVolumSubView.OnCtrlBuyEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.QuickBuyItem then
    	-- self.m_ItemData.amount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemData.sid)
    	-- self.m_HaveCountLabel:SetText("当前拥有数量:"..self.m_ItemData.amount)
    	-- self.m_WealthLabel:SetText(g_AttrCtrl:GetGoldCoin())
    	-- self.m_BuyCnt = 1
    	-- self:SetCountInfo()
    	self:OnClose()
    end
end

function CTradeVolumSubView.SetCountInfo(self, iCount)
	iCount = iCount or self.m_BuyCnt
	self.m_TotalPriceLabel:SetText(iCount * self.m_Price)
	self.m_CountLabel:SetText(iCount)
end

function CTradeVolumSubView.OpenKeyboard(self)
	local function keyCb(oView)
		local iValue = oView:GetNumber()
		self:SetCountInfo(iValue)
	end
	local function confirmCb(oView)
		self.m_BuyCnt = oView:GetNumber()
		self:SetCountInfo()
	end
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_CountLabel, keyCb, confirmCb, nil, self.m_MinValue, self.m_MaxValue)
	end)
end

function CTradeVolumSubView.OnEnterBtnCB(self, sType)
	--printc("TODO >>> ===== 点击确定按钮 ======")
	if self.m_BuyCnt*self.m_Price > g_AttrCtrl:GetGoldCoin() then
		g_NotifyCtrl:FloatMsg("元宝不足")
	else
		self:BuyItem()
	end
	--self:OnClose()
end

function CTradeVolumSubView.CompoundItem(self)
	printc("TODO >>> ===== 合成物品 ======")
end

function CTradeVolumSubView.BuyItem(self)
	netopenui.C2GSQuickBuyItem(self.m_ItemData.sid, self.m_BuyCnt)
end

function CTradeVolumSubView.SellItem(self)
	printc("TODO >>> ====== 出售物品 ======")
end

-- [[道具类型]]
function CTradeVolumSubView.GetItemType(self, index)
	local tb = {"刀","枪","棍","棒"}
	return tb[index]
end

return CTradeVolumSubView