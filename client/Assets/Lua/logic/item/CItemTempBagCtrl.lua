local CItemTempBagCtrl = class("CItemTempBagCtrl",CCtrlBase)

function CItemTempBagCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CItemTempBagCtrl.Clear(self)
	self.m_TempBagList = {}
end

function CItemTempBagCtrl.ShowView(self)
	 CItemTempBagView:ShowView()
end

function CItemTempBagCtrl.GS2CLoginTempItem(self, itemdata)
	self.m_TempBagList = itemdata
	self:OnEvent(define.Item.Event.RefreshTempBag)
end

function CItemTempBagCtrl.GS2CAddTempItem(self,itemdata)
	--判定是否有被顶替的道具
	if #self.m_TempBagList == 15 then
		table.remove(self.m_TempBagList,itemdata.pos)
	end
	table.insert(self.m_TempBagList, itemdata)
	self:OnEvent(define.Item.Event.AddItemToTempBag)
end

function CItemTempBagCtrl.GS2CRefreshTempItem(self, itemdata)
	for i ,v in ipairs(self.m_TempBagList) do 
		if v.id == itemdata.id then
			v.amount = itemdata.amount
		end
	end
	self:OnEvent(define.Item.Event.RefreshTempBag)
end

function CItemTempBagCtrl.GS2CDelTempItem(self,id)
	for i,v in ipairs(self.m_TempBagList) do 
		if id == v.id then
			table.remove(self.m_TempBagList,i)
		end
	end
	self:OnEvent(define.Item.Event.RefreshTempBag)
end

function CItemTempBagCtrl.GetEquipList(self)
	local equiplist = {}
	for i,v in ipairs(self.m_TempBagList) do
		local oItem = CItem.New(v)
		if oItem:IsEquip() and not oItem:IsSummonEquip() then
			oItem.m_Type ="Temp"
			table.insert(equiplist, oItem)
		end
	end
	return equiplist
end

function CItemTempBagCtrl.GS2CRefreshAllTemItem(self,itemdata)
	self.m_TempBagList = {}
	for i ,v in ipairs(itemdata) do 
		table.insert(self.m_TempBagList, v)
	end
	-- body
	self:OnEvent(define.Item.Event.RefreshTempBag)
end

return CItemTempBagCtrl