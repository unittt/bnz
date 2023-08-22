local CZeroBuyChenPart = class("CZeroBuyChenPart", CPageBase)

function CZeroBuyChenPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_RewardSp = self:NewUI(2, CSprite)
	self.m_PrizeScrollView = self:NewUI(3, CScrollView)
	self.m_PrizeGrid = self:NewUI(4, CGrid)
	self.m_PrizeBoxClone = self:NewUI(5, CBox)
	self.m_BuyBtn = self:NewUI(6, CButton)
	self.m_BuyGetBtn = self:NewUI(7, CButton)
	self.m_GoldGetBtn = self:NewUI(8, CButton)
	self.m_DescLbl = self:NewUI(9, CLabel)
	self.m_ChenBtn = self:NewUI(10, CButton)
	self.m_ItemBox = self:NewUI(11, CBox)
	self.m_ItemBoxIcon = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBoxCountLbl = self.m_ItemBox:NewUI(2, CLabel)
	self.m_ItemBoxBorderSp = self.m_ItemBox:NewUI(3, CSprite)

	self.m_ItemBoxIcon.m_IgnoreCheckEffect = true

	self:InitContent()
end

function CZeroBuyChenPart.InitContent(self)
	self.m_BuyBtn.m_IgnoreCheckEffect = true
	self.m_GoldGetBtn.m_IgnoreCheckEffect = true
	self.m_PrizeBoxClone:SetActive(false)
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
	self.m_BuyGetBtn:AddUIEvent("click", callback(self, "OnClickBuyGetBtn"))
	self.m_GoldGetBtn:AddUIEvent("click", callback(self, "OnClickGoldBuyBtn"))
	g_ZeroBuyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnZeroBuyEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self,"OnWelfareEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:RefreshUI()
end

function CZeroBuyChenPart.OnZeroBuyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ZeroBuy.Event.UpdateInfo then
		self:RefreshUI()
	end
end

function CZeroBuyChenPart.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
		self:RefreshTime()
	end
end

function CZeroBuyChenPart.OnCtrlAttrEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshButton()
	end
end

function CZeroBuyChenPart.RefreshUI(self)
	self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("ZEROYUAN", data.zerobuydata.ACTIVITY[g_ZeroBuyCtrl.m_ZeroBuyChenIndex].reward_id))

	self:RefreshButton()
	self:RefreshTime()
end

function CZeroBuyChenPart.RefreshItemBox(self, oList)
	if oList and next(oList) then
		local oData = oList[1]
		self.m_ItemBoxBorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
    	self.m_ItemBoxIcon:SpriteItemShape(oData.item.icon)
    	if oData.amount > 0 then
	        self.m_ItemBoxCountLbl:SetText("") --oData.amount
	    else
	        self.m_ItemBoxCountLbl:SetText("")
	    end
	    self.m_ItemBoxIcon:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, self.m_ItemBox, oData))
	end
end

function CZeroBuyChenPart.RefreshButton(self)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyChenIndex]
	if not oServerData then
		return
	end
	self.m_RewardSp:SetActive(true)
	self.m_BuyBtn:DelEffect("RedDot")
	self.m_GoldGetBtn:DelEffect("RedDot")
	self.m_ChenBtn:DelEffect("RedDot")
	self.m_ItemBoxIcon:DelEffect("Screen")
	if oServerData.status == 0 then
		self.m_BuyBtn:SetActive(true)
		self.m_GoldGetBtn:SetActive(false)
		self.m_BuyBtn:SetText("免费领取")
		if g_AttrCtrl.grade >= data.zerobuydata.ACTIVITY[1].limit_level then
			self.m_BuyBtn:AddEffect("RedDot", 25, Vector2(-18, -18))
			self.m_ChenBtn:AddEffect("RedDot", 25, Vector2(-25, -25))
		end
		self.m_RewardSp:SetActive(false)
		self.m_ItemBoxIcon:AddEffect("Screen", "ui_eff_0100")
	elseif oServerData.status == 1 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(true)
	elseif oServerData.status == 2 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(true)
		self.m_GoldGetBtn:AddEffect("RedDot", 25, Vector2(-18, -18))
		self.m_ChenBtn:AddEffect("RedDot", 25, Vector2(-25, -25))
	elseif oServerData.status == 3 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(false)
	end
end

function CZeroBuyChenPart.RefreshTime(self)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyChenIndex]
	if not oServerData then
		return
	end
	if oServerData.status == 0 then
		local oLeftTime = oServerData.buy_endtime - g_TimeCtrl:GetTimeS()
		if oLeftTime > 0 then
			self.m_DescLbl:SetText("[63432C]抢购剩余时间：[1d8e00]"..g_TimeCtrl:GetLeftTimeDHM(oLeftTime))
		else
			self.m_DescLbl:SetText("")
			-- self.m_DescLbl:SetText("[63432C]抢购剩余时间：[1d8e00]0")
		end
	elseif oServerData.status == 1 then
		local oLeftTime = oServerData.back_endtime - g_TimeCtrl:GetTimeS()
		if oLeftTime > 0 then
			self.m_DescLbl:SetText("[63432C]距离领取返利时间：[1d8e00]"..g_TimeCtrl:GetLeftTimeDHM(oLeftTime))
		else
			self.m_DescLbl:SetText("")
			-- self.m_DescLbl:SetText("[63432C]距离领取返利时间：[1d8e00]0")
		end
	elseif oServerData.status == 2 then
		self.m_DescLbl:SetText("")
		-- self.m_DescLbl:SetText("[63432C]距离领取返利时间：[1d8e00]0")
	elseif oServerData.status == 3 then
		self.m_DescLbl:SetText("")
	end
end

function CZeroBuyChenPart.SetPrizeList(self, oList)
	self:RefreshItemBox(oList)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyChenIndex]
	if not oServerData then
		return
	end

	local optionCount = #oList
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
			self:SetPrizeBox(oPrizeBox, oList[i], oServerData.status == 0, i)
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

function CZeroBuyChenPart.SetPrizeBox(self, oPrizeBox, oData, oIsNotGet, oIndex)
	oPrizeBox:SetActive(true)
    oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
    oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
    oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
    oPrizeBox.m_RewardSp = oPrizeBox:NewUI(4, CSprite)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
    oPrizeBox.m_IconSp:SpriteItemShape(oData.item.icon)
    oPrizeBox.m_Data = oData
    if oData.amount > 0 then
        oPrizeBox.m_CountLbl:SetActive(true)
        oPrizeBox.m_CountLbl:SetText(oData.amount)
    else
        oPrizeBox.m_CountLbl:SetActive(false)
    end
    if oIsNotGet then
    	oPrizeBox.m_RewardSp:SetActive(false)
    else
    	oPrizeBox.m_RewardSp:SetActive(true)
    end

    oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, oPrizeBox, oData))

	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
end

function CZeroBuyChenPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CZeroBuyChenPart.OnClickBuyBtn(self)
	nethuodong.C2GSZeroYuanBuy(g_ZeroBuyCtrl.m_ZeroBuyChenIndex)
end

function CZeroBuyChenPart.OnClickBuyGetBtn(self)
	
end

function CZeroBuyChenPart.OnClickGoldBuyBtn(self)
	nethuodong.C2GSZeroYuanReward(g_ZeroBuyCtrl.m_ZeroBuyChenIndex)
end

return CZeroBuyChenPart