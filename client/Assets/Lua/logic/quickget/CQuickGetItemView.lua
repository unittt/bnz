local CQuickGetItemView = class("CQuickGetItemView", CViewBase)

function CQuickGetItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/QuickGet/QuickGetItemView.prefab", cb)
	self.m_ExtendClose = "Pierce"
	self.m_DepthType = "Dialog"
end

function CQuickGetItemView.OnCreateView(self)
	-- body
	self.m_Grid	    = self:NewUI(1, CGrid)
	self.m_Item     = self:NewUI(2, CBox)
	self.m_OKBtn  = self:NewUI(3, CButton)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_BgSpr 	= self:NewUI(5, CSprite)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_BgHeight = self.m_BgSpr:GetHeight()

	self.m_Currencys = nil
    self.m_ExchangeCnt = 0
    self.m_MoneyType = nil

	self:InitContent()
end

function CQuickGetItemView.InitContent(self)
	self.m_Item:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnClickOKBtn"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CQuickGetItemView.OnClickOKBtn(self)
	-- TODO:需后期改成统一的道具快捷购买，不建议单系统的cb处理
	-- 需求是购买后直接消耗，故做不了通用，需单系统处理
	if self.m_ExchangeCb then
		self.m_ExchangeCb(self.m_ExchangeCnt, self.m_MoneyType)
		self.m_Callback = nil
	end
	--self.m_NeedCloseViwe字段控制是否关闭界面
	if self.m_NeedCloseViwe then
		self:CloseView()
	end
end

function CQuickGetItemView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		if self.m_NeedChangeCb then
			self.m_NeedChangeCb()
		end
	end
end

function CQuickGetItemView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if self.m_NeedChangeCb then
			self.m_NeedChangeCb()
		end
    end
end

function CQuickGetItemView.OnQuickGetCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.ReceiveQuickBuyPrice then
        local dInfo = oCtrl.m_EventData
        if dInfo and self.m_PriceDict and self.m_PriceDict[dInfo.sid or 0] then
            self.m_PriceDict[dInfo.sid].price = dInfo
            self:RefreshExchCost()
        end
    elseif oCtrl.m_EventID == define.Item.Event.ReceiveQuickBuyPriceList then
        local infoList = oCtrl.m_EventData
        local bRefresh = false
        local dItem = nil
        for _, dInfo in ipairs(infoList) do
            dItem = self.m_PriceDict[dInfo.sid or 0]
            if dItem then
                dItem.price = dInfo
                bRefresh = true
            end
        end
        if bRefresh then
            self:RefreshExchCost()
        end
    end
end

function CQuickGetItemView.InitAllInfo(self, args)
	self.m_NeedChangeCb = args.needChangeCb
	self.m_ShowCallback = args.showCb
	self.m_HideCallback = args.hideCb
	self.m_ExchangeCb = args.exchangeCb
	self.m_NeedCloseViwe = true
	self.m_AllBuy = args.allBuy and true or false
	if g_QuickGetCtrl:IsLackCoin(args.coinlist) then
		self:SetCallback(function()
            g_QuickGetCtrl:ShowCostExchView(function (oView)
                oView:InitCoinInfo(args.coinlist)
            end)
		end)
	end
	self:InitItemInfo(args.itemlist, args.exchangeCost, args.coinlist, args.depthType)
end

function CQuickGetItemView.InitItemInfo(self, itemlist, exchangeCost, currencys, oDepthType)
	--TODO
	local bCanExchange = false
	local tBtnStr = ""
	self.m_Currencys = currencys
    if g_KuafuCtrl:IsInKS() then
        self.m_OKBtn:SetActive(false)
        self.m_BgSpr:SetHeight(self.m_BgHeight - 30)
	elseif exchangeCost then
		if type(exchangeCost) == "number" and exchangeCost > 0 then
			bCanExchange = true
			tBtnStr = exchangeCost.."#cur_1购买"
		elseif type(exchangeCost) == "string" and string.len(exchangeCost) > 0 then
			bCanExchange = true
			tBtnStr = exchangeCost
		end
		self.m_OKBtn:SetActive(bCanExchange)
		self.m_BgSpr:SetHeight(bCanExchange and self.m_BgHeight or (self.m_BgHeight - 30))
	else
		self:InitExchCost(itemlist)
	end

	if bCanExchange then
		self.m_OKBtn:SetText(tBtnStr)
	end

	local totalList = table.copy(itemlist)
	if currencys and next(currencys) then
		table.extend(totalList, currencys)
	end
	self.m_Grid:Clear()
	local list = self.m_Grid:GetChildList()
	local oGrid = self.m_Grid.m_UIGrid
	local pos = self.m_Grid:GetLocalPos()
	if #totalList > 3 then
		oGrid.pivot = enum.UIWidget.Pivot.Left
		oGrid.cellWidth = 110
		pos.x = -144
		self.m_ScrollView.m_UIScrollView.enabled = true
	else
		oGrid.pivot = enum.UIWidget.Pivot.Center
		oGrid.cellWidth = 120
		pos.x = 0
		self.m_ScrollView.m_UIScrollView.enabled = false
	end
	self.m_Grid:SetLocalPos(pos)
    local i = 1
	for _,v in ipairs(totalList) do
        local bShow = true
        if v.sid == 1001 and g_AttrCtrl.gold >= v.amount then
            bShow = false
        elseif v.sid == 1002 and g_AttrCtrl.silver >= v.amount then
            bShow = false
        end
        if bShow then
    		local cell = nil
    		if i>#list then	
    			cell = self.m_Item:Clone()
    			self.m_Grid:AddChild(cell)
    			cell:SetGroup(self.m_Grid:GetInstanceID())
    			cell.icon = cell:NewUI(1, CSprite)
    			cell.amount  = cell:NewUI(2, CLabel)
    			cell.name = cell:NewUI(3, CLabel)
    			cell.qualitySpr = cell:NewUI(4, CSprite)
    			cell.count  = cell:NewUI(5, CLabel)
    			local itemdata = DataTools.GetItemData(v.sid, "VIRTUAL")
    			local bVirtual = itemdata and true or false
    			itemdata = itemdata or DataTools.GetItemData(v.sid)
    			cell.icon:SpriteItemShape(itemdata.icon)
    			local iAmount, iCount = tonumber(v.count or g_ItemCtrl:GetBagItemAmountBySid(v.sid)), tonumber(v.amount or 0)
    			cell.amount:SetActive(not bVirtual)
    			if bVirtual then
    				cell.count:SetText(string.format("[c][ffb398]%d[-][/c]", iCount - iAmount))
                    cell.count:SetEffectColor(Color.RGBAToColor("cd0000"))
    			else
    				cell.count:SetText(string.format("/%d", iCount, iAmount))
                    cell.count:SetEffectColor(Color.RGBAToColor("003C41"))
    				cell.amount:SetText("[ffb398]"..iAmount)
            		cell.amount:SetEffectColor(Color.RGBAToColor("cd0000"))
    			end
    			cell.name:SetText(itemdata.name)
    			cell.icon:AddUIEvent("click", callback(self, "OpenTipView", v.sid, oDepthType))
    			cell.qualitySpr:SetItemQuality(itemdata.quality)
    			cell:SetActive(true)
    		else
    			cell = list[i]
    		end
            i = i + 1
        end
	end
end

function CQuickGetItemView.OpenTipView(self, sid, oDepthType)
 	-- local oView = CQuickGetTipView:ShowView(function (oView)
 	-- 	-- body
 	-- 	oView:InitItemInfo(sid)
 	-- end)
	--TODO:临时替换旧的跳转
	g_WindowTipCtrl:SetWindowGainItemTip(sid, nil, nil, nil, oDepthType)
end

function CQuickGetItemView.InitExchCost(self, items)
	if not items or #items < 1 then return end
	self.m_PriceDict = {}
    local bMul = #items > 1
    local askList
    if bMul then
        askList = {}
    end
	for i, v in ipairs(items) do
		local sid = v.sid
		local dPrice = g_QuickGetCtrl:GetQuickBuyPriceInfo(sid, bMul)
		self.m_PriceDict[sid] = {
			id = sid,
			cnt = v.amount,
			price = dPrice,
		}
        if bMul and not dPrice then
            table.insert(askList, sid)
        end
	end
    if askList then
        if #askList > 1 then
            g_QuickGetCtrl:AskPriceInfoList(askList)
        elseif #askList == 1 then
            g_QuickGetCtrl:GetQuickBuyPriceInfo(askList[1])
        end
    end
    self:RefreshExchCost()
	g_QuickGetCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnQuickGetCtrlEvent"))
end

function CQuickGetItemView.RefreshExchCost(self)
	if not self.m_PriceDict or not next(self.m_PriceDict) then return end
	local bShow = true
	for k, dItem in pairs(self.m_PriceDict) do
        local dPrice = dItem.price
        if dPrice and (not dPrice.price or dPrice.price <= 0) then
            bShow = false
            break
        end
	end
	if bShow then
		local currencys = g_QuickGetCtrl:ConvertItem2Currency(self.m_Currencys)
		local iTotal, iMoneyType = g_QuickGetCtrl:GetTotalGoldCoinCost(self.m_PriceDict, currencys, self.m_AllBuy)
		if iTotal > 0 then
            local sCost = CQuickGetCostHelp.GetCostText(iMoneyType)
			self.m_OKBtn:SetText(string.format("%d%s购买", iTotal, sCost))
			self.m_Callback = nil
		end
		bShow = iTotal > 0
		self.m_MoneyType = iMoneyType
        self.m_ExchangeCnt = iTotal
	end
	self.m_OKBtn:SetActive(bShow)
	self.m_BgSpr:SetHeight(bShow and self.m_BgHeight or (self.m_BgHeight - 30))
	return bShow
end

function CQuickGetItemView.SetCallback(self, cb)
	self.m_Callback = cb
end

function CQuickGetItemView.SetExchangeCallback(self, cb)
	self.m_ExchangeCb = cb
end

function CQuickGetItemView.Destroy(self)
	if self.m_Callback then
		self.m_Callback()
		self.m_Callback = nil
	end
	g_QuickGetCtrl.m_IsLackItem = false
	CViewBase.Destroy(self)
end

function CQuickGetItemView.OnShowView(self)
	if self.m_ShowCallback then
		self.m_ShowCallback()
		self.m_ShowCallback = nil
	end
end

function CQuickGetItemView.OnHideView(self)
	if self.m_HideCallback then
		self.m_HideCallback()
		self.m_HideCallback = nil
	end
end

return CQuickGetItemView