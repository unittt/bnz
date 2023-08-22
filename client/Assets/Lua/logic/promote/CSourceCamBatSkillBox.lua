 local   CSourceCamBatSkillBox = class("CSourceCamBatSkillBox", CBox)

function CSourceCamBatSkillBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_RowScrollView = self:NewUI(1, CScrollView)
	-- self.m_RowGrid = self:NewUI(2, CGrid)
	-- self.m_RowBoxClone = self:NewUI(3, CBox)
	self.m_PopPart = self:NewUI(4, CBox)
	self.m_PopTweenBG = self:NewUI(5, CWidget)
	self.m_PopScrollView = self:NewUI(6, CScrollView)
	self.m_PopGrid = self:NewUI(7, CGrid)
	self.m_PopBoxClone = self:NewUI(8, CBox)
	self.m_KindBtn = self:NewUI(9, CSprite)
	self.m_KindLab = self:NewUI(10, CLabel)
	self.m_ColScrollView = self:NewUI(11, CScrollView)
	self.m_ColGrid = self:NewUI(12, CGrid)
	self.m_ColBoxClone = self:NewUI(13, CBox)
	self.m_SkillSpr  = self:NewUI(14, CSprite)
	self.m_SkillName = self:NewUI(15, CLabel)
	self.m_SkillDes = self:NewUI(16, CLabel)
	self.m_LowSkill = self:NewUI(17, CLabel)


	self.m_RideUpgradeBox = self:NewUI(19, CBox)
	self.m_RideUpLab = self:NewUI(20, CLabel)
	self.m_RideUpGrid = self:NewUI(21, CGrid)
	self.m_RideUpBox = self:NewUI(22, CBox)

	self.m_SelectLevel = nil
	self.m_Skillkind = {}

	self:InitKindData()

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
end

function CSourceCamBatSkillBox.InitKindData(self)
	-- body
	self.m_CurrRowInx = nil
	self.m_KindBtn:AddUIEvent("click", callback(self, "OnKindBtnClick"))
	local combatinfo = data.sourcebookdata.CAMBATSKILL

	for i,v in ipairs(combatinfo) do
		local skill = {id = v.cat_id, name = v.cat_name, sort = v.sort}
		local exist = false
		for j,k in ipairs(self.m_Skillkind) do
			if skill.id == k.id and skill.name == k.name then
				exist = true
				break
			end
		end
		if not exist  then
			table.insert(self.m_Skillkind, skill)
		end
	end
	table.sort(self.m_Skillkind, function (a,b)
		-- body
		return a.sort < b.sort
	end)
	-- self.m_RowGrid:Clear()
	-- local rowlist = self.m_RowGrid:GetChildList()
	-- for i,v in ipairs(skillkind) do
	-- 	local box = nil
	-- 	if i>#list then
	-- 		box = self.m_RowBoxClone:Clone()
	-- 		box:SetActive(true)
	-- 		self.m_RowGrid:AddChild(box)
	-- 		box.btn = box:NewUI(1, CButton)
	-- 		box.btn:SetGroup(self.m_RowGrid:GetInstanceID())
	-- 		box.norlab = box:NewUI(2, CLabel)
	-- 		box.sellab = box:NewUI(3, CLabel)
	-- 	else
	-- 		box = rowlist[i]
	-- 	end
	-- 	box.norlab:SetText(v.name)
	-- 	box.sellab:SetText(v.name)

	-- 	box.btn:AddUIEvent("click", callback(self, "OnRowBtnClick", v.id, i))
	-- end

	-- self.m_RowGrid:GetChild(1).btn:SetSelected(true)
	-- self.m_RowGrid:Reposition()
	-- self.m_RowScrollView:ResetPosition()
	-- self:OnRowBtnClick(skillkind[1].id, 1)
end

function CSourceCamBatSkillBox.RefreshUI(self, index)
	local id = self.m_Skillkind[index].id
	if self.m_CurrRowInx and self.m_CurrRowInx == id then
		return 
	end

	self.m_CurrRowInx = id
	local combatinfo = data.sourcebookdata.CAMBATSKILL
	local skillkind = {}
	local idx = 0
	for i,v in ipairs(combatinfo) do
		if id == v.cat_id then
			idx = idx  + 1
			local single = {name = v.sub_name, catid = v.cat_id ,subid = v.sub_id}
			table.insert(skillkind, single)
		end
	end
	table.sort(skillkind, function (a,b)
		-- body
		return a.subid < b.subid
	end)
	self.m_PopGrid:Clear()
	local poplist = self.m_PopGrid:GetChildList()
	for i,v in ipairs(skillkind) do
		local box = nil
		if i>#poplist then
			box = self.m_PopBoxClone:Clone()
			box:SetActive(true)
			self.m_PopGrid:AddChild(box)
			box.btn = box:NewUI(1, CSprite)
			box.btn:SetGroup(self.m_PopGrid:GetInstanceID())
			box.norlab = box:NewUI(2, CLabel)
			box.sellab = box:NewUI(3, CLabel)
			box.btn:AddUIEvent("click", callback(self, "OnPopBtnClick", v, i))
		else	
			box = poplist[i]
		end
		box.norlab:SetText(v.name)
		box.sellab:SetText(v.name)
	end
	self.m_PopGrid:Reposition()
	self.m_PopScrollView:ResetPosition()
		

	if id == 1 or id == 2 then -- 招式 ,心法 默认显示 玩家所在门派
		local school 
		local schoolinfo = data.schooldata.DATA
		for i,v in ipairs(schoolinfo) do
			if g_AttrCtrl.school == v.id then
				school = v
				break
			end
		end
		local idx
		for i,k in ipairs(skillkind) do
			if school.name ==  k.name then
				idx = k.subid
				self.m_SelectLevel = i
				break
			end
		end
		self.m_PopGrid:GetChild(idx).btn:SetSelected(true)
		self:OnPopBtnClick(skillkind[idx], self.m_SelectLevel)
	else
		self.m_PopGrid:GetChild(1).btn:SetSelected(true)
		self:OnPopBtnClick(skillkind[1], 1)
	end
end

function CSourceCamBatSkillBox.OnPopBtnClick(self, kind, selectlevel)
	
	local mainid, subid, btnname = kind.catid, kind.subid, kind.name

	self.m_SelectLevel =  selectlevel
	self.m_KindLab:SetText(btnname)
	self.m_PopScrollView:ResetPosition()
	self.m_PopGrid:Reposition()
	self.m_PopPart:SetActive(false)
	self.m_ColScrollView:ResetPosition()
	local skillinfo = data.sourcebookdata.CAMBATCONTENT
	local skillkind = {}
	if subid == 1 then -- 全部的技能在最上 或者最下 #templist
 		for i,v in ipairs(skillinfo) do
 			if mainid == v.cat_id then
	 			local  skill = {skillid = v.skill_id}
				table.insert(skillkind, skill)
			end
 		end
 	else
 		for i,v in ipairs(skillinfo) do
			if  mainid == v.cat_id and subid == v.sub_id then
				local  skill = {skillid = v.skill_id}
				table.insert(skillkind, skill)
			end
		end
 	end
	local mainskill 
	if mainid == 1 then --招式
		mainskill = data.skilldata.SCHOOL -- icon -- desc -- funcdesc
	elseif mainid == 2 then --心法
		mainskill = data.skilldata.PASSIVE --icon --desc
	elseif mainid == 3 then --特技&特效
		mainskill = data.skilldata.SPECIAL_EFFC --icon -- desc
	elseif mainid == 4 then --宠物
		mainskill = data.skilldata.SummonSkill --iconlv[1].icon -- des
	elseif mainid == 5 then --坐骑
		mainskill = data.ridedata.SKILL --icon -- desc
	end
	self.m_ColGrid:Clear()
	local collist = self.m_ColGrid:GetChildList()
	for i,v in ipairs(skillkind)  do
		local box = nil
		if i>#collist then
			box = self.m_ColBoxClone:Clone()
			box:SetActive(true)
			self.m_ColGrid:AddChild(box)
			box.btn = box:NewUI(1, CSprite)
			box.btn:SetGroup(self.m_ColGrid:GetInstanceID())
			box.norlab = box:NewUI(2, CLabel)
			box.sellab = box:NewUI(3, CLabel)
			box.icon = box:NewUI(4, CSprite)
		else
			box = collist[i]
		end
		local skill = mainskill[v.skillid]
		if mainid> 3 then
			if mainid == 4 then
				box.icon:SpriteSkill(skill.iconlv[1].icon)
			else
				box.icon:SpriteSkill(skill.icon)	
			end
		else
			box.icon:SpriteSkill(skill.icon)
		end
		box.norlab:SetText(skill.name)
		box.sellab:SetText(skill.name)
		box.btn:AddUIEvent("click", callback(self, "OnSkillBtnClick", skill, mainid))
	end
	self.m_ColGrid:GetChild(1).btn:SetSelected(true)	
	self:OnSkillBtnClick(mainskill[skillkind[1].skillid], mainid)
end

function CSourceCamBatSkillBox.OnSkillBtnClick(self, skillinfo, mainid)
	-- body
	if mainid > 3 then
		if mainid == 4 then
			self.m_SkillSpr:SpriteSkill(skillinfo.iconlv[1].icon)
		else
			self.m_SkillSpr:SpriteSkill(skillinfo.icon)	
		end
	else
		self.m_SkillSpr:SpriteSkill(skillinfo.icon)
	end
	self.m_SkillDes:SetText(skillinfo.funcdesc or skillinfo.des or skillinfo.desc)
	
	self.m_SkillName:SetText(skillinfo.name)
	if mainid == 1 then
		self.m_LowSkill:SetActive(true)
		if skillinfo.desc  then
			-- self.m_UpgradeLab:SetActive(true)
			local str = ""
			-- for i,v in ipairs(skillinfo.desc) do
			-- 	str = str ..v.desc.."\n"
			-- end
			str = skillinfo.desc[1].desc
			self.m_LowSkill:SetActive(true)
			self.m_LowSkill:SetText(str)
		else
			self.m_LowSkill:SetActive(false)
		end
	else
		-- self.m_UpgradeLab:SetActive(false)
		self.m_LowSkill:SetActive(false)
	end
    self:InitRideBox(mainid, skillinfo.id)
end

function CSourceCamBatSkillBox.InitRideBox(self, mainid, skillid)
	-- body
	if mainid == 5 then
		self.m_RideUpgradeBox:SetActive(true)
	else
		self.m_RideUpgradeBox:SetActive(false)
		return
	end
	local mainskill = data.ridedata.SKILL
	local skilllist = {}
	self.m_RideUpGrid:Clear()
	if next(mainskill[skillid].con_skill) then
		self.m_RideUpLab:SetText("需要学习的基础技能")
		skilllist = mainskill[skillid].con_skill
	else
		self.m_RideUpLab:SetText("可学习以下进阶技能")
		skilllist = g_HorseCtrl:FindAdvanceSkills(skillid)
	end

	if next(skilllist) then
		for i,v in ipairs(skilllist) do
			local box = self.m_RideUpBox:Clone()
			box:SetActive(true)
			self.m_RideUpGrid:AddChild(box)
			box.icon = box:NewUI(1, CSprite)
			box.name = box:NewUI(2, CLabel)
			local skill = mainskill[v]
			box.icon:SpriteSkill(skill.icon)
			box.name:SetText(skill.name)
		end
	end
	self.m_RideUpGrid:Reposition()
end

function CSourceCamBatSkillBox.OnKindBtnClick(self)
	if self.m_PopPart:GetActive() then
		self.m_PopPart:SetActive(false)
	else
		self.m_PopPart:SetActive(true)
		if self.m_SelectLevel then
			self.m_PopScrollView:ResetPosition()
			self.m_PopGrid:Reposition()
			local gridlist = self.m_PopGrid:GetChildList()
			local _,h = self.m_PopGrid:GetCellSize()
			if #gridlist - self.m_SelectLevel >= 3 then
				self.m_PopScrollView:MoveRelative(Vector3.New(0, h*(self.m_SelectLevel-1),0) )
			else
				self.m_PopScrollView.m_UIScrollView:SetDragAmount(0, 1, false)
			end
		end
	end
	
end

function CSourceCamBatSkillBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshCamBatSkillInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

 return CSourceCamBatSkillBox