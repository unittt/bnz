local CEngageGiftSelectView = class("CEngageGiftSelectView", CViewBase)

function CEngageGiftSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/EngageGiftSelectView.prefab", cb)

	self.m_GroupName = "main"
	self.m_DepthType = "Middle"
    self.m_ExtendClose = "Shelter"
end

function CEngageGiftSelectView.OnCreateView(self)
	-- body
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GiftGrid = self:NewUI(2, CGrid)
	self.m_GiftItemClone = self:NewUI(3, CBox)
	self.m_NpcTexture = self:NewUI(4, CActorTexture)
	self.m_EngageBtn = self:NewUI(5, CButton)

	self.m_DefaultRing = 3
	self.m_RingAmount = {}
	self.m_Titles = {"银戒指礼包", "金戒指礼包", "钻石戒指礼包"}
	
	self:InitContent()
end

function CEngageGiftSelectView.InitContent(self)
	-- body --
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_EngageBtn:AddUIEvent("click", callback(self, "OnStartEngageClick"))

	g_EngageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEngageEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))

	self.m_GiftItemClone:SetActive(false)

	self:InitNpcTexture()

	self:RefreshRingBox()
end

function CEngageGiftSelectView.RefreshRingBox(self)
	if table.count(self.m_RingAmount) > 0 then
		for i=#self.m_RingAmount, 1, -1 do
			table.remove(self.m_RingAmount, i)
		end
	end
	local ringConfig = g_EngageCtrl:GetAllRingConfig()
	for i, v in ipairs(ringConfig) do
		local oBox = self.m_GiftGrid:GetChild(i)
		if oBox == nil then
			oBox = self.m_GiftItemClone:Clone()
			oBox:SetActive(true)
			self.m_GiftGrid:AddChild(oBox)
		end
		self:InItBox(oBox, v)
	end
	self:SetDefaultRing()
	self.m_GiftGrid:GetChild(self.m_DefaultRing):SetSelected(true)
	self.m_GiftGrid:Reposition()
end

function CEngageGiftSelectView.InitNpcTexture(self)
	local model_info = g_EngageCtrl:GetNpcModelInfo()
	self.m_NpcTexture:ChangeShape(model_info)
end

function CEngageGiftSelectView.InItBox(self, oBox, data)
	local oBox = oBox
	oBox.m_Title = oBox:NewUI(1, CLabel)
	oBox.m_Sp = oBox:NewUI(2, CSprite)
	oBox.m_Desc = oBox:NewUI(3, CLabel)
	oBox.m_Bg = oBox:NewUI(4, CSprite)

	local idx = data.type
	local title = self.m_Titles[idx]
	oBox.m_Title:SetText(title)
	oBox.m_Title:SetGradientTop(Color.RGBAToColor(data.color.top))
	oBox.m_Title:SetGradientBottom(Color.RGBAToColor(data.color.bottom))
	oBox.m_Title:SetEffectColor(Color.RGBAToColor(data.color.shadow))
	oBox.m_Desc:SetText(data.desc)

	local atlas, icon = data.atlas, data.icon
	oBox.m_Sp:SetStaticSprite(atlas, icon)
	oBox.m_Sp:AddEffect(data.ringEffect, 0, 1) --最后参数为戒指等级

	local _type = data.type
	oBox:SetGroup(self:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnSelect", _type))

	local sid = data.sid
	local amount = g_ItemCtrl:GetBagItemAmountBySid(sid)
	table.insert(self.m_RingAmount, {amount = amount, sid = sid})
	oBox.m_Bg:SetGrey(true)--amount <= 0)
end

function CEngageGiftSelectView.OnClose(self)
	self:CloseView()
end

function CEngageGiftSelectView.OnSelect(self, type)
	self.m_DefaultRing = type
end

function CEngageGiftSelectView.SetDefaultRing(self)
	local amount = 0
	for i, v in ipairs(self.m_RingAmount) do
		if v.amount > amount then
			amount = v.amount
		end
	end

	if amount == 0 then
		self.m_DefaultRing = 3 --数量全为0，选最贵
	else
		for i, v in ipairs(self.m_RingAmount) do
			if v.amount > 0 then
				self.m_DefaultRing = i --选择已有中最贵的
			end
		end
	end
end

function CEngageGiftSelectView.OnStartEngageClick(self)
	-- todo --
	local count = self.m_RingAmount[self.m_DefaultRing].amount
	local sid = self.m_RingAmount[self.m_DefaultRing].sid

	local memberlist = g_TeamCtrl:GetMemberList()
	local text = data.engagedata.TEXT

	local msg = nil
	if table.count(memberlist) <= 1 then  --必须组队
		msg = text[1002].content
	elseif table.count(memberlist) ~= 2 then  --必须为两人组队
		msg = text[1004].content
	elseif g_TeamCtrl.m_LeaderID ~= g_AttrCtrl.pid then  --必须为队长
		msg = text[1003].content
	end

	if msg then
		g_NotifyCtrl:FloatMsg(msg)
		return
	end

	if count < 1 then
		local itemlist = {{sid = sid, count = count, amount = 1}}
		--local shopdata = data.shopdata.NPCSHOP
		local buyId, price = self:GetItemShopInfo(sid)
		g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, price, callback(self, "exchangeCb", buyId, price))
		-- g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
		-- 	netengage.C2GSEngageCondition(self.m_DefaultRing)
		-- end)
		return
	end

	netengage.C2GSEngageCondition(self.m_DefaultRing)
end

function CEngageGiftSelectView.GetItemShopInfo(self, sid)
	local shopdata = data.shopdata.NPCSHOP
	local buyId, price = 0, 0
	for k, v in pairs(shopdata) do
		if v.item_id == sid then
			buyId = v.id
			price = v.virtual_coin[1003].count --价格
			break
		end
	end
	return buyId, price
end

function CEngageGiftSelectView.exchangeCb(self, buyId, price)
	if g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin < price then
		-- CNpcShopMainView:ShowView(function(oView) 
		-- 	oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) 
		-- end)
		g_ShopCtrl:ShowChargeView()
	else
		netstore.C2GSNpcStoreBuy(buyId, 1) --默认买1个
	end
	CQuickGetItemView:CloseView()
end

function CEngageGiftSelectView.OnEngageEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Engage.Event.EngageSuccess then
		self:CloseView()
	elseif oCtrl.m_EventID == define.Engage.Event.EngageFail then
		self:CloseView()
	end
end

function CEngageGiftSelectView.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		
		local oItem = oCtrl.m_EventData
		local sid = oItem:GetSValueByKey("sid")
		if g_EngageCtrl:IsRingGift(sid) then
			self:RefreshRingBox()
		end
	end
end

return CEngageGiftSelectView