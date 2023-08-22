local CItemQuickUseView = class("CItemQuickUseView", CViewBase)

function CItemQuickUseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/QuickUseView.prefab", cb)
	self.m_DepthType = "Login"
	self.m_ItemUseTimeList = {}
end

function CItemQuickUseView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_FunctionBtn = self:NewUI(4, CButton)
	self.m_NameBtn = self:NewUI(5, CLabel)
	self.m_ItemBorderSpr = self:NewUI(6, CSprite)
	self.m_ClickWidget = self:NewUI(7, CWidget)
	self.m_AmountLbl = self:NewUI(8, CLabel)

	self.m_ClickWidget:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_FunctionBtn:AddUIEvent("click", callback(self, "OnClickFunction"))
	self.m_ClickWidget:AddUIEvent("click", callback(self, "OnClose"))

	g_GuideCtrl:AddGuideUI("item_quickuse_btn", self.m_FunctionBtn)

	self.m_Item = nil
	self.m_UpgradePackItemid = nil
	self.m_Treasure = nil
	self.m_IsLingxi = nil
	self.m_IsGiftPack = false
	self.m_QuickUseList = {}
end

function CItemQuickUseView.OnClickFunction(self)
	if self.m_IsLingxi then
		local encodePos = netscene.EncodePos(g_MapCtrl:GetHero():GetPos())
		local posX, posY = g_LingxiCtrl:GetPutSeedPos(encodePos.x, encodePos.y)
		nettask.C2GSLingxiUseSeed(g_LingxiCtrl.m_Taskid, posX, posY)
		-- self:ActualCloseFunc()
		g_ItemCtrl:DelAllQuickUseDataByType(4)
		g_ItemCtrl:CheckQuickUseContent()
		return
	end
	
	printc("我快速使用，道具配置Id:"..self.m_Item:GetSValueByKey("sid"))
	printc("我快速使用，道具服务器Id:"..self.m_Item:GetSValueByKey("id"))

	if self.m_UpgradePackItemid then
		local oGrade = g_GuideHelpCtrl:CheckUseItemGrade(self.m_UpgradePackItemid)
		g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[oGrade] = nil
		g_GuideHelpCtrl.m_IsOnlineClickGradeGift[oGrade] = nil

		local list = {}
		if g_ItemCtrl.m_UpgardePackConfigList[oGrade] then
			for k,v in pairs(g_ItemCtrl.m_UpgardePackConfigList[oGrade]) do
				local oEquipItem = g_ItemCtrl:GetGuideEquipItemListBySid(v.sid)[1]
				if oEquipItem then
					table.insert(list, {itemid = oEquipItem:GetSValueByKey("id"), amount = 1})
				end
			end
		end
		netitem.C2GSItemListUse(list, g_AttrCtrl.pid, "EQUIP:W,UNEQUIPED:SELL")
		g_ItemCtrl:DelAllQuickUseDataByType(2)
		g_ItemCtrl:CheckQuickUseContent()
		g_GuideCtrl:OnTriggerAll()
		return
	end

	if self.m_Treasure then
		netopenui.C2GSUseAdvanceMap(self.m_Item:GetSValueByKey("id"))
		g_ItemCtrl:DelAllQuickUseDataByType(3)
		g_ItemCtrl:CheckQuickUseContent()
		return
	end

	local oUseGrade = g_GuideHelpCtrl:CheckUseItemGrade(self.m_Item:GetSValueByKey("sid"))
	if oUseGrade then
		g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[self.m_Item:GetSValueByKey("sid")] = true
	end

	local sid = self.m_Item:GetSValueByKey("sid")
	local itemdata = DataTools.GetItemData(sid)
	local isConinuousUse = itemdata.canContinuousUse == 1
	local bIsNormal = g_ItemViewCtrl:RequestUseItem(self.m_Item, true)
	
	if bIsNormal then
		if self.m_Item:IsEquip() then
			if self.m_Item:IsEquiped() then
				netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"), nil, "EQUIP:U")
			else
				netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"), nil, "EQUIP:W")
			end
			g_ItemCtrl:DelAllQuickUseDataBySid(sid)
			g_ItemCtrl:CheckQuickUseContent()
		else			
			--提示全部使用的弹框
			local oBagList = g_ItemCtrl:GetBagItemListBySid(sid)
			local iAmount = 0
			if oBagList then
				for _,v in ipairs(oBagList) do
					iAmount = iAmount + v:GetSValueByKey("amount")
				end
			end
			if iAmount > 2 and isConinuousUse and (self.m_ItemUseTimeList[sid] or 0) >= 2 then
				local function useAllItem()
					local itemList = {}
					if oBagList then
						for _,v in ipairs(oBagList) do
							table.insert(itemList, {itemid = v:GetSValueByKey("id"), amount = v:GetSValueByKey("amount")})
						end
					end
				    netitem.C2GSItemListUse(itemList)
			    end

				local name = self.m_Item:GetSValueByKey("name")
				local args = {	msg = "您要使用全部的"..name.."吗", 
								title	= "全部使用", 							 
						  		okCallback = useAllItem
							 }
				g_WindowTipCtrl:SetWindowConfirm(args)
				self.m_ItemUseTimeList[sid] = 0
			else
				netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"))
				self.m_ItemUseTimeList[sid] = (self.m_ItemUseTimeList[sid] or 0) + 1
			end
		end
	else
		g_ItemCtrl:DelAllQuickUseDataBySid(sid)
		g_ItemCtrl:CheckQuickUseContent()
	end

	g_GuideCtrl:OnTriggerAll()
end

--type 1普通道具 , 2 upgradepackitemid, 3 isTreasure, 4 isLingxi
function CItemQuickUseView.AddQuickUseData(self, oItem, upgradepackitemid, isTreasure, isLingxi)
	local dItemCfg = {
		item = oItem,
		upgradepackitemid = upgradepackitemid,
		isTreasure = isTreasure,
		isLingxi = isLingxi,
	}
	-- table.insert(self.m_QuickUseList, dItemCfg)

	if isLingxi then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, isLingxi = isLingxi, type = 4})
	elseif upgradepackitemid then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, upgradepackitemid = upgradepackitemid, type = 2})
	elseif isTreasure then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, isTreasure = isTreasure, type = 3})
	else
		local oSid = oItem:GetSValueByKey("sid")
		g_ItemCtrl:DelAllQuickUseDataBySid(oSid)
		local oBagItemList = g_ItemCtrl:GetBagItemListBySid(oSid)
		if oBagItemList and next(oBagItemList) then
			for k,v in pairs(oBagItemList) do
				table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = v, type = 1})
			end
		end		
	end
	g_ItemCtrl:CheckQuickUseContent()
end

--显示快捷使用的具体内容
function CItemQuickUseView.SetDataQuickUse(self, oItem, upgradepackitemid, isTreasure, isLingxi)
	self.m_IsLingxi = isLingxi
	self.m_UpgradePackItemid = upgradepackitemid
	self.m_Treasure = isTreasure
	
	--灵犀传的不是道具
	self.m_Item = oItem

	if self.m_IsLingxi then
		self.m_ClickWidget:SetActive(true)
		local itemConfig = DataTools.GetTaskItem(oItem.itemid)
		self.m_IconSprite:SpriteItemShape(itemConfig.icon)
		self.m_Amount = 1
		self:UpdataItemAmount()
		local sName = string.format("#G%s#n", itemConfig.name)
		self.m_NameLabel:SetRichText(sName, nil, nil, true)
		self.m_NameBtn:SetText("使用")
		self.m_NameBtn.m_UIWidget.spacingX = 15
		return
	end

	if self.m_UpgradePackItemid then
		--清除快捷使用的列表
		-- self.m_QuickUseList = {}

		self.m_IconSprite:SpriteItemShape(oItem:GetCValueByKey("icon"))
		self.m_Amount = 1
		self:UpdataItemAmount()
		--快捷使用道具的边框随等级显示
		local quick = oItem:GetQuality()
		local name = oItem:GetItemName()
		local sName = string.format(data.colorinfodata.ITEM[quick].color, name)
		self.m_NameLabel:SetRichText(sName, nil, nil, true)
		self.m_ItemBorderSpr:SetItemQuality(quick)
		self.m_NameBtn:SetText("一键穿戴")
		self.m_NameBtn.m_UIWidget.spacingX = 2
		g_GuideCtrl:OnTriggerAll()
		-- self.m_EquipList = DataTools.GetItemGiftList(self.m_UpgradePackItemid, g_AttrCtrl.roletype, g_AttrCtrl.sex)
		return
	end

	if self.m_Treasure then
		self.m_Amount = 1
	else
		local sid = self.m_Item:GetSValueByKey("sid")
		self.m_Amount = g_ItemCtrl:GetBagItemAmountBySid(sid) or 0
	end
	self:UpdataItemAmount()

	-- if g_GuideHelpCtrl:CheckUseItemGrade(oItem.itemid) then
	-- 	--清除快捷使用的列表
	-- 	self.m_QuickUseList = {}
	-- end

	self.m_IconSprite:SpriteItemShape(oItem:GetCValueByKey("icon"))
	--快捷使用道具的边框随等级显示
	local quick = oItem:GetQuality()
	local itemId = oItem:GetSValueByKey("sid")
	if itemId >= 10046 and itemId <= 10064 then  --特殊处理
	   quick = 0
	end

	local name = oItem:GetItemName()
	local sName = string.format(data.colorinfodata.ITEM[quick].color, name)
	self.m_NameLabel:SetRichText(sName, nil, nil, true)
	self.m_ItemBorderSpr:SetItemQuality(quick)
	self.m_NameBtn:SetText("使用")
	self.m_NameBtn.m_UIWidget.spacingX = 15

	g_GuideCtrl:OnTriggerAll()
end

function CItemQuickUseView.UpdataItemAmount(self)
	if self.m_Amount > 1 then
		self.m_AmountLbl:SetText(self.m_Amount)
	else
		self.m_AmountLbl:SetText("")
	end
end

function CItemQuickUseView.OnClickClose(self)
	g_ItemCtrl.m_ItemQuickUseWaitList = {}
	self:OnClose()
end

function CItemQuickUseView.OnClose(self)
	--暂时屏蔽
	-- if self.m_UpgradePackItemid and not g_GuideCtrl:IsGuideDone() then
	-- 	return
	-- end
	self.m_ItemUseTimeList = {}
	self:ActualCloseFunc()
end

function CItemQuickUseView.ActualCloseFunc(self)	
	self:CloseView()
	for k,v in pairs(g_ItemCtrl.m_ItemQuickUseEndCbList) do
		if v then v() end
	end
	g_ItemCtrl.m_ItemQuickUseEndCbList = {}
end

return CItemQuickUseView