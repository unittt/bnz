local CRecoveryCtrl = class("CRecoveryCtrl",CCtrlBase)

function CRecoveryCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_RecoveryItemList ={}
	self.m_RecoverySumList = {}
	self.m_DeleteSumID  = nil
end

function CRecoveryCtrl.GS2COpenRecoveryItem(self,itemdata)
	self.m_RecoveryItemList = itemdata
	CRecoveryItemView:ShowView()
end

function CRecoveryCtrl.GS2CDelRecoveryItem(self,id)
	for i,v in ipairs(self.m_RecoveryItemList) do
		if v.id == id then
			table.remove(self.m_RecoveryItemList, i)
			break
		end
	end
	self:OnEvent(define.Recovery.Event.RecoveryItem)
end

function CRecoveryCtrl.GetRecoveryItemByID(self, id)
	-- body
	local oItem = nil
	for i,v in ipairs(self.m_RecoveryItemList) do
		if  id ==  v.id then
			oItem = v
			break
		end
	end
	return oItem
end

function CRecoveryCtrl.GS2COpenRecoverySum(self,sumdata)
	self.m_RecoverySumList = {}
	self.m_RecoverySumList =sumdata
	CRecoverySumView:ShowView()
end

function CRecoveryCtrl.GS2CDelRecoverSum(self,id)
	 self.m_DeleteSumID = id
	self:OnEvent(define.Recovery.Event.RecoverySum)
end


function CRecoveryCtrl.GetEquipList(self)
	-- body
	local equiplist = {}
	for i,v in ipairs(self.m_RecoveryItemList) do
		local oItem = CItem.New(v)
		if oItem:IsEquip() and not oItem:IsSummonEquip() then
			oItem.m_Type ="Re"
			table.insert(equiplist, oItem)
		end
	end
	return equiplist
end

function CRecoveryCtrl.GetItemByPos(self, pos)
	-- body
	if pos then
		local oItem = nil
		for i,v in ipairs(self.m_RecoveryItemList) do
			if pos == v.pos then
				oItem  = v
				break
			end
		end
		return oItem
	else
		table.sort(self.m_RecoveryItemList, function (a,b)
			-- body
			return a.pos < b.pos
		end)
		return self.m_RecoveryItemList[1]
	end
end

----------------------C2GS

function CRecoveryCtrl.C2GSRecoveryItem(self,ItemID)
	netrecovery.C2GSRecoveryItem(ItemID)
end

function CRecoveryCtrl.C2GSRecoverySum(self,SumID)
	netrecovery.C2GSRecoverySum(SumID)
end

return CRecoveryCtrl