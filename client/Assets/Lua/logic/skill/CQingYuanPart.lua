local CQingYuanPart = class("CQingYuanPart", CPageBase)

function CQingYuanPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_SelectSkill = 0 --当前选中的技能
end

function CQingYuanPart.OnInitPage(self)

	self.m_Grid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CBox)

	self.m_Icon = self:NewUI(3, CSprite)
	self.m_name = self:NewUI(4, CLabel)
	self.m_UseL = self:NewUI(5, CLabel)
	self.m_InstrcutionL = self:NewUI(6, CLabel)

	self.m_ConditionL = self:NewUI(7, CLabel)
	self.m_SkillDescL = self:NewUI(8, CLabel)
	self.m_SkillInstructionL = self:NewUI(9, CLabel)

	self.m_DegreeL = self:NewUI(10, CLabel)
	self.m_DegreeTip = self:NewUI(11, CLabel)

	self:InitContent()
end

function CQingYuanPart.InitContent(self)
	
	-- 初始化全部情缘技能
	local skilldata = data.skilldata.MARRY
	local index = 1
	for k, v in pairs(skilldata) do    
		local oItem = self.m_Grid:GetChild(index) 
		if oItem == nil then
			oItem = self.m_ItemClone:Clone()
			oItem.m_Icon = oItem:NewUI(1, CSprite)
			oItem.m_name = oItem:NewUI(2, CLabel)
			oItem.m_SelName = oItem:NewUI(4, CLabel)

			oItem:SetGroup(self.m_Grid:GetInstanceID())
			oItem:SetActive(true)
			self.m_Grid:AddChild(oItem)
		end

		oItem.m_Icon:SpriteSkill(v.icon)
		oItem.m_name:SetText(v.name)

		--不能使用的技能灰色处理
		oItem.m_Icon:SetGrey(self:CheckSkillCanUse(k))
		oItem:AddUIEvent("click", callback(self, "OnItemSelect", index, v))

		if index == 1 then
			self:OnItemSelect(index, v) --默认选择第一个
		end

		index = index + 1

	end
	self.m_Grid:Reposition()
end

function CQingYuanPart.OnItemSelect(self, idx, skill)
	if self.m_SelectSkill == skill.id then
		return
	end
	self.m_SelectSkill = skill.id

	local oItem = self.m_Grid:GetChild(idx)
	oItem.m_SelName:SetText(skill.name)
	oItem:SetSelected(true)

	self:RefreshSkillInfo()
end

--技能是否可以使用
function CQingYuanPart.CheckSkillCanUse(self, skillID)
	local skill_list = g_SkillCtrl.m_QingYuanSkills
	for i, v in ipairs(skill_list) do
		if v.sk == skillID then
			return false
		end
	end
	return true
end

function CQingYuanPart.RefreshSkillInfo(self)

	local sData = data.skilldata.MARRY[self.m_SelectSkill]

	self.m_Icon:SpriteSkill(sData.icon)
	self.m_name:SetText(sData.name)
	self.m_UseL:SetText(sData.use)
	self.m_InstrcutionL:SetText(sData.instruction)

	self.m_ConditionL:SetText(sData.condition)
	self.m_SkillDescL:SetText(sData.skill_desc)
	self.m_SkillInstructionL:SetText(sData.skill_instruction)

	self.m_DegreeL:SetText(sData.degree_instruction)
end


return CQingYuanPart