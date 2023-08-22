local CZeroBuyFlyPart = class("CZeroBuyFlyPart", CPageBase)

function CZeroBuyFlyPart.ctor(self, obj)
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
	self.m_FlyBtn = self:NewUI(10, CButton)
	
	self:InitContent()
end

function CZeroBuyFlyPart.InitContent(self)
	self.m_BuyBtn.m_IgnoreCheckEffect = true
	self.m_GoldGetBtn.m_IgnoreCheckEffect = true
	self.m_PrizeBoxClone:SetActive(false)
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
	self.m_BuyGetBtn:AddUIEvent("click", callback(self, "OnClickBuyGetBtn"))
	self.m_GoldGetBtn:AddUIEvent("click", callback(self, "OnClickGoldBuyBtn"))
	g_ZeroBuyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnZeroBuyEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self,"OnWelfareEvent"))

	self:RefreshUI()
end

function CZeroBuyFlyPart.OnZeroBuyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ZeroBuy.Event.UpdateInfo then
		self:RefreshUI()
	end
end

function CZeroBuyFlyPart.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
		self:RefreshTime()
	end
end

function CZeroBuyFlyPart.RefreshUI(self)
	self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("ZEROYUAN", data.zerobuydata.ACTIVITY[g_ZeroBuyCtrl.m_ZeroBuyFlyIndex].reward_id))

	self:RefreshActorTexture()
	self:RefreshButton()
	self:RefreshTime()
end

function CZeroBuyFlyPart.RefreshActorTexture(self)
	local oShape = data.ridedata.RIDEINFO[data.zerobuydata.CONFIG[1].flyfigureid].shape 
    local model_info = {}
    model_info.ignoreClick = true
    model_info.shape = data.modeldata.CONFIG[oShape] and data.modeldata.CONFIG[oShape].model or 1110
    model_info.rendertexSize = 1.5
    self.m_ActorTexture:ChangeShape(model_info, function () end)
end

function CZeroBuyFlyPart.RefreshButton(self)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyFlyIndex]
	if not oServerData then
		return
	end
	self.m_RewardSp:SetActive(true)
	self.m_GoldGetBtn:DelEffect("RedDot")
	self.m_FlyBtn:DelEffect("RedDot")
	if oServerData.status == 0 then
		self.m_BuyBtn:SetActive(true)
		self.m_GoldGetBtn:SetActive(false)
		self.m_BuyBtn:SetText("立即抢购")
		self.m_RewardSp:SetActive(false)
	elseif oServerData.status == 1 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(true)
	elseif oServerData.status == 2 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(true)
		self.m_GoldGetBtn:AddEffect("RedDot", 25, Vector2(-18, -18))
		self.m_FlyBtn:AddEffect("RedDot", 25, Vector2(-25, -25))
	elseif oServerData.status == 3 then
		self.m_BuyBtn:SetActive(false)
		self.m_GoldGetBtn:SetActive(false)
	end
end

function CZeroBuyFlyPart.RefreshTime(self)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyFlyIndex]
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

function CZeroBuyFlyPart.SetPrizeList(self, oList)
	local oServerData = g_ZeroBuyCtrl.m_ZeroInfoHashList[g_ZeroBuyCtrl.m_ZeroBuyFlyIndex]
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
			self:SetPrizeBox(oPrizeBox, oList[i], oServerData.status == 0)
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

function CZeroBuyFlyPart.SetPrizeBox(self, oPrizeBox, oData, oIsNotGet)
	oPrizeBox:SetActive(true)
    oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
    oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
    oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
    oPrizeBox.m_RewardSp = oPrizeBox:NewUI(4, CSprite)

    oPrizeBox.m_QualitySp:SetActive(false)
    if oData.type == 1 then
		oPrizeBox.m_QualitySp:SetActive(true)
		oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
		oPrizeBox.m_IconSp:SpriteItemShape(oData.item.icon)	
	elseif oData.type == 2 then
		oPrizeBox.m_IconSp:SpriteAvatar(oData.partner.shape)
	elseif oData.type == 3 then
		oPrizeBox.m_IconSp:SpriteAvatar(oData.ride.shape)
	end

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

function CZeroBuyFlyPart.OnClickPrizeBox(self, oPrize, oPrizeBox, oData)
    if oData.type == 1 then
		local args = {
	        widget = oPrizeBox,
	        side = enum.UIAnchor.Side.Top,
	        offset = Vector2.New(0, 0)
	    }
	    g_WindowTipCtrl:SetWindowItemTip(oData.item.id, args)
	elseif oData.type == 2 then
		g_PartnerCtrl.m_PartnerNotSelectFirst = true
		CPartnerMainView:ShowView(function (oView)
			oView:ResetCloseBtn()
			oView:SetSpecificPartnerIDNode(oData.partner.id)
		end)
	elseif oData.type == 3 then
		CHorseMainView:ShowView(function (oView)
			oView:ShowSpecificPart(oView:GetPageIndex("detail"))
			oView:ChooseDetailPartHorse(oData.ride.id)
		end)
	end
end

function CZeroBuyFlyPart.OnClickBuyBtn(self)
	local oCost = data.zerobuydata.ACTIVITY[g_ZeroBuyCtrl.m_ZeroBuyFlyIndex].pay
	if oCost > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
        g_QuickGetCtrl:OnShowNotEnoughGoldCoin()
    else
        local windowConfirmInfo = {
			msg = "是否花费"..oCost.."#cur_1购买飞行坐骑礼包？",
			title = "提示",
			okCallback = function () nethuodong.C2GSZeroYuanBuy(g_ZeroBuyCtrl.m_ZeroBuyFlyIndex) end,	
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    end	
end

function CZeroBuyFlyPart.OnClickBuyGetBtn(self)
	
end

function CZeroBuyFlyPart.OnClickGoldBuyBtn(self)
	nethuodong.C2GSZeroYuanReward(g_ZeroBuyCtrl.m_ZeroBuyFlyIndex)
end

return CZeroBuyFlyPart