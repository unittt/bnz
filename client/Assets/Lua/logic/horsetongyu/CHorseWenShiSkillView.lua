local CHorseWenShiSkillView = class("CHorseWenShiSkillView", CViewBase)

function CHorseWenShiSkillView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiSkillView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CHorseWenShiSkillView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SkillGrid = self:NewUI(2, CGrid)
	self.m_SkillItem = self:NewUI(3, CBox)
	self.m_SkillName = self:NewUI(4, CLabel)
	self.m_SkillIcon = self:NewUI(5, CSprite)
	self.m_Grid = self:NewUI(6, CGrid)
	self.m_Skill = self:NewUI(7, CBox)
	self.m_SkillDes = self:NewUI(8, CLabel)

	--g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	--g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSysOpenEvent"))

    self:InitContent()

end

function CHorseWenShiSkillView.InitContent(self)


	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self:RefreshSkillCol()

	local item = self.m_SkillGrid:GetChild(1)
	item.collider:ForceSelected(true)
	self:OnClickSkillItem(item)

end

function CHorseWenShiSkillView.RefreshSkillCol(self)
	
	local wenshiSkillConfig = data.itemwenshidata.WENSHI_SKILL
	local index = 1
	for k, v in pairs(wenshiSkillConfig) do 
		local item = self.m_SkillGrid:GetChild(index)
		index = index + 1
		if not item then 
			item = self.m_SkillItem:Clone()
			item:SetActive(true)
			self.m_SkillGrid:AddChild(item)
		end 
		item:SetActive(true)
		self:SetSkillItemData(item, v)
	end 

end

function CHorseWenShiSkillView.SetSkillItemData(self, item, info)

	item.icon = item:NewUI(1, CSprite)
	item.name = item:NewUI(2, CLabel)
	item.grid = item:NewUI(3, CGrid)
	item.wenshiIcon = item:NewUI(4, CSprite)
	item.collider = item:NewUI(5, CWidget)
	item.name2 = item:NewUI(6, CLabel)
	item.collider:AddUIEvent("click", callback(self, "OnClickSkillItem", item))

	local skillId = info.skill
	local skillInfo = data.summondata.SKILL[skillId]
	if skillInfo then
		item.Info = skillInfo 
		item.sInfo = info
		local icon = skillInfo.iconlv[1].icon
		item.icon:SpriteSkill(icon)
		item.name:SetText(skillInfo.name)
		item.name2:SetText(skillInfo.name)

		local wenshiIconList = {}
		local wenshiConfig = data.itemwenshidata.WENSHI
		for k, v in pairs(wenshiConfig) do 
		    local icon = wenshiIconList[v.wenshi_type]
		    if not icon then 
		        wenshiIconList[v.wenshi_type] = v.icon
		    end
		end

		local condition = info.condition
		local typeIdList = {}
		for k, v in pairs(condition) do
			if v.cnt == 2 then 
				table.insert(typeIdList, v.sid)
				table.insert(typeIdList, v.sid)
			elseif v.cnt == 1 then 
				table.insert(typeIdList, v.sid)
			end 
		end

		local index = 1
		for k, v in pairs(typeIdList) do
			local wenshiIcon = item.grid:GetChild(index)
			index = index + 1
			if not wenshiIcon then 
				wenshiIcon = item.wenshiIcon:Clone()
				wenshiIcon:SetActive(true)
				item.grid:AddChild(wenshiIcon)
			end
			wenshiIcon:SetActive(true)
			local icon = wenshiIconList[v]
			wenshiIcon:SpriteItemShape(icon)
		end

	end 

end

function CHorseWenShiSkillView.OnClickSkillItem(self, item)

	self.m_CurSkillInfo = item.Info
	self.m_CurSInfo = item.sInfo

	self:RefreshSkillItem()
	self:RefreshWenShiSkillDes()
	self:RefreshWenShiSkillItem()

end

function CHorseWenShiSkillView.RefreshSkillItem(self)
	
	--name
	self.m_SkillName:SetText(self.m_CurSkillInfo.name)
	--icon
	local icon = self.m_CurSkillInfo.iconlv[1].icon
	self.m_SkillIcon:SpriteSkill(icon)

end

function CHorseWenShiSkillView.RefreshWenShiSkillItem(self)

	local wenshiIconList = {}
	local wenshiConfig = data.itemwenshidata.WENSHI
	for k, v in pairs(wenshiConfig) do 
	    local icon = wenshiIconList[v.wenshi_type]
	    if not icon then 
	        wenshiIconList[v.wenshi_type] = v.icon
	    end
	end
	
	local condition = self.m_CurSInfo.condition
	local typeIdList = {}
	for k, v in pairs(condition) do
		if v.cnt == 2 then 
			table.insert(typeIdList, v.sid)
			table.insert(typeIdList, v.sid)
		elseif v.cnt == 1 then 
			table.insert(typeIdList, v.sid)
		end 
	end

	local index = 1
	for k, v in pairs(typeIdList) do
		local item = self.m_Grid:GetChild(index)
		index = index + 1
		if not item then 
			item = self.m_Skill:Clone()
			item:SetActive(true)
			self.m_Grid:AddChild(item)
		end
		item:SetActive(true)
		item.icon = item:NewUI(1, CSprite)
		local icon = wenshiIconList[v]
		item.icon:SpriteItemShape(icon)
	end

end

function CHorseWenShiSkillView.RefreshWenShiSkillDes(self)
	
	local des =  self.m_CurSkillInfo.des
	self.m_SkillDes:SetText(des)

end

return CHorseWenShiSkillView