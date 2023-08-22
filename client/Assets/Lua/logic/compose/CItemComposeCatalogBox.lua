local CItemComposeCatalogBox = class("CItemComposeCatalogBox", CBox)

function CItemComposeCatalogBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SubMenuBg = self:NewUI(1, CWidget)
	self.m_CatalogMenu = self:NewUI(2, CButton, true ,false)
	self.m_SubMenuGrid = self:NewUI(3, CGrid)
	self.m_SubMenuClone = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
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

function CItemComposeCatalogBox.BindButtonEvent(self)
	self.m_CatalogMenu:AddUIEvent("click", callback(self, "OnClickCatalog"))
end

-- 初始化数据
function CItemComposeCatalogBox.SetCatalogData(self, tData)
	self.m_CatalogData = tData
	self.m_ItemId = tData.item_id
	self.m_CatalogId = tData.cat_id
	local list = DataTools.GetItemComposeSubCatalog(self.m_CatalogId)
	if #list > 0 then
		self.m_SubCatalogData = list
	end
	self:RefreshUI()
end

-- 设置监听器
function CItemComposeCatalogBox.SetCatalogCallback(self, catalogCb, subCatalogCb)
	self.m_CatalogCb = catalogCb
	self.m_SubCatalogCb = subCatalogCb
end

-- 执行UI刷新
function CItemComposeCatalogBox.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshCatalogMenu()
end

function CItemComposeCatalogBox.RefreshCatalogMenu(self)
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
end

function CItemComposeCatalogBox.RefreshSubMenuGrid(self)
	local iCount = #self.m_SubCatalogData
	self.m_SubMenuGrid:Clear()
	for _,dData in ipairs(self.m_SubCatalogData) do
		local oBox = self:CreateSubCatalogBox(dData)
		self.m_SubMenuGrid:AddChild(oBox)
		self.m_SubMenus[dData.subcat_id] = oBox
	end

	local _, h = self.m_SubMenuGrid:GetCellSize()
	self.m_TweenHeight.to = h*iCount + 10
end

function CItemComposeCatalogBox.CreateSubCatalogBox(self, dData)
	local oBox = self.m_SubMenuClone:Clone(false)
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_SelNameL = oBox:NewUI(2, CLabel)
	oBox.m_ItemBox = oBox:NewUI(3, CItemBaseBox)

	oBox.m_Id = dData.subcat_id
	oBox.m_ItemId = dData.item_id

	oBox.m_ItemBox:SetBagItem(CItem.CreateDefault(dData.item_id))
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

function CItemComposeCatalogBox.ForceSelected(self, b)
	self.m_CatalogMenu:ForceSelected(b)
end

function CItemComposeCatalogBox.OnClickCatalog(self)
	self:ForceSelected(true)
	if self.m_CatalogCb then
		self.m_CatalogCb(self)
	end
end

function CItemComposeCatalogBox.JumpToSubCatalog(self, iSubIndex)
	local oSubMenu = self.m_SubMenus[iSubIndex] or self.m_SubMenuGrid:GetChild(1)
	if oSubMenu then 
		self:ExpandSubMenu(true)
		oSubMenu:Notify(enum.UIEvent["click"])
	end
end

function CItemComposeCatalogBox.ExpandSubMenu(self, bIsExpand)
	if self.m_SubCatalogData == nil or self.m_SubMenuBg:GetActive() == bIsExpand then
		return
	end
	self.m_SubMenuBg:SetActive(bIsExpand)
	self.m_TweenHeight:Toggle()
	self.m_TweenRotation_1:Toggle()
	self.m_TweenRotation_2:Toggle()
end

return CItemComposeCatalogBox