local CItemComposeCatalogListBox = class("CItemComposeCatalogListBox", CBox)

function CItemComposeCatalogListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_CatalogTable = self:NewUI(2, CTable)
	self.m_CatalogBoxClone = self:NewUI(3, CItemComposeCatalogBox)

	self:InitContent()
end

function CItemComposeCatalogListBox.InitContent(self)
	self.m_CatalogBoxClone:SetActive(false)
end

function CItemComposeCatalogListBox.SetCatalogData(self, tData)
	self.m_CatalogList = tData
	self:RefreshCatalogTable()
end

-- 设置监听器
function CItemComposeCatalogListBox.SetCatalogCallback(self, catalogCb, subCatalogCb)
	self.m_CatalogCb = catalogCb
	self.m_SubCatalogCb = subCatalogCb
end

function CItemComposeCatalogListBox.JumpToCatalog(self, iIndex, iSubIndex)
	printc("CItemComposeCatalogListBox.JumpToCatalog", iIndex, iSubIndex, self.m_CatalogTable:GetCount())
	if self.m_SelectedBox then
		self.m_SelectedBox:ForceSelected(false)
	end
	local oBox = self.m_CatalogTable:GetChild(iIndex)
	if oBox then
		printc("find")
		oBox:OnClickCatalog()
		oBox:JumpToSubCatalog(iSubIndex)
		self.m_CatalogTable:Reposition()
	end
end

function CItemComposeCatalogListBox.RefreshCatalogTable(self)
	self.m_CatalogTable:Clear()
	if not self.m_CatalogList then
		return
	end

	for i,dCatalog in ipairs(self.m_CatalogList) do
		if dCatalog.is_open == 1 then
			local oBox = self.m_CatalogBoxClone:Clone()
			oBox:SetActive(true)
			oBox:SetCatalogCallback(self.m_CatalogCb, self.m_SubCatalogCb)
			oBox:SetCatalogData(dCatalog)
			self.m_CatalogTable:AddChild(oBox)
			self.m_CatalogTable:CheckChange()
		end
	end
	self.m_ScrollView:ResetPosition()
	self.m_CatalogTable:Reposition()
end

function CItemComposeCatalogListBox.HideOther(self, oTarget)
	for i,oBox in ipairs(self.m_CatalogTable:GetChildList()) do
		if oBox ~= oTarget then
			oBox:ExpandSubMenu(false)
		end
	end
	self.m_CatalogTable:Reposition()
end

return CItemComposeCatalogListBox