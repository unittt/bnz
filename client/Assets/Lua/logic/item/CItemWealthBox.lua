local CItemWealthBox = class("CItemWealthBox", CBox)

function CItemWealthBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_GoldIconInfoBox = self:NewUI(1, CBox)
	self.m_GoldIconInfoBgWidget = self.m_GoldIconInfoBox:NewUI(1, CWidget)
	self.m_GoldIconInfoAddBtn = self.m_GoldIconInfoBox:NewUI(2, CButton)
	self.m_GoldIconInfoCountLbl = self.m_GoldIconInfoBox:NewUI(3, CLabel)
	self.m_JifenBtn = self:NewUI(2, CButton)
	self.m_JifenBtnBgSp = self:NewUI(3, CSprite)
	self.m_JifenBtnBgSp:SetActive(false)
	self.m_GoldBgWidget = self:NewUI(4, CWidget)
	self.m_SilverBgWidget = self:NewUI(5, CWidget)

	self.m_JifenTipsBox = self:NewUI(6, CBox)
	self.m_JifenDescBox = self.m_JifenTipsBox:NewUI(1, CBox)
	self.m_JifenDescTitleLbl = self.m_JifenDescBox:NewUI(1, CLabel)
	self.m_JifenDescLbl = self.m_JifenDescBox:NewUI(2, CLabel)
	self.m_JifenDescArrow = self.m_JifenDescBox:NewUI(3, CSprite)
	self.m_JifenDescBg = self.m_JifenDescBox:NewUI(4, CSprite)
	self.m_JifenDescBox:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_JifenDescBox, callback(self.m_JifenDescBox, "SetActive", false))

	self.m_JifenListBox = self.m_JifenTipsBox:NewUI(2, CBox)
	self.m_JifenListCloseBtn = self.m_JifenListBox:NewUI(1, CButton)
	self.m_JifenListScrollView = self.m_JifenListBox:NewUI(2, CScrollView)
	self.m_JifenListGrid = self.m_JifenListBox:NewUI(3, CGrid)
	self.m_JifenListBoxClone = self.m_JifenListBox:NewUI(4, CBox)
	self.m_JifenTipsWdiget = self.m_JifenTipsBox:NewUI(3, CWidget)
	self.m_JifenTipsWdiget2 = self.m_JifenTipsBox:NewUI(4, CWidget)
	self.m_JifenDescPanel = self.m_JifenTipsBox:NewUI(5, CPanel)
	self.m_JifenDescPanel:SetActive(false)
	self.m_JifenListBox:SetActive(false)
	self.m_JifenListBoxClone:SetActive(false)

	self.m_JifenTipsBox:SetActive(false)

	self.m_GoldIconTipsBox = self:NewUI(7, CBox)
	self.m_GoldIconTipsWidget = self.m_GoldIconTipsBox:NewUI(1, CWidget)
	self.m_GoldIconTipsGoldLbl = self.m_GoldIconTipsBox:NewUI(2, CLabel)
	self.m_GoldIconTipsBindGoldLbl = self.m_GoldIconTipsBox:NewUI(3, CLabel)
	self.m_GoldIconTipsBox:SetActive(false)

	self.m_GoldAddBtn = self:NewUI(8, CButton)
	self.m_SilverAddBtn = self:NewUI(9, CButton)
	self.m_GoldCountLable = self:NewUI(10, CLabel)
	self.m_SilverCountLabel = self:NewUI(11, CLabel)
	self.m_GoldOver = self:NewUI(12, CLabel)
	self.m_SilverOver = self:NewUI(13, CLabel)

	self:InitBox()
	self:SetWealth()
end

function CItemWealthBox.InitBox(self)
	local function hintGold()
		local sNum = string.AddCommaToNum(g_AttrCtrl.gold_over) or ""
		sNum = "[FFDE00]" .. sNum .. "[-]"
		return string.gsub(DataTools.GetMiscText(2010).content, "#goldover", sNum)
	end
	self.m_GoldOver:SetHint(hintGold, enum.UIAnchor.Side.Bottom, Vector2.New(0, -10))

	local function hintSilver()
		local sNum = string.AddCommaToNum(g_AttrCtrl.silver_over) or ""
		sNum = "[FFDE00]" .. sNum .. "[-]"
		return string.gsub(DataTools.GetMiscText(2011).content, "#silverover", sNum)
	end
	self.m_SilverOver:SetHint(hintSilver, enum.UIAnchor.Side.Bottom, Vector2.New(0, -10))

	self:SetMoney()

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
	self.m_GoldIconInfoBgWidget:AddUIEvent("click", callback(self, "OnClickGoldIconInfoBtn"))
	self.m_GoldIconInfoAddBtn:AddUIEvent("click", callback(self, "OnGoldIconInfoAddBtn"))
	self.m_JifenBtn:AddUIEvent("click", callback(self, "OnClickJifenBtn"))
	self.m_GoldBgWidget:AddUIEvent("click", callback(self, "OnClickGoldBgBtn"))
	self.m_SilverBgWidget:AddUIEvent("click", callback(self, "OnClickSilverBgBtn"))
	self.m_GoldIconTipsWidget:AddUIEvent("click", callback(self, "OnClickGoldIconTipsWidget"))
	self.m_JifenListCloseBtn:AddUIEvent("click", callback(self, "OnClickJifenListCloseBtn"))
	self.m_JifenTipsWdiget:AddUIEvent("click", callback(self, "OnClickJifenTipsWdiget"))
	self.m_JifenTipsWdiget2:AddUIEvent("click", callback(self, "OnClickJifenTipsWdiget2"))
	self.m_GoldAddBtn:AddUIEvent("click", callback(self, "OnGoldAddBtn"))
	self.m_SilverAddBtn:AddUIEvent("click", callback(self, "OnSilverAddBtn"))
end

function CItemWealthBox.RefreshMoney(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:SetWealth()
		self:SetJifenList()
		self:SetMoney()
	end
end

function CItemWealthBox.SetMoney(self, oCtrl)
	self.m_GoldCountLable:SetCommaNum(g_AttrCtrl.gold)
	self.m_SilverCountLabel:SetCommaNum(g_AttrCtrl.silver)
	-- self.m_RoleTotalMark:SetText("总评分："..g_AttrCtrl.score)
	local showGoldOver = g_AttrCtrl.gold_over and g_AttrCtrl.gold_over > 0
	self.m_GoldOver:SetActive(showGoldOver)
	if showGoldOver then
		local sNum = string.AddCommaToNum(g_AttrCtrl.gold_over) or ""
		self.m_GoldOver:SetText(sNum)
		
	end
	local showSilverOver = g_AttrCtrl.silver_over and g_AttrCtrl.silver_over > 0
	self.m_SilverOver:SetActive(showSilverOver)
	if showSilverOver then
		local sNum = string.AddCommaToNum(g_AttrCtrl.silver_over) or ""
		self.m_SilverOver:SetText(sNum)
	end
end

function CItemWealthBox.OnClickGoldIconInfoBtn(self)
	self:OnShowGoldIconInfoView()
end

function CItemWealthBox.OnGoldIconInfoAddBtn(self)
	-- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end)
	g_ShopCtrl:ShowChargeView()
end

function CItemWealthBox.OnClickJifenBtn(self)
	self:OnShowJifenListView()
end

function CItemWealthBox.OnClickGoldBgBtn(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1001, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_GoldBgWidget, oView.m_MainBox, enum.UIAnchor.Side.Bottom, Vector2.New(0, -10))
    end)
end

function CItemWealthBox.OnClickSilverBgBtn(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1002, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_SilverBgWidget, oView.m_MainBox, enum.UIAnchor.Side.Bottom, Vector2.New(0, -10))
    end)
end

function CItemWealthBox.SetWealth(self)
	self.m_GoldIconInfoCountLbl:SetCommaNum(g_AttrCtrl.goldcoin+g_AttrCtrl.rplgoldcoin)
end

--显示元宝的tips界面
function CItemWealthBox.OnShowGoldIconInfoView(self)
	self.m_GoldIconTipsBox:SetActive(true)
	self.m_GoldIconTipsGoldLbl:SetCommaNum(g_AttrCtrl.goldcoin)
	self.m_GoldIconTipsBindGoldLbl:SetCommaNum(g_AttrCtrl.rplgoldcoin)
end

function CItemWealthBox.OnHideGoldIconInfoView(self)
	self.m_GoldIconTipsBox:SetActive(false)
end

--显示积分列表界面
function CItemWealthBox.OnShowJifenListView(self)
	self.m_JifenBtnBgSp:SetActive(true)
	self.m_JifenTipsBox:SetActive(true)
	self.m_JifenListBox:SetActive(true)
	self.m_JifenDescBox:SetActive(false)
	self.m_JifenDescPanel:SetActive(false)
	self:SetJifenList()
end

function CItemWealthBox.SetJifenList(self)
	local optionCount = #g_ItemCtrl.m_JifenList
	local GridList = self.m_JifenListGrid:GetChildList() or {}
	local oJifenBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oJifenBox = self.m_JifenListBoxClone:Clone(false)
				-- self.m_JifenListGrid:AddChild(oOptionBtn)
			else
				oJifenBox = GridList[i]
			end
			self:SetJifenBox(oJifenBox, g_ItemCtrl.m_JifenList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_JifenListGrid:Reposition()
	self.m_JifenListScrollView:ResetPosition()
end

function CItemWealthBox.SetJifenBox(self, oJifenBox, oData)
	oJifenBox:SetActive(true)
	oJifenBox.m_TipsBtn = oJifenBox:NewUI(1, CButton)
	oJifenBox.m_IconSp = oJifenBox:NewUI(2, CSprite)
	oJifenBox.m_CountLbl = oJifenBox:NewUI(3, CLabel)
	oJifenBox.m_UseBtn = oJifenBox:NewUI(4, CButton)

	oJifenBox.m_IconSp:SpriteItemShape(oData.icon)
	local _, oCount = self:GetJifenShopIndex(oData.id)
	oJifenBox.m_CountLbl:SetText(oCount)

	oJifenBox.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickJifenBoxTipsBtn", oJifenBox, oData))
	oJifenBox.m_UseBtn:AddUIEvent("click", callback(self, "OnClickJifenBoxUseBtn", oData))

	self.m_JifenListGrid:AddChild(oJifenBox)
	self.m_JifenListGrid:Reposition()
end

function CItemWealthBox.OnHideJifenListView(self)
	self.m_JifenBtnBgSp:SetActive(false)
	self.m_JifenTipsBox:SetActive(false)
	self.m_JifenListBox:SetActive(false)
	self.m_JifenDescBox:SetActive(false)
	self.m_JifenDescPanel:SetActive(false)
end

--显示积分说明界面
function CItemWealthBox.OnShowJifenDescView(self, oJifenBox, oData)
	self.m_JifenTipsBox:SetActive(true)
	self.m_JifenDescBox:SetActive(true)
	self.m_JifenDescPanel:SetActive(true)
	local _, _, oInsId =  self:GetJifenShopIndex(oData.id)
	self.m_JifenDescTitleLbl:SetText(data.instructiondata.DESC[oInsId].title)
	self.m_JifenDescLbl:SetRichText(data.instructiondata.DESC[oInsId].desc, nil, nil, true)
	UITools.NearTarget(oJifenBox.m_TipsBtn, self.m_JifenDescBox, enum.UIAnchor.Side.Left, Vector2.New(-140, -40))
	self.m_JifenDescBg:SetAnchorTarget(self.m_JifenDescLbl.m_GameObject, 0, 0, 0, 0)
	self.m_JifenDescBg:SetAnchor("leftAnchor", -23, 0)
	self.m_JifenDescBg:SetAnchor("topAnchor", 60, 1)
    self.m_JifenDescBg:SetAnchor("bottomAnchor", -15, 0)
    self.m_JifenDescBg:SetAnchor("rightAnchor", 25, 1)
	self.m_JifenDescBg:ResetAndUpdateAnchors()
end

function CItemWealthBox.OnHideJifenDescView(self)
	self.m_JifenDescBox:SetActive(false)
	self.m_JifenDescPanel:SetActive(false)
end

function CItemWealthBox.OnClickGoldIconTipsWidget(self)
	self:OnHideGoldIconInfoView()
end

function CItemWealthBox.OnClickJifenListCloseBtn(self)
	self:OnHideJifenListView()
end

function CItemWealthBox.OnClickJifenTipsWdiget(self)
	self:OnHideJifenListView()
end

function CItemWealthBox.OnClickJifenTipsWdiget2(self)
	self:OnHideJifenDescView()
end

function CItemWealthBox.OnClickJifenBoxTipsBtn(self, oJifenBox, oData)
	self:OnShowJifenDescView(oJifenBox, oData)
end

function CItemWealthBox.OnClickJifenBoxUseBtn(self, oData)
	local _, _, _, oId = self:GetJifenShopIndex(oData.id)
	g_ShopCtrl:ShowScoreShop(oId)
end

function CItemWealthBox.GetJifenShopIndex(self, oJifenId)
	if oJifenId == 1013 then
		return 1, g_AttrCtrl.wuxun or 0, 11001, 101
	elseif oJifenId == 1014 then
		return 2, g_AttrCtrl.jjcpoint or 0, 11002, 102
	elseif oJifenId == 1021 then
		return 3, g_AttrCtrl.leaderpoint or 0, 11003, 103
	elseif oJifenId == 1022 then
		return 4, g_AttrCtrl.xiayipoint or 0, 11004, 104
	elseif oJifenId == 1025 then
		return 5, g_AttrCtrl.summonpoint or 0, 11005, 105
	elseif oJifenId == 1027 then
		return 6, g_AttrCtrl.chumopoint or 0, 11006, 106
	else
		return 1, g_AttrCtrl.wuxun or 0, 11001, 101
	end
end

function CItemWealthBox.OnGoldAddBtn(self)
	-- CCurrencyView:ShowView(function(oView)
	-- 	oView:SetCurrencyView(define.Currency.Type.Gold)
	-- end)
	g_ShopCtrl:ShowAddMoney(define.Currency.Type.Gold)
end

function CItemWealthBox.OnSilverAddBtn(self)
	-- CCurrencyView:ShowView(function(oView)
	-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
	-- end)
	g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
end

return CItemWealthBox