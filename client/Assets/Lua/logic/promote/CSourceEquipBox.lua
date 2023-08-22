local CSourceEquipBox = class("CSourceEquipBox", CBox)

function CSourceEquipBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_EquipCheckBtn = self:NewUI(1, CButton) --查看装备
	-- self.m_EquipDesBtn = self:NewUI(2, CButton)   -- 装备说明

	self.m_PopBox = self:NewUI(3, CBox)
	self.m_SegmentScrollView = self:NewUI(4, CScrollView)
	self.m_SegmentGrid = self:NewUI(5, CGrid)
	self.m_SegmentBtnClone = self:NewUI(6, CBox)
	self.m_EquipSVPart = self:NewUI(7, CBox)
	self.m_EquipScorllView = self:NewUI(8, CScrollView)
	self.m_EquipGrid = self:NewUI(9, CGrid)
	self.m_EquipItemClone = self:NewUI(10, CBox)
	self.m_ExplainPart = self:NewUI(11, CBox)
	self.m_EquipDesPart = self:NewUI(12, CBox)
	
	self.m_EquipSegmentBox = self:NewUI(13, CBox) -- 等级段装备按钮

	self.m_EquipSegmentBtn =  self.m_EquipSegmentBox:NewUI(1, CSprite)
	self.m_EquipSegmentNorLab = self.m_EquipSegmentBox:NewUI(2, CLabel)

	self.m_SelectLevel = nil

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))

	self:InitCheckPart()
	self:InitEquipDesPart()
	self:InitContent()
end

function CSourceEquipBox.InitCheckPart(self)
	-- body
	self.m_EquipBox  =  self.m_ExplainPart:NewUI(1, CBox)
	self.m_SelectEquipItemSpr = self.m_EquipBox:NewUI(1, CSprite)
	self.m_SelectEquipNameLab = self.m_EquipBox:NewUI(2, CLabel)
	-- self.m_SelectEquipLevelLab = self.m_EquipBox:NewUI(3, CLabel)
	self.m_SelectEquipTypeLab = self.m_EquipBox:NewUI(4, CLabel)


	self.m_BaseTable = self.m_ExplainPart:NewUI(11, CTable)
	self.m_ShenHunTitle = self.m_ExplainPart:NewUI(2, CLabel)
	self.m_ShenHunTable = self.m_ExplainPart:NewUI(3, CTable)

	self.m_AttrName = self.m_ExplainPart:NewUI(4, CLabel)
	self.m_AttrVal = self.m_ExplainPart:NewUI(5, CLabel)
	self.m_FujiaTitle = self.m_ExplainPart:NewUI(6, CLabel)
	self.m_FujiaDesLab = self.m_ExplainPart:NewUI(7, CLabel)
	self.m_EquipDesLab = self.m_ExplainPart:NewUI(8, CLabel)
	self.m_GainWayGrid = self.m_ExplainPart:NewUI(9, CGrid)	
	self.m_GainWayBox = self.m_ExplainPart:NewUI(10, CBox)

	self.m_EquipDesTitle = self.m_ExplainPart:NewUI(12, CLabel)
	self.m_GainWayLab    = self.m_ExplainPart:NewUI(13, CLabel)
	self.m_Table = self.m_ExplainPart:NewUI(14, CTable)

end

function CSourceEquipBox.InitContent(self)
	-- body
	self.m_CurrPopIdx = nil
	self.m_EquipDesPart:SetActive(false)

	self.m_EquipSVPart:SetActive(true)
	self.m_PopBox:SetActive(false)
	-- self.m_EquipCheckBtn:AddUIEvent("click", callback(self, "OnEquipCheckClick"))
	-- self.m_EquipDesBtn:AddUIEvent("click", callback(self, "OnEquipDesClick"))
	

	-- self.m_EquipCheckBtn:SetGroup(self:GetInstanceID())
	-- self.m_EquipDesBtn:SetGroup(self:GetInstanceID())
	

	self.m_EquipSegmentBtn:AddUIEvent("click", callback(self, "OnPopBox"))


	self.m_SegmentGrid:Clear()
	local equipSegment = data.sourcebookdata.EQUIPFUJIADES
	local segmentList = self.m_SegmentGrid:GetChildList()
	local level = math.floor(g_AttrCtrl.grade/10)
	local maxlevel = 0
	for i,v in ipairs(equipSegment) do
		if v.level > maxlevel then
			maxlevel = v.level
		end
	end
	-- local coypinfo = equipSegment[maxlevel/10]
	-- if level > maxlevel/10 then
	-- 	equipSegment = table.copy(equipSegment)
	-- 	for i= maxlevel/10 + 1,level,1 do
	-- 		table.insert(equipSegment, {catalogue = tostring(i*10).."级装备",fujiades = coypinfo.fujiades, level = i*10 })
	-- 	end  
	-- end
 	for i,v in ipairs(equipSegment) do
 		local boxclone= nil
 		if i>#segmentList then
 			boxclone = self.m_SegmentBtnClone:Clone()
 			boxclone:SetActive(true)
 			self.m_SegmentGrid:AddChild(boxclone)
 			boxclone.namelab = boxclone:NewUI(1, CLabel)
 			boxclone.flaglab = boxclone:NewUI(2, CLabel)
 			boxclone.btn     = boxclone:NewUI(3, CSprite)
 			boxclone.btn:SetGroup(self.m_SegmentGrid:GetInstanceID())
 		else
 			boxclone = segmentList[i]
 		end
 		boxclone.namelab:SetText(v.catalogue)
 		boxclone.flaglab:SetText(v.catalogue)
 		boxclone.btn:AddUIEvent("click", callback(self, "OnSelectSegment", v.level, equipSegment, i))
	end
	self.m_SegmentGrid:Reposition()
	-- self.m_EquipCheckBtn:ForceSelected(true)
	-- self.m_EquipDesBtn:ForceSelected(false)
	self.m_EquipSegmentBox:SetActive(true)
	-- local level = math.floor(g_AttrCtrl.grade/10)
	if level*10 > maxlevel then
		self.m_SegmentGrid:GetChild(#equipSegment).btn:SetSelected(true)
		self:OnSelectSegment(maxlevel, equipSegment, #equipSegment)
	else
		self.m_SegmentGrid:GetChild(level+1).btn:SetSelected(true)
		self:OnSelectSegment(math.floor(g_AttrCtrl.grade), equipSegment, level+1)
	end
end

function CSourceEquipBox.OnSelectSegment(self, grade, equipSegment, i)
	-- body
	if self.m_CurrPopIdx and self.m_CurrPopIdx == grade then
		return
	end
	self.m_CurrPopIdx = grade
	self.m_SelectLevel = i
	self.m_PopBox:SetActive(false)
	self.m_EquipSegmentNorLab:SetText(equipSegment[math.floor(grade/10+1)].catalogue)
	local equipinfo = data.itemequipdata.EQUIP
	local cacheequip = {}
	for i,v in pairs(equipinfo) do
		if math.floor(grade/10)*10 ==  v.equipLevel then
			table.insert(cacheequip, v)
		end
	end
	for i,v in ipairs(cacheequip) do
		if v.partName == "武器" then
			v.sort = 1
		elseif v.partName == "头盔" or v.partName=="发簪" then
			v.sort = 2
		elseif v.partName == "铠甲" or v.partName == "衣裙"  then
			v.sort = 3
		elseif v.partName == "项链" then
			v.sort = 4
		elseif v.partName == "腰带" then
			v.sort = 5
		elseif v.partName == "鞋子" then
			v.sort = 6
		end
	end
	table.sort(cacheequip,function (a,b)
		-- body
		if a.sort~= b.sort then
			return a.sort<b.sort
		end
	end)
	self.m_EquipGrid:Clear()
	local equiplist = self.m_EquipGrid:GetChildList()
	for i,v in ipairs(cacheequip) do
		local equip = nil
		if i>#equiplist then
			equip = self.m_EquipItemClone:Clone()
			equip:SetGroup(self.m_EquipGrid:GetInstanceID())
			self.m_EquipGrid:AddChild(equip)
			equip.m_ItemSpr = equip:NewUI(1, CSprite)
			equip.m_NameLab = equip:NewUI(2, CLabel)
			-- equip.m_LevelLab = equip:NewUI(3, CLabel)
			-- equip.m_TypeLab = equip:NewUI(4, CLabel)
			equip.m_flagname = equip:NewUI(5, CLabel)
		else
			equip = equiplist[i]
		end
		equip:SetActive(true)
		local dData = DataTools.GetItemData(v.id)
		equip.m_ItemSpr:SpriteItemShape(dData.icon)
		equip.m_NameLab:SetText(dData.name)
		-- equip.m_LevelLab:SetText(dData.equipLevel)
		-- equip.m_TypeLab:SetText(dData.partName)
		equip.m_flagname:SetText(dData.name)

		equip:AddUIEvent("click", callback(self, "RefreshExplainPart", v.id, equipSegment))
	end
	self.m_EquipGrid:Reposition()
	self.m_EquipScorllView:ResetPosition()

	self.m_EquipGrid:GetChild(1):SetSelected(true)
	self:RefreshExplainPart(cacheequip[1].id, equipSegment)
end


function CSourceEquipBox.RefreshExplainPart(self, sid, equipSegment)
	-- body
	local dData = DataTools.GetItemData(sid)
	self.m_SelectEquipItemSpr:SpriteItemShape(dData.icon)
	self.m_SelectEquipNameLab:SetText(dData.name)
	-- self.m_SelectEquipLevelLab:SetText(dData.equipLevel)
	self.m_SelectEquipTypeLab:SetText(dData.partName)

	-- 刷新基础属性
	local dItem = CItem.CreateDefault(sid)
	local tData = g_ItemCtrl:GetEquipPreview(dItem)
	self.m_BaseTable:Clear()
	for i,v in pairs(tData) do
		local name = self.m_AttrName:Clone()
		name:SetActive(true)
		name:SetText(v.name)
		self.m_BaseTable:AddChild(name)
		local range = self.m_AttrVal:Clone()
		range:SetActive(true)
		range:SetText(v.min.."~"..v.max)
		self.m_BaseTable:AddChild(range)
	end
	self.m_BaseTable:Reposition()

	-- 刷新神魂属性
	if dData.equipLevel >= 50 then
		self.m_ShenHunTable:Clear()
		self.m_ShenHunTitle:SetActive(true)
		self.m_ShenHunTable:SetActive(true)

		-- 伪造一份 "apply_info"
		dItem.m_SData.apply_info = {}
		for i,v in ipairs(tData) do
			local t = {key = v.attr, value = v.max}
			table.insert(dItem.m_SData.apply_info, t)
		end
		-- 完成

		for k,v in ipairs(dItem:GetSValueByKey("apply_info")) do
			local sAttrName = data.attrnamedata.DATA[v.key].name
			local iMin,iMax = DataTools.GetEquipSoulEffectRange(dItem:GetCValueByKey("equipLevel"))

			local oAttrLabel = self.m_AttrName:Clone()
			local oRangeLabel = self.m_AttrVal:Clone()

			oAttrLabel:SetActive(true)
			oRangeLabel:SetActive(true)

			oAttrLabel:SetText("")
			oRangeLabel:SetText("+"..100 + iMin.."%~"..100 + iMax.."%")

			self.m_ShenHunTable:AddChild(oRangeLabel)
			self.m_ShenHunTable:AddChild(oAttrLabel)
		end	
		self.m_ShenHunTable:Reposition()
	else
		self.m_ShenHunTitle:SetActive(false)
		self.m_ShenHunTable:SetActive(false)
	end

	-- 附加属性
	local fujiavalue = nil
	for i,v in ipairs(data.sourcebookdata.EQUIPFUJIADES) do
		if string.len(v.fujiades)> 0 then
			fujiavalue = v.level
			break
		end 
	end

	if dData.equipLevel >= fujiavalue then
		self.m_FujiaTitle:SetActive(true)
		self.m_FujiaDesLab:SetActive(true)
		local text = equipSegment[dData.equipLevel/10+1].fujiades
		self.m_FujiaDesLab:SetText(text)
	else
		self.m_FujiaTitle:SetActive(false)
		self.m_FujiaDesLab:SetActive(false)
	end
	
	-- 增加物品描述
	self.m_EquipDesLab:SetText(g_ItemCtrl:GetItemDesc(sid))

	-- 增加获取途径
	self.m_GainWayGrid:Clear()
	local gainwayinfo = data.itemequipdata.EQUIP[sid].gainWayIdStr
	local gainwaypath = data.itemgaindata.CONFIG
	local gainbtnlist = self.m_GainWayGrid:GetChildList()
	for i,v in ipairs(gainwayinfo) do
		local btnbox = nil
		if i>#gainbtnlist then
			btnbox = self.m_GainWayBox:Clone()
			btnbox:SetActive(true)
			btnbox:SetGroup(self.m_GainWayGrid:GetInstanceID())
			self.m_GainWayGrid:AddChild(btnbox)
			btnbox.btn = btnbox:NewUI(1, CSprite)
			btnbox.name = btnbox:NewUI(2, CLabel)
		else
			btnbox = gainbtnlist[i]
		end
		local gaininfo = gainwaypath[v]
		btnbox.name:SetText(gaininfo.gaindesc)
		btnbox.btn:AddUIEvent("click", callback(self, "OnJumpToGainWay", v, sid))
	end
	self.m_Table:Reposition()
end

function CSourceEquipBox.RefreshUI(self, idx)
	if idx == 1 then
		self.m_EquipSVPart:SetActive(true)
		self.m_EquipSegmentBox:SetActive(true)
		self.m_EquipDesPart:SetActive(false)
	else
		self.m_EquipSVPart:SetActive(false)
		self.m_EquipSegmentBox:SetActive(false)
		self.m_PopBox:SetActive(false)
		self.m_EquipDesPart:SetActive(true)
	end
end

-- function CSourceEquipBox.OnEquipCheckClick(self, btn)
-- 	self.m_EquipSVPart:SetActive(true)
-- 	self.m_EquipSegmentBox:SetActive(true)

-- 	self.m_EquipDesPart:SetActive(false)
-- end

-- function CSourceEquipBox.OnEquipDesClick(self)
-- 	-- body
-- 	self.m_EquipSVPart:SetActive(false)
-- 	self.m_EquipSegmentBox:SetActive(false)
-- 	self.m_PopBox:SetActive(false)

-- 	self.m_EquipDesPart:SetActive(true)
-- end


function CSourceEquipBox.OnJumpToView(self, viewname, tabname, viewtype)
	-- body
	if g_OpenSysCtrl:GetOpenSysState(viewtype) then
		g_ViewCtrl:ShowViewBySysName(viewname, tabname)
	else
		local openInfo = DataTools.GetViewOpenData(viewtype)
		local oName = string.gsub(openInfo.name, "系统", "")
		local oMsg = string.gsub(data.textdata.TEXT[3006].content, "#name", oName)
		oMsg = string.gsub(oMsg, "#grade", openInfo.p_level)
		g_NotifyCtrl:FloatMsg(oMsg)
	end
end

function CSourceEquipBox.OnJumpToGainWay(self, pathid, sid)
	-- body
	local dConfig = data.itemgaindata.CONFIG[pathid]
	local bIsUnlock = g_OpenSysCtrl:GetOpenSysState(dConfig.open_sys)
	g_ItemGainWayCtrl:JumpToTargetSystem(dConfig, bIsUnlock, sid)
end


function CSourceEquipBox.OnPopBox(self)
	-- body
	if self.m_PopBox:GetActive() then
		self.m_PopBox:SetActive(false) 
	else
		self.m_PopBox:SetActive(true) 
		if self.m_SelectLevel then
			self.m_SegmentScrollView:ResetPosition()
			self.m_SegmentGrid:Reposition()
			local gridlist = self.m_SegmentGrid:GetChildList()
			local _,h = self.m_SegmentGrid:GetCellSize()
			if #gridlist - self.m_SelectLevel >= 3 then
				self.m_SegmentScrollView:MoveRelative(Vector3.New(0, h*(self.m_SelectLevel-1),0) )
			else
				self.m_SegmentScrollView.m_UIScrollView:SetDragAmount(0, 1, false)
			end
		end
	end
	-- self.m_SubMenuBG:SetActive(true)
end


function CSourceEquipBox.InitEquipDesPart(self)
	-- body
	self.m_EquipDesGrid = self.m_EquipDesPart:NewUI(1, CGrid)
	self.m_EquipDesClone = self.m_EquipDesPart:NewUI(2, CBox)
	local desinfo = data.sourcebookdata.EQUIPDES
	self.m_EquipDesGrid:Clear()
	local deslist = self.m_EquipDesGrid:GetChildList()
	for i,v in ipairs(desinfo) do
		local desclone = nil
		if i>#deslist then
			desclone = self.m_EquipDesClone:Clone()
			desclone:SetActive(true)
			self.m_EquipDesGrid:AddChild(desclone)
			desclone.titlelab = desclone:NewUI(1, CLabel)
			desclone.deslab = desclone:NewUI(2, CLabel)
			desclone.btn = desclone:NewUI(3, CSprite)
			desclone.btnname = desclone:NewUI(4, CLabel)
		else
			desclone = deslist[i]
		end
		desclone.titlelab:SetText(v.title)
		desclone.btnname:SetText(v.btnname)
		desclone.deslab:SetText(v.des)
		desclone.btn:SetGroup(self.m_EquipDesGrid:GetInstanceID())
		desclone.btn:AddUIEvent("click", callback(self, "OnJumpToView", v.View, v.tab, v.view_stype))
	end
	self.m_EquipDesGrid:Reposition()
end

function CSourceEquipBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshSourceEquipInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

return CSourceEquipBox