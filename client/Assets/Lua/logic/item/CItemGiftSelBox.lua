local CItemGiftSelBox = class("CItemGiftSelBox", CBox)

function CItemGiftSelBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemBoxClone = self:NewUI(2, CItemBaseBox)
	self.m_OkBtn = self:NewUI(3, CButton)

	self.m_OkBtn:AddUIEvent("click", callback(self, "RequestGiftItem"))
end

function CItemGiftSelBox.SetInitBox(self, citem)
	self.m_Item = citem
	self:RefreshGrid()
	local oView = CItemTipsView:GetView()
	if oView then
		oView.m_MainBox:HideButton()
	end
end

function CItemGiftSelBox.RefreshGrid(self)
	self.m_ItemGrid:Clear()
	local itemlist = DataTools.GetItemGiftList(self.m_Item:GetCValueByKey("id"), g_AttrCtrl.roletype, g_AttrCtrl.sex)
	for i,item in ipairs(itemlist) do
		local cItem = CItem.CreateDefault(item.sid)
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(item.sid)
		local oBox = self.m_ItemBoxClone:Clone()
		oBox.m_Groupidx = item.groupidx
		oBox:SetBagItem(cItem)
		oBox.m_BorderSprite:SetItemQuality(oBox.m_Item:GetQuality())
		oBox:SetAmountText(iAmount)
		oBox:SetClickCallback(callback(self, "OnClickItemBox", oBox))
		self.m_ItemGrid:AddChild(oBox)
	end
	self.m_ItemBoxClone:SetActive(false)
	self.m_ItemGrid:Reposition()
end

function CItemGiftSelBox.OnClickItemBox(self, oBox)
	self.m_SelectedId = oBox.m_Groupidx
	local oView = CItemTipsView:GetView()
	if oView then
		oView.m_MainBox:SetInitBox(oBox.m_Item)
		oView.m_MainBox:HideButton()
	end
end

function CItemGiftSelBox.RequestGiftItem(self)
	if self.m_SelectedId == nil then
		g_NotifyCtrl:FloatMsg("请选择你需要的类型")
		return
	end
	netitem.C2GSItemUse(self.m_Item:GetSValueByKey("id"), nil, tostring(self.m_SelectedId))
	local oView = CItemTipsView:GetView()
	if oView then
		oView:CloseView()
	end
end

return CItemGiftSelBox