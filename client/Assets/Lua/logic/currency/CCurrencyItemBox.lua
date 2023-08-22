local CCurrencyItemBox = class("CCurrencyItemBox", CBox)

function CCurrencyItemBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_GainLabel = self:NewUI(1, CLabel)
	self.m_CostLabel = self:NewUI(2, CLabel)
	self.m_ItemBg = self:NewUI(3, CTexture)
	self.m_RewardLabel = self:NewUI(4, CLabel)

	self.m_Type = 0
	self.m_CashType = ""		--金币、银币
	self.m_Cost = 0
	self.m_Gains = 0
	self.m_ItemID = 0
	self.m_DataList = {}
	self.m_LodedoneCb = {}
end

function CCurrencyItemBox.SetInitBox(self, itype, datalist, iIndex, cb)
	self.m_Type = itype
	self.m_ItemID = datalist.id
	self.m_DataList = datalist
	self.m_LodedoneCb = cb

	self.m_GainLabel:SetActive(false)
	self.m_CostLabel:SetActive(false)
	self.m_ItemBg:SetActive(false)
	self.m_RewardLabel:SetActive(false)

	local sTextureName = "Texture/Currency/"..datalist.icon..".png"
	local oTexture = g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))

	self.m_ItemBg:AddUIEvent("click", callback(self, "BtnCallback"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
end

function CCurrencyItemBox.RefreshBaseInfo(self, datalist)
	local datalist = self.m_DataList

	if self.m_Type == define.Currency.Type.Gold then
		self.m_CashType = "#cur_3"
		self.m_GainLabel:SetText(string.AddCommaToNum(datalist.gold_gains) .. self.m_CashType)		
		self.m_Gains = datalist.gold_gains
		self.m_RewardLabel:SetActive(false)
		-- sTextureName = "Texture/Currency/h7_jindiban.png"
	elseif self.m_Type == define.Currency.Type.Silver then		
		self.m_CashType = "#cur_4"
		local formula = string.gsub(datalist.sliver_gains_formula, "SLV", g_AttrCtrl.server_grade)
		local func = loadstring("return"..formula)
		self.m_Gains = func()
		self.m_GainLabel:SetText(string.AddCommaToNum(self.m_Gains) .. self.m_CashType)	
		self.m_RewardLabel:SetActive(true)
		if datalist.reward_silver == 0 then
			self.m_RewardLabel:SetActive(false)
		else
			self.m_RewardLabel:SetActive(true)
			self.m_RewardLabel:SetCommaNum(datalist.reward_silver)
		end
		-- sTextureName = "Texture/Currency/h7_landiban.png"
	end

	self.m_Cost = datalist.gold_coin_cost
	self:RefreshMoney()

	self.m_GainLabel:SetActive(true)
	self.m_CostLabel:SetActive(true)
	self.m_ItemBg:SetActive(true)
end

function CCurrencyItemBox.RefreshMoney(self)
	if g_AttrCtrl:GetGoldCoin() < self.m_Cost then
		self.m_CostLabel:SetText("#R" .. string.AddCommaToNum(self.m_Cost))
	else
		self.m_CostLabel:SetCommaNum(self.m_Cost)
	end
end

function CCurrencyItemBox.SetTexture(self, prefab, errcode)
	if prefab then
		self.m_ItemBg:SetMainTexture(prefab)
		-- self:RefreshBaseInfo(self.m_DataList)
		if self.m_LodedoneCb then
			self.m_LodedoneCb()
		end
	else
		print(errcode)
	end
end

function CCurrencyItemBox.BtnCallback(self)
	if g_AttrCtrl:GetGoldCoin() < self.m_Cost then 
		g_NotifyCtrl:FloatMsg("元宝不足")
		return
	end

	local args = {
		msg  				= string.format("是否花费%d#cur_1,兑换%d%s",self.m_Cost, self.m_Gains, self.m_CashType),
		title   			= "提示", 
		okCallback			= function()
			if self.m_Type == define.Currency.Type.Gold then
				self:ExchangeGold()
			elseif self.m_Type == define.Currency.Type.Silver then
				self:ExchangeSilver()
			end
		end,
		pivot			    =  enum.UIWidget.Pivot.Center
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CCurrencyItemBox.ExchangeGold(self)
	netstore.C2GSExchangeGold(self.m_ItemID)
end

function CCurrencyItemBox.ExchangeSilver(self)
	netstore.C2GSExchangeSilver(self.m_ItemID)
end

return CCurrencyItemBox