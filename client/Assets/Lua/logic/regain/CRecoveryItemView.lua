local CRecoveryItemView = class("CRecoveryItemView",CViewBase)

function CRecoveryItemView.ctor(self, cb)
	CViewBase.ctor(self,"UI/Recovery/CRecoveryItemView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_CurrItem = nil
	self.m_CostNum = 0
end

function CRecoveryItemView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TipBtn = self:NewUI(2, CButton)
	self.m_GetBtn = self:NewUI(3, CButton)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_CloneItem = self:NewUI(5, CBox)
	self.m_DetailItem = self:NewUI(6, CBox)
	self.m_Icon = self.m_DetailItem:NewUI(1, CSprite)
	self.m_Border = self.m_DetailItem:NewUI(3, CSprite)
	self.m_Grade = self.m_DetailItem:NewUI(4, CLabel)

	self.m_NameLabel = self:NewUI(7, CLabel)
	self.m_DescLabel = self:NewUI(8, CLabel)
	self.m_MoneyLabel = self:NewUI(9, CLabel)
	self.m_CostLabel = self:NewUI(10 ,CLabel)
	-- self.m_ItemScroll = self:NewUI(11 ,CScrollView)


	self.m_CloseBtn:AddUIEvent("click",callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click",callback(self, "OnTipBtn"))
	self.m_GetBtn:AddUIEvent("click",callback(self, "OnSendMsg"))
	self.m_DetailItem:SetActive(false)
	self.m_CloneItem:SetActive(false)

	g_RecoveryCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "RefreshReUI"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
	self:IninContent()
end

function CRecoveryItemView.IninContent(self)
	
	local gridChildList = self.m_ItemGrid:GetChildList()
	for i=1,30  do
		local oItemBox = nil 
		if i >#gridChildList then
			oItemBox = self.m_CloneItem:Clone()
			oItemBox:SetActive(true)
			self.m_ItemGrid:AddChild(oItemBox)
			oItemBox:SetGroup(self.m_ItemGrid:GetInstanceID())
			oItemBox.icon = oItemBox:NewUI(1, CSprite)
			oItemBox.border = oItemBox:NewUI(3, CSprite)
			oItemBox.grade = oItemBox:NewUI(4, CLabel)
		else
			oItemBox = gridChildList[i]
		end
		local oItem = g_RecoveryCtrl:GetItemByPos(i) 
		if oItem then
			oItemBox:EnableTouch(true)
			local dItem  = DataTools.GetItemData(oItem.sid)
			oItemBox.icon:SpriteItemShape(dItem.icon)
			oItemBox.border:SetItemQuality(oItem.itemlevel)
			oItemBox.grade:SetText("Lv."..dItem.equipLevel)
			oItem.m_Type = "Re"
			oItemBox.itemdata = oItem
		else
			oItemBox:EnableTouch(false)
			oItemBox.icon:SetSpriteName(nil)
			oItemBox.border:SetItemQuality(0)
			oItemBox.grade:SetText("")
		end
		oItemBox:AddUIEvent("click",callback(self, "OnClickShowInfo", i))
	end
	self.m_ItemGrid:Reposition()
	self.m_CurrItem = g_RecoveryCtrl:GetItemByPos()
	local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
	self.m_MoneyLabel:SetText(str)

	self:CurrItem()
end

function CRecoveryItemView.OnClickShowInfo(self, index)
	-- body
	local oItemBox = self.m_ItemGrid:GetChild(index)
	if oItemBox.itemdata then
		self.m_CurrItem = oItemBox.itemdata
		self:CurrItem()
		g_WindowTipCtrl:ItemRecoveryShow(self.m_CurrItem.id)
	end
end

function CRecoveryItemView.SetCurrItem(self, oItem)
	-- body
	self.m_CurrItem = g_RecoveryCtrl:GetRecoveryItemByID(oItem.m_SData.id)
	self:CurrItem()
end

function CRecoveryItemView.CurrItem(self)
	-- body
	if self.m_CurrItem then
		self.m_ItemGrid:GetChild(self.m_CurrItem.pos):SetSelected(true)
		self.m_DetailItem:SetActive(true)
		local v = data.recoverydata.RECOVERYITEM[self.m_CurrItem.sid].cost
		v = string.gsub(v,"lv",self.m_CurrItem.itemlevel) 
		local func = loadstring("return " .. v)
		self.m_CostNum = tonumber( func() )
		self.m_CostLabel:SetCommaNum( self.m_CostNum )
		
		local time = g_TimeCtrl:Convert(self.m_CurrItem.cycreate_time)

		self.m_DescLabel:SetActive(true)
		self.m_DescLabel:SetText(time)

		local dItem  = DataTools.GetItemData(self.m_CurrItem.sid)
		self.m_Icon:SpriteItemShape(dItem.icon)
		self.m_Border:SetItemQuality(self.m_CurrItem.itemlevel)
		self.m_Grade:SetText("Lv."..dItem.equipLevel)

		self.m_NameLabel:SetActive(true)
		self.m_NameLabel:SetText(self.m_CurrItem.name)

	else
		self.m_DetailItem:SetActive(false)
		self.m_MoneyLabel:SetCommaNum(g_AttrCtrl:GetGoldCoin())
		self.m_CostNum = 0
		self.m_CostLabel:SetText(self.m_CostNum)
		self.m_NameLabel:SetActive(false)
		self.m_DescLabel:SetActive(false)
	end
end

function CRecoveryItemView.RefreshMoney(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local data = oCtrl.m_EventData
		if data then
			local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
			self.m_MoneyLabel:SetText(str)
		end
	end
end

function CRecoveryItemView.RefreshReUI(self ,oCtrl)
	if oCtrl.m_EventID == define.Recovery.Event.RecoveryItem then
		self:IninContent()
	end
end

function CRecoveryItemView.OnTipBtn(self)
	local Id = define.Instruction.Config.RecoverEqu
		if data.instructiondata.DESC[Id]~=nil then
			local Content = {
				 title = data.instructiondata.DESC[Id].title,
			 	 desc = data.instructiondata.DESC[Id].desc
				}
				g_WindowTipCtrl:SetWindowInstructionInfo(Content)
		end
end

function CRecoveryItemView.OnSendMsg(self)
   
	if self.m_CurrItem then
		 if g_AttrCtrl:GetGoldCoin() < self.m_CostNum then
			g_NotifyCtrl:FloatMsg(data.textdata.TEXT[3005].content)

			-- CNpcShopMainView:ShowView(function (oView)
			-- 	oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
			-- end
			-- )
			g_ShopCtrl:ShowChargeView()
			return 
		end
		g_RecoveryCtrl:C2GSRecoveryItem(self.m_CurrItem.id)
	end
end

return CRecoveryItemView