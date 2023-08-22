local CEcononmyCatalogBoxNew = class("CEcononmyCatalogBoxNew", CBox)

function CEcononmyCatalogBoxNew.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SubMenuBg = self:NewUI(1, CWidget)
	self.m_CatalogMenu = self:NewUI(2, CButton, true ,false)
	self.m_SubMenuGrid = self:NewUI(3, CGrid)
	self.m_SubMenuClone = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_TaskFlagSpr = self:NewUI(6, CSprite)
	self.m_CatalogNameL = self:NewUI(7, CLabel)
	self.m_SelCatalogNameL = self:NewUI(8, CLabel)
	self.m_SelArrowSpr = self:NewUI(9, CSprite)

	self.m_IsInit = true
	self.m_Callback = nil
	self.m_SubCatalogData = nil
	self.m_SubMenus = {}
	self:BindButtonEvent()
	self.m_SubMenuClone:SetActive(false)
	self.m_TweenHeight = self.m_SubMenuBg:GetComponent(classtype.TweenHeight)
	self.m_TweenRotation_1 = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_TweenRotation_2 = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)
end

function CEcononmyCatalogBoxNew.BindButtonEvent(self)
	self.m_CatalogMenu:AddUIEvent("click", callback(self, "OnClickCatalog", true))
end

-- 初始化数据
function CEcononmyCatalogBoxNew.SetCatalogData(self, tData, iType)
	self.m_CatalogData = tData
	self.m_CatalogId = tData.cat_id
	self.m_CatalogType = iType
	local list = DataTools.GetEcononmySubCatalogListById(self.m_CatalogId, iType, g_AttrCtrl.server_grade)
	if #list > 0 then
		self.m_SubCatalogData = list
	end
	self:RefreshUI()
end

-- 设置监听器
function CEcononmyCatalogBoxNew.SetCatalogCallback(self, catalogCb, subCatalogCb)
	self.m_CatalogCb = catalogCb
	self.m_SubCatalogCb = subCatalogCb
end

-- 执行UI刷新
function CEcononmyCatalogBoxNew.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshCatalogMenu()
end

function CEcononmyCatalogBoxNew.RefreshCatalogMenu(self)
	local bIsEmpty = self.m_SubCatalogData == nil 
	if bIsEmpty then
		self.m_SubMenuBg:SetParent(nil)
		self.m_SubMenuBg:Destroy()
	else
		self:RefreshSubMenuGrid()
		
	end
	self.m_ArrowSpr:SetActive(not bIsEmpty)
	self.m_SelArrowSpr:SetActive(not bIsEmpty)

	self.m_CatalogNameL:SetText(self.m_CatalogData.cat_name)
	self.m_SelCatalogNameL:SetText(self.m_CatalogData.cat_name)
	self.m_TaskFlagSpr:SetActive(g_EcononmyCtrl:IsTaskCatalog(self.m_CatalogType, self.m_CatalogId))
end

function CEcononmyCatalogBoxNew.RefreshSubMenuGrid(self)
	local iCount = #self.m_SubCatalogData
	self.m_SubMenuGrid:Clear()
	for _,dData in ipairs(self.m_SubCatalogData) do
		local oBox = self:CreateSubCatalogBox(dData)
		self.m_SubMenuGrid:AddChild(oBox)
		self.m_SubMenus[dData.subcat_id] = oBox
	end

	local _, h = self.m_SubMenuGrid:GetCellSize()
	self.m_TweenHeight.to = h*iCount
end

function CEcononmyCatalogBoxNew.CreateSubCatalogBox(self, dData)
	local oBox = self.m_SubMenuClone:Clone(false)
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_SelNameL = oBox:NewUI(2, CLabel)
	oBox.m_TaskFlagSpr = oBox:NewUI(3, CSprite)

	local bIsTaskCatalog = g_EcononmyCtrl:IsTaskSubCatalog(self.m_CatalogType, self.m_CatalogId, dData.subcat_id)
	oBox.m_Id = dData.subcat_id
	oBox.m_TaskFlagSpr:SetActive(bIsTaskCatalog)
	oBox.m_NameL:SetText(dData.subcat_name)
	oBox.m_SelNameL:SetText(dData.subcat_name)
	oBox:AddUIEvent("click", function()
		oBox:ForceSelected(true)
		if self.m_SubCatalogCb then
			self.m_SubCatalogCb(oBox)
		end
	end)
	oBox:SetActive(true)
	return oBox
end

function CEcononmyCatalogBoxNew.ForceSelected(self, b)
	self.m_CatalogMenu:ForceSelected(b)
end

function CEcononmyCatalogBoxNew.OnClickCatalog(self, bAutoJump)
	self:ForceSelected(true)
	if self.m_CatalogCb then
		self.m_CatalogCb(self)
	end
	if bAutoJump then
		self:JumpToSubCatalog(1)
	end
end

function CEcononmyCatalogBoxNew.JumpToSubCatalog(self, iSubIndex)
	if not self.m_SubCatalogData then
		return
	end
	local oSubMenu = self.m_SubMenus[iSubIndex] or self.m_SubMenuGrid:GetChild(1)
	if oSubMenu then 
		self:ExpandSubMenu(true)
		oSubMenu:ForceSelected(true)
		if self.m_SubCatalogCb then
			self.m_SubCatalogCb(oSubMenu)
		end
	end
end

function CEcononmyCatalogBoxNew.ExpandSubMenu(self, bIsExpand)
	if self.m_SubCatalogData == nil or self.m_SubMenuBg:GetActive() == bIsExpand then
		return
	end
	self.m_SubMenuBg:SetActive(bIsExpand)
	self.m_TweenHeight:Toggle()
	self.m_TweenRotation_1:Play(bIsExpand)
	self.m_TweenRotation_2:Play(bIsExpand)
end

return CEcononmyCatalogBoxNew