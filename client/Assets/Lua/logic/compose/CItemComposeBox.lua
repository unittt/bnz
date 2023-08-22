local CItemcomposeBox = class("CItemcomposeBox", CBox)

function CItemcomposeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CatalogListBox = self:NewUI(1, CItemComposeCatalogListBox)
	self.m_TipBtn = self:NewUI(2, CButton)
	self.m_CommonBox = self:NewUI(3, CItemCommonComposeBox)
	self.m_GemStoneComposeBox = self:NewUI(4, CItemGemStoneComposeBox)
	self.m_GemStoneMixBox = self:NewUI(5, CItemGemStoneMixBox)

	self.m_CurComposeBox = self.m_CommonBox
	self:InitContent()
end

function CItemcomposeBox.InitContent(self)
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))

	self:InitCatalogListBox()
end

function CItemcomposeBox.InitCatalogListBox(self)
	self.m_CatalogListBox:SetCatalogCallback(callback(self, "OnCatalogChange"), callback(self, "OnSubCatalogChange"))
	self.m_CatalogListBox:SetCatalogData(data.itemcomposedata.CATALOG)
	-- self.m_CatalogListBox:JumpToCatalog(1, 1)
end

function CItemcomposeBox.JumpToTargetCatalog(self, iCatalogId, iSubCatalogId)
	self.m_CatalogListBox:JumpToCatalog(iCatalogId, iSubCatalogId)
end

function CItemcomposeBox.SetSelectedItem(self, iItemId)
	self.m_CurComposeBox:SetSelectedItem(iItemId)
end

function CItemcomposeBox.ChangeComposeMode(self, iCatId)
	local bIsGemStoneCompose = iCatId == 4
	local bIsGemStoneMix = iCatId == 5
	self.m_CommonBox:SetActive(not bIsGemStoneCompose and not bIsGemStoneMix)
	self.m_GemStoneComposeBox:SetActive(bIsGemStoneCompose)
	self.m_GemStoneMixBox:SetActive(bIsGemStoneMix)
	self.m_CurComposeBox = self.m_CommonBox
	if bIsGemStoneMix then
		self.m_CurComposeBox = self.m_GemStoneMixBox
		self.m_CurComposeBox:SetSelectedItem(nil)
	elseif bIsGemStoneCompose then
		self.m_CurComposeBox = self.m_GemStoneComposeBox
		self.m_CurComposeBox:SetSelectedItem(nil)
	end
end

function CItemcomposeBox.OnCatalogChange(self, oBox)
	self.m_CatalogId = oBox.m_CatalogId
	self:ChangeComposeMode(self.m_CatalogId)
	if oBox.m_ItemId == 0 then
	else
		self:SetSelectedItem(oBox.m_ItemId)
	end
	self.m_CatalogListBox:HideOther(oBox)
end

function CItemcomposeBox.OnSubCatalogChange(self, oBox)
	self.m_SubCatalogId = oBox.m_Id
	self:SetSelectedItem(oBox.m_ItemId)
end

function CItemcomposeBox.ShowTipView(self)
	local id = define.Instruction.Config.Compose
	if self.m_GemStoneComposeBox:GetActive() then
		id = define.Instruction.Config.GemStoneCompose
	elseif self.m_GemStoneMixBox:GetActive() then
		id = define.Instruction.Config.GemStoneMix
	end
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end
return CItemcomposeBox