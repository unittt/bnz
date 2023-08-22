local CEcononmySubCatalogListBox = class("CEcononmySubCatalogListBox", CBox)

CEcononmySubCatalogListBox.PageLimit = 8

function CEcononmySubCatalogListBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_PreBtn = self:NewUI(1, CButton)
	self.m_NextBtn = self:NewUI(2, CButton)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_SubCatalogBoxClone = self:NewUI(4, CBox)

	self.m_PageCount = 1
	self.m_CatalogLimit = 8
	self.m_CurrntPage = 1
	self:InitContent()
end

function CEcononmySubCatalogListBox.InitContent(self)
	self.m_SubCatalogBoxClone:SetActive(false)
	self.m_PreBtn:AddUIEvent("click", callback(self, "OnPageChange", -1))
	self.m_NextBtn:AddUIEvent("click", callback(self, "OnPageChange", 1))
end

function CEcononmySubCatalogListBox.SetCatalogInfo(self, iCatalogID, tSubCatalogList, iType)
	self.m_CatalogId = iCatalogID
	self.m_SubCatalogList = tSubCatalogList
	self.m_Type = iType
 
	self.m_PageCount = math.max(math.floor((#self.m_SubCatalogList - 1)/self.m_CatalogLimit) + 1, 1)
	self.m_CurrntPage = 1 
	self:OnPageChange(0)
end

function CEcononmySubCatalogListBox.SetClickCallback(self, cb)
	self.m_CallBack = cb
end

function CEcononmySubCatalogListBox.SetDragCallback(self, startFunc, dragFunc, endFunc)
	self.m_DragStartCb = startFunc
	self.m_DragCb = dragFunc
	self.m_DragEndCb = endFunc
end

function CEcononmySubCatalogListBox.SetActive(self, b)
	CBox.SetActive(self, b)
	self:OnPageChange(0)
end

function CEcononmySubCatalogListBox.RefreshAll(self)
	self:RefreshSubCatalogGrid()
end

function CEcononmySubCatalogListBox.RefreshSubCatalogGrid(self)
	self.m_Grid:Clear()
	local iIndex = (self.m_CurrntPage - 1)*self.m_CatalogLimit + 1
	local iLastIndex = iIndex + self.m_CatalogLimit - 1
	local bIsHasTaskItem = g_EcononmyCtrl:HasTaskItem(self.m_Type)
	for i = iIndex, iLastIndex do
		local dInfo = self.m_SubCatalogList[i]
		if not dInfo then
			break
		end
		if dInfo.cat_id == self.m_CatalogId then
			local oBox = self:CreateSubCatalogBox(dInfo)
			self.m_Grid:AddChild(oBox)
		end
	end
	self.m_Grid:Reposition() 
end

function CEcononmySubCatalogListBox.CreateSubCatalogBox(self, dInfo)
	local oBox = self.m_SubCatalogBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_TaskSpr = oBox:NewUI(4, CSprite)

	oBox.m_Id = dInfo.subcat_id
	oBox.m_SubCataLogInfo = dInfo
	oBox.m_NameL:SetText(dInfo.subcat_name)
	oBox.m_TaskSpr:SetActive(g_EcononmyCtrl:IsTaskSubCatalog(self.m_Type, self.m_CatalogId, dInfo.subcat_id))

	oBox:AddUIEvent("click", callback(self, "OnClickBox", oBox))
	oBox:AddUIEvent("dragstart", self.m_DragStartCb)
	oBox:AddUIEvent("drag", self.m_DragCb)
	oBox:AddUIEvent("dragend", self.m_DragEndCb)
	oBox:SetActive(true)
	return oBox
end

function CEcononmySubCatalogListBox.OnPageChange(self, iChangeValue)
	local iLastPage = self.m_CurrntPage
	self.m_CurrntPage = self.m_CurrntPage + iChangeValue
	self.m_CurrntPage = math.max(1, self.m_CurrntPage)
	self.m_CurrntPage = math.min(self.m_CurrntPage, self.m_PageCount)

	self.m_NextBtn:SetActive(self.m_CurrntPage < self.m_PageCount and self:GetActive())
	self.m_PreBtn:SetActive(self.m_CurrntPage > 1 and self:GetActive())
	if iLastPage == self.m_CurrntPage then
		return
	end
	self:RefreshSubCatalogGrid()
end

function CEcononmySubCatalogListBox.OnClickBox(self, oBox)
	-- TODO:请求子目录下的物品
	-- netxxx.getxxxx()
	if self.m_CallBack then
		self.m_CallBack(oBox)
	end
end

return CEcononmySubCatalogListBox