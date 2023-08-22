local CCurrencyView = class("CCurrencyView", CViewBase)

function CCurrencyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Currency/GetCurrencyView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CCurrencyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleLb = self:NewUI(2, CLabel)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemClone = self:NewUI(4, CCurrencyItemBox)
	self.m_GoldLable = self:NewUI(5, CLabel)
	self.m_CashLabel = self:NewUI(6, CLabel)
	self.m_CashIcon = self:NewUI(7, CSprite)
	self.m_ItemClone:SetActive(false)
	self.m_GoldLable:AddUIEvent("click", callback(self, "OnClickIngot"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_DataList = {}
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))

	local function initbox(obj, idx)
		local oBox = CCurrencyItemBox.New(obj)
		return oBox
	end
	self.m_ItemGrid:InitChild(initbox)
end

function CCurrencyView.SetCurrencyView(self, itype)
	self.m_Type = itype
	self.m_DataList = DataTools.GetStoreData(self.m_Type)
	self:SetViewInfo()
end

function CCurrencyView.OnClickIngot(self)
	g_NotifyCtrl:ShowClickIngot(self.m_GoldLable)
end

function CCurrencyView.SetViewInfo(self)	
	self:InstanceItem()
	local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
	self.m_GoldLable:SetText(str)

	if tonumber(self.m_Type) == define.Currency.Type.Gold then
		self.m_TitleLb:SetText("金币兑换")
		self.m_CashIcon:SetSpriteName("10002")
		str = string.AddCommaToNum(g_AttrCtrl.gold ) or ""
		self.m_CashLabel:SetText(str)
	elseif tonumber(self.m_Type) == define.Currency.Type.Silver then
		self.m_TitleLb:SetText("银币兑换")
		self.m_CashIcon:SetSpriteName("10003")
		str = string.AddCommaToNum(g_AttrCtrl.silver) or ""
		self.m_CashLabel:SetText(str)
	end
end

function CCurrencyView.InstanceItem(self)
	self.m_LoadDoneCnt = 0
	local oItem = nil
	for i = 1, #self.m_DataList do
		-- oItem = self.m_ItemClone:Clone()
		oItem = self.m_ItemGrid:GetChild(i)
		if not oItem then
			oItem = self.m_ItemClone:Clone()
			oItem:SetActive(true)
			self.m_ItemGrid:AddChild(oItem, false)
		end
		oItem:SetInitBox(self.m_Type, self.m_DataList[i], i, callback(self, "LoadDoneTexture"))
		-- oItem:SetActive(true)
		-- self.m_ItemGrid:AddChild(oItem, false)		
	end
	local iCount = self.m_ItemGrid:GetCount()
	for i = #self.m_DataList + 1, iCount  do
		oItem = self.m_ItemGrid:GetChild(i)
		if oItem then
			oItem:SetActive(false)
		end
	end
end

function CCurrencyView.LoadDoneTexture(self)
	self.m_LoadDoneCnt = self.m_LoadDoneCnt + 1

	if self.m_LoadDoneCnt < #self.m_DataList then
		return
	end
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
	end

	local iIndex = 1
	local iCount = #self.m_DataList
	local function RefreshItem()
		if Utils.IsNil(self) then
			return false
		end
		if iIndex > iCount then
			return false
		end
		local oItem = self.m_ItemGrid:GetChild(iIndex)
		if oItem then
			oItem:RefreshBaseInfo()
		end
		iIndex = iIndex + 1
		return true
	end
	self.m_RefreshTimer = Utils.AddTimer(RefreshItem, 1/30, 1/30)
end

function CCurrencyView.RefreshMoney(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local data = oCtrl.m_EventData
		if data then
			local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
			self.m_GoldLable:SetText(str)

			if tonumber(self.m_Type) == define.Currency.Type.Gold and data.dAttr.gold then
				str = string.AddCommaToNum(data.dAttr.gold ) or ""
				self.m_CashLabel:SetText(str)
			elseif tonumber(self.m_Type) == define.Currency.Type.Silver and data.dAttr.silver then
				str = string.AddCommaToNum(data.dAttr.silver) or ""
				self.m_CashLabel:SetText(str)
			end
		end
	end
end

return CCurrencyView