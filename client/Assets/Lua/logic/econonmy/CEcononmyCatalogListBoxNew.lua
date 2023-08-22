local CEcononmyCatalogListBoxNew = class("CEcononmyCatalogListBoxNew", CBox)

function CEcononmyCatalogListBoxNew.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_CatalogTable = self:NewUI(2, CTable)
	self.m_CatalogBoxClone = self:NewUI(3, CEcononmyCatalogBoxNew)

	self:InitContent()
end

function CEcononmyCatalogListBoxNew.InitContent(self)
	self.m_CatalogBoxClone:SetActive(false)
end

function CEcononmyCatalogListBoxNew.SetCatalogData(self, tData, iType)
	self.m_CatalogList = tData
	self.m_CatalogType = iType
	self:RefreshCatalogTable()
end

-- 设置监听器
function CEcononmyCatalogListBoxNew.SetCatalogCallback(self, catalogCb, subCatalogCb)
	self.m_CatalogCb = catalogCb
	self.m_SubCatalogCb = subCatalogCb
end

function CEcononmyCatalogListBoxNew.JumpToCatalog(self, iIndex, iSubIndex)
	-- printc("CEcononmyCatalogListBoxNew.JumpToCatalog", iIndex, iSubIndex, self.m_CatalogTable:GetCount())
	if self.m_SelectedBox then
		self.m_SelectedBox:ForceSelected(false)
	end
	local oBox = self.m_CatalogTable:GetChild(iIndex)
	if oBox then
		-- printc("find")
		oBox:OnClickCatalog(false)
		oBox:JumpToSubCatalog(iSubIndex)
		self.m_CatalogTable:Reposition()
	end
end

function CEcononmyCatalogListBoxNew.RefreshCatalogTable(self)
	self.m_CatalogTable:Clear()
	if not self.m_CatalogList then
		return
	end

	for i,dCatalog in ipairs(self.m_CatalogList) do
		local oBox = self.m_CatalogBoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetCatalogCallback(self.m_CatalogCb, self.m_SubCatalogCb)
		oBox:SetCatalogData(dCatalog, self.m_CatalogType)
		self.m_CatalogTable:AddChild(oBox)
		self.m_CatalogTable:CheckChange()
	end
	self.m_ScrollView:ResetPosition()
	self.m_CatalogTable:Reposition()
end

function CEcononmyCatalogListBoxNew.HideOther(self, oTarget)
	for i,oBox in ipairs(self.m_CatalogTable:GetChildList()) do
		if oBox ~= oTarget then
			oBox:ExpandSubMenu(false)
		end
	end
	self.m_CatalogTable:Reposition()
end

return CEcononmyCatalogListBoxNew