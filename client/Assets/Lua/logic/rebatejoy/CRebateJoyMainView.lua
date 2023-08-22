local CRebateJoyMainView = class("CRebateJoyMainView", CViewBase)

function CRebateJoyMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RebateJoy/RebateJoyMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRebateJoyMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	-- self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_EmptyBox = self:NewUI(3, CBox)
	self.m_EmptyLbl = self.m_EmptyBox:NewUI(1, CLabel)
	self.m_LeftTimeLbl = self:NewUI(4, CLabel)
	self.m_ResetTimeLbl = self:NewUI(5, CLabel)
	self.m_PrizeScrollView = self:NewUI(6, CScrollView)
	self.m_PrizeGrid = self:NewUI(7, CGrid)
	self.m_PrizeBoxClone = self:NewUI(8, CBox)
	self.m_HasConsumeLbl = self:NewUI(9, CLabel)
	self.m_ShopScrollView = self:NewUI(10, CScrollView)
	self.m_ShopGrid = self:NewUI(11, CGrid)
	self.m_ShopBoxClone = self:NewUI(12, CBox)

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CRebateJoyMainView.InitContent(self)
	self.m_PrizeBoxClone:SetActive(false)
	self.m_ShopBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWelfareEvent"))
	g_RebateJoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRebateJoyEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlShopEvent"))
end

function CRebateJoyMainView.OnCtrlWelfareEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        self:RefreshTime()
    end
end

function CRebateJoyMainView.OnCtrlRebateJoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseState then
		self:RefreshTime()
	elseif oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseRewardState then
		self:SetPrizeList()
	elseif oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseGoldCoin then
		self:RefreshConsumeGoldcoin()
		self:SetPrizeList()
	end
end

function CRebateJoyMainView.OnCtrlShopEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.EnterScoreShop or oCtrl.m_EventID == define.Shop.Event.RefreshScoreShopItem then 
		self:SetShopList()
	end
end

function CRebateJoyMainView.RefreshUI(self)
	self:RefreshTime()
	self.m_ResetTimeLbl:SetText("[63432C]每日凌晨[1d8e00]5[-]点重置")
	self.m_DescLbl:SetText(data.instructiondata.DESC[13011].desc)
	self:RefreshConsumeGoldcoin()
	self:SetPrizeList()
	self:SetShopList()
end

function CRebateJoyMainView.RefreshTime(self)
	if g_RebateJoyCtrl.m_EndTime <= 0 then
		return
	end
	local oLeftTime = g_RebateJoyCtrl.m_EndTime - g_TimeCtrl:GetTimeS()
	if oLeftTime > 0 then
		self.m_LeftTimeLbl:SetText("[63432C]活动剩余时间：[1d8e00]"..g_TimeCtrl:GetLeftTimeDHM(oLeftTime))
	else
		self.m_LeftTimeLbl:SetText("[63432C]活动剩余时间：[1d8e00]已结束")
	end
end

function CRebateJoyMainView.RefreshConsumeGoldcoin(self)
	if g_RebateJoyCtrl.m_ConsumeGoldCoin >= 10000 then
		self.m_HasConsumeLbl:SetText("今日消费    ："..math.floor(g_RebateJoyCtrl.m_ConsumeGoldCoin/1000).."K" )
	else
		self.m_HasConsumeLbl:SetText("今日消费    ："..g_RebateJoyCtrl.m_ConsumeGoldCoin )
	end
end

function CRebateJoyMainView.SetPrizeList(self)
	if not g_RebateJoyCtrl.m_RewardSortConfig then
		return
	end
	local optionCount = #g_RebateJoyCtrl.m_RewardSortConfig
	local GridList = self.m_PrizeGrid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = self.m_PrizeBoxClone:Clone(false)
				-- self.m_PrizeGrid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetPrizeBox(oPrizeBox, g_RebateJoyCtrl.m_RewardSortConfig[i], i)
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

	self.m_PrizeGrid:Reposition()
	-- self.m_PrizeScrollView:ResetPosition()
end

function CRebateJoyMainView.SetPrizeBox(self, oPrizeBox, oData, oIndex)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_BaoxiangSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_RedPointSp = oPrizeBox:NewUI(2, CSprite)
	oPrizeBox.m_GetLbl = oPrizeBox:NewUI(3, CLabel)
	oPrizeBox.m_TitleLbl = oPrizeBox:NewUI(4, CLabel)
	oPrizeBox.m_GoldCoinSp = oPrizeBox:NewUI(5, CSprite)
	oPrizeBox.m_PrizeEffectSp = oPrizeBox:NewUI(6, CSprite)

	if oIndex == 1 then
		oPrizeBox.m_BaoxiangSp:SetSpriteName("h7_1yuan_1")
	elseif oIndex == 2 then
		oPrizeBox.m_BaoxiangSp:SetSpriteName("h7_3yuan_1")
	else
		oPrizeBox.m_BaoxiangSp:SetSpriteName("h7_1yuan_1")
	end
	oPrizeBox.m_BaoxiangSp:SetGrey(false)
	oPrizeBox.m_RedPointSp:SetActive(false)
	oPrizeBox.m_PrizeEffectSp:SetActive(false)
	oPrizeBox.m_TitleLbl:SetText(oData.multiple.."倍返利礼包")
	local oServerData = g_RebateJoyCtrl.m_RewardHashList[oData.id]
	if not oServerData or oServerData.reward_state == 0 then
		oPrizeBox.m_GetLbl:SetText("再消费"..(oData.expense - g_RebateJoyCtrl.m_ConsumeGoldCoin))
		oPrizeBox.m_GoldCoinSp:SetActive(true)
	elseif oServerData and oServerData.reward_state == 1 then
		oPrizeBox.m_GetLbl:SetText("可领取")
		oPrizeBox.m_GoldCoinSp:SetActive(false)
		oPrizeBox.m_RedPointSp:SetActive(true)
		oPrizeBox.m_PrizeEffectSp:SetActive(true)
	elseif oServerData and oServerData.reward_state == 2 then
		oPrizeBox.m_GetLbl:SetText("已领取")
		oPrizeBox.m_GoldCoinSp:SetActive(false)
		oPrizeBox.m_BaoxiangSp:SetGrey(true)
	end
	oPrizeBox.m_GoldCoinSp:ResetAndUpdateAnchors()
	oPrizeBox:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData))

	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
end

function CRebateJoyMainView.SetShopList(self)
	self.m_EmptyBox:SetActive(false)
	self.m_ShopScrollView:SetActive(true)
	if not g_RebateJoyCtrl.m_MainConfig then
		return
	end
	if not g_ShopCtrl.m_ScoreInfo[g_RebateJoyCtrl.m_MainConfig.shop_id] then
		return
	end
	local oList = {}
	for k,v in pairs(g_ShopCtrl.m_ScoreInfo[g_RebateJoyCtrl.m_MainConfig.shop_id]) do
		if v.dayamount > 0 then
			table.insert(oList, v)
		end
	end
	table.sort(oList, function (a, b)
		return a.goodid < b.goodid
	end)
	local optionCount = #oList
	if optionCount <= 0 then
		self.m_EmptyBox:SetActive(true)
		self.m_EmptyLbl:SetText("商品已售罄，请明天再来吧！")
		self.m_ShopScrollView:SetActive(false)
	end
	local GridList = self.m_ShopGrid:GetChildList() or {}
	local oShopBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oShopBox = self.m_ShopBoxClone:Clone(false)
				-- self.m_ShopGrid:AddChild(oOptionBtn)
			else
				oShopBox = GridList[i]
			end
			self:SetShopBox(oShopBox, oList[i])
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

	self.m_ShopGrid:Reposition()
	-- self.m_ShopScrollView:ResetPosition()
end

function CRebateJoyMainView.SetShopBox(self, oShopBox, oData)
	oShopBox:SetActive(true)
	oShopBox.m_IconSp = oShopBox:NewUI(1, CSprite)
	oShopBox.m_BorderSp = oShopBox:NewUI(2, CSprite)
	oShopBox.m_CountLbl = oShopBox:NewUI(3, CLabel)
	oShopBox.m_BuyBtn = oShopBox:NewUI(4, CButton)
	oShopBox.m_MoneyIconSp = oShopBox:NewUI(5, CSprite)
	oShopBox.m_MoneyLbl = oShopBox:NewUI(6, CLabel)

	local oItemConfig = DataTools.GetItemData(oData.itemsid)
	oShopBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oShopBox.m_CountLbl:SetText(oData.dayamount)
	oShopBox.m_MoneyLbl:SetText(oData.money[1].moneyvalue)
	-- oShopBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickShopIconSp", oData))
	oShopBox:AddUIEvent("click", callback(self, "OnClickShopBuyBtn", oData))

	self.m_ShopGrid:AddChild(oShopBox)
	self.m_ShopGrid:Reposition()
end

---------------以下是点击事件--------------

function CRebateJoyMainView.OnClickPrizeBox(self, oData)
	if not g_RebateJoyCtrl:CheckIsRebateJoyOpen() then
		g_NotifyCtrl:FloatMsg("活动已经结束了哦")
		return
	end

	local oServerData = g_RebateJoyCtrl.m_RewardHashList[oData.id]

	local itemlist = g_GuideHelpCtrl:GetRewardList("JOYEXPENSE", oData.reward_id)
	local oItemConfig = DataTools.GetItemData(1003, "VIRTUAL")
	local item = table.copy(oItemConfig)
	item.name = oData.multiple.."倍充值返利"
	item.introduction = "用于充值时获得绑定元宝返利"
	item.description = oData.multiple.."倍充值返利，拥有该返利时进行充值可通过邮件额外获得"..(oData.multiple-1).."倍的绑定元宝，仅当天有效"
	table.insert(itemlist, 1, {item = item, amount = oData.multiple.."倍", type = 1, sid =  1003, isMarkItemData = true})

	local title = oData.multiple.."倍返利礼包"

	local desc = nil
	local hideBtn = nil
	local cb = nil

	if not oServerData or oServerData.reward_state == 0 then
		hideBtn = true
		desc = "[244B4E]再消费#G"..(oData.expense - g_RebateJoyCtrl.m_ConsumeGoldCoin).."#n#cur_1即可领取该礼包"
	elseif oServerData and oServerData.reward_state == 1 then
		cb = function ( ... )
			nethuodong.C2GSJoyExpenseGetReward(oData.id)
			local windowConfirmInfo = {
				msg = "恭喜您获得一次"..oData.multiple.."倍返利机会，充值即可返利绑定元宝！是否立即充值？",
				title = "提示",
				okCallback = function () 
					CNpcShopMainView:ShowView(function (oView)
						oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
					end)
				end,	
				okStr = "充值",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	elseif oServerData and oServerData.reward_state == 2 then
		hideBtn = true
		desc = "[244B4E]礼包已领取，请明天再来吧！"
	end

	g_WindowTipCtrl:ShowItemBoxView({
		title = title,
        hideBtn = hideBtn,
        items = itemlist,
        comfirmText = "领取",
        desc = desc,
        comfirmCb = cb,
        color = Color.white,
	})
end

function CRebateJoyMainView.OnClickShopIconSp(self, oData)
	
end

function CRebateJoyMainView.OnClickShopBuyBtn(self, oData)
	if not g_RebateJoyCtrl:CheckIsRebateJoyOpen() then
		g_NotifyCtrl:FloatMsg("活动已经结束了哦")
		return
	end

	CRebateJoyBuyView:ShowView(function (oView)
		oView:RefreshUI(oData)
	end)
end

return CRebateJoyMainView