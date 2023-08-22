local ItemButtonBox = class("ItemButtonBox", CBox)

function ItemButtonBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_Callback = cb
	self.m_CItem = nil
	self.m_LeftBtn = self:NewUI(1, CButton)
	self.m_RightBtn = self:NewUI(2, CButton)
	self.m_BtnPrefab = self:NewUI(3, CButton)
	self.m_LBtnTable = self:NewUI(4, CTable)
	self.m_MoreSprite = self:NewUI(5, CSprite)
	self.m_LeftBtnLabel = self:NewUI(6, CLabel)
	self.m_RightBtnLabel = self:NewUI(7, CLabel)
	self.m_CenterBtn = self:NewUI(8, CButton)
	self.m_CenterBtnLabel = self:NewUI(9, CLabel)
	self.m_GainWayBtn = self:NewUI(10, CLabel)

	self.m_TempBagBtn = self:NewUI(11,CButton)
	self.m_RightBtnCb = nil
	self.m_CenterBtnCb = nil
	self.m_IsHideBtn = true
	self.m_BtnPrefab:SetActive(false)

	self.itemUseTimes = 0

	self.m_QiYinItemId = 10181
end

function ItemButtonBox.SetInitBox(self, citem)
	self.m_CItem = citem
	self.m_GuildItem = DataTools.GetEcononmyGuildItem(citem.m_SID)

	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnShowBtnList"))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnClickRightBtn"))
	self.m_CenterBtn:AddUIEvent("click", callback(self, "OnClickCenterBtn"))
	self.m_GainWayBtn:AddUIEvent("click", callback(self, "OpenGainWay"))

	self.m_IsShowBtnList = false
	self.m_TempBagBtn:SetActive(false)
	self:InitRightButton()
	self:InitCenterButton()
	self:InitLeftButton()

	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEcononmyEvent"))
end

function ItemButtonBox.OnCtrlEcononmyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallSellGrid then
		if self.m_IsOpenStall then
			self:OpenStallView()
		end
	end
end

-- 绑定父节点，用以初始化坐标
function ItemButtonBox.SetParentNode(self, obj)
	self:SetParent(obj.m_Transform)
	self:SetLocalPos(Vector3.New(0, 0, 0))
end

function ItemButtonBox.ShowGainBtn(self)
	self.m_LeftBtn:SetActive(false)
	self.m_RightBtn:SetActive(false)
	self.m_CenterBtn:SetActive(false)
	self.m_GainWayBtn:SetActive(true)
end

-- 控制按钮显示
function ItemButtonBox.ShowCenterBtn(self, bIsShow)
	self.m_LeftBtn:SetActive(not bIsShow and not self.m_IsHideBtn)
	self.m_RightBtn:SetActive(not bIsShow and not self.m_IsHideBtn)
	self.m_CenterBtn:SetActive(bIsShow and not self.m_IsHideBtn)
	self.m_GainWayBtn:SetActive(false)
end

-- 按钮初始化，默认根据Citem生成，特殊按钮可以自行setXXXButton，
function ItemButtonBox.InitRightButton(self)
		if self.m_CItem:IsEquip() then
			if not self.m_CItem:IsEquiped() then
				self:SetRightButton("装备", callback(self, "RequestUseItem"))
			else
				self:SetRightButton("卸下", callback(self, "RequestUseItem"))
			end
		elseif self.m_CItem:IsWenShi() then
			self:SetRightButton("镶嵌", callback(self, "UseWenShiItem"))
		else 
			if self.m_CItem:GetCValueByKey("clientExtra") == "use" then
				self:SetRightButton("使用", callback(self, "RequestUseItem"))
			end
		end
end

function ItemButtonBox.InitCenterButton(self)
	if self.m_CItem:IsEquip() then
		if self.m_CItem:IsEquiped() then
			self:SetCenterButton("卸下", callback(self, "RequestUseItem"))
		else 
			self:SetCenterButton("装备", callback(self, "RequestUseItem"))
		end
	else
		local sid = self.m_CItem:GetCValueByKey("id")
		if self.m_CItem:GetCValueByKey("clientExtra") == "use" then
			--是否是集字换礼
			local bIsWordItem = g_ItemCtrl:IsStaleDatedWordItem(sid)
			if not bIsWordItem then
				self:SetCenterButton("使用", callback(self, "RequestUseItem"))
			else
				local status = g_WelfareCtrl:GetCollectGiftStatus()

				if status and status ~= 0 then
					self:SetCenterButton("使用", callback(self, "RequestUseItem"))	
				else
					self:SetCenterButton("出售", callback(self, "RequestSalePrice"))
				end
			end
		elseif self.m_CItem:IsSellEnable() then
			self:SetCenterButton("出售", callback(self, "RequestSalePrice"))
		end
	end
end

function ItemButtonBox.SetRightButton(self, sText, cb)
	self.m_RightBtnLabel:SetText(sText)
	self.m_RightBtnCb = cb
	self.m_IsHideBtn = false
end

function ItemButtonBox.SetCenterButton(self, sText, cb)
	self.m_CenterBtnLabel:SetText(sText)
	self.m_CenterBtnCb = cb
	self.m_IsHideBtn = false
end

--初始化左边按钮列表，后期有按钮增减需求自行添加
function ItemButtonBox.InitLeftButton(self)
	-- 后期添加装备修理之类按钮
	local btnList = {}
	if self.m_CItem:GetCValueByKey("clientExtra") == "use" then
		self:InitCommonLeftButton(btnList)
	elseif self.m_CItem:IsEquip() then
		self:InitEquipLeftButton(btnList)
	elseif self.m_CItem:IsWenShi() then  
		self:InitWenShiLeftButton(btnList)
	end

	local listCount = #btnList
	self:ShowCenterBtn(listCount < 1)

	if listCount == 1 then
		self.m_LeftBtnLabel:SetLocalPos(Vector3.New(0,0,0))
		self.m_LeftBtnLabel:SetText(btnList[1].name)
		self.m_MoreSprite:SetActive(false)
		self.m_LeftBtn:AddUIEvent("click", callback(self, btnList[1].callback))
		self.m_LeftBtn:SetBtnGrey(btnList[1].grey)
	else
		self.m_LBtnTable:SetActive(false)
		self.m_LeftBtnLabel:SetText("更多")
		self.m_LeftBtnLabel:SetLocalPos(Vector3.New(-16,0,0))
		self.m_MoreSprite:SetActive(true)
		self:CreatePopButtons(btnList)
		self.m_LBtnTable:Reposition()
	end	

	self:SetBtnPos()
end

function ItemButtonBox.InitCommonLeftButton(self, btnList)
	-- if self.m_CItem:GetCValueByKey("giftable") == 0 then
	-- 	table.insert(btnList, {name = "赠送", callback = "RequestGiftable"})
	-- end
	local sid = self.m_CItem:GetCValueByKey("id")
	if g_ItemCtrl:IsStaleDatedWordItem(sid) then --集字
		return
	end

	if #self.m_CItem:GetCValueByKey("gainWayIdStr") > 0 then
		table.insert(btnList, {name = "获取", callback = "OpenGainWay"})
	end
	--TODO:摆摊条件不完整，待补充装备评分
	if self.m_CItem:IsStallEnable() then
		table.insert(btnList, {name = "摆摊", callback = "RequestStallInfo"})
	end
	if self.m_CItem:IsComposeEnable() or self.m_CItem:IsMixEnable() or self.m_CItem:IsComposWenShi() then
		table.insert(btnList, {name = "合成", callback = "RequestComposeItem"})
	end
	-- if self.m_CItem:IsMixEnable() then
	-- 	table.insert(btnList, {name = "混合", callback = "RequestMixItem"})
	-- end
	if self.m_CItem:IsSellEnable() then
		table.insert(btnList, {name = "出售", callback = "RequestSalePrice"})
	end
	if self.m_CItem:IsDeComposeEnable() then
		table.insert(btnList, {name = "分解", callback = "RequestDecomposeItem"})
	end	

	if self.m_CItem:IsGemStoneChangeEnable() then
		table.insert(btnList, {name = "转化", callback = "RequestChangeAttr"})
	end	
	local iValue = self.m_CItem:GetRefineValue()
	if iValue and iValue > 0 then
		table.insert(btnList, {name = "炼化", callback = "OpenRefineView"})
	end
	-- 结婚喜糖
	if self.m_CItem:GetCValueByKey("id") == 10148 then
		table.insert(btnList, {name = "赠送", callback = "OpenXTGiftView", grey = self.m_CItem:IsBinding()})
	end
	if self.m_CItem:IsExchangeEnable() then
		local oBtnName = "兑换"
		if self.m_CItem:GetCValueByKey("id") == self.m_QiYinItemId then
			oBtnName = "寻龙令"
		end
		table.insert(btnList, {name = oBtnName, callback = "RequestExchItem"})
	end
end

function ItemButtonBox.InitEquipLeftButton(self, btnList)
	if self.m_CItem:GetEquipLast() < self.m_CItem:GetCValueByKey("last") then
	table.insert(btnList, {name = "修理", callback = "RequestFixEquip"})
	end

	local sid = self.m_CItem:GetCValueByKey("id")
	if not self.m_CItem:IsEquiped() then
		if self.m_CItem:IsSellEnable() then
			table.insert(btnList, {name = "出售", callback = "RequestSalePrice"})
		end

		if self.m_CItem:IsStallEnable() then
			table.insert(btnList, {name = "摆摊", callback = "RequestStallInfo"})
		end

		local iValue = self.m_CItem:GetRefineValue()
		if iValue and iValue > 0 then
			table.insert(btnList, {name = "炼化", callback = "OpenRefineView"})
		end

		-- http://oa.cilugame.com/redmine/issues/19530
		-- 50级以下的装备不能分解不要显示分解按钮
		if self.m_CItem:IsDeComposeEnable() then
			table.insert(btnList, {name = "分解", callback = "RequestDecomposeItem"})
		end
	end

	local list = g_ItemCtrl.m_EquipedItems
	for k,v in pairs(list) do
		if v.m_ID == self.m_CItem.m_ID and self.m_CItem:GetSValueByKey("itemlevel") >= define.Item.Quality.Purple and 
			self.m_CItem:GetItemEquipLevel() >= g_ForgeCtrl.m_AttachSoulLimitLv then
			table.insert(btnList, {name = "附魂", callback = "OpenAttachSoulView"})
			break
		end
	end

	list = g_ItemCtrl:GetEquipList(g_AttrCtrl.school, g_AttrCtrl.sex, DataTools.GetEquipWashLvLimit(), nil, nil, g_AttrCtrl.race, g_AttrCtrl.roletype, true)
	for k,v in pairs(list) do
		if v.m_ID == self.m_CItem.m_ID then
			table.insert(btnList, {name = "洗炼", callback = "OpenWashView"})
			break
		end
	end

	if g_OpenSysCtrl:GetOpenSysState(define.System.EquipInlay) and self.m_CItem:GetItemEquipLevel() >= data.hunshidata.UNLOCK[1] then
		table.insert(btnList, {name = "镶嵌", callback = "OpenInlayView"})	
	end

	if self.m_CItem:IsEquiped() then
		table.insert(btnList, {name = "强化", callback = "OpenEquipStrengthView"})
	end
end

function ItemButtonBox.InitWenShiLeftButton(self, btnList)
	
	if #self.m_CItem:GetCValueByKey("gainWayIdStr") > 0 then
		table.insert(btnList, {name = "获取", callback = "OnClickWenShiGet"})
	end

	local iValue = self.m_CItem:GetRefineValue()
	if iValue and iValue > 0 then
		table.insert(btnList, {name = "炼化", callback = "OpenRefineView"})
	end

	table.insert(btnList, {name = "分解", callback = "OnClickFusionDecomposeBtn"})

	table.insert(btnList, {name = "洗炼", callback = "OnClickWashBtn"})

	table.insert(btnList, {name = "融合", callback = "OnClickFusionBtn"})

end

function ItemButtonBox.OnClickWenShiGet(self)
	
	CEcononmyMainView:ShowView(function ( oView )
		oView:ShowSubPageByIndex(oView:GetPageIndex("Guild"))
		oView:JumpToTargetItem(self.m_CItem.m_SID)
	end)

end

function ItemButtonBox.OnClickWashBtn(self)
	
	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseWenShiMainView:ShowView(function ( oView )
			oView:OpenWashPart(self.m_CItem.m_ID)
		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end  

end

function ItemButtonBox.OnClickFusionDecomposeBtn(self)
	
	 g_ItemCtrl:DeComposeItem(self.m_CItem.m_ID, 1)

end

function ItemButtonBox.OnClickFusionBtn(self)

	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseWenShiMainView:ShowView(function ( oView )
			oView:OpenFusionPart(self.m_CItem.m_ID)
		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end 

end

--设置按钮位置
function ItemButtonBox.SetBtnPos(self)
	self.m_RightBtn:ResetAndUpdateAnchors()
	self.m_LeftBtn:ResetAndUpdateAnchors()
	self.m_CenterBtn:ResetAndUpdateAnchors()
	local vPos = self.m_LeftBtn:GetLocalPos()
	self.m_LBtnTable:SetLocalPos(vPos + Vector3.New(0, 25, 0))
end

--实例化按钮
function ItemButtonBox.CreatePopButtons(self, btnList)	
	local oBtn = nil
	local iBtnCnt = #btnList
	local btnObjList = self.m_LBtnTable:GetChildList()
	for i = 1, iBtnCnt do
		oBtn = btnObjList[i]
		if not oBtn then
			oBtn = self.m_BtnPrefab:Clone()
			self.m_LBtnTable:AddChild(oBtn)
		end
		oBtn:SetActive(true)
		oBtn:SetText(btnList[i].name)
		oBtn:AddUIEvent("click", callback(self, btnList[i].callback))
	end
	local iObjCnt = #btnObjList
	if iObjCnt > iBtnCnt then
		for i = iBtnCnt + 1, iObjCnt do
			oBtn = btnObjList[i]
			oBtn:SetActive(false)
		end
	end
end

function ItemButtonBox.DoCallback(self)
	if self.m_Callback then
		self.m_Callback()
	end
end

function ItemButtonBox.OnShowBtnList(self)
	self.m_IsShowBtnList = not self.m_IsShowBtnList
	local flip = (self.m_IsShowBtnList and "Vertically") or "Horizontally"
	self.m_MoreSprite:SetFlip(enum.UISprite.Flip[flip])
	self.m_LBtnTable:SetActive(self.m_IsShowBtnList)
end

--按钮事件响应相关
function ItemButtonBox.OnClickRightBtn(self)
	if self.m_RightBtnCb then
		self.m_RightBtnCb()
	end
end

function ItemButtonBox.OnClickCenterBtn(self)
	if self.m_CenterBtnCb then
		self.m_CenterBtnCb()
	end
end

function ItemButtonBox.RequestGiftable(self)
	g_NotifyCtrl:FloatMsg("===赠送物品===")
end

function ItemButtonBox.RequestStallInfo(self)
	if self.m_CItem:IsEquip() and self.m_CItem:IsInlayGemStone() then
		g_NotifyCtrl:FloatMsg("镶嵌有宝石的装备无法摆摊")
		return
	end
	netstall.C2GSOpenStall()
	self.m_IsOpenStall = true
end

function ItemButtonBox.OpenStallView(self)
	-- g_NotifyCtrl:FloatMsg("===摆摊物品===")
	self.m_IsOpenStall = false

	local econonmyDefaultTabIndex = g_EcononmyCtrl:GetDefaultTabIndex()
	if not econonmyDefaultTabIndex then
		return
	end

	local stallOpen = g_EcononmyCtrl:IsSpecityTabOpen(define.Econonmy.Type.Stall)
	if not stallOpen then
		g_NotifyCtrl:FloatMsg("摆摊系统暂时关闭,敬请期待")
		return
	end

	printc("self.m_CItem", self.m_CItem.m_ID)
	g_EcononmyCtrl.m_JumpStallItem = self.m_CItem.m_ID
	CEcononmyMainView:ShowView(function(oView)
		oView:ShowSubPageByIndex(define.Econonmy.Type.Stall)
		oView.m_CurPage:ChangeTab(2)
	end)
	self:DoCallback()
	local oView = CItemMainView:GetView()
	if oView then
		oView:CloseView()
	end
end

function ItemButtonBox.RequestSalePrice(self)
	if self.m_GuildItem then
		CItemSaleView:ShowView(function(oView)
			oView:SetItemInfo(self.m_CItem)
		end)
		self:DoCallback()
	else
		CItemSaleView:ShowView(function(oView)
			oView:SetNotGuildItemInfo(self.m_CItem)
		end)
		self:DoCallback()
	end
end

function ItemButtonBox.OpenEquipDecomposeView(self)
	-- local iLevel = datauser.colordata.ITEM.Quality[self.m_CItem:GetSValueByKey("itemlevel")]
	-- local itemList = DataTools.GetDecomposeList(self.m_CItem)

	-- local sItems = ""
	-- for k,v in pairs(itemList) do
	-- 	local tItemData = DataTools.GetItemData(v.sid)
	-- 	local iQuality = datauser.colordata.ITEM.Quality[tItemData.quality]
	-- 	sItems = string.format("%s[c]%s%s[-][/c]%d~%d", sItems, iQuality, tItemData.name, v.minAmount, v.maxAmount)
	-- end
	-- local sDesc = string.format("是否要分解%s?,可以获得%s.",
	-- 	"[c]"..iLevel..self.m_CItem:GetCValueByKey("name").."[-][/c]", sItems)
	-- local windowConfirmInfo = {
	-- 	msg = sDesc,
	-- 	title = "分解道具",
	-- 	okCallback = function () self:RequestResolveItem(1) end,	
	-- 	okStr = "确定",
	-- 	cancelStr = "取消",
	-- }
	-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function ItemButtonBox.RequestDecomposeItem(self)
	printc("TODO >>> ===== 分解道具数量 =====", self.m_CItem:GetCValueByKey("name"))
	-- if self.m_CItem:GetSValueByKey("itemlevel") >= define.Item.Quality.Purple then
	-- 	local windowConfirmInfo = {
	-- 		msg = "[63432c]分解的装备中含有稀有装备，是否确定分解？[-]",
	-- 		title = "分解",
	-- 		okCallback = function () netitem.C2GSDeComposeItem(self.m_CItem.m_ID, 1) end,	
	-- 		okStr = "确定",
	-- 		cancelStr = "取消",
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	-- 	self:DoCallback()
	-- 	return
	-- end
	-- netitem.C2GSDeComposeItem(self.m_CItem.m_ID, 1)
	CItemComposeView:ShowView(function(oView)
		oView:JumpToDeCompose(self.m_CItem.m_ID)
	end)
	self:DoCallback()
end

function ItemButtonBox.RequestComposeItem(self)
	g_ItemCtrl:RequestComposeItem(self.m_CItem, callback(self, "DoCallback"))
end

function ItemButtonBox.RequestMixItem(self)
	CItemComposeView:ShowView(function(oView)
		oView:JumpToGemStoneMix(self.m_CItem)
	end)
	self:DoCallback()
end

function ItemButtonBox.UseWenShiItem(self)

	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseTongYuMainView:ShowView(function ( oView )	
			oView:OpenWenShiWearPart()
		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end 

end

function ItemButtonBox.RequestUseItem(self)
	local oView = CItemTipsView:GetView()
	if oView and self.m_CItem:IsGiftItem() and 
		self.m_CItem:GetCValueByKey("gift_type") == define.Item.GiftType.Optional then
		oView:OpenGiftSelBox()
		return
	end

	local itemdata = DataTools.GetItemData(self.m_CItem.m_SID)
	local isConinuousUse = itemdata.canContinuousUse == 1

	local bIsNormal = g_ItemViewCtrl:RequestUseItem(self.m_CItem, isConinuousUse)

	if bIsNormal then

		--订婚戒指礼包特殊处理--
		if self.m_CItem:IsEngageRingGift() then
			--寻路至红娘npc
			g_MapTouchCtrl:WalkToGlobalNpc(5229)
			CItemMainView:CloseView()
			return
		end

		--纹饰精华使用特殊处理----
		if self.m_CItem:IsWenShiJingHua() then 
			g_WenShiCtrl:CheckOpenWenShiWashView()
			return
		end 

		local iAmount = self.m_CItem:GetSValueByKey("amount")
		if iAmount > 0 then
			if self.m_CItem:IsEquip() then
				if self.m_CItem:IsEquiped() then
					netitem.C2GSItemUse(self.m_CItem:GetSValueByKey("id"), nil, "EQUIP:U")
				else
					netitem.C2GSItemUse(self.m_CItem:GetSValueByKey("id"), nil, "EQUIP:W")
					--local text = data.textdata.ITEM[1039].content
					--g_NotifyCtrl:FloatMsg(text) --换装提示
				end
			else
				--个别道具支持批量使用，即连续使用两次后，弹出二次确认框提示全部使用,点击确定则等于1次使用多个该道具,使用数量取决于当日最大使用量
				if self.itemUseTimes >= 2 and iAmount >= 2 then

					local function useAllItem()
						local itemList = {{itemid = self.m_CItem:GetSValueByKey("id"), amount = iAmount}}
						netitem.C2GSItemListUse(itemList)
					end

					local name = self.m_CItem:GetSValueByKey("name")
					local args = {	msg = "您要使用全部的"..name.."吗", 
									title	= "全部使用", 							 
								  	okCallback = useAllItem
								 }

					g_WindowTipCtrl:SetWindowConfirm(args)
					self:DoCallback()
				else
					netitem.C2GSItemUse(self.m_CItem:GetSValueByKey("id"))
					self.itemUseTimes = self.itemUseTimes + 1
				end				
			end
		end
		if iAmount <= 1 then
			self:DoCallback()
		end
	end
end

function ItemButtonBox.RequestFixEquip(self )
	netitem.C2GSFixEquip(self.m_CItem:GetSValueByKey("pos"))
	self:DoCallback()
end

function ItemButtonBox.OpenEquipStrengthView(self)
	CForgeMainView:ShowView(
		function(oView)
			local iTab = oView:GetPageIndex("Strengthen")
			oView:ShowSubPageByIndex(iTab, self.m_CItem:GetCValueByKey("equipPos"))
		end
	)
end

function ItemButtonBox.OpenAttachSoulView(self)
	CForgeMainView:ShowView(
		function(oView)
			local iTab = oView:GetPageIndex("Attach")
			oView:ShowSubPageByIndex(iTab, self.m_CItem.m_ID)
		end
	)
end

function ItemButtonBox.OpenWashView(self)
	CForgeMainView:ShowView(
		function(oView)
			local iTab = oView:GetPageIndex("Wash")
			oView:ShowSubPageByIndex(iTab, self.m_CItem.m_ID)
		end
	)
end

function ItemButtonBox.OpenGainWay(self)
	local oView = CItemTipsView:GetView()
	if oView then
		oView:OpenGainWayView()
	end
end

function ItemButtonBox.OpenRefineView(self)
	local bIsSysOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Vigor, true) 
	if not bIsSysOpen then
		return
	end
	CItemBatchRefineView:ShowView(function(oView)
		oView:SetSelectedItem(self.m_CItem.m_ID)
	end)
end

function ItemButtonBox.RequestChangeAttr(self)
	CItemGemStoneChangeView:ShowView(function(oView)
		oView:SetItem(self.m_CItem)
	end)
	self:DoCallback()
end

function ItemButtonBox.OpenInlayView(self)
	CForgeMainView:ShowView(
		function(oView)
			local iTab = oView:GetPageIndex("Inlay")
			oView:ShowSubPageByIndex(iTab, self.m_CItem.m_ID)
		end
	)
end

function ItemButtonBox.RequestExchItem(self)
	local sid = self.m_CItem.m_SID
	g_ItemCtrl:RequestExcItem(sid)
end

function ItemButtonBox.OpenXTGiftView(self)
	if self.m_CItem:IsBinding() then
		g_MarryCtrl:MarryFloatMsg(2051)
		return
	end
	g_MarryCtrl:OpenXTGiftView()
	local oView = CItemTipsView:GetView()
	if oView then
		oView:CloseView()
	end
end

return ItemButtonBox