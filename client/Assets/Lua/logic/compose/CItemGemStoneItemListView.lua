local CItemGemStoneItemListView = class("CItemGemStoneItemListView", CViewBase)

function CItemGemStoneItemListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemGemStoneListView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CItemGemStoneItemListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemBoxClone = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_EmptyL = self:NewUI(5, CLabel)
	self.m_TipsL = self:NewUI(6, CLabel)

	self:InitContent()
end

function CItemGemStoneItemListView.InitContent(self)
	self.m_ItemBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CItemGemStoneItemListView.SetFiterCondition(self, iColor, iLevel, bIsSortUp)
	self.m_FiterColor = iColor
	self.m_FiterLevel = iLevel
	self.m_IsSortUp = bIsSortUp
end

function CItemGemStoneItemListView.SetGradeArea(self, iMinGrade, iMaxGrade)
	self.m_MinGrade = iMinGrade
	self.m_MaxGrade = iMaxGrade
end

function CItemGemStoneItemListView.SetClickCallback(self, cb)
	self.m_ClickCb = cb
end

function CItemGemStoneItemListView.SetTipsText(self, sTips)
	self.m_TipsL:SetText(sTips)
end

function CItemGemStoneItemListView.RefreshItemGrid(self)
	--TODO:需过滤掉可不合成的材料
	local list = {}
	for i,v in ipairs(data.hunshidata.COLOR) do
		if v.color ~= self.m_FiterColor and v.level ~= self.m_FiterLevel then
			table.extend(list, g_ItemCtrl:GetGemStoneList(v.color, false, self.m_MinGrade, self.m_MaxGrade, nil, nil, self.m_IsSortUp))
		end
	end

	local dMergeRecord = {}
	local dDelRecore = {}
	for i,oItem in ipairs(list) do
		local iGrade = oItem:GetSValueByKey("hunshi_info").grade
		local iColor = data.hunshidata.ITEM2COLOR[oItem.m_SID]
		local lAttr = oItem:GetSValueByKey("hunshi_info").addattr
		local bIsBind = oItem:IsBinding() and 1 or 0
		local sKey = string.format("%d_%d_%s_%s_%d", iGrade, iColor, lAttr[1], (lAttr[2] or ""), bIsBind)
		local iRecoreIndex = dMergeRecord[sKey]
		if iRecoreIndex then
			local oTarget = list[iRecoreIndex]
			oTarget.m_TempCnt = oTarget.m_TempCnt + oItem:GetSValueByKey("amount")
			dDelRecore[i] = true
		else
			dMergeRecord[sKey] = i
			oItem.m_TempCnt = oItem:GetSValueByKey("amount")
		end
	end	

	for i = #list, 1, -1 do
		if dDelRecore[i] then
			table.remove(list, i)
		end
	end

	local function sort(d1, d2)
		local iGrade_1 = d1:GetSValueByKey("hunshi_info").grade
		local iColor_1 = data.hunshidata.ITEM2COLOR[d1.m_SID]
		local iGrade_2 = d2:GetSValueByKey("hunshi_info").grade
		local iColor_2 = data.hunshidata.ITEM2COLOR[d2.m_SID]
		if iGrade_1 ~= iGrade_2 then
			if self.m_IsSortUp then
				return iGrade_1 > iGrade_2
			else
				return iGrade_1 < iGrade_2
			end
		elseif iColor_1 ~= iColor_2 then
			return iColor_1 < iColor_2
		elseif d1:IsBinding() and not d2:IsBinding() then
			return true
		end
		return d1.m_ID < d2.m_ID
	end 
	table.sort(list, sort)

	self.m_ScrollView:ResetPosition()
	local iCnt = math.max(self.m_ItemGrid:GetCount(), #list)
	for i=1, iCnt do
		local oItem = list[i]
		local oBox = self.m_ItemGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateItemBox()
			self.m_ItemGrid:AddChild(oBox)
		end	
		self:UpdateItemBox(oBox, oItem)
	end
	self.m_ItemGrid:Reposition()
	self.m_EmptyL:SetActive(iCnt == 0)
end

function CItemGemStoneItemListView.CreateItemBox(self)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AttrL = oBox:NewUI(3, CLabel)
	oBox.m_BindSpr = oBox:NewUI(4, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnClickItemBox", oBox))
	return oBox
end

function CItemGemStoneItemListView.UpdateItemBox(self, oBox, oItem)
	oBox:SetActive(oItem ~= nil)
	if not oItem then
		return 
	end
	oBox.m_Item = oItem
	oBox.m_ItemBox:SetBagItem(oItem)
	oBox.m_BindSpr:SetActive(oItem:IsBinding())
	local sName = oItem:GetItemName()
	oBox.m_NameL:SetText(sName)
	oBox.m_ItemBox:SetAmountText(oItem.m_TempCnt)
	--TODO:魂石属性
	local lAttr = oItem:GetGemStoneAttr()
	local sAttr = ""
	for i,dAttr in ipairs(lAttr) do
		sAttr = string.format("%s%s +%d\n", sAttr, dAttr.attrname, dAttr.value)
	end
	oBox.m_AttrL:SetText(sAttr)
end

function CItemGemStoneItemListView.OnClickItemBox(self, oBox)
	if self.m_ClickCb then
		self.m_ClickCb(oBox.m_Item, self.m_FiterColor ~= nil and 2 or 1)
	end
	self:CloseView()
end

return CItemGemStoneItemListView