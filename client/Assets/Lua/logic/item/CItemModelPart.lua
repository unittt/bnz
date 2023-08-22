local CItemModelPart = class("CItemModelPart", CPageBase)

function CItemModelPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.ItemIcon = {"h7_wuqi","h7_maozi","h7_yifu","h7_shoushi","h7_toushi","h7_xiezi","h7_shoushi","h7_shoushi"}
end

function CItemModelPart.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_EquipmentGrid = self:NewUI(2, CGrid)
	self.m_EquipItemClone = self:NewUI(3, CItemBox)
	
	self.m_RoleTotalMark = self:NewUI(10, CLabel)
	self.m_MasterSpr = self:NewUI(11, CSprite)
	self.m_MasterLvL = self:NewUI(12, CLabel)
	self.m_OutSideBtn = self:NewUI(13, CButton)

	self.m_EquipItemClone:SetActive(false)
	self.m_WingBox = nil

	self:RegisterEvent()
	self:RefreshModel()
	self:InitGridBox()
	self:RefreshMaster()
    g_AttrCtrl:C2GSGetScore(2)
end

function CItemModelPart.RegisterEvent(self)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshEquip"))
	g_WingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWingEventCtrl"))

	self.m_MasterSpr:AddUIEvent("click", callback(self, "OnShowMaster"))
	self.m_OutSideBtn:AddUIEvent("click", callback(self, "OnClickOutSideBtn"))
end

function CItemModelPart.RefreshMoney(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData.dAttr.model_info then
			self:RefreshModel()
		end
	end
	if oCtrl.m_EventID == define.Attr.Event.UpDateScore then
	   self.m_RoleTotalMark:SetText("人物评分："..oCtrl.m_EventData)
	end
end

function CItemModelPart.RefreshModel(self)
	if g_AttrCtrl.model_info.horse and g_AttrCtrl.model_info.horse ~=0 then
		g_AttrCtrl.model_info.size = data.ridedata.RIDEINFO[g_AttrCtrl.model_info.horse].size
		local dInfo = table.copy(g_AttrCtrl.model_info)
		local model_info =   table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 2
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = -25
		self.m_ActorTexture:SetLocalPos(lp)
	else
		local model_info =  table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 1.2
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = 50
		self.m_ActorTexture:SetLocalPos(lp)

	end
end

function CItemModelPart.RefreshEquip(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		local gridList = self.m_EquipmentGrid:GetChildList()
		local posMap = {1, 2, 4, 3, 5, 6, 8, 7}
		for i,oBox in ipairs(gridList) do
			local equipData = g_ItemCtrl:GetEquipedByPos(posMap[i])
			table.print(equipData and equipData.m_SData, "CItemModelPart.RefreshEquip")
			oBox:SetBagItem(equipData)
			oBox:ForceSelected(false)
			--以后要根据需求修改
			local showLine = i < define.Equip.Pos.Seven and not equipData
			oBox.m_LinesSprite:SetActive(showLine)
			if showLine then
				oBox.m_LinesSprite:SetSpriteName(self.ItemIcon[i])
				oBox.m_LinesSprite:MakePixelPerfect()
			end
			if equipData and posMap[i] == define.Equip.Pos.Seven then
				self:RefreshWingIcon(oBox)
			end
		end
		self:RefreshMaster()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshStrengthLv then
		self:RefreshMaster()
	end

end

function CItemModelPart.OnWingEventCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Wing.Event.RefreshWing or oCtrl.m_EventID == define.Wing.Event.RefreshTimeWing then
		if self.m_WingBox then
			self:RefreshWingIcon(self.m_WingBox)
		end
	end
end

function CItemModelPart.InitGridBox(self)
	-- 排序，支持策划改顺序需求策略（固定后可删除）
	local posMap = {1, 2, 4, 3, 5, 6, 7, 8}
	local sort = {1, 2, 3, 4, 5, 6, 8, 7}
	-- local groupID = self.m_EquipmentGrid:GetInstanceID()
	for i = 1, define.Equip.Pos.Eight do
		local oEquipmentBox = self.m_EquipItemClone:Clone(define.Item.CellType.ModelEquip)
		oEquipmentBox.m_LinesSprite = oEquipmentBox:NewUI(6, CSprite)
		oEquipmentBox:SetActive(true)
		self.m_EquipmentGrid:AddChild(oEquipmentBox)
		oEquipmentBox:SetGroup(99999) --groupID
		oEquipmentBox:SetName(sort[i] .. "_equip")
		
		-- local showLock = i > 8
		oEquipmentBox:SetLock(false)
		local equipData = g_ItemCtrl:GetEquipedByPos(posMap[i])
		table.print(equipData and equipData.m_SData, "CItemModelPart.InitGridBox")
		oEquipmentBox:SetBagItem(equipData)
		--以后要根据需求修改
		local showLine = i < define.Equip.Pos.Seven and not equipData
		oEquipmentBox.m_LinesSprite:SetActive(showLine)
		if showLine then
			oEquipmentBox.m_LinesSprite:SetSpriteName(self.ItemIcon[i])
			oEquipmentBox.m_LinesSprite:MakePixelPerfect()
		end
		if equipData and posMap[i] == define.Equip.Pos.Seven then
			self:RefreshWingIcon(oEquipmentBox)
		end
		-- if i == 7 and equipData then
		-- 	local bRed = g_ItemCtrl:IsEquipdRed(posMap[i]) --戒指红点特殊处理
		-- 	oEquipmentBox:SetEquipedRed(bRed)
		-- end 
	end
end

function CItemModelPart.RefreshMaster(self)
	local dInfo = g_ItemCtrl:GetStrengthMasterInfo()
	self.m_MasterLvL:SetText(dInfo.lv)
end

function CItemModelPart.RefreshWingIcon(self, oBox)
	if not self.m_WingBox then
		self.m_WingBox = oBox
	end
	local dWing = g_WingCtrl:GetBagWingConfig()
	if dWing then
		oBox.m_IconSprite:SpriteItemShape(dWing.icon)
		local dItem = g_WingCtrl:GetWingItemData(dWing.wing_id)
		if dItem then
			oBox.m_BorderSprite:SetItemQuality(g_ItemCtrl:GetQualityVal(dItem.id, dItem.quality or 0))
		end
	end
end

function CItemModelPart.OnShowMaster(self)
	CItemSetAttrView:ShowView()
end

function CItemModelPart.OnClickOutSideBtn(self)

	CRanseMainView:ShowView(function (oView)
		oView:ShowWaiGuan()
	end)

end

return CItemModelPart