local CRebateJoyBuyView = class("CRebateJoyBuyView", CViewBase)

function CRebateJoyBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RebateJoy/RebateJoyBuyView.prefab", cb)
	--界面设置
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRebateJoyBuyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemIconSpr = self:NewUI(2, CSprite)
	self.m_QualitySpr = self:NewUI(3, CSprite)
	self.m_NameL = self:NewUI(4, CLabel)
	self.m_IntroductionL = self:NewUI(5, CLabel)
	self.m_DescLabelClone = self:NewUI(6, CLabel)
	self.m_DescTable = self:NewUI(7, CTable)
	self.m_DescScrollView = self:NewUI(8, CScrollView)
	self.m_RemainLbl = self:NewUI(9, CLabel)
	self.m_ChangeNumBox = self:NewUI(10, CBox)
	self.m_SubNumBtn = self.m_ChangeNumBox:NewUI(1, CButton)
	self.m_AddNumBtn = self.m_ChangeNumBox:NewUI(2, CButton)
	self.m_ChangeNumLbl = self.m_ChangeNumBox:NewUI(3, CLabel)
	self.m_ChangeNumBgSp = self.m_ChangeNumBox:NewUI(4, CSprite)
	self.m_ItemMoneyIconSp = self:NewUI(11, CSprite)
	self.m_ItemMoneyLbl = self:NewUI(12, CLabel)
	self.m_TotalMoneyIconSp = self:NewUI(13, CSprite)
	self.m_TotalMoneyLbl = self:NewUI(14, CLabel)
	self.m_BuyBtn = self:NewUI(15, CButton)

	self.m_Count = 1
	self.m_TotalPrice = 0
	self.m_MaxBuy = 1
	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CRebateJoyBuyView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
	self.m_SubNumBtn:AddUIEvent("click", callback(self, "OnClickSubNumBtn"))
	self.m_AddNumBtn:AddUIEvent("click", callback(self, "OnClickAddNumBtn"))
	self.m_ChangeNumBgSp:AddUIEvent("click", callback(self, "OnClickChangeNumBg"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlShopEvent"))
end

function CRebateJoyBuyView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshGoldCoin()
	end
end

function CRebateJoyBuyView.OnCtrlShopEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.EnterScoreShop or oCtrl.m_EventID == define.Shop.Event.RefreshScoreShopItem then
		if not g_RebateJoyCtrl.m_MainConfig then
			return
		end
		if not g_ShopCtrl.m_ScoreInfo[g_RebateJoyCtrl.m_MainConfig.shop_id] then
			return
		end
		if not self.m_ItemShopData then
			return
		end
		self.m_ItemShopData = g_ShopCtrl.m_ScoreInfo[g_RebateJoyCtrl.m_MainConfig.shop_id][self.m_ItemShopData.goodid]
		self.m_MaxBuy = self.m_ItemShopData.dayamount
		self:RefreshCouldBuy()
		self:RefreshBuyCount()
		self:RefreshTotalPrice()
	end
end

function CRebateJoyBuyView.RefreshUI(self, oData)
	self.m_ItemShopData = oData
	self.m_Count = 1
	self.m_MaxBuy = self.m_ItemShopData.dayamount
	self.m_ItemShopConfig = DataTools.GetItemData(self.m_ItemShopData.itemsid)

	self:RefreshItemBasePanel()
	self:RefreshCouldBuy()
	self:RefreshGoldCoin()
	self:RefreshBuyCount()
	self:RefreshTotalPrice()
end

function CRebateJoyBuyView.RefreshItemBasePanel(self)
	if not self.m_ItemShopData then
		return
	end
	local oConfig = self.m_ItemShopConfig
	local icon = oConfig.icon
	self.m_ItemIconSpr:SpriteItemShape(icon)
	local quality = g_ItemCtrl:GetQualityVal( oConfig.id, oConfig.quality or 0 )
	local textName = string.format(data.colorinfodata.ITEM[quality].color, oConfig.name)
	self.m_NameL:SetText(textName)
	self.m_IntroductionL:SetText(oConfig.introduction)
	self.m_QualitySpr:SetItemQuality(quality)

	self:CreateItemDesc()
end

function CRebateJoyBuyView.CreateItemDesc(self)
	local tableList = self.m_DescTable:GetChildList()

	local function createDes(index, des)
		local oLabel = nil
		if index > #tableList then
			oLabel = self.m_DescLabelClone:Clone()
			self.m_DescTable:AddChild(oLabel)
		else	
			oLabel = tableList[index]
		end
		--对一些description进行特殊处理，如根据宝图item数据设置地图坐标描述
		local function SetLabel(sText)
			local itemsid = self.m_ItemShopConfig.id
			if itemsid == define.Treasure.Config.Item5 or itemsid == define.Treasure.Config.Item4 then
				-- local treasureInfo = g_ItemViewCtrl:GetTreasureInfo(self.m_Item)
				-- local sInfo = DataTools.GetSceneNameByMapId(treasureInfo.treasure_mapid)
				-- oLabel:SetText(string.format(sText,sInfo))
			else
				oLabel:SetText(sText)
			end
		end
		SetLabel(des)
		-- oLabel:SetText(des)
		oLabel:SetActive(true)
	end

	local description = g_ItemCtrl:GetItemDesc(self.m_ItemShopConfig.id) --self.m_ItemShopConfig.description
	if type(description) == "table" then
		for i,v in ipairs(description) do
			createDes(v)
		end
	elseif type(description) == "string" then
		createDes(1, description)
	end
end

function CRebateJoyBuyView.RefreshCouldBuy(self)
	if not self.m_ItemShopData then
		return
	end
	self.m_RemainLbl:SetText("还可以购买："..self.m_ItemShopData.dayamount.."个")
end

function CRebateJoyBuyView.RefreshGoldCoin(self)
	self.m_TotalMoneyLbl:SetCommaNum(g_AttrCtrl.goldcoin)
end

function CRebateJoyBuyView.RefreshBuyCount(self)	
	self.m_ChangeNumLbl:SetText(self.m_Count)
end

function CRebateJoyBuyView.RefreshTotalPrice(self)
	local dPrice = self.m_ItemShopData.money[1].moneyvalue
	self.m_TotalPrice = dPrice * self.m_Count
	self.m_ItemMoneyLbl:SetCommaNum(self.m_TotalPrice)
end

-------------以下是点击事件--------------

function CRebateJoyBuyView.OnClickBuyBtn(self)
	if not self.m_ItemShopData then
		return
	end
	if self.m_TotalPrice > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
        g_QuickGetCtrl:OnShowNotEnoughGoldCoin()
    else
        nethuodong.C2GSJoyExpenseBuyGood(g_RebateJoyCtrl.m_MainConfig.shop_id, self.m_ItemShopData.goodid, 12, self.m_Count)
    end	
	self:OnClose()
end

function CRebateJoyBuyView.OnClickSubNumBtn(self)
	local iMax = self.m_MaxBuy or 99
	if self.m_Count > 1 then 
		self.m_Count = self.m_Count - 1
		self:RefreshBuyCount()
		self:RefreshTotalPrice()
	else
		g_NotifyCtrl:FloatMsg("输入范围1~" .. iMax)
	end
end

function CRebateJoyBuyView.OnClickAddNumBtn(self)
	local iMax = self.m_MaxBuy or 99
	if self.m_Count < iMax then 
		self.m_Count = self.m_Count + 1
		self:RefreshBuyCount()
		self:RefreshTotalPrice()
	end
	if self.m_Count == iMax then 
		g_NotifyCtrl:FloatMsg("输入范围1~" .. iMax)
	end 
end

function CRebateJoyBuyView.OnClickChangeNumBg(self)
	local function keycallback(oView)
		self:KeyboardCallback(oView)
	end
	local iMax = self.m_MaxBuy or 99
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_ChangeNumLbl, keycallback, nil, nil, 1, iMax)
	end)
end

function CRebateJoyBuyView.KeyboardCallback(self, oView, isHint)
	self.m_Count = oView:GetNumber()
	self:RefreshTotalPrice()
	-- printc(self.m_Count)
	if isHint then
		g_NotifyCtrl:FloatMsg("最多购买99个道具")
	end
end

function CRebateJoyBuyView.OnClose(self)
    self:CloseView()
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

return CRebateJoyBuyView