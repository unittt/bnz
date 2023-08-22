local CEcononmyBagItemListBox = class("CEcononmyBagItemListBox", CBox)

function CEcononmyBagItemListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemBoxClone = self:NewUI(2, CItemBaseBox)

	self.m_ItemBoxs = {}
	self:InitContent()
end

function CEcononmyBagItemListBox.InitContent(self)
	self.m_ItemBoxClone:SetActive(false)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_ItemGrid:Clear()
end

function CEcononmyBagItemListBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self:RefreshItemGrid()
	end
end

function CEcononmyBagItemListBox.SetEcononmyType(self, iType)
	self.m_Type = iType
	self:RefreshItemGrid()
end

function CEcononmyBagItemListBox.ResetAllItemBox(self)
	for i,oBox in ipairs(self.m_ItemBoxs) do
		oBox:SetActive(false)
	end
end

function CEcononmyBagItemListBox.RefreshItemGrid(self)
	local tItemList = {}
	if self.m_Type == define.Econonmy.Type.Stall then
		tItemList = g_ItemCtrl:GetCanStallItemList()
	else
		tItemList = g_ItemCtrl:GetCanGuildItemList()
	end
	self:ResetAllItemBox()
	local iUnlockCount = g_ItemCtrl:GetBagOpenCount()
	for i=1, iUnlockCount do
		local oItem = tItemList[i]
		local oBox = self.m_ItemBoxs[i]
		if not oBox then
			oBox = self:CreateItemBox() 
			self.m_ItemGrid:AddChild(oBox)
			self.m_ItemBoxs[i] = oBox
		end
		self:UpdateItemBox(oBox, oItem)
	end
end

function CEcononmyBagItemListBox.CreateItemBox(self)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox:SetClickCallback(callback(self, "OnClickItem"))
	return oBox
end

function CEcononmyBagItemListBox.UpdateItemBox(self, oBox, oItem)
	oBox:SetBagItem(oItem)
	oBox:SetActive(true)
end

function CEcononmyBagItemListBox.OnClickItem(self, oBox)
	if self.m_Type == define.Econonmy.Type.Stall then
		local iRemainingGrid = g_EcononmyCtrl:GetRemainingGridCount()
		CEcononmyBatchStallView:ShowView(function(oView)
			if iRemainingGrid > 0 then
				oView:SetSelectedItem(oBox.m_Item.m_ID)
				oView:RefreshItemGrid()
			end
		end)		
	else
		CItemSaleView:ShowView(function(oView)
			oView:SetItemInfo(oBox.m_Item)
		end)
	end
end

return CEcononmyBagItemListBox