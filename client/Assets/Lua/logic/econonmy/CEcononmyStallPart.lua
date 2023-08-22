local CEcononmyStallPart = class("CEcononmyStallPart", CPageBase)

function CEcononmyStallPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CEcononmyStallPart.OnInitPage(self)
	-- self.m_SilverBox = self:NewUI(1, CCurrencyBox)
	self.m_ShoppingTab = self:NewUI(1, CButton)
	self.m_SaleTab = self:NewUI(2, CButton)
	self.m_ShoppingBox = self:NewUI(3, CEcononmyStallShoppingBox)
	self.m_SaleBox = self:NewUI(4, CEcononmyStallSaleBox)
	self.m_Boxs = {
		[1] = self.m_ShoppingBox,
		[2] = self.m_SaleBox
	}
	self.m_Tabs = {
		[1] = self.m_ShoppingTab,
		[2] = self.m_SaleTab
	}
	self.m_CurrentBox = nil
	self.m_CurrentTab = -1
	self:InitContent()
end

function CEcononmyStallPart.InitContent(self)
	-- self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_ShoppingTab:AddUIEvent("click", callback(self, "ChangeTab", 1))
	self.m_SaleTab:AddUIEvent("click", callback(self, "ChangeTab", 2))
	self:ChangeTab(1)
	self.m_ShoppingTab:SetSelected(true)
	self:RefreshRedPoint(g_EcononmyCtrl.m_StallNotify)
end

function CEcononmyStallPart.ChangeTab(self, iTab)
	if iTab == self.m_CurrentTab then
		return
	end
	if self.m_CurrentBox then
		self.m_CurrentBox:SetActive(false)
	end
	self.m_Tabs[iTab]:SetSelected(true)
	local oBox = self.m_Boxs[iTab]
	if oBox then
		oBox:SetActive(true)
		self.m_CurrentBox = oBox
		self.m_CurrentTab = iTab
		-- self:RefreshAll()
		if iTab == 2 then
			netstall.C2GSOpenStall()
			g_EcononmyCtrl:RefreshStallNotify(false)
		end
	end
end

function CEcononmyStallPart.RefreshBox(self)
	self.m_Boxs[self.m_CurrentTab]:RefreshAll()
end

function CEcononmyStallPart.RefreshRedPoint(self, bIsShow)
	if not self.m_SaleTab then
		return
	end
	if bIsShow then
		self.m_SaleTab:AddEffect("RedDot", 20, Vector2(-13, -17))
	else
		self.m_SaleTab:DelEffect("RedDot")
	end
end

return CEcononmyStallPart