local CForgeInlayPart = class("CForgeInlayPart", CPageBase)


function CForgeInlayPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CForgeInlayPart.OnInitPage(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_BagEquipBoxClone = self:NewUI(2, CBox)
	self.m_EquipScrollView = self:NewUI(3, CScrollView)
	self.m_WarningL = self:NewUI(4, CLabel)
	self.m_TipBtn = self:NewUI(5, CButton)
	self.m_EquipBox = self:NewUI(6, CBox)
	self.m_InlayItemBoxs = {
		[1] = self:NewUI(7, CBox),
		[2] = self:NewUI(8, CBox),
		[3] = self:NewUI(9, CBox)
	}
	-- self.m_GemstoneListBox = self:NewUI(10, CForgeInlayItemListBox)
	self.m_HoleNames = {
		[1] = "红色镶嵌孔",
		[2] = "黄色镶嵌孔",
		[3] = "蓝色镶嵌孔",
	} 

	self.m_LimitLv = 50
	self.m_InlayPos = data.hunshidata.UNLOCK[1]
	self.m_SelectedId = -1
	self.m_SelectedItem = nil
	self.m_SelectedBox = nil
	self.m_IsChangeSel = false
	self.m_GemstoneList = nil
	self.m_ItemDict = {}

	g_ForgeCtrl:ResetAllInlayRedPointStatus()
	self:InitContent()
end

function CForgeInlayPart.InitContent(self)
	self:InitInlayBox()
	self:InitEquipBox()

	self.m_BagEquipBoxClone:SetActive(false)
	-- self.m_GemstoneListBox:SetSelectCallback(callback(self, "OnGemstoneSelect"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ForgeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlForgeEvent"))
end

function CForgeInlayPart.InitInlayBox(self)
	for i,oBox in ipairs(self.m_InlayItemBoxs) do
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_ItemBgSpr = oBox:NewUI(2, CSprite)
		oBox.m_AttrL = oBox:NewUI(3, CLabel)
		oBox.m_AddBtn = oBox:NewUI(4, CSprite)
		oBox.m_ItemInfoNode = oBox:NewUI(5, CObject)
		oBox.m_DelBtn = oBox:NewUI(6, CSprite)
		oBox.m_LockSpr = oBox:NewUI(7, CSprite)
		oBox.m_TipsL = oBox:NewUI(8, CLabel)
		oBox.m_InlayRedPointSpr = oBox:NewUI(9, CSprite)
		oBox.m_NearTargetObj = oBox:NewUI(10, CObject)

		oBox.m_Index = i
		oBox:AddUIEvent("click", callback(self, "RefreshInlayItemList", i))
		oBox.m_ItemSpr:AddUIEvent("click", callback(self, "OnClickInlayItem", oBox))
		oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickInlayItem", oBox))
		oBox.m_DelBtn:AddUIEvent("click", callback(self, "OnClickDelInlayItem", oBox))
		oBox:SetGroup(self:GetInstanceID())
	end
end

function CForgeInlayPart.InitEquipBox(self)
	local oBox = self.m_EquipBox
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	local function OpenItemTip()
		if not self.m_EquipBox.m_Item then
			return
		end
		CItemTipsView:ShowView(function(oView)
			local cItem = g_ItemCtrl.m_BagItems[self.m_EquipBox.m_Item.m_ID]
			oView:SetItem(cItem)
			oView:HideBtns()
		end)
	end
	oBox.m_ItemSpr:AddUIEvent("click", OpenItemTip)
end

function CForgeInlayPart.InitData(self, oItem)
	self.m_SelectedId = oItem.m_ID
	self.m_SelectedItem = oItem
	local iEquipLv = oItem:GetItemEquipLevel()
	if iEquipLv % 10 ~= 0 then
		iEquipLv = math.floor(iEquipLv/10)*10
	end
	self.m_LimitData = data.hunshidata.EQUIPLIMIT[iEquipLv]
	self.m_ColorData = data.hunshidata.EQUIPCOLOR[oItem:GetCValueByKey("equipPos")]
end

function CForgeInlayPart.OnShowPage(self)
	self:RefreshEquipGrid()
end

function CForgeInlayPart.ChangeSelectId(self, iItemId)
	if not iItemId then
		return
	end
	self.m_SelectedId = iItemId
	-- self.m_IsChangeSel = true
	self:RefreshEquipGrid()
end

----------------------Otrl Event-----------------------------------------
function CForgeInlayPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.DelItem then
		local iItemId = oCtrl.m_EventData
		self:DelEquipByItemId(iItemId)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.AddItem then
		local oItem = g_ItemCtrl.m_BagItems[self.m_SelectedId]
		if oItem then
			self:RefreshEquip(self.m_SelectedBox, oItem)
			self:InitData(oItem)
			self:RefreshAllInlayItem()
		end
	end
end

function CForgeInlayPart.OnCtrlForgeEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Forge.Event.RefreshInlayRedPoint then
		self:RefreshAllInlayRedPoint()
	end
end

--------------------refresh UI-----------------------------
function CForgeInlayPart.RefreshEquipGrid(self)
	self.m_EquipScrollView:ResetPosition()
	self.m_EquipGrid:Clear()
	self.m_ItemDict = {}

	--TODO:装备列表获取
	local list =  g_ItemCtrl:GetEquipList(nil, nil, 
		self.m_LimitLv, nil, nil, nil, nil)
	local iCount = 1
	local oSelectedBox = nil

	for k, oItem in ipairs(list) do
		local oBox = self:CreateEquip(oItem)
		self.m_EquipGrid:AddChild(oBox)
		if (not self:IsSelectedItem() and k == 1) or
			self.m_SelectedId == oItem.m_ID then
			self:ScrollToBox(iCount - 1)
			oSelectedBox = oBox
		else
			iCount = iCount + 1
		end
	end

	local bIsEmpty = self.m_EquipGrid:GetCount() == 0
	self.m_WarningL:SetActive(bIsEmpty)
	if bIsEmpty then
		self:RefreshEmptyStatus()
		return
	end

	if not oSelectedBox then
		oSelectedBox = self.m_EquipGrid:GetChild(1)
		iCount = 1
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnEquipSelect(oSelectedBox)
	end
	self:RefreshAllInlayRedPoint()
end

function CForgeInlayPart.RefreshEmptyStatus(self)
	self.m_SelectedId = -1
	self.m_SelectedItem = nil
	self.m_SelectedBox = nil
	self:RefreshEquipBox()
	for i=1,3 do
		local oBox = self.m_InlayItemBoxs[i]
		self:UpdateInlayItemBox(oBox, nil, i)
	end
end

function CForgeInlayPart.CreateEquip(self, oItem)
	local oBox = self.m_BagEquipBoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LevelLabel = oBox:NewUI(3, CLabel)
	oBox.m_StoneGrid = oBox:NewUI(4, CGrid)
	oBox.m_EmptyLabel = oBox:NewUI(5, CLabel)
	oBox.m_EquipSpr = oBox:NewUI(6, CSprite)
	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_ItemBgSpr = oBox:NewUI(2, CSprite)
		return oBox
	end
	oBox.m_StoneGrid:InitChild(init)

	oBox:SetActive(true)
	self:RefreshEquip(oBox, oItem)

	oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnEquipSelect", oBox))
	return oBox
end

function CForgeInlayPart.RefreshEquip(self, oBox, oItem)
	if not oBox then
		return
	end
	self.m_ItemDict[oItem.m_ID] = true 
	local iEquipLv = oItem:GetItemEquipLevel()
	oBox.m_CItem = oItem
	oBox.m_ItemBox:SetBagItem(oItem)
	oBox.m_ItemBox:SetEnableTouch(false)

	oBox.m_NameLabel:SetText(oItem:GetItemName())
	oBox.m_LevelLabel:SetText(iEquipLv.."级")
	oBox.m_EquipSpr:SetActive(oItem:IsEquiped())

	local lInlayInfo = oItem:GetSValueByKey("equip_info").hunshi
	local bIsEmpty = #lInlayInfo == 0
	oBox.m_EmptyLabel:SetActive(false)
	-- oBox.m_EmptyLabel:SetActive(bIsEmpty)
	-- oBox.m_StoneGrid:SetActive(not bIsEmpty)
	-- if bIsEmpty then
	-- 	return
	-- end

	if iEquipLv % 10 ~= 0 then
		iEquipLv = math.floor(iEquipLv/10)*10
	end

	local iEquipPos = oItem:GetCValueByKey("equipPos")
	local lEquipColor = data.hunshidata.EQUIPCOLOR[iEquipPos].colorlist
	local dLimitData = data.hunshidata.EQUIPLIMIT[iEquipLv]
	local lBox = oBox.m_StoneGrid:GetChildList()

	for i,oBox in ipairs(lBox) do
		if i > dLimitData.holecnt then
			oBox:SetActive(false)
		else
			oBox:SetActive(true)
			
			local iColor = lEquipColor[i]
			oBox.m_ItemBgSpr:SpriteGemstoneBg(iColor)

			--TODO:服务器下发的镶嵌状态
			local dInlay = lInlayInfo[i]
			oBox.m_ItemSpr:SetActive(dInlay ~= nil)
			if dInlay then
				local dColorData = data.hunshidata.COLOR[dInlay.color]
				local dItemData = DataTools.GetItemData(dColorData.itemsid)	
				oBox.m_InlayInfo = dInlay
				oBox.m_ItemSpr:SpriteItemShape(dItemData.icon)
			end
		end
	end
end

function CForgeInlayPart.DelEquipByItemId(self, iItemId)
	if not self.m_ItemDict[iItemId] then
		return
	end
	local lBox = self.m_EquipGrid:GetChildList()
	for i,oBox in ipairs(lBox) do
		if oBox.m_CItem.m_ID == iItemId then
			self.m_EquipGrid:RemoveChild(oBox)
			self.m_ItemDict[iItemId] = nil
			if iItemId == self.m_SelectedId then
				local iNearIndex = i - 1
				local oSelectedBox = self.m_EquipGrid:GetChild(iNearIndex > 0 and iNearIndex or 1)
				if oSelectedBox then
					oSelectedBox:SetSelected(true)
					self:OnEquipSelect(oSelectedBox)
				else
					self.m_WarningL:SetActive(true)
					self:RefreshEmptyStatus()
				end
			end
		end
	end
end

function CForgeInlayPart.ScrollToBox(self, iIndex)
	local oPanel = self.m_EquipScrollView:GetComponent(classtype.UIPanel)
	local iScrollViewH = oPanel:GetViewSize().y
	local _,iCellH = self.m_EquipGrid:GetCellSize()
	local iDiffH = iCellH * self.m_EquipGrid:GetCount() - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_EquipScrollView:MoveRelative(vPos)
end

function CForgeInlayPart.RefreshAllInlayItem(self)
	--TODO:获取已镶嵌的物品列表
	self.m_InlayPos = math.min(self.m_LimitData.holecnt, self.m_InlayPos)
	for i=1,3 do
		local dInlay = self.m_SelectedItem:GetInlayItemByPos(i)
		local oBox = self.m_InlayItemBoxs[i]
		self:UpdateInlayItemBox(oBox, dInlay, i)
		-- if self.m_InlayPos == i then
			-- self:OnClickInlayItem(oBox)
			-- if not oBox:GetSelected() then
			-- 	oBox:ForceSelected(true)
			-- end
		-- end
		oBox:SetEnabled(i <= self.m_LimitData.holecnt)
	end
end

function CForgeInlayPart.UpdateInlayItemBox(self, oBox, dInlay, iIndex)
	--TODO:设置镶嵌状态
	oBox.m_InlayRedPointSpr:SetActive(false)

	oBox:EnableTouch(self:IsSelectedItem())
	if not self:IsSelectedItem() then
		oBox.m_ItemInfoNode:SetActive(false)
		oBox.m_AddBtn:SetActive(false)
		oBox.m_TipsL:SetText("")
		return
	end

	local lEquipColor = self.m_ColorData.colorlist
	local iColor = lEquipColor[iIndex]
	local bIsLock = self.m_LimitData.holecnt < iIndex 

	oBox.m_EquipColor = iColor
	oBox.m_InlayInfo = nil
	oBox.m_LockSpr:SetActive(bIsLock)
	oBox.m_ItemBgSpr:SpriteGemstoneBg(bIsLock and 3 or iColor)
	if bIsLock then
		oBox.m_TipsL:SetText(data.hunshidata.UNLOCK[iIndex].."级装备开启")
		oBox.m_AddBtn:SetActive(false)
		oBox.m_ItemInfoNode:SetActive(false)
		return
	end

	local bIsEmpty = dInlay == nil
	oBox.m_AddBtn:SetActive(bIsEmpty)
	oBox.m_ItemInfoNode:SetActive(not bIsEmpty)
	if bIsEmpty then
		local lGemStone = g_ItemCtrl:GetGemStoneList(self.m_ColorData.colorlist[1], true, 1, self.m_LimitData.maxlv, nil, nil, true)
		oBox.m_InlayRedPointSpr:SetActive(#lGemStone > 0)
		oBox.m_TipsL:SetText(self.m_HoleNames[iColor])
		return
	end

	local dColorData = data.hunshidata.COLOR[dInlay.color]
	local dItemData = DataTools.GetItemData(dColorData.itemsid)	
	oBox.m_InlayInfo = dInlay
	oBox.m_ItemSpr:SpriteItemShape(dItemData.icon)

	local lAttr = self:GetGemStoneAttr(dColorData.itemsid, dInlay.grade, dInlay.addattr)
	local sAttr = dInlay.grade.."级 "
	for i,dAttr in ipairs(lAttr) do
		sAttr = string.format("%s%s+%d ", sAttr, dAttr.attrname, dAttr.value)
	end
	oBox.m_AttrL:SetText(sAttr)
	oBox.m_TipsL:SetText("")
end

function CForgeInlayPart.RefreshEquipBox(self)
	local oItem = self.m_SelectedItem
	local oBox = self.m_EquipBox
	oBox.m_ItemSpr:SetActive(oItem ~= nil)
	oBox.m_NameL:SetActive(oItem ~= nil)
	oBox.m_Item = oItem
	if not oItem then
		return
	end
	
	local iEquipLv = oItem:GetItemEquipLevel()
	local sName = oItem:GetItemName()
	sName = string.format("%s %d级", sName, iEquipLv)

	oBox.m_NameL:SetText(sName)
	oBox.m_ItemSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
end

function CForgeInlayPart.RefreshInlayItemList(self, iIndex)
	self.m_InlayPos = iIndex
	local iSelectedColor = self.m_ColorData.colorlist[self.m_InlayPos]
	-- self.m_GemstoneListBox:SetMaxGrade(self.m_LimitData.maxlv)
	-- if not self.m_IsChangeSel then
	-- 	self.m_GemstoneListBox:RefreshScrollView()
	-- end
	-- self.m_IsChangeSel = false
	-- self.m_GemstoneListBox:OnClickSwitchStone(iSelectedColor)
end

function CForgeInlayPart.RefreshAllInlayRedPoint(self)
	local list = self.m_EquipGrid:GetChildList()

	for i,oBox in ipairs(list) do
		local iItemId = oBox.m_CItem.m_ID
		local bShow = g_ForgeCtrl:GetInlayRedPointStatus(iItemId)
		if bShow then
			oBox:AddEffect("RedDot", 20, Vector2(-15,-15))
		else
			oBox:DelEffect("RedDot")
		end
	end
end

--------------------click event------------------------
function CForgeInlayPart.ShowTipView(self)
	local id = define.Instruction.Config.ForgeInlay
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CForgeInlayPart.OnEquipSelect(self, oBox)
	self.m_SelectedBox = oBox
	self:InitData(oBox.m_CItem)
	self:RefreshEquipBox()
	self:RefreshAllInlayItem()
end

function CForgeInlayPart.OnGemstoneSelect(self, oBox)
	--TODO:如果可镶嵌就执行镶嵌,服务器暂时不支持直接覆盖，先执行卸下
	local oItem = oBox.m_Item
	if not self:IsSelectedItem() then
		return
	end
	netitem.C2GSEquipAddHS(oItem.m_ID, self.m_SelectedId, self.m_InlayPos)
end

function CForgeInlayPart.OnClickInlayItem(self, oBox)
	if not self:IsSelectedItem() then
		return
	end
	--TODO:卸载并切换到目标的颜色宝石列表
	-- oBox:SetSelected(true)
	-- self:RefreshInlayItemList(oBox.m_Index)
	self.m_InlayPos = oBox.m_Index
	CForgeInlayItemSelView:ShowView(function (oView)
		oView:SetSelectCallback(callback(self, "OnGemstoneSelect"))
		oView:SetSelGemstoneInfo(self.m_LimitData.maxlv, oBox.m_EquipColor, oBox.m_Index)
	end)
end

function CForgeInlayPart.OnClickDelInlayItem(self, oBox)
	--TODO:宝石卸下
	netitem.C2GSEquipDelHS(self.m_SelectedId, oBox.m_Index)
	-- self:RefreshInlayItemList(oBox.m_Index)
	-- oBox:SetSelected(true)
end

---------------------other helper------------------------------
function CForgeInlayPart.GetGemStoneAttr(self, iItemId, iGrade, lAttr)
	local list = {}
	for i,sAttrKey in ipairs(lAttr) do
		local sAttrName = data.attrnamedata.DATA[sAttrKey].name
		local dAttrData = DataTools.GetGemStoneAttrData(iItemId, iGrade, sAttrKey)
		dAttrData.attrname = sAttrName
		table.insert(list, dAttrData)
	end
	return list
end

function CForgeInlayPart.IsSelectedItem(self)
	return self.m_SelectedId ~= -1
end
return CForgeInlayPart