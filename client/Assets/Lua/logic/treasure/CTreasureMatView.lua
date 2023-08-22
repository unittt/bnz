local CTreasureMatView = class("CTreasureMatView", CViewBase)

function CTreasureMatView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasureMatView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_NeedMoney = 0
end

function CTreasureMatView.OnCreateView(self)
	for i=1,3,1 do
		self["m_ItemBox"..i] = self:NewUI(i,CBox)
	end
	self.m_MoneyLbl = self:NewUI(4,CLabel)
	self.m_CloseBtn = self:NewUI(5,CButton)
	self.m_ConfirmBtn = self:NewUI(6,CButton)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self:InitContent()
end

function CTreasureMatView.InitContent(self)
	self.m_NeedMoney = 0
	for i=1,3,1 do
		local iconSp = self["m_ItemBox"..i]:NewUI(1,CSprite)
		local numLbl = self["m_ItemBox"..i]:NewUI(2,CLabel)
		local num = g_ItemCtrl:GetBagItemAmountBySid(self:GetItemConfig()[i])
		local iconStr = tostring(DataTools.GetItemData(self:GetItemConfig()[i]).icon)
		self["m_ItemBox"..i]:AddUIEvent("click", callback(self, "OnClickTips",self:GetItemConfig()[i]))
		iconSp:SetSpriteName(iconStr)
		numLbl:SetText(num)

		if num <= 0 then
			self.m_NeedMoney = self.m_NeedMoney + DataTools.GetItemData(self:GetItemConfig()[i]).buyPrice
		end
	end

	if g_AttrCtrl:GetGoldCoin() >= self.m_NeedMoney then
		self.m_MoneyLbl:SetRichText("[FFFFFF]"..self.m_NeedMoney.."#n", nil, nil, true)
	else
		self.m_MoneyLbl:SetRichText("#R"..self.m_NeedMoney.."#n", nil, nil, true)
	end
end

--获取itembox对应的item
function CTreasureMatView.GetItemConfig(self)
	local list = {define.Treasure.Config.Item1,define.Treasure.Config.Item2,define.Treasure.Config.Item3}
	return list
end

--点击确认用元宝补足材料
function CTreasureMatView.OnConfirm(self)
	if g_AttrCtrl:GetGoldCoin() >= self.m_NeedMoney then
		--材料足够是1，用元宝是2
		netitem.C2GSCompoundItem(define.Treasure.Config.Item4, 2, define.Currency.Type.GoldCoin)
	else
		-- CNpcShopMainView:ShowView(function (oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end)
		g_ShopCtrl:ShowChargeView()
	end
	self:OnClose()
end

--点击显示道具tips
function CTreasureMatView.OnClickTips(self,itemid)
	g_WindowTipCtrl:SetWindowItemTip(itemid,
	{widget = self, side = enum.UIAnchor.Side.Center,offset = Vector2.New(0, 140)})
end

return CTreasureMatView