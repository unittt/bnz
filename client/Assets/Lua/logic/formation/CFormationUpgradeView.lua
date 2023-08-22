local CFormationUpgradeView = class("CFormationUpgradeView", CViewBase)

function CFormationUpgradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Formation/FormationUpgradeView.prefab", cb)
	--界面设置
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CFormationUpgradeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBoxClone = self:NewUI(4, CFormationItemBox)
	self.m_UpgradeBtn = self:NewUI(5, CButton)
	self.m_FormationSpr = self:NewUI(6, CSprite)
	self.m_NameLabel = self:NewUI(7, CLabel)
	self.m_LvLabel = self:NewUI(8, CLabel)
	self.m_ExpSlider = self:NewUI(9, CSlider)
	self.m_WarningLabel = self:NewUI(10, CLabel)
	self.m_ExpSpr = self:NewUI(11, CSprite)
    self.m_QuickBuyBox = self:NewUI(12, CQuickBuyBox)
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_QuickBuyBox:SetInfo({
        id = define.QuickBuy.FormationUpgrade,
        name = "便捷购买",
        offset = Vector3(-15,0,0),
        allBuy = true,
    })
	self.m_CostItemList = {}
	self.m_IsFull = false
	self:InitContent()
end

function CFormationUpgradeView.InitContent(self)
	self.m_ItemBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "RequestUpgrade"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFormationEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CFormationUpgradeView.OnCtrlFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.UpdateFormationInfo then
		local dInfo = g_FormationCtrl:GetFormationInfoByFmtID(self.m_FormationID)
		self:SetFormationInfo(dInfo)
		self:RefreshExpPanel()
	end
end

function CFormationUpgradeView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		define.Item.Event.RefreshSpecificItem then
		self:InitFormationItemGride()
	end
end

function CFormationUpgradeView.SetFormationInfo(self, dInfo)
	self.m_FormationInfo = dInfo
	self.m_FormationID = dInfo.fmt_id
end

function CFormationUpgradeView.RefreshAll(self)
	self:InitFormationItemGride()
	self:RefreshExpPanel()
end

function CFormationUpgradeView.InitFormationItemGride(self)
	self.m_ScrollView:ResetPosition()
	self.m_ItemGrid:Clear()

	local list = g_ItemCtrl:GetAllItem()
	for i,oItem in ipairs(list) do
		local sid = oItem:GetCValueByKey("id")
		if data.formationdata.ITEMINFO[sid] then
			local oBox = self:CreateFormationItemBox(oItem)
			self.m_ItemGrid:AddChild(oBox)
		end
	end
	self.m_WarningLabel:SetActive(self.m_ItemGrid:GetCount() == 0)
end

-- function CFormationUpgradeView.UpdateForm(self, oBox, dInfo)
	
-- end

function CFormationUpgradeView.CreateFormationItemBox(self, oItem)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox:SetActive(true)
	oBox:SetBagItem(oItem)
	oBox:SetListener(callback(self,"ChangeSelect"))
	return oBox
end

function CFormationUpgradeView.DelFormationItemBox(self, oBox)
	self.m_ItemGrid:RemoveChild(oBox)
end

function CFormationUpgradeView.ChangeSelect(self, itemid, amount)
	if amount == 0 then
		self.m_CostItemList[itemid] = nil
	else
		self.m_CostItemList[itemid] = amount
	end
	self:RefreshPreExp()
end

function CFormationUpgradeView.RequestUpgrade(self)
	if self.m_IsFull then
		return
	end
	local list
	local bQuickSel = self.m_QuickBuyBox:IsSelected()
	if bQuickSel then
		if not self.m_QuickBuyBox:CheckCostEnough() then
			return
		end
	end
	if bQuickSel then
		list = self:GetItemList()
		netformation.C2GSUpgradeFormation(self.m_FormationID, list)
	else
		list = self:GetItemList()
		netitem.C2GSItemListUse(list, self.m_FormationID)
	end
	self.m_CostItemList = {}
end

function CFormationUpgradeView.GetItemList(self)
	local list = {}
	for k,v in pairs(self.m_CostItemList) do
		if v then
			table.insert(list, {itemid = k, amount = v})
		end
	end
	return list
end

function CFormationUpgradeView.GetCItemList(self)
	local list = {}
	for k,v in pairs(self.m_CostItemList) do
		if v then
			local oItem = g_ItemCtrl.m_BagItems[k]
			table.insert(list, {sid = oItem:GetSValueByKey("sid"), amount = v})
		end
	end
	return list
end

function CFormationUpgradeView.RefreshExpPanel(self)
	local dInfo = self.m_FormationInfo
	local iCurExp = dInfo.exp
	local iMaxExp = dInfo.cData.exp[dInfo.grade] or dInfo.exp
	iMaxExp = math.max(iMaxExp, 1)
	-- self.m_ExpSpr:SetColor(Color.New(0x1D/0xff,0xB7/0xff,0x4B/0xff,1))
	self.m_FormationSpr:SetSpriteName(dInfo.cData.icon)
	self.m_ExpSpr:SetSpriteName("h7_lv")
	self.m_NameLabel:SetText(dInfo.cData.name)
	self.m_IsFull = self:IsMaxGrade(dInfo.grade)
	if self.m_IsFull then
		self.m_LvLabel:SetText(dInfo.grade.."级")
		self.m_ExpSlider:SetSliderText("满级")
		self.m_ExpSlider:SetValue(1)
		self.m_QuickBuyBox:SetItemsInfo(nil)
	else
		self.m_LvLabel:SetText(dInfo.grade.."级")
		self.m_ExpSlider:SetValue(iCurExp/iMaxExp)
		self.m_ExpSlider:SetSliderText(string.format("%d/%d", iCurExp, iMaxExp))
		self:RefreshQuickBuyBox(iMaxExp - iCurExp)
	end
end

function CFormationUpgradeView.RefreshPreExp(self)
	local list = self:GetCItemList()
	local iSumExp = DataTools.CalculateItemExpByFormationId(self.m_FormationID, list)
	--printc("总经验",iSumExp)
	if iSumExp == 0 then
		self:RefreshExpPanel()
		return
	else
		self.m_ExpSpr:SetSpriteName("h7_cheng")
	end
	local dInfo = self.m_FormationInfo
	local iNewGrade, iNewExp, bIsFull = DataTools.GetFormationGrade(self.m_FormationID, dInfo.exp, dInfo.grade, iSumExp)
	local iMaxExp = dInfo.cData.exp[iNewGrade]
	iMaxExp = math.max(iMaxExp, 1)
	self.m_LvLabel:SetText(iNewGrade.."级")
	self.m_ExpSlider:SetValue(iNewExp/iMaxExp)
	self.m_ExpSlider:SetSliderText(string.format("%d/%d", iNewExp, iMaxExp))
	local iNeedExp = 0
	if iNewGrade == dInfo.grade then
		iNeedExp = iMaxExp - iNewExp
	end
	self:RefreshQuickBuyBox(iNeedExp)
	if bIsFull then
		g_NotifyCtrl:FloatMsg("经验已满")
		self.m_ExpSlider:SetSliderText("满级")
		self.m_ExpSlider:SetValue(1)
	end
end

function CFormationUpgradeView.RefreshQuickBuyBox(self, iNeedExp)
	if iNeedExp < 0 or not self.m_FormationID then
		self.m_QuickBuyBox:SetItemsInfo(nil)
	else
		local expItem = DataTools.GetFormationItemExpData(self.m_FormationID)
		local items = nil
		if expItem then
			local iCnt = math.ceil(iNeedExp/expItem.data.exp)
			items = {{id = expItem.itemid, cnt = iCnt}}
		end
		self.m_QuickBuyBox:SetItemsInfo(items)
	end
end

function CFormationUpgradeView.IsMaxGrade(self, iGrade)
	local dBaseInfo = data.formationdata.BASEINFO[self.m_FormationID]
	local iUpgradeExp = dBaseInfo.exp[iGrade]
	if not iUpgradeExp or dBaseInfo.id == 1 then
		return false
	end
	return #dBaseInfo.exp <= iGrade
end

return CFormationUpgradeView