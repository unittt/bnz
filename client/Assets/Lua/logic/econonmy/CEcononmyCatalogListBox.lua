local CEcononmyCatalogListBox = class("CEcononmyCatalogListBox", CBox)

function CEcononmyCatalogListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_CatalogGrid = self:NewUI(2, CGrid)
	self.m_CatalogBoxClone = self:NewUI(3, CBox)

	self:InitContent()
end

function CEcononmyCatalogListBox.InitContent(self)
	self.m_CatalogBoxClone:SetActive(false)
end

function CEcononmyCatalogListBox.SetCatalogData(self, tData, iType)
	self.m_CatalogList = tData
	self.m_CatalogType = iType
	self:RefreshCatalogGrid()
end

function CEcononmyCatalogListBox.SetCallback(self, cb)
	self.m_CallBack = cb
end

function CEcononmyCatalogListBox.JumpToCatalog(self, iIndex)
	if self.m_SelectedBox then
		self.m_SelectedBox:ForceSelected(false)
	end
	local oBox = self.m_CatalogGrid:GetChild(iIndex)
	if oBox then
		oBox:SetSelected(true)
		self:OnClickCatalog(oBox)
	end
end

function CEcononmyCatalogListBox.RefreshCatalogGrid(self)
	self.m_ScrollView:ResetPosition()
	self.m_CatalogGrid:Clear()
	if not self.m_CatalogList then
		return
	end
	for i,dInfo in ipairs(self.m_CatalogList) do
		local oBox = self:CreateCatalogBox(dInfo)
		self.m_CatalogGrid:AddChild(oBox)
		-- if i == 1 then
		-- 	oBox:SetSelected(true)
		-- 	self:OnClickCatalog(oBox)
		-- end
	end
end

function CEcononmyCatalogListBox.CreateCatalogBox(self, dInfo)
	local oBox = self.m_CatalogBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_TypeSpr = oBox:NewUI(2, CSprite)
	oBox.m_TaskSpr = oBox:NewUI(3, CSprite)

	oBox.m_CatalogId = dInfo.cat_id
	oBox.m_CatalogInfo = dInfo
	oBox.m_NameL:SetText(dInfo.cat_name)
	-- oBox.m_TypeSpr:SetSpriteName("")
	oBox.m_TaskSpr:SetActive(g_EcononmyCtrl:IsTaskCatalog(self.m_CatalogType, dInfo.cat_id))

	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnClickCatalog", oBox))
	return oBox
end

function CEcononmyCatalogListBox.OnClickCatalog(self, oBox)
	self.m_SelectedBox = oBox
	if self.m_CallBack then
		self.m_CallBack(oBox)
	end
end

return CEcononmyCatalogListBox