local CRechargePart = class("CRechargePart", CPageBase)

function CRechargePart.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CRechargeItem)
	self.m_CashLabel = self:NewUI(3, CLabel)
	self.m_BuyGlodBtn = self:NewUI(4, CButton)
	self.m_RechargeTipBtn = self:NewUI(5, CButton)
	self.m_RebateBtn = self:NewUI(6, CButton)
	self.m_ItemGoldCoinClone = self:NewUI(7, CRechargeGoldCoinItem)
	-- self.m_RebatePart = self:NewUI(8, CRebateBox)
	self.m_RechargeWidget = self:NewUI(9, CWidget)
	self.m_YouhuiSp = self:NewUI(10, CSprite)
	self.m_FanliLbl = self:NewUI(11, CLabel)

	self.m_ItemDict = {}

	self:InitContent()
	self:InitGridBox()
end

function CRechargePart.OnInitPage(self)
	
end

function CRechargePart.InitContent(self)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnShopCtrlEvent"))
	g_RebateJoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRebateJoyEvent"))

	self.m_BuyGlodBtn:AddUIEvent("click", callback(self, "BuyGoldCallBack"))
	self.m_RebateBtn:AddUIEvent("click", callback(self, "RebateCallBack"))
	self.m_RechargeTipBtn:AddUIEvent("click", callback(self, "OpenTips"))
	self.m_CashLabel:AddUIEvent("click", callback(self, "OnClickIngot"))
	-- self.m_RebateBtn:SetActive(false)
	-- self.m_RechargeTipBtn:SetActive(false)
	self.m_ItemClone:SetActive(false)
	-- self.m_BuyGlodBtn:ForceSelected(true)
	self:RefreshYouhui()
	self:RefreshGoldCoin()

	self.m_RebateBtn.m_IgnoreCheckEffect = true
	self:UpdateRebateRedPoint()
end

function CRechargePart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData.dAttr.goldcoin or oCtrl.m_EventData.dAttr.rplgoldcoin then
			self:RefreshGoldCoin()
		end
	end
end

function CRechargePart.OnWelfareCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateYuanbaoPnl then
        for _, info in ipairs(oCtrl.m_EventData) do
            self:RefreshChargeItem(info)
        end
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
    	self:UpdateRebateRedPoint()
	end
end

function CRechargePart.OnShopCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.RefreshChargeItem then
        self:RefreshChargeItem(oCtrl.m_EventData)
	end
end

function CRechargePart.OnCtrlRebateJoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RebateJoy.Event.RelGoldCoinGift then
		self:RefreshYouhui()
	end
end

function CRechargePart.RefreshYouhui(self)
	local bIsShow = g_RebateJoyCtrl:CheckIsShopYouhui()
	self.m_YouhuiSp:SetActive(bIsShow)
	if bIsShow then
		self.m_FanliLbl:SetText("[244B4E]您当前有#G"..(g_RebateJoyCtrl.m_ActualFanliMultiple).."#n倍充值返利机会")
	else
		self.m_FanliLbl:SetText("")
	end
end

function CRechargePart.RefreshGoldCoin(self)
	self.m_CashLabel:SetCommaNum(g_AttrCtrl.goldcoin+g_AttrCtrl.rplgoldcoin)
end

function CRechargePart.RefreshChargeItem(self, info)
	local oItem = self.m_ItemDict[info.key]
	info.val = info.val or 0
	if oItem then
		if oItem.itemType == 1 then
			oItem:UpdateBuyCount(info.val)
		elseif oItem.itemType == 2 and 0 ~= info.val then	-- 元宝大礼
			oItem:SetActive(false)
			self.m_ItemGrid:Reposition()
		end
	end
end

function CRechargePart.InitGridBox(self)
	local oItem = nil
	local rechargelist = DataTools.GetStoreData(define.Currency.Type.GoldCoin)
	table.sort(rechargelist, function (a, b)
		return a.RMB < b.RMB
	end)
	for _, v in ipairs(rechargelist) do
		local goon = true
		-- if g_SdkCtrl:IsIOSNativePay() then
		-- 	if v.payid == "com.cilu.dhxx.gold_68" or v.payid == "com.cilu.dhxx.gold_488" then
		-- 		goon = false
		-- 	end
		-- end
		if goon then
			local bShow = true
			local sKey = "goldcoinstore_" .. v.id
			local iType = 1
			if v.spc_key and string.len(v.spc_key) > 0 then
				if DataTools.GetChargeData("YUANBAO", v.spc_key) then
					-- local iState = g_WelfareCtrl:GetChargeItemInfo(v.spc_key)
					-- if iState == 0 and v.spc_key ~= g_WelfareCtrl:GetGoldCoinBanId() then
					-- 	self.m_ItemClone = self.m_ItemGoldCoinClone
					-- 	sKey = v.spc_key
					-- 	iType = 2
					-- else
						bShow = false
					-- end
				end
			end
			if bShow then
				oItem = self.m_ItemClone:Clone(function()
					self:ItemCallBack(v)
				end)
				oItem:SetActive(true)
				oItem.itemType = iType
				oItem.itemKey = sKey
				oItem:SetBoxInfo(v)
				self.m_ItemGrid:AddChild(oItem)
			end
			self.m_ItemDict[sKey] = oItem
		end
	end
	self.m_ItemGrid:Reposition()
end

function CRechargePart.BuyGoldCallBack(self)
	self.m_BuyGlodBtn:ForceSelected(true)
	self:ShowPnl(1)
end

function CRechargePart.RebateCallBack(self)
	-- self.m_RebateBtn:ForceSelected(true)
	self:ShowPnl(2)
end

function CRechargePart.OpenTips(self)
	local zContent = {
		title = data.instructiondata.DESC[1005].title,
		desc = data.instructiondata.DESC[1005].desc,
	}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end
function CRechargePart.OnClickIngot(self)
	g_NotifyCtrl:ShowClickIngot( self.m_CashLabel)
end


function CRechargePart.ItemCallBack(self, v)
    table.print(v, "普通充值回调数据信息")
    if g_RebateJoyCtrl:CheckIsShopYouhui() then
    	local windowConfirmInfo = {
			msg = "您当前有"..(g_RebateJoyCtrl.m_ActualFanliMultiple).."倍返利机会，本次充值可额外获得"..((g_RebateJoyCtrl.m_ActualFanliMultiple-1)*v.gold_coin_gains).."绑定元宝返利，是否充值？",
			title = "提示",
			okCallback = function () 
				if v.payid and string.len(v.payid) > 0 then 
					g_PayCtrl:Charge(v.payid)
			    end
			end,	
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    else
		if v.payid and string.len(v.payid) > 0 then 
			g_PayCtrl:Charge(v.payid)
	    end
	end
end

function CRechargePart.ShowPnl(self, idx)
	-- self.m_RechargeWidget:SetActive(idx == 1)
	-- local bShowRebate = idx == 2
	-- self.m_RebatePart:SetActive(bShowRebate)
	-- if bShowRebate then
		-- self.m_RebatePart:InitInfo()
	-- end
	if idx == 2 then
		CChargeRebateView:ShowView()
	end
end

function CRechargePart.UpdateRebateRedPoint(self)
	local redState = g_WelfareCtrl:IsHadRebateRedPoint()
	if redState then
		self.m_RebateBtn:AddEffect("RedDot", 20, Vector2.New(-16, -16))
		self.m_RebateBtn:AddEffect("Rect")
	else
		self.m_RebateBtn:DelEffect("RedDot")
		self.m_RebateBtn:DelEffect("Rect")
	end
end

return CRechargePart