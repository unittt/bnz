CForgeCtrl = class("CForgeCtrl", CCtrlBase)

function CForgeCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Reset()

	self.m_UnlockTab = {
		[1] = define.System.EquipForge,
		[2] = define.System.EquipStrengthen,
		[3] = define.System.EquipWash,
		[4] = define.System.EquipSoul,
		[5] = define.System.EquipInlay,
	}

	self.m_AttachSoulLimitLv = 50
	self.m_LastTab = nil
	self.m_InlayRedPointStatus = {}
end

function CForgeCtrl.Reset(self)
	self.m_LastTab = nil
	self.m_InlayRedPointStatus = {}
end

function CForgeCtrl.ShowView(self, cls, cb)
	local defaultIndex = self:GetDefaultTabIndex()
	if defaultIndex then
		CViewBase.ShowView(cls, cb)
	end
end

function CForgeCtrl.GetDefaultTabIndex(self)
	if self.m_LastTab then
		return self.m_LastTab
	end
	for i,v in ipairs(self.m_UnlockTab) do
		local open = g_OpenSysCtrl:GetOpenSysState(v)
		if open then
			return i
		end
	end
end

function CForgeCtrl.IsSpecityTabOpen(self, index)
	local openKey = self.m_UnlockTab[index]
	return g_OpenSysCtrl:GetOpenSysState(openKey)
end

function CForgeCtrl.RecordLastTab(self, iTab)
	self.m_LastTab = iTab
end

function CForgeCtrl.ResetAllInlayRedPointStatus(self)
	self.m_InlayRedPointStatus = {}
	local lEquip =  g_ItemCtrl:GetEquipList(nil, nil, 
		50, nil, nil, nil, nil)

	for _,oItem in pairs(lEquip) do
		self.m_InlayRedPointStatus[oItem.m_ID] = false

		local iEquipLv = oItem:GetItemEquipLevel()
		if iEquipLv % 10 ~= 0 then
			iEquipLv = math.floor(iEquipLv/10)*10
		end
		local dLimitData = data.hunshidata.EQUIPLIMIT[iEquipLv]
		local dColorData = data.hunshidata.EQUIPCOLOR[oItem:GetCValueByKey("equipPos")]

		for i=1,3 do
			local dInlay = oItem:GetInlayItemByPos(i)
			if dLimitData.holecnt < i then
				break
			end
			if dInlay == nil then
				local lGemStone = g_ItemCtrl:GetGemStoneList(dColorData.colorlist[1], true, 1, dLimitData.maxlv, nil, nil, true)
				if #lGemStone > 0 then
					self.m_InlayRedPointStatus[oItem.m_ID] = true
					break
				end
			end
		end
	end

	self:OnEvent(define.Forge.Event.RefreshInlayRedPoint)
end

function CForgeCtrl.GetInlayRedPointStatus(self, iItemId)
	return self.m_InlayRedPointStatus[iItemId]
end

return CForgeCtrl