local CCurrencyBox = class("CCurrencyBox", CBox)

function CCurrencyBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CurrencySpr = self:NewUI(1, CSprite)
	self.m_CountLabel = self:NewUI(2, CLabel)
	self.m_AddButton = self:NewUI(3, CWidget)

	self.m_CurrencyType = 0
	self.m_IsCost = false
	self.m_Amount = 0
	self.m_WarningValue = -1
	                           --金币     银币          元宝 
	self.m_CurrencyMap = {[1] = 1001, [2] = 1002, [3] = 1003}
	self.m_CurrencySpr:AddUIEvent("click", callback(self, "OnGainWayEvent"))
	self.m_AddButton:AddUIEvent("click", callback(self, "OpenCurrencyView"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CCurrencyBox.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshCurrency()
	end
end

--设置警告值，低于警告值显示红色
--@param iValue 警告值
function CCurrencyBox.SetWarningValue(self, iValue)
	self.m_WarningValue = iValue
	self:RefreshCurrency()
end

--设置货币类型
--@param iType 
--@param bIsCost 默认非消耗
function CCurrencyBox.SetCurrencyType(self, iType, bIsCost)
	self.m_CurrencyType = iType
	self.m_IsCost = bIsCost or false
	self:InitCurrencySpr()
	self:RefreshCurrency()
	self.m_AddButton:SetActive(not self.m_IsCost)
end

--初始货币Icon
function CCurrencyBox.InitCurrencySpr(self)
	self.m_CurrencySpr:SpriteCurrency(self.m_CurrencyType)
end

--设置货币数量
--@param iCount 
function CCurrencyBox.SetCurrencyCount(self, iCount)
	if iCount < self.m_WarningValue then
		self.m_CountLabel:SetText("[c][AF302A]" .. string.AddCommaToNum(iCount) .. "[-]")
	else
		self.m_CountLabel:SetCommaNum(iCount)
	end
	self.m_Amount = iCount
end

function CCurrencyBox.GetCurrencyCount(self)
	return self.m_Amount
end

--非消耗状态下自动刷新货币
function CCurrencyBox.RefreshCurrency(self)
	if self.m_IsCost then
		self:SetCurrencyCount(self.m_Amount)
		return
	end
	local iCount = 0
	if self.m_CurrencyType == define.Currency.Type.Gold then
		iCount = g_AttrCtrl.gold
	elseif self.m_CurrencyType == define.Currency.Type.Silver then
		iCount = g_AttrCtrl.silver
	elseif self.m_CurrencyType == define.Currency.Type.GoldCoin then
		iCount = g_AttrCtrl.goldcoin
	elseif self.m_CurrencyType == define.Currency.Type.AnyGoldCoin then
		iCount = g_AttrCtrl.goldcoin
	else
		iCount = g_AttrCtrl:GetGoldCoin()
	end
	self:SetCurrencyCount(iCount)
end

function CCurrencyBox.OpenCurrencyView(self)
	g_ShopCtrl:ShowAddMoney(self.m_CurrencyType)
	-- if self.m_CurrencyType == define.Currency.Type.Gold then
	-- 	CCurrencyView:ShowView(function(oView)
	-- 		oView:SetCurrencyView(define.Currency.Type.Gold)
	-- 	end)
	-- elseif self.m_CurrencyType == define.Currency.Type.Silver then
	-- 	CCurrencyView:ShowView(function(oView)
	-- 		oView:SetCurrencyView(define.Currency.Type.Silver)
	-- 	end)
	-- elseif self.m_CurrencyType == define.Currency.Type.GoldCoin or self.m_CurrencyType == define.Currency.Type.AnyGoldCoin then
	-- 	CNpcShopMainView:ShowView(function(oView) 
	-- 		oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) 
	-- 	end) 
	-- else
	-- 	return
	-- end
end

function CCurrencyBox.OnGainWayEvent(self)
	-- body
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_CurrencyMap[self.m_CurrencyType], function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_CurrencySpr, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

return CCurrencyBox