local CSkillSchoolPart = class("CSkillSchoolPart", CPageBase)

function CSkillSchoolPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_SkillGrid = self:NewUI(1, CGrid)
	self.m_SkillBoxClone = self:NewUI(2, CBox)
	self.m_NameLbl = self:NewUI(3, CLabel)
	self.m_DescLbl = self:NewUI(4, CLabel)

	self.m_TypeLbl = self:NewUI(5, CLabel)
	self.m_ValueLbl = self:NewUI(6, CLabel)
	self.m_TargetLbl = self:NewUI(7, CLabel)
	self.m_CostEnergyLbl = self:NewUI(8, CLabel)

	self.m_NextTypeLbl = self:NewUI(9, CLabel)
	self.m_NextValueLbl = self:NewUI(10, CLabel)
	self.m_NextTargetLbl = self:NewUI(11, CLabel)
	self.m_NextCostEnergyLbl = self:NewUI(12, CLabel)

	self.m_CostBox = self:NewUI(13, CCurrencyBox)
	self.m_SilverBox = self:NewUI(14, CCurrencyBox)
	self.m_NextCostTitleLbl = self:NewUI(15, CLabel)
	self.m_EachUpBtn = self:NewUI(16, CButton)
	self.m_ResetBtn = self:NewUI(17, CButton)
	self.m_Content = self:NewUI(18, CObject)
	self.m_CostTitleLbl = self:NewUI(19, CLabel)
	self.m_OpenInfoLbl = self:NewUI(20, CLabel)
	self.m_TotalSkillPointLbl = self:NewUI(21, CLabel)
	self.m_ConsumeSkillPointLbl = self:NewUI(22, CLabel)
	self.m_ScrollView = self:NewUI(23, CScrollView)
	self.m_ResetFullBtn = self:NewUI(24, CButton)
	
    self.m_TipBtn = self:NewUI(25,CButton)
    self.m_MainTypeLbl = self:NewUI(26, CLabel)
    self.m_FuncLbl = self:NewUI(27, CLabel)
    self.m_MainIconSp = self:NewUI(28, CSprite)
    self.m_SkillCol = self:NewUI(29, CBox)
    self.m_SkillColList = {}
    for i = 1, 7 do
    	table.insert(self.m_SkillColList, self.m_SkillCol:NewUI(i, CBox))
    end
    self.m_DescTable = self:NewUI(30, CTable)
    self.m_DescScrollView = self:NewUI(31, CScrollView)
    self.m_MaxSkillBox = self:NewUI(32, CBox)
    self.m_MaxCountLbl = self:NewUI(33, CLabel)
    self.m_GradeLbl = self:NewUI(34, CLabel)
    self.m_SkillSliderBox = self:NewUI(35, CBox)
    self.m_SkillSlider = self.m_SkillSliderBox:NewUI(1, CSlider)
    self.m_SkillSliderLbl = self.m_SkillSliderBox:NewUI(2, CLabel)
    self.m_SkillSliderIconSp = self.m_SkillSliderBox:NewUI(3, CSprite)
    self.m_SkillSliderItemBox = self.m_SkillSliderBox:NewUI(4, CBox)
    self.m_ItemBoxIconSp = self.m_SkillSliderItemBox:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp = self.m_SkillSliderItemBox:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl = self.m_SkillSliderItemBox:NewUI(3, CLabel)
	self.m_ItemBoxNameLbl = self.m_SkillSliderItemBox:NewUI(4, CLabel)

    self.m_SkillSliderMaxBox = self:NewUI(36, CBox)
    self.m_SkillSliderMax = self.m_SkillSliderMaxBox:NewUI(1, CSlider)
    self.m_SkillSliderMaxLbl = self.m_SkillSliderMaxBox:NewUI(2, CLabel)
    self.m_SkillSliderMaxIconSp = self.m_SkillSliderMaxBox:NewUI(3, CSprite)

    self.m_UnopenWidget1 = self:NewUI(37, CWidget)
    self.m_UnopenWidget2 = self:NewUI(38, CWidget)

    self.m_ItemSid = data.skilldata.CONFIG[1].active_itemid
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
    
	g_GuideCtrl:AddGuideUI("skill_eachup_btn", self.m_EachUpBtn)
	
	self.m_DelayTimer = nil
	self.m_BoxList = {}
	self.m_IsMoveToItem = false
	self.m_UpgradeEnable = false
	self.m_TopLimitLvDict = {}

	self:InitContent()
end

function CSkillSchoolPart.OnInitPage(self)
	local function update()
		self:RefreshSkillGrid()
	end
	self.m_Timer = Utils.AddTimer(update, 0, 0)
end

function CSkillSchoolPart.InitContent(self)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_SkillBoxClone:SetActive(false)
	--
    self.m_TipBtn:AddUIEvent("click",callback(self,"OnClickTips"))
	--
	self.m_EachUpBtn:AddUIEvent("click", callback(self, "OnLearnSkill"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetSkill"))
	self.m_ResetFullBtn:AddUIEvent("click", callback(self, "OnResetSkill"))
	self.m_UnopenWidget1:AddUIEvent("click", callback(self, "OnClickUnopenWidget"))
	self.m_UnopenWidget2:AddUIEvent("click", callback(self, "OnClickUnopenWidget"))
	self.m_SkillSliderIconSp:AddUIEvent("click", callback(self, "OnClickSkillSliderIconSp"))
	self.m_SkillSliderMaxIconSp:AddUIEvent("click", callback(self, "OnClickSkillSliderMaxIconSp"))
	self.m_SkillSliderItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self:RefreshSkillPoint()
	self:RefreshSkillGrid()
	self:DefaultSelect()
	self:RefreshRedPoint()
end

function CSkillSchoolPart.OnClickTips(self)
    -- local zId =define.Instruction.Config.SkillPoint
    -- local zContent={title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
    -- g_WindowTipCtrl:SetWindowInstructionInfo(zContent)

    CSkillAuraTipsView:ShowView(function (oView)
    	oView:RefreshUI(data.instructiondata.DESC[define.Skill.AuraTips[g_AttrCtrl.school]].desc)   	
    	UITools.NearTarget(self.m_TipBtn, oView.m_BgSp, enum.UIAnchor.Side.Left, Vector2.New(-20, -50))
    end)
end


--协议通知返回
function CSkillSchoolPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Skill.Event.LoginSkill then
		self:DelayRefresh()
	elseif oCtrl.m_EventID == define.Skill.Event.SchoolRefresh then
		self:DelayRefresh(oCtrl.m_EventData)
	end
end

--属性协议通知返回
function CSkillSchoolPart.OnCtrlAttrEvent(self,oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshSkillPoint()
	end
end

function CSkillSchoolPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
		self:RefreshRedPoint()
	end
end

--延迟刷新技能Box
function CSkillSchoolPart.DelayRefresh(self,pData)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		self.m_DelayTimer = nil
		if not pData then
			self:RefreshAll()
		else
			self:RefreshOneBox(pData)
		end
		self:RefreshRedPoint()
	end
	self.m_DelayTimer = Utils.AddTimer(delay, 0, 0.1)
end

function CSkillSchoolPart.RefreshAll(self)
	self:RefreshSkillPoint()
	self:RefreshSkillGrid()
	self:PreSelect()
end

function CSkillSchoolPart.RefreshItem(self)
	if not self.m_ItemSid then
		return
	end
	if not self.m_CurSkill then
		return
	end
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	self.m_ItemBoxIconSp:SpriteItemShape(self.m_ItemConfig.icon)
	self.m_ItemBoxBorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig.id, self.m_ItemConfig.quality or 0 ))
	self.m_ItemBoxNameLbl:SetText(self.m_ItemConfig.name)

	local oNeedCount = 0
	local oCurLevel = g_SkillCtrl:GetSchoolSkillLevel(self.m_CurSkill)
	local oConfig = data.skilldata.SCHOOL[self.m_CurSkill].skillpoint_learn
	local oNextLevel = oCurLevel+1 >= oConfig[#oConfig].lv and oConfig[#oConfig].lv or (oCurLevel+1)
	oNeedCount = math.ceil(tonumber(load(string.format([[return (%s)]], oConfig[oNextLevel].formula))()))

	self.m_EachUpBtn:DelEffect("RedDot")
	if iAmount >= oNeedCount and self.m_UpgradeEnable then
		self.m_EachUpBtn:AddEffect("RedDot", 20, Vector2(-17, -17))
	end
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：".."[1d8e00]"..iAmount.."[-]/"..oNeedCount)
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：".."[af302a]"..iAmount.."[-]/"..oNeedCount)
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("790036"))
	end
end

--刷新总技能点数
function CSkillSchoolPart.RefreshSkillPoint(self)
	self.m_TotalSkillPointLbl:SetText(g_AttrCtrl.skill_point)

	if not self.m_CurSkill then
		return
	end

	local oNeedPoint = g_SkillCtrl:GetSchoolSkillData(self.m_CurSkill).needpoint
	self.m_SkillSlider:SetValue(g_AttrCtrl.skill_point/oNeedPoint)
	self.m_SkillSliderLbl:SetText(g_AttrCtrl.skill_point.."/"..oNeedPoint)
end

--刷新整个技能Box
function CSkillSchoolPart.RefreshSkillGrid(self)
	-- self.m_SkillGrid:Clear()
	-- local skills = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
	-- self.m_BoxList = {}
	-- local moveToIndex = 1

	-- for i, dSkill in ipairs(skills) do
	-- 	local oBox = self:CreateSkillBox(dSkill)
	-- 	self.m_BoxList[oBox.m_Skill] = oBox
	-- 	self.m_SkillGrid:AddChild(oBox)

	-- 	if self.m_CurSkill and self.m_CurSkill == dSkill.id then
	-- 		moveToIndex = i
	-- 	end
	-- end

	-- if self.m_IsMoveToItem then
	-- 	local _,h = self.m_SkillGrid:GetCellSize()
 --        local scrollPos = Vector3.New(0, (moveToIndex-1) * h, 0)
 --        self.m_ScrollView:MoveRelative(scrollPos)
 --        self.m_IsMoveToItem = false
 --    end

    local skills = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
    if #skills > 7 then
    	printerror("技能数量超出技能框总数了")
    	return
    end

    self.m_BoxList = {}
    for i, dSkill in ipairs(skills) do
    	local oBox = self:CreateSkillBox(i, dSkill)
    	self.m_BoxList[oBox.m_Skill] = oBox
    end
end

--刷新一个技能Box
function CSkillSchoolPart.RefreshOneBox(self,pData)
	local oBox = self.m_BoxList[pData.sk]
	if oBox then
		oBox.m_LevelLabel:SetText("Lv."..g_SkillCtrl:GetSchoolSkillLevel(oBox.m_Skill))
		if not g_SkillCtrl.m_SchoolSkills[oBox.m_Skill] then
			oBox.m_MaskSp:SetActive(true)
			oBox.m_SkillSpr:SetColor(Color.RGBAToColor("616161"))
			oBox.m_LevelLabel:SetActive(true)
			oBox.m_LevelLabel:SetText(data.skilldata.SCHOOL[oBox.m_Skill].open_level.."级\n开启")
		elseif g_SkillCtrl:GetSchoolSkillLevel(oBox.m_Skill) <= 0 then
			oBox.m_MaskSp:SetActive(true)
			oBox.m_SkillSpr:SetColor(Color.RGBAToColor("616161"))
			oBox.m_LevelLabel:SetActive(false)
		else
			oBox.m_MaskSp:SetActive(false)
			oBox.m_SkillSpr:SetColor(Color.RGBAToColor("FFFFFF"))
			oBox.m_LevelLabel:SetActive(false)
		end
		self:OnSkillSelect(oBox)
	end
end

--刷新技能Box之后选择第一个
function CSkillSchoolPart.DefaultSelect(self)
	if not self.m_CurSkill then
		-- local oBox = self.m_SkillGrid:GetChild(1)
		local oBox
		for k,v in pairs(self.m_BoxList) do
			if v.m_Key == 1 then
				oBox = v
				break
			end
		end
		if oBox then
			self:OnSkillSelect(oBox)
		end
	end
end

--刷新技能Box之后选择其中一个
function CSkillSchoolPart.PreSelect(self)
	if not self.m_CurSkill then
		self:DefaultSelect()
	else
		if self.m_BoxList[self.m_CurSkill] then
			self:OnSkillSelect(self.m_BoxList[self.m_CurSkill])
		end
	end
end

--选中可以升级的第一个技能box
function CSkillSchoolPart.SetCurSkillByCouldUp(self)
	local oGuideSelectSkill
	local oSecondSkill
	local skills = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
	for i, v in ipairs(skills) do
		local skilldata = g_SkillCtrl.m_SchoolSkills[v.id]
		if skilldata then
			local Skill = DataTools.GetSchoolSkillData(v.id)
			local NumStr = string.gsub(Skill.top_limit, "grade", tostring(g_AttrCtrl.grade))
			local TopLimitLv = math.floor(tonumber(load(string.format([[return (%s)]], NumStr))()))

			local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
			local oNeedCount = 0
			local oCurLevel = skilldata.level
			local oConfig = data.skilldata.SCHOOL[v.id].skillpoint_learn
			local oNextLevel = oCurLevel+1 >= oConfig[#oConfig].lv and oConfig[#oConfig].lv or (oCurLevel+1)
			oNeedCount = math.ceil(tonumber(load(string.format([[return (%s)]], oConfig[oNextLevel].formula))()))
			local oLearnLevel = skilldata.level + 1
			local oNeedGrade = 0
			if not Skill.learn_limit[oLearnLevel] then
				oNeedGrade = Skill.learn_limit[#Skill.learn_limit].grade
			else
				oNeedGrade = Skill.learn_limit[oLearnLevel].grade
			end

			if skilldata and oNeedCount <= itemNum and skilldata.level < TopLimitLv 
			and skilldata.level >= 0 and g_AttrCtrl.grade >= oNeedGrade then --and skilldata.needmoney <= g_AttrCtrl.silver
				-- self.m_CurSkill = skilldata.sk
				if not oGuideSelectSkill then
					oGuideSelectSkill = skilldata.sk
				end
				if i == 2 then
					oSecondSkill = skilldata.sk
				end
				-- break
			end
		end
	end
	if oSecondSkill then
		self.m_CurSkill = oSecondSkill
	else
		if oGuideSelectSkill then
			self.m_CurSkill = oGuideSelectSkill
		end
	end
	self.m_IsMoveToItem = true
end

--刷新整个技能Box,创建Box过程
function CSkillSchoolPart.CreateSkillBox(self, oKey, dSkill)
	-- local oBox = self.m_SkillBoxClone:Clone()
	local oBox = self.m_SkillColList[oKey]
	local oLevel = g_SkillCtrl:GetSchoolSkillLevel(dSkill.id)

	oBox.m_Key = oKey
	oBox.m_SkillSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LevelLabel = oBox:NewUI(3, CLabel)
	oBox.m_ElementSp = oBox:NewUI(4, CSprite)
	oBox.m_MaskSp = oBox:NewUI(5, CSprite)
	oBox:SetGroup(self:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnSkillSelect"))
	oBox.m_Skill = dSkill.id
	oBox.m_SkillSpr:SpriteSkill(dSkill.icon)
	oBox.m_NameLabel:SetText(dSkill.name)
	oBox.m_LevelLabel:SetText("Lv."..oLevel)
	oBox.m_ElementSp:SetSpriteName("h7_element_"..dSkill.element)
	oBox.m_MaskSp:SetActive(false)
	if not g_SkillCtrl.m_SchoolSkills[dSkill.id] then
		oBox.m_MaskSp:SetActive(true)
		oBox.m_SkillSpr:SetColor(Color.RGBAToColor("616161"))
		oBox.m_LevelLabel:SetActive(true)
		oBox.m_LevelLabel:SetText(dSkill.open_level.."级\n开启")
	elseif oLevel <= 0 then
		oBox.m_MaskSp:SetActive(true)
		oBox.m_SkillSpr:SetColor(Color.RGBAToColor("616161"))
		oBox.m_LevelLabel:SetActive(false)
	else
		oBox.m_MaskSp:SetActive(false)
		oBox.m_SkillSpr:SetColor(Color.RGBAToColor("FFFFFF"))
		oBox.m_LevelLabel:SetActive(false)
	end
	oBox:SetActive(false)
	oBox:SetActive(true)
	return oBox
end

--刷新右边技能描述的内容
function CSkillSchoolPart.RefreshContent(self)
	local Skill = DataTools.GetSchoolSkillData(self.m_CurSkill)
	local elementStr = ""
	if Skill.element_type and Skill.element_type~="" then
		elementStr = string.format("#T%s#n", "("..Skill.element_type..")")
	end
	local NameStr = string.format("%s", Skill.name) --#C #n
		
	self.m_NextTypeLbl:SetText(Skill.type_desc)
	self.m_MainIconSp:SpriteSkill(Skill.icon)
	self.m_FuncLbl:SetText(Skill.funcdesc)

	--获取主动技能属性值
	self.m_NextTypeLbl:SetText(Skill.client_skillAttackType)

	local CurLevel = g_SkillCtrl:GetSchoolSkillLevel(self.m_CurSkill)
	self.m_DescLbl:SetText(g_SkillCtrl:GetSchoolDesc(CurLevel, Skill))
	self.m_NameLbl:SetText(NameStr)
	self.m_MainTypeLbl:SetText("[244B4E]等级:[63432C]"..CurLevel.."/"..Skill.top_limit)
	local NextLevel = CurLevel + 1
	local NumStr = string.gsub(Skill.top_limit,"grade",tostring(g_AttrCtrl.grade))
	local TopLimitLv = math.floor(tonumber(load(string.format([[return (%s)]], NumStr))()))

	local RangeIndex = self:GetRangeIndex(Skill.client_range,CurLevel)
	local RangeValue = Skill.client_range[RangeIndex].range
	self.m_TargetLbl:SetText(RangeValue)
	local DamageRatioIndex = self:GetRangeIndex(Skill.client_damageRatio,CurLevel)
	local DamageRatioValue = self:GetConsumeValue(Skill.client_damageRatio[DamageRatioIndex].range,CurLevel,true)
	self.m_ValueLbl:SetText(DamageRatioValue.."%")

	local CostTitleStr
	local HpResumeIndex
	local HpResumeValue
	local MpResumeIndex
	local MpResumeValue
	local AuraResumeIndex
	local AuraResumeValue
	local NextHpResumeIndex
	local NextHpResumeValue
	local NextMpResumeIndex
	local NextMpResumeValue
	local NextAuraResumeIndex
	local NextAuraResumeValue
	if table.count(Skill.client_aura_resume) > 0 then
		CostTitleStr = "消耗灵气:"
		AuraResumeIndex = self:GetRangeIndex(Skill.client_aura_resume,CurLevel)
		AuraResumeValue = self:GetConsumeValue(Skill.client_aura_resume[AuraResumeIndex].range,CurLevel) 

		NextAuraResumeIndex = self:GetRangeIndex(Skill.client_aura_resume,NextLevel)
		NextAuraResumeValue = self:GetConsumeValue(Skill.client_aura_resume[NextAuraResumeIndex].range,NextLevel)
	end
	if table.count(Skill.client_hpResume) > 0 then
		CostTitleStr = "消耗气血:"
		HpResumeIndex = self:GetRangeIndex(Skill.client_hpResume,CurLevel)
		HpResumeValue = self:GetConsumeValue(Skill.client_hpResume[HpResumeIndex].range,CurLevel)

		NextHpResumeIndex = self:GetRangeIndex(Skill.client_hpResume,NextLevel)
		NextHpResumeValue = self:GetConsumeValue(Skill.client_hpResume[NextHpResumeIndex].range,NextLevel)
	end
	if table.count(Skill.client_mpResume) > 0 then
		CostTitleStr = "消耗法力:"
		MpResumeIndex = self:GetRangeIndex(Skill.client_mpResume,CurLevel)
		MpResumeValue = self:GetConsumeValue(Skill.client_mpResume[MpResumeIndex].range,CurLevel)

		NextMpResumeIndex = self:GetRangeIndex(Skill.client_mpResume,NextLevel)
		NextMpResumeValue = self:GetConsumeValue(Skill.client_mpResume[NextMpResumeIndex].range,NextLevel)
	end	

	if CostTitleStr then
		self.m_CostTitleLbl:SetText(CostTitleStr)
		self.m_NextCostTitleLbl:SetText(CostTitleStr)
	end
	-- if AuraResumeValue then
	-- 	self.m_CostEnergyLbl:SetText(AuraResumeValue)
	-- end
	-- if HpResumeValue then
	-- 	self.m_CostEnergyLbl:SetText(HpResumeValue)
	-- end
	-- if MpResumeValue then
	-- 	self.m_CostEnergyLbl:SetText(MpResumeValue)
	-- end	

	--技能新ui的修改
	--只显示法力和灵气消耗
	local bIsShowTips = false
	local costEnergyStr = "招式消耗："--"当前"
	if MpResumeValue then
		costEnergyStr = costEnergyStr.."法力 "..MpResumeValue.." "
	end	
	if AuraResumeValue then
		bIsShowTips = true
		costEnergyStr = costEnergyStr.."灵气 "..AuraResumeValue.." "
	end
	if HpResumeValue then
		costEnergyStr = costEnergyStr.."气血 "..HpResumeValue.." "
	end
	self.m_CostEnergyLbl:SetText(costEnergyStr)
	self.m_TipBtn:SetActive(bIsShowTips)

	local NextRangeIndex = self:GetRangeIndex(Skill.client_range,NextLevel)
	local NextRangeValue = Skill.client_range[NextRangeIndex].range
	local NextDamageRatioIndex = self:GetRangeIndex(Skill.client_damageRatio,NextLevel)
	local NextDamageRatioValue = self:GetConsumeValue(Skill.client_damageRatio[NextDamageRatioIndex].range,NextLevel,true)

	self.m_UpgradeEnable = false
	if not g_SkillCtrl.m_SchoolSkills[self.m_CurSkill] then
		self.m_Content:SetActive(false)
		self.m_ResetFullBtn:SetActive(false)
		self.m_MaxSkillBox:SetActive(false)
		self.m_SkillSliderMaxBox:SetActive(false)
		self.m_OpenInfoLbl:SetActive(true)
		self.m_OpenInfoLbl:SetText(Skill.open_level.."级开启")
		self.m_NextTargetLbl:SetText(NextRangeValue)
		self.m_NextValueLbl:SetText(NextDamageRatioValue.."%")
		self:SetUpgradeNeedLbl(Skill, 0)
		-- if NextAuraResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextAuraResumeValue)
		-- end
		-- if NextHpResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextHpResumeValue)
		-- end
		-- if NextMpResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextMpResumeValue)
		-- end

		--技能新ui的修改
		--只显示法力和灵气消耗
		--下级的暂时屏蔽
		-- local costEnergyStr = "下级"
		-- if NextMpResumeValue then
		-- 	costEnergyStr = costEnergyStr.."\n".."消耗法力："..NextMpResumeValue
		-- end	
		-- if NextAuraResumeValue then
		-- 	costEnergyStr = costEnergyStr.."\n".."消耗灵气："..NextAuraResumeValue
		-- end
		-- self.m_NextCostEnergyLbl:SetText(costEnergyStr)
	elseif CurLevel >= TopLimitLv then
		self.m_Content:SetActive(false)
		--暂时屏蔽
		self.m_ResetFullBtn:SetActive(false)
		self.m_SkillSliderMaxBox:SetActive(false)

		self.m_SkillSliderMax:SetValue(1)
		self.m_SkillSliderMaxLbl:SetText(g_AttrCtrl.skill_point.."/--")
		self.m_MaxCountLbl:SetText(g_AttrCtrl.skill_point)
		self.m_OpenInfoLbl:SetActive(true)
		self.m_OpenInfoLbl:SetText("当前已达最高等级")
		-- self.m_NextTargetLbl:SetText(string.format("#I%s#n","已达最高等级"))
		-- self.m_NextValueLbl:SetText(string.format("#I%s#n","已达最高等级"))
		-- self.m_NextCostEnergyLbl:SetText(string.format("#I%s#n","已达最高等级"))
		self.m_NextTargetLbl:SetText("已达最高等级")
		self.m_NextValueLbl:SetText("已达最高等级")
		self.m_NextCostEnergyLbl:SetText("已达最高等级")
		self.m_GradeLbl:SetText("已达最高等级")
		self.m_UpgradeEnable = false
	else
		self.m_Content:SetActive(true)
		self.m_ResetFullBtn:SetActive(false)
		self.m_MaxSkillBox:SetActive(false)
		self.m_SkillSliderMaxBox:SetActive(false)
		self.m_OpenInfoLbl:SetActive(false)
		self.m_NextTargetLbl:SetText(NextRangeValue)
		self.m_NextValueLbl:SetText(NextDamageRatioValue.."%")
		-- if NextAuraResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextAuraResumeValue)
		-- end
		-- if NextHpResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextHpResumeValue)
		-- end
		-- if NextMpResumeValue then
		-- 	self.m_NextCostEnergyLbl:SetText(NextMpResumeValue)
		-- end

		--技能新ui的修改
		--只显示法力和灵气消耗
		--下级的暂时屏蔽
		-- local costEnergyStr = "下级"
		-- if NextMpResumeValue then
		-- 	costEnergyStr = costEnergyStr.."\n".."消耗法力："..NextMpResumeValue
		-- end	
		-- if NextAuraResumeValue then
		-- 	costEnergyStr = costEnergyStr.."\n".."消耗灵气："..NextAuraResumeValue
		-- end
		-- self.m_NextCostEnergyLbl:SetText(costEnergyStr)

		self:RefreshCost(g_SkillCtrl:GetSchoolSkillCost(self.m_CurSkill))
		--刷新消耗技能点
		local oNeedPoint = g_SkillCtrl:GetSchoolSkillData(self.m_CurSkill).needpoint
		self.m_ConsumeSkillPointLbl:SetText(oNeedPoint)
		self.m_SkillSlider:SetValue(g_AttrCtrl.skill_point/oNeedPoint)
		self.m_SkillSliderLbl:SetText(g_AttrCtrl.skill_point.."/"..oNeedPoint)

		self:SetUpgradeNeedLbl(Skill, CurLevel)
	end

	self.m_DescTable:Reposition()
	self.m_DescScrollView:ResetPosition()
end

function CSkillSchoolPart.SetUpgradeNeedLbl(self, Skill, CurLevel)
	local oNeedGrade = 0	
	CurLevel = CurLevel + 1
	if not Skill.learn_limit[CurLevel] then
		oNeedGrade = Skill.learn_limit[#Skill.learn_limit].grade
	else
		oNeedGrade = Skill.learn_limit[CurLevel].grade
	end
	self.m_GradeLbl:SetText("升级要求：角色"..oNeedGrade.."级")
	self.m_UpgradeEnable = oNeedGrade <= g_AttrCtrl.grade
end

function CSkillSchoolPart.GetRangeIndex(self,pConfig,pLevel)
	local MinIndex = 1
	for k,v in ipairs(pConfig) do
		if v.level <= pLevel then
			MinIndex = k
		else
			break
		end
	end
	return MinIndex
end

--根据公式计算出消耗属性值(法力、气血、灵气)或效率,根据参数是否计算效率
function CSkillSchoolPart.GetConsumeValue(self,configStr,level,bIsRatio)
	bIsRatio = bIsRatio or false
	local ValueStr = string.gsub(configStr,"level",tostring(level))
	ValueStr = string.gsub(configStr, "grade", tostring(g_AttrCtrl.grade))
	local Value = load(string.format([[return (%s)]], ValueStr))()
	local floorValue
	if bIsRatio then
		floorValue = math.floor(tonumber(Value)*100)
	else
		floorValue = math.floor(tonumber(Value))
	end
	return floorValue
end

--刷新消耗和金钱
function CSkillSchoolPart.RefreshCost(self,pCost)
	self.m_CostBox:SetCurrencyCount(pCost)
	self.m_SilverBox:SetWarningValue(pCost)
end

function CSkillSchoolPart.RefreshRedPoint(self)
	local bUpgradeEnable = false
	local iLv = 0
	local oNeedGrade = 0	
	local oNeedCount = 0
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)

	local function GetTopLimitLv(sk)
		if self.m_TopLimitLvDict[sk] then
			return self.m_TopLimitLvDict[sk]
		end
		local Skill = DataTools.GetSchoolSkillData(sk)
		local NumStr = string.gsub(Skill.top_limit,"grade",tostring(g_AttrCtrl.grade))
		local TopLimitLv = math.floor(tonumber(load(string.format([[return (%s)]], NumStr))()))
		self.m_TopLimitLvDict[sk] = TopLimitLv
		return TopLimitLv
	end
	
	for sk,oBox in pairs(self.m_BoxList) do
		iLv = g_SkillCtrl:GetSchoolSkillLevel(sk)
		local Skill = DataTools.GetSchoolSkillData(sk)
		local TopLimitLv = GetTopLimitLv(sk)

		if not g_SkillCtrl.m_SchoolSkills[sk] then
			iLv = 0
		end
		if iLv >= TopLimitLv then
			bUpgradeEnable = false
		else
			local iNextLv = iLv + 1
			if not Skill.learn_limit[iNextLv] then
				oNeedGrade = Skill.learn_limit[#Skill.learn_limit].grade
			else
				oNeedGrade = Skill.learn_limit[iNextLv].grade
			end
			bUpgradeEnable = oNeedGrade <= g_AttrCtrl.grade
		end

		oBox:DelEffect("Circu")
		if bUpgradeEnable then
			local oCurLevel = iLv
			local oConfig = data.skilldata.SCHOOL[sk].skillpoint_learn
			local oNextLevel = oCurLevel+1 >= oConfig[#oConfig].lv and oConfig[#oConfig].lv or (oCurLevel+1)
			oNeedCount = math.ceil(tonumber(load(string.format([[return (%s)]], oConfig[oNextLevel].formula))()))
			if oNeedCount <= iAmount then
				oBox.m_IgnoreCheckEffect = true
				oBox:AddEffect("RedDot")
				if iLv <= 0 and not g_SkillCtrl.m_ActiveSkillEffect[sk] then
					oBox:AddEffect("Circu")
				end
			else
				oBox:DelEffect("RedDot")
			end
		else
			oBox:DelEffect("RedDot")
		end
	end
end

--点击事件，点击左边一个技能box
function CSkillSchoolPart.OnSkillSelect(self, oBox)
	oBox:SetSelected(true)
	self.m_CurSkill = oBox.m_Skill
	self:RefreshContent()
	self:RefreshItem()
	oBox:DelEffect("Circu")
	g_SkillCtrl.m_ActiveSkillEffect[self.m_CurSkill] = true
end

--点击事件，点击升级按钮
function CSkillSchoolPart.OnLearnSkill(self)
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("正在战斗中，请稍后再操作")
	-- 	return
	-- end
	if not self.m_CurSkill then
		return
	end
	local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	local oNeedCount = 0
	local oCurLevel = g_SkillCtrl:GetSchoolSkillLevel(self.m_CurSkill)
	local oConfig = data.skilldata.SCHOOL[self.m_CurSkill].skillpoint_learn
	local oNextLevel = oCurLevel+1 >= oConfig[#oConfig].lv and oConfig[#oConfig].lv or (oCurLevel+1)
	oNeedCount = math.ceil(tonumber(load(string.format([[return (%s)]], oConfig[oNextLevel].formula))()))
	if itemNum < oNeedCount then
		local itemlist = {{sid = self.m_ItemSid, count = itemNum, amount = oNeedCount}}
	    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
			netskill.C2GSLearnSkill(define.Skill.Type.SchoolSkill, self.m_CurSkill, 1)
	    end)
	    return
	end
	netskill.C2GSLearnSkill(define.Skill.Type.SchoolSkill, self.m_CurSkill)
end

--点击事件，点击重置按钮
function CSkillSchoolPart.OnResetSkill(self)
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("正在战斗中，请稍后再操作")
	-- 	return
	-- end

	if g_SkillCtrl:GetSchoolSkillLevel(self.m_CurSkill) <= 1 then
		g_NotifyCtrl:FloatMsg("只有技能等级大于1级才能重置")
		return
	end
	local windowConfirmInfo = {
		msg				= "重置后技能将变为1级，确定重置？",
		title			= "提示",
		okCallback = function ()
			if g_SkillCtrl:GetSchoolSkillLevel(self.m_CurSkill) > 1 then
				netskill.C2GSResetActiveSchool(self.m_CurSkill)
			end
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
		self.m_WinTipViwe = oView
	end)
end

function CSkillSchoolPart.OnClickUnopenWidget(self)
	g_NotifyCtrl:FloatMsg(data.textdata.TEXT[define.Skill.Text.NotOpenSkill].content)
end

function CSkillSchoolPart.OnClickSkillSliderIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(11044, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_SkillSliderIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillSchoolPart.OnClickSkillSliderMaxIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(11044, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_SkillSliderMaxIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillSchoolPart.OnClickItemBox(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_SkillSliderItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

return CSkillSchoolPart