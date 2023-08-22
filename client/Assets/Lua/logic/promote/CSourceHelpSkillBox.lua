local CSourceHelpSkillBox = class("CSourceHelpSkillBox", CBox)

function CSourceHelpSkillBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_RowScrollView = self:NewUI(1, CScrollView)
	-- self.m_RowGrid = self:NewUI(2, CGrid)
	-- self.m_RowBoxClone = self:NewUI(3, CBox)
	self.m_ExplainPart = self:NewUI(4, CBox)
	self.m_StrongGrid = self:NewUI(5, CGrid)
	self.m_strongBox = self:NewUI(6, CBox)
	self.m_PengRenPart = self:NewUI(7, CBox)
	self.m_PengRenBox =self:NewUI(8, CBox)

	self.m_PengRenIcon = self.m_PengRenBox:NewUI(1, CSprite)
	self.m_PengRenName = self.m_PengRenBox:NewUI(2, CLabel)
	self.m_PengRenDes  = self.m_PengRenBox:NewUI(3, CLabel)

	self.m_ItemSpr    =  self.m_PengRenBox:NewUI(4, CSprite)
	self.m_ItemName   =  self.m_PengRenBox:NewUI(5, CLabel)
	self.m_ItemType   =  self.m_PengRenBox:NewUI(6, CLabel)
	self.m_ItemLevel  =  self.m_PengRenBox:NewUI(7, CLabel)
	self.m_ItemDes    =  self.m_PengRenBox:NewUI(8, CLabel)

	self.m_ItemScrollView = self:NewUI(9, CScrollView)
	self.m_ItemGrid = self:NewUI(10, CGrid)
	self.m_ItemBox = self:NewUI(11, CBox)

	self.m_GainWayGrid = self:NewUI(12, CGrid)
	self.m_GainWayBox = self:NewUI(13, CBox)
	self.m_DragKindLab  = self:NewUI(14, CLabel)
	self.m_CurrRowIdx = nil
	--self:InitContent()

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
end

-- function CSourceHelpSkillBox.InitContent(self)
-- 	-- body
-- 	local helpdata = data.sourcebookdata.HELPSKILL
-- 	self.m_RowGrid:Clear()
-- 	local rowList = self.m_RowGrid:GetChildList()
-- 	for i,v in ipairs(helpdata) do
-- 		local box = nil
-- 		if i>#rowList then
-- 			box = self.m_RowBoxClone:Clone()
-- 			box:SetActive(true)
-- 			self.m_RowGrid:AddChild(box)
-- 			box.btn = box:NewUI(1, CButton)
-- 			box.btn:SetGroup(self.m_RowGrid:GetInstanceID())
-- 			box.norlab = box:NewUI(2, CLabel)
-- 			box.sellab = box:NewUI(3, CLabel)
-- 		else
-- 			box = rowList[i]
-- 		end
-- 		box.norlab:SetText(v.cat_name)
-- 		box.sellab:SetText(v.cat_name)
-- 		box.btn:AddUIEvent("click", callback(self, "OnRowBtnClick", i))
-- 	end
-- 	self.m_RowGrid:Reposition()
-- 	self.m_RowScrollView:ResetPosition()
-- 	self.m_RowGrid:GetChild(1).btn:SetSelected(true)
-- 	self:OnRowBtnClick(1)
-- end

function CSourceHelpSkillBox.RefreshUI(self, idx)

	local helpdata = data.sourcebookdata.HELPSKILL
	local mainid = helpdata[idx].cat_id
	-- body
	if self.m_CurrRowIdx and self.m_CurrRowIdx == idx then
		return 
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	-- local function fun()
	-- 	-- body
	-- 	local oScroll = self.m_RowScrollView.m_UIScrollView
	-- 	if idx >3 then
	--    		oScroll:SetDragAmount(1, 0, false)
	--    	else
	--    		oScroll:SetDragAmount(0, 0, false)
	--    	end
 --   		return false
	-- end
	-- self.m_ItemGrid:Reposition()
	-- self.m_ItemScrollView:ResetPosition()
	-- self.m_Timer = Utils.AddTimer(fun, 0, 0.1)
	-- local obj = self.m_RowGrid:GetChild(idx)
	 
	-- self.m_RowScrollView:SetDragAmount(1, 0, false)
	self.m_CurrRowIdx = idx
	local strongdata = data.sourcebookdata.HELPSKILLCONTENT
	local skillinfo = data.skilldata.ORGSKILL

	local templist = {}
	for i,v in ipairs(strongdata) do
		if mainid == v.cat_id then
			table.insert(templist, v)
		end
	end
	if mainid == 1 then --强身&冥想:
		self.m_StrongGrid:SetActive(true)
		self.m_PengRenPart:SetActive(false)
		self.m_StrongGrid:Clear()
		local stronglist = self.m_StrongGrid:GetChildList()
		for i,v in ipairs(templist) do
			local box = nil
			if i>#stronglist then
				box = self.m_strongBox:Clone()
				box:SetActive(true)
				self.m_StrongGrid:AddChild(box)
				box.icon = box:NewUI(1, CSprite)
				box.name = box:NewUI(2, CLabel)
				box.des = box:NewUI(3, CLabel)
				box.btn = box:NewUI(4, CButton)
			else
				box = stronglist[i]
			end
			local skill = skillinfo[v.skill_idx]
			box.icon:SetSpriteName(skill.icon)
			box.name:SetText(skill.name)
			box.des:SetText(skill.des)
			box.btn:AddUIEvent("click", callback(self, "OnStrongBtnClick", v))
		end

	else  --
		self.m_StrongGrid:SetActive(false)
		self.m_PengRenPart:SetActive(true)
		local skill 
		if mainid == 3 then
			skill = table.copy(skillinfo[templist[1].skill_idx])
			skill.itemlist = {}
			for i,v in ipairs(skill.make_item) do
				table.insert(skill.itemlist, v)
			end
			for i,v in ipairs(skill.item) do
				table.insert(skill.itemlist, v.id)
			end
			skill.item = skill.itemlist 
		else
			 skill =  skillinfo[templist[1].skill_idx]
		end

		if not skill then
			printc("符篆内容待配置！")
			return
		end

		self.m_PengRenIcon:SetSpriteName(skill.icon)
		self.m_PengRenName:SetText(skill.name)
		self.m_PengRenDes:SetText(skill.des)
		self.m_DragKindLab:SetText(skill.name.."种类")
	
		self.m_ItemGrid:Clear()
		local itemlist = self.m_ItemGrid:GetChildList()
		for i,v in ipairs(skill.item) do
			local box = nil
			if i>#itemlist then
				box = self.m_ItemBox:Clone()
				box:SetActive(true)
				self.m_ItemGrid:AddChild(box)
				box.icon = box:NewUI(1, CSprite)
				box.qua = box:NewUI(2, CSprite)
			else
				box = itemlist[i]
			end
			local dItem 
			if mainid == 3 then
			 	dItem = DataTools.GetItemData(v)
			 else
			 	dItem = DataTools.GetItemData(v.id)
			 end
			box.icon:SetSpriteName(dItem.icon)
			box.qua:SetItemQuality(dItem.quality)
			box.icon:AddUIEvent("click", callback(self, "OnItemClick", dItem.id))
		end
		if mainid == 3 then
			self:OnItemClick(skill.item[1])
		else
			self:OnItemClick(skill.item[1].id)
		end

	end
end

function CSourceHelpSkillBox.OnItemClick(self, sid)
	-- body

	local dItem = DataTools.GetItemData(sid)
	self.m_ItemSpr:SpriteItemShape(dItem.icon)
	self.m_ItemName:SetText(dItem.name)
	self.m_ItemType:SetText(dItem.introduction)
	self.m_ItemDes:SetText(g_ItemCtrl:GetItemDesc(sid))


	local gainwaypath = data.itemgaindata.CONFIG

	self.m_GainWayGrid:Clear()
	local gainwaylist = self.m_GainWayGrid:GetChildList()
	local dItem = DataTools.GetItemData(sid)
	for i,v in ipairs(dItem.gainWayIdStr) do
		local box = nil
		if i>#gainwaylist then
			box = self.m_GainWayBox:Clone()
			box:SetActive(true)
			self.m_GainWayGrid:AddChild(box)
			box.btn = box:NewUI(1, CButton)
			box.btn:SetGroup(self.m_GainWayGrid:GetInstanceID())
			box.norlab = box:NewUI(2, CLabel)
		else
			box = gainwaylist[i]
		end
		local gaininfo = gainwaypath[v]
		box.norlab:SetText(gaininfo.gaindesc)
		box.btn:AddUIEvent("click", callback(self, "OnGainBtnClick", v, sid))
	end

end


function CSourceHelpSkillBox.OnGainBtnClick(self, path, sid)
	-- body
	local dConfig = data.itemgaindata.CONFIG[path]
	local bIsUnlock = g_OpenSysCtrl:GetOpenSysState(dConfig.open_sys)
	g_ItemGainWayCtrl:JumpToTargetSystem(dConfig, bIsUnlock, sid)
end

function CSourceHelpSkillBox.OnStrongBtnClick(self, skillinfo)
	if  g_OpenSysCtrl:GetOpenSysState([[HELPSKILL]]) then
		local gainwaylist = data.itemgaindata.CONFIG
		local config = nil
		for i,v in ipairs(gainwaylist) do
			if skillinfo.skill_idx ==   v.openid then
				config = v
				break
			end
		end
		local dConfig = data.itemgaindata.CONFIG[config.id]
		g_ItemGainWayCtrl:JumpToTargetSystem(dConfig, true, nil)
	else
		local openInfo = DataTools.GetViewOpenData("HELPSKILL")
		local oName = string.gsub(openInfo.name, "系统", "")
		local oMsg = string.gsub(data.textdata.TEXT[3006].content, "#name", oName)
		oMsg = string.gsub(oMsg, "#grade", openInfo.p_level)
		g_NotifyCtrl:FloatMsg(oMsg)
	end
end

function CSourceHelpSkillBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshHelpSkillInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

return CSourceHelpSkillBox