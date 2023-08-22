local CFaBaoAttrBox = class("CFaBaoAttrBox", CBox)

function CFaBaoAttrBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CurSelIndex = 1
	self.m_CurSelFabaoId = nil

	self:InitContent()
end

function CFaBaoAttrBox.InitContent(self)
	self.m_TabBtnGrid = self:NewUI(1, CGrid)
	self.m_AttrLabel = self:NewUI(2, CLabel)
	self.m_AttrGrid = self:NewUI(3, CGrid)
	self.m_AttrClone = self:NewUI(4, CBox)

	self.m_SkillScroll = self:NewUI(5, CScrollView)
	self.m_Grid = self:NewUI(6, CGrid)
	self.m_AwakenSkillClone = self:NewUI(7, CBox)
	self.m_TipBtn = self:NewUI(8, CButton)


	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTip"))
	g_FaBaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFaBaoEvent"))
	
	self:InitTabGrid()
end

function CFaBaoAttrBox.InitTabGrid(self)
	local groupId = self.m_TabBtnGrid:GetInstanceID()
	local function Init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(groupId)
		oBtn:AddUIEvent("click", callback(self, "OnTabSelect", idx))
		return oBtn
	end

	self.m_TabBtnGrid:InitChild(Init)
	
	local oBtn = self.m_TabBtnGrid:GetChild(1)
	if oBtn then
		oBtn:SetSelected(true)
	end
	self:ShowAttrInfo() --默认显示属性界面
end

function CFaBaoAttrBox.OnTabSelect(self, idx)

	-- local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	-- if #fabaolist <= 0 then
	-- 	g_NotifyCtrl:FloatMsg("目前没有佩戴的法宝")
	-- 	return
	-- end

	if self.m_CurSelIndex == idx then
		return
	end
	self.m_CurSelIndex = idx

	self.m_TabBtnGrid:GetChild(idx):SetSelected(true)
	self:Refresh()
end

function CFaBaoAttrBox.OnTip(self)
	local content = {
		title = data.instructiondata.DESC[16000].title,
		desc = data.instructiondata.DESC[16000].desc,
	}
	g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CFaBaoAttrBox.Refresh(self)

	local bShowAttr = self.m_CurSelIndex == 1
	self.m_SkillScroll:SetActive(not bShowAttr)
	self.m_AttrGrid:SetActive(bShowAttr)
	self.m_AttrLabel:SetActive(bShowAttr)
	self.m_TipBtn:SetActive(bShowAttr)

	if bShowAttr then
		self:ShowAttrInfo()
	else
		self:ShowSkillInfo()
	end
	
end

function CFaBaoAttrBox.SetAttrInfo(self, fabaoId)

	self.m_CurSelFabaoId = fabaoId

	self:Refresh()
end

-- 显示属性列表
function CFaBaoAttrBox.ShowAttrInfo(self)
	local dXianLing = data.fabaodata.XIANLING

	local attrInfo

	local fabao = g_FaBaoCtrl:GetFaBaoById(self.m_CurSelFabaoId)
	--if fabao and fabao.equippos > 0 then
	if fabao then
		attrInfo = g_FaBaoCtrl:GetFaBaoAttrInfo(self.m_CurSelFabaoId)
	else
		attrInfo = g_FaBaoCtrl:GetAllFabaoAttrInfo()
	end

	local attrList = {"physique", "magic", "strength", "endurance", "agility"}
	--self.m_AttrGrid:Clear()

	for i, v in ipairs(attrList) do
		local oAttr = self.m_AttrGrid:GetChild(i)
		if oAttr == nil then
			oAttr = self.m_AttrClone:Clone()
			oAttr.m_AttrLbl = oAttr:NewUI(1, CLabel)
			oAttr.m_AttrNumber = oAttr:NewUI(2, CLabel)

			oAttr:SetActive(true)
			self.m_AttrGrid:AddChild(oAttr)
		end
		local attrLbl = dXianLing[v].desc
		local num = attrInfo[v]
		oAttr.m_AttrLbl:SetText(attrLbl)
		oAttr.m_AttrNumber:SetText(num)
	end

	self.m_AttrGrid:Reposition()
end

function CFaBaoAttrBox.ShowSkillInfo(self)

	local fabaoInfo = data.fabaodata.INFO

	local skillInfo = {}
	if self.m_CurSelIndex == 2 then
		skillInfo = g_FaBaoCtrl:GetJueXingSkillInfo(self.m_CurSelFabaoId)
	elseif self.m_CurSelIndex == 3 then
		skillInfo = g_FaBaoCtrl:GetAllHunSkillInfo(self.m_CurSelFabaoId)
	end  

	local index = 1
	self.m_Grid:Clear()
	for _, info in ipairs(skillInfo) do
		local oSkill = self.m_Grid:GetChild(index)
		if oSkill == nil then
			oSkill = self.m_AwakenSkillClone:Clone()
			oSkill.m_Icon = oSkill:NewUI(1, CSprite)
			oSkill.m_MaskSpr = oSkill:NewUI(2, CSprite)
			oSkill.m_MaskLbl = oSkill:NewUI(3, CLabel)
			oSkill.m_SkillName = oSkill:NewUI(4, CLabel)
			oSkill.m_SkillLevel = oSkill:NewUI(5, CLabel)
			oSkill.m_InstructionL = oSkill:NewUI(6, CLabel)
			oSkill.m_FabaoNameL = oSkill:NewUI(7, CLabel)

			index = index + 1
			oSkill:SetActive(true)	
			self.m_Grid:AddChild(oSkill)
		end

		local skdata = DataTools.GetFaBaoSkillData(info.sk)
		oSkill.m_Icon:SpriteSkill(skdata.icon)
		oSkill.m_MaskSpr:SetActive(not (info.bUse == 1))
		oSkill.m_SkillName:SetText(skdata.name)
		oSkill.m_InstructionL:SetText(skdata.desc)

		local fname = fabaoInfo[info.fabao].name
		oSkill.m_FabaoNameL:SetText(string.format("(%s)", fname)) --todo

		if self.m_CurSelIndex == 2 then
			oSkill.m_MaskLbl:SetText("未觉醒")
			local slevel = info.level or 0
			oSkill.m_SkillLevel:SetText(slevel.."级")
		elseif self.m_CurSelIndex == 3 then
			oSkill.m_MaskLbl:SetText("未突破")
			oSkill.m_SkillLevel:SetText("")
		end

	end
	self.m_Grid:Reposition()
	self.m_SkillScroll:ResetPosition()
end

function CFaBaoAttrBox.OnFaBaoEvent(self, oCtrl)

	local infoEvent = define.FaBao.Event.RefreshFaBaoInfo
	local listEvent = define.FaBao.Event.RefreshFaBaolist

	if oCtrl.m_EventID == infoEvent then
		self:Refresh()
	elseif oCtrl.m_EventID == listEvent then
		self.m_CurSelFabaoId = nil
		self:Refresh()
	end
end

return CFaBaoAttrBox