local CItemBox = class("CItemBox", CItemBaseBox)

function CItemBox.ctor(self, obj, boxType)
	CItemBaseBox.ctor(self, obj, boxType)

	self.m_Effect = false
	self.m_Red = false
	self.m_EquipedRed = false
	self.itemUseTimes = 0
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	-- if boxType == define.Item.CellType.BagCell or boxType == define.Item.CellType.ModelEquip or boxType == define.Item.CellType.WHCell then
		-- 目前全部都需要取消选中判断（如以后需要非选中判断，编辑判断逻辑）
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOutDetect"))
	-- end
end

function CItemBox.OnTouchOutDetect(self, gameObj)
	local function update()
		if Utils.IsExist(self) then
			local oItemTipView = CItemTipsView:GetView()
			local oItemWHTipsView = CItemWHTipsView:GetView()
			if Utils.IsExist(oItemTipView) or Utils.IsExist(oItemWHTipsView) then
				-- 正在打开ItemTip界面，无法取消选中ItemCell
				return false
			elseif self:GetSelected() then
				self:ForceSelected(true)
			end
		end
		return false
	end
	Utils.AddTimer(update, 1, 0.05)
end

function CItemBox.BindUIEvent(self)
	if not self.m_IsBindEvent then
		self:AddUIEvent("click", callback(self, "OnItemBoxClick"))
		self:AddUIEvent("doubleclick", callback(self, "OnItemBoxDoubleClick"))
		self.m_IsBindEvent = true
	end
end

function CItemBox.SetEffect(self, show)
	local effRect = show and self.m_Item and g_ItemCtrl:IsItemEff(self.m_ID)
	if effRect then
		if not self.m_Effect then
			self.m_Effect = true
			self:AddEffect("Rect")
		end
	elseif self.m_Effect then
		self.m_Effect = false
		self:DelEffect("Rect")
	end
end

function CItemBox.SetRed(self, show)
	local redDot = show and self.m_Item and g_ItemCtrl:IsItemRed(self.m_ID)
	if redDot then
		if not self.m_Red then
			self.m_Red = true
			self:AddEffect("RedDot", 20, Vector2(-24, -24))
		end
	elseif self.m_Red then
		self.m_Red = false
		self:DelEffect("RedDot")
	end
end

--穿戴区红点--
function CItemBox.SetEquipedRed(self, bshow)
	if not self.m_EquipedRed and bshow then
		self:AddEffect("RedDot", 20, Vector2(-24, -24))
		self.m_IgnoreCheckEffect = false
		self.m_EquipedRed = true
	end
end

function CItemBox.RemoveItemFloat(self)
	g_ItemCtrl:RemoveItemEff(self.m_ID)
	g_ItemCtrl:RemoveItemRed(self.m_ID)
end

function CItemBox.OnItemBoxDoubleClick(self)
	if self.m_Item then
		--特殊处理点击器灵事件
		if self.m_Item.m_Type == CItem.TypeEnum[2] and self.m_Item:GetSValueByKey("pos") == define.Equip.Pos.Eight then
			CArtifactMainView:ShowView(function (oView)		
				oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
			end)
			return
		elseif self.m_Item.m_Type == CItem.TypeEnum[2] and self.m_Item:GetSValueByKey("pos") == define.Equip.Pos.Seven then
			g_WingCtrl:ShowWingTipView()
			return
		end
		self:SetEffect(false)
		self:SetRed(false)
		self:RemoveItemFloat()
		self:SetSelected(true)
		if g_ItemCtrl.m_RecordItemPartTab == 1 then
			-- 双击直接使用
			local bIsNormal = g_ItemViewCtrl:RequestUseItem(self.m_Item)
			if bIsNormal then
				if self.m_Item:IsEquip() then
					if self.m_Item:IsEquiped() then
						netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"), nil, "EQUIP:U")
					else
						netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"), nil, "EQUIP:W")
					end
				elseif self.m_Item:IsSummonEquip() then
					CSummonMainView:ShowView()
				else
					----------个别物品支持双击批量使用----------------------------
					local iAmount = self.m_Item:GetSValueByKey("amount")
					local item = DataTools.GetItemData(self.m_Item.m_SID)
					
					if iAmount > 2 and item.canContinuousUse == 1 and self.itemUseTimes >= 2 then
						local function useAllItem()
						    local itemList = {{itemid = self.m_Item:GetSValueByKey("id"), amount = iAmount}}
						    netitem.C2GSItemListUse(itemList)
					    end

						local name = self.m_Item:GetSValueByKey("name")
						local args = {	msg = "您要使用全部的"..name.."吗", 
										title	= "全部使用", 							 
								  		okCallback = useAllItem
									 }
						g_WindowTipCtrl:SetWindowConfirm(args)

						self.itemUseTimes = 0
					else
						netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"))
						self.itemUseTimes = self.itemUseTimes + 1
					end
					
				end
			end
		elseif g_ItemCtrl.m_RecordItemPartTab == 2 then
			if self.m_BoxType == define.Item.CellType.BagCell then
				g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_Item.m_ID)
			elseif self.m_BoxType == define.Item.CellType.WHCell then
				local itemPos = self.m_Item:GetSValueByKey("pos")
				g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, itemPos)
			end
		end

		-- if self:GetSelected() then
		-- 	self:ForceSelected(false)
		-- end
	end
end

function CItemBox.OnItemBoxClick(self)
	if self.m_Item then
		--特殊处理点击器灵事件
		if self.m_Item.m_Type == CItem.TypeEnum[2] and self.m_Item:GetSValueByKey("pos") == define.Equip.Pos.Eight then
			CArtifactMainView:ShowView(function (oView)		
				oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
			end)
			return
		elseif self.m_Item.m_Type == CItem.TypeEnum[2] and self.m_Item:GetSValueByKey("pos") == define.Equip.Pos.Seven then
			g_WingCtrl:ShowWingTipView()
			return
		end
		self:SetSelected(true)
		self:SetEffect(false)
		self:SetRed(false)
		self:RemoveItemFloat()
			-- CTradeVolumSubView:ShowView(function(oView)
			-- 	oView:SetTradeVolumSubView(self.m_Item.m_SData)
			-- end)
		if g_ItemCtrl.m_RecordItemPartTab == 1 then
			CItemTipsView:ShowView(function(oView)
				oView:SetItem(self.m_Item)
			end)
		else
			CItemWHTipsView:ShowView(function(oView)
				oView:SetItemData(self.m_Item, self.m_BoxType)
			end)
		end
	elseif self.m_Lock then
		if self.m_BoxType == define.Item.CellType.BagCell then
			self:ShowLockWindowTip()
		end
	end
	if self.m_EquipedRed then
		table.remove(g_ItemCtrl.m_ItemEquipRedList, 1) --去除戒指红点
	end
end

function CItemBox.ShowLockWindowTip(self)
	local lockRows = 1
	if g_ItemCtrl:GetBagLockCount() >= 10 then
		if self.m_Index and (self.m_Index > g_ItemCtrl:GetBagOpenCount() + 5) then
			lockRows = 2
		end
	end

	local baseConsume = tonumber(DataTools.GetGlobalData(103).value or 1000000)
	local totalConsume = baseConsume*lockRows
	local totalCount = 5*lockRows

	local tMsg = string.gsub(DataTools.GetMiscText(2006).content, "#consume", totalConsume)
	tMsg = string.gsub(tMsg, "#count", totalCount)
	-- 弹出窗口询问是否开启格子
	local okCb = function()
		if Utils.IsNil(self) then return end
		if g_AttrCtrl.silver < totalConsume then
	        g_QuickGetCtrl:CheckLackItemInfo({
	            coinlist = {{sid = 1002, amount = totalConsume, count = g_AttrCtrl.silver}},
	            exchangeCb = function()
	                g_ItemCtrl:AddItemExtendSize(totalCount)
	            end
	        })
		else
			g_ItemCtrl:AddItemExtendSize(totalCount)
		end
	end
	local windowConfirmInfo = {
		msg = tMsg,
		title = "开启包裹",
		okCallback = okCb,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CItemBox.SetBagItem(self, oItem)
	local isTouch = false
	if not self.m_Lock then
		self.m_Item = oItem
		if oItem then
			self.m_ID = oItem:GetSValueByKey("id")
			self.m_Name = oItem:GetItemName()
			isTouch = true
		end
		self:RefreshBox()
	elseif self.m_BoxType == define.Item.CellType.ModelEquip then
		isTouch = false
	else
		isTouch = true
	end

	local showEff = false
	if not self.m_Lock and oItem then
		showEff = true
	end
	-- 特效环绕、红点bug暂时使用其他的方式处理了，回头再看
	-- table.print(oItem)
	-- printc(showEff, self.m_Lock, showEff)
	self:SetEffect(showEff)
	self:SetRed(showEff)

	self:SetEnableTouch(isTouch)
end

function CItemBaseBox.SetLines(self, lineID)
	self.m_Lock = isLock
	if index then
		self.m_Index = index
	end
	self.m_LockSprite:SetActive(isLock)
end

-- override
function CItemBox.SetAmountText(self, amount, maxOverlay)
	local maxOverlay = maxOverlay or 100
	local showAmount = amount > 1 and maxOverlay > 1 
	self.m_AmountLabel:SetActive(showAmount)
	if showAmount then self.m_AmountLabel:SetText(amount) end
end

function CItemBox.OnCtrlEvent(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.Item.Event.TabSwitch then
		if self:GetSelected() then
			self:ForceSelected(false)
		end
	end
end
return CItemBox