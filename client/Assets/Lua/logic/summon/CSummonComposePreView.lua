local CSummonComposePreView = class("CSummonComposePreView", CViewBase)

function CSummonComposePreView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonComposePreView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSummonComposePreView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LeftBox = self:NewUI(2, CBox)
	self.m_RightBox = self:NewUI(3, CBox)

	self.m_SummonScrollView = self.m_LeftBox:NewUI(1, CScrollView)
	self.m_SummonGrid = self.m_LeftBox:NewUI(2, CGrid)
	self.m_SummonBoxClone = self.m_LeftBox:NewUI(3, CBox)
	self.m_JifenLbl = self.m_LeftBox:NewUI(4, CLabel)

	self.m_AttrGrid = self.m_RightBox:NewUI(1, CGrid)
	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_TypeLbl = oBox:NewUI(1, CLabel)
		oBox.m_CountLbl = oBox:NewUI(2, CLabel)
		if idx ~= 6 then
			oBox.m_BgSp = oBox:NewUI(3, CSprite)
		end
		return oBox
	end
	self.m_AttrGrid:InitChild(init)
	self.m_SkillScrollView = self.m_RightBox:NewUI(2, CScrollView)
	self.m_SkillGrid = self.m_RightBox:NewUI(3, CGrid)
	self.m_SkillBoxClone = self.m_RightBox:NewUI(4, CBox)
	self.m_CancelBtn = self.m_RightBox:NewUI(5, CButton)
	self.m_ComposeBtn = self.m_RightBox:NewUI(6, CButton)

	self.m_AttrOrderList = {"attack", "defense", "health", "mana", "speed"}
	self.m_AttrList = {attack = "攻资", defense = "防资", health = "体资", mana = "法资", speed = "速资"}
	self.m_SkillList = {}
	self.m_SkillBoxTotal = 12
	self.m_SkillEmptySk = -9999999
	self.m_ComposeSummonList = {}
	self.m_JifenLbl:SetColor(Color.white)
	
	self:InitContent()
end

function CSummonComposePreView.InitContent(self)
	self.m_SummonBoxClone:SetActive(false)
	self.m_SkillBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))
	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonComposePreView.RefreshUI(self, oSum1, oSum2)
	self.m_SummonData1 = oSum1
	self.m_SummonData2 = oSum2
	self:GetComposeSummonListNew(oSum1, oSum2)
	self:GetTalentList()
	self:GetSkillList(oSum1, oSum2)
	for k,v in ipairs(self.m_AttrOrderList) do
		local oBox = self.m_AttrGrid:GetChild(k)
		oBox.m_TypeLbl:SetText(self.m_AttrList[v])
		oBox.m_CountLbl:SetText( self:GetDownAttr(oSum1.maxaptitude[v], oSum2.maxaptitude[v]) .. "-" ..self:GetUpAttr(oSum1.maxaptitude[v], oSum2.maxaptitude[v]) )
	end
	local oGrowBox = self.m_AttrGrid:GetChild(6)
	oGrowBox.m_TypeLbl:SetText("成长")
	if oGrowBox.m_BgSp then
		oGrowBox.m_BgSp:SetActive(false)
	end
	self:RefreshGrow(oGrowBox.m_CountLbl)
	-- oGrowBox.m_CountLbl:SetText( math.floor(math.min(oSum1.grow*0.98, oSum2.grow*0.98))/1000 .."-".. math.floor(math.max(oSum1.grow*1.02, oSum2.grow*1.02))/1000 )

	self:SetSummonSkillList()
	self:SetSummonList()
	self:SetScoreL()
end

function CSummonComposePreView.RefreshGrow(self, oLabel)
	local iMin, iMax
	for i, v in ipairs(self.m_ComposeSummonList) do
		local dSumm = SummonDataTool.GetSummonInfo(v.typeid)
		if dSumm then
			local iGrow = dSumm.grow
			if not iMin then
				iMin = iGrow
				iMax = iGrow
			else
				if iMin > iGrow then
					iMin = iGrow
				end
				if iMax < iGrow then
					iMax = iGrow
				end
			end
		end
	end
	local iMinR, iMaxR = SummonDataTool.GetSummonGrowRange()
	local sMax = string.format("%0.4f", iMaxR * iMax * 0.00001)
	local sMin = string.format("%0.4f", iMinR * iMin * 0.00001)
	sMax = string.sub(sMax,0,-2)
	sMin = string.sub(sMin,0,-2)
	oLabel:SetText(sMin.."～"..sMax)
end

function CSummonComposePreView.GetUpAttr(self, oAttr1, oAttr2)
	return math.floor((oAttr1 + oAttr2) /2 * SummonDataTool.GetCombindAptiMax())
end

function CSummonComposePreView.GetDownAttr(self, oAttr1, oAttr2)
	return math.floor((oAttr1 + oAttr2) /2 * SummonDataTool.GetCombindAptiMin())
end

function CSummonComposePreView.GetSkillList(self, oSum1, oSum2)
	self.m_SkillList = {}
	local dCheck = {}
	local addSkFunc = function(list)
		for k, v in ipairs(list) do
			local bNum = type(v) == "number"
			local skId = bNum and v or v.sk
			if not dCheck[skId] then
				local dSk = bNum and {sk = v} or v
				table.insert(self.m_SkillList, dSk)
				dCheck[skId] = true
			end
		end
	end
	local infoList = {oSum1.talent, oSum2.talent, oSum1.skill, oSum2.skill}
	local bXiyou = false
	for i, v in ipairs(self.m_ComposeSummonList) do
		if v.typeid ~= oSum1.typeid and v.typeid ~= oSum2.typeid then
			local dConfig = SummonDataTool.GetSummonInfo(v.typeid)
			table.insert(infoList, dConfig.skill1)
			table.insert(infoList, dConfig.talent)
			bXiyou = true
		end
	end
	if not bXiyou then
		local dSumm1 = SummonDataTool.GetSummonInfo(oSum1.typeid)
		local dSumm2 = SummonDataTool.GetSummonInfo(oSum2.typeid)
		table.insert(infoList, dSumm1.skill1)
		table.insert(infoList, dSumm2.skill1)
	end
	for i, v in ipairs(infoList) do
		addSkFunc(v)
	end
	local oNeedNum = self.m_SkillBoxTotal - #self.m_SkillList
	if oNeedNum > 0 then
		for i = 1, oNeedNum do
			table.insert(self.m_SkillList, {sk = self.m_SkillEmptySk})
		end
	end
	table.sort(self.m_SkillList, function (a, b) return a.sk > b.sk end)
end

function CSummonComposePreView.GetTalentList(self)
	self.m_TalentList = {}
	self.m_TalentTag = nil
	for k,v in pairs(self.m_ComposeSummonList) do
		local oConfig = data.summondata.INFO[v.typeid]
		if oConfig and next(oConfig.talent) then
			-- if not self.m_TalentTag then
			-- 	self.m_TalentTag = oConfig
			-- else
			-- 	if self.m_TalentTag.type < oConfig.type then
			-- 		self.m_TalentTag = oConfig
			-- 	elseif self.m_TalentTag.type == oConfig.type then
			-- 		if self.m_TalentTag.carry < oConfig.carry then
			-- 			self.m_TalentTag = oConfig
			-- 		elseif self.m_TalentTag.carry == oConfig.carry then
			-- 			if self.m_TalentTag.id < oConfig.id then
			-- 				self.m_TalentTag = oConfig
			-- 			end
			-- 		end
			-- 	end
			-- end
			self.m_TalentTag = oConfig
		end
		if self.m_TalentTag and self.m_TalentTag.talent then
			for k,v in pairs(self.m_TalentTag.talent) do
				table.insert(self.m_TalentList, v)
			end
		end
	end
	-- table.print(self.m_TalentList, "哈哈哈哈哈哈哈哈哈哈哈哈")
end

function CSummonComposePreView.GetIsInTalentList(self, oTalentList, oSk)
	for k,v in pairs(oTalentList) do
		if oSk == v then
			return v
		end
	end
end

function CSummonComposePreView.GetComposeSummonListNew(self, oSum1, oSum2)
	self.m_ComposeSummonList = {}
	local iTypeId1, iTypeId2 = oSum1.typeid, oSum2.typeid
	local iType1, iType2 = oSum1.type, oSum2.type
	local dComposeConfig = self:GetXiYouConfig(iTypeId1, iTypeId2)
	if dComposeConfig then
		table.insert(self.m_ComposeSummonList, {typeid = dComposeConfig.sid3, rate = 100})
		return
	end
	local bXiyou1 = SummonDataTool.IsUnnormalSummon(iType1)
	local bXiyou2 = SummonDataTool.IsUnnormalSummon(iType2)
	local iRate1, iRate2 = 0, 0
	local bSwp = false
	if (bXiyou1 and not bXiyou2) or (bXiyou2 and not bXiyou1) then
		iRate1 = data.globaldata.SUMMONCK[1].combine_xy_ratio_new
		iRate2 = 100 - iRate1
		bSwp = bXiyou2
	elseif iTypeId1 == iTypeId2 then
		table.insert(self.m_ComposeSummonList, {typeid = iTypeId1, rate = 100})
		return
	else
		local iLv1, iLv2 = oSum1.carrygrade, oSum2.carrygrade
		if iLv1 == iLv2 then
			iRate1, iRate2 = 50, 50
		else
			local b1Max = iLv1 > iLv2
			local iMaxLv = b1Max and iLv1 or iLv2
			local iMinLv = b1Max and iLv2 or iLv1
			local sFormul = data.globaldata.SUMMONCK[1].heigh_ratio
			sFormul = string.replace(sFormul, "//", "/")
			iRate1 = math.floor(string.eval(sFormul, {maxlv = iMaxLv, minlv = iMinLv, math = math}))
			iRate2 = 100 - iRate1
			bSwp = not b1Max
		end
	end
	if bSwp then
		local iTp = iTypeId1
		iTypeId1 = iTypeId2
		iTypeId2 = iTp
	end
	table.insert(self.m_ComposeSummonList, {typeid = iTypeId1, rate = iRate1})
	table.insert(self.m_ComposeSummonList, {typeid = iTypeId2, rate = iRate2})
end

-- 策划改规则了，使用GetComposeSummonListNew
--下面用A\B\C\D代号来解释4中合成结果的情况：
--1.A和B都是普通宠物，且没有公式可以合成稀有宠物（在xiyou.lua中可以查询）
--则A的获得概率=50%；B的获得概率=50%
--2.A和B都是普通宠物，有公式可以合成稀有宠物C
--则A获得的概率为33%，B获得的概率为33%，C获得的概率为33%
--3.如果C是稀有宠物，是由A+B合成而来，现在使用C+A或者C+B或者C+C
--则A获得的概率为33%，B获得的概率为33%，C获得的概率为33%
--4.如果A是稀有宠物，B是稀有宠物
--则A获得的概率=50%，B获得概率=50%
--5.A是普通宠物，B（B=C+D)是稀有宠物，但是A和B没有合成关系
--则A、B、C、D获得的概率=25%
function CSummonComposePreView.GetComposeSummonList(self, oSum1, oSum2)
	self.m_ComposeSummonList = {}
	local oXiYouConfig1 = self:GetXiYouConfig(oSum1.typeid, oSum2.typeid)
	if oSum1.type == 2 and oSum2.type == 2 and not oXiYouConfig1 then
		table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 50})
		table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 50})
		return
	elseif oSum1.type == 2 and oSum2.type == 2 and oXiYouConfig1 then
		table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig1.sid1, rate = 33})
		table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig1.sid2, rate = 33})
		table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig1.sid3, rate = 33})
		return
	elseif oSum1.type == 4 and oSum2.type == 4 then
		local oXiYouConfig2 = self:GetXiYouConfig2(oSum1.typeid)
		if oSum1.typeid == oSum2.typeid and oXiYouConfig2 then
			table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid1, rate = 33})
			table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid2, rate = 33})
			table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid3, rate = 33})
		else
			table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 50})
			table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 50})
		end
		return
	elseif (oSum1.type == 4 and oSum2.type ~= 4) or (oSum1.type ~= 4 and oSum2.type == 4) then
		if oSum1.type == 4 then
			local oXiYouConfig2 = self:GetXiYouConfig2(oSum1.typeid)
			if oXiYouConfig2 then
				if oXiYouConfig2.sid1 == oSum2.typeid or oXiYouConfig2.sid2 == oSum2.typeid or oXiYouConfig2.sid3 == oSum2.typeid then
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid1, rate = 33})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid2, rate = 33})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid3, rate = 33})
					return
				else
					table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid1, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid2, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid3, rate = 25})
					return
				end
			else
				table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 50})
				table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 50})
				return
			end
		elseif oSum2.type == 4 then
			local oXiYouConfig2 = self:GetXiYouConfig2(oSum2.typeid)
			if oXiYouConfig2 then
				if oXiYouConfig2.sid1 == oSum1.typeid or oXiYouConfig2.sid2 == oSum1.typeid or oXiYouConfig2.sid3 == oSum1.typeid then
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid1, rate = 33})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid2, rate = 33})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid3, rate = 33})
					return
				else
					table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid1, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid2, rate = 25})
					table.insert(self.m_ComposeSummonList, {typeid = oXiYouConfig2.sid3, rate = 25})
					return
				end
			else
				table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 50})
				table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 50})
				return
			end
		end
	else
		table.insert(self.m_ComposeSummonList, {typeid = oSum1.typeid, rate = 50})
		table.insert(self.m_ComposeSummonList, {typeid = oSum2.typeid, rate = 50})
		return
	end
end

function CSummonComposePreView.GetXiYouConfig(self, oSumid1, oSumid2)
	for k,v in pairs(g_SummonCtrl.m_SumXiYouConfig) do
		if (v.sid1 == oSumid1 and v.sid2 == oSumid2) or (v.sid1 == oSumid2 and v.sid2 == oSumid1) then
			return v
		end
	end
end

function CSummonComposePreView.GetXiYouConfig2(self, oSumid3)
	for k,v in pairs(g_SummonCtrl.m_SumXiYouConfig) do
		if v.sid3 == oSumid3 then
			return v
		end
	end
end

function CSummonComposePreView.SetSummonList(self)
	local optionCount = #self.m_ComposeSummonList
	local GridList = self.m_SummonGrid:GetChildList() or {}
	local oSummonBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSummonBox = self.m_SummonBoxClone:Clone(false)
				-- self.m_SummonGrid:AddChild(oOptionBtn)
			else
				oSummonBox = GridList[i]
			end
			self:SetSummonBox(oSummonBox, self.m_ComposeSummonList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_SummonGrid:Reposition()
	self.m_SummonScrollView:ResetPosition()
end

function CSummonComposePreView.SetSummonBox(self, oSummonBox, oData)
	oSummonBox:SetActive(true)
	oSummonBox.m_IconSp = oSummonBox:NewUI(1, CSprite)
	oSummonBox.m_LevelLbl = oSummonBox:NewUI(2, CLabel)
	oSummonBox.m_RateLbl = oSummonBox:NewUI(3, CLabel)
	oSummonBox.m_TypeSp = oSummonBox:NewUI(4, CSprite)

	oSummonBox.m_IconSp:SpriteAvatar(data.summondata.INFO[oData.typeid].shape)
	oSummonBox.m_LevelLbl:SetText(data.summondata.INFO[oData.typeid].carry.."级")
	oSummonBox.m_RateLbl:SetText((oData.rate).."%")
	oSummonBox.m_TypeSp:SetSpriteName(data.summondata.SUMMTYPE[data.summondata.INFO[oData.typeid].type].icon)
	oSummonBox.m_TypeSp:MakePixelPerfect()

	self.m_SummonGrid:AddChild(oSummonBox)
	self.m_SummonGrid:Reposition()
end

function CSummonComposePreView.SetSummonSkillList(self)
	local optionCount = #self.m_SkillList
	local GridList = self.m_SkillGrid:GetChildList() or {}
	local oSummonSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSummonSkillBox = self.m_SkillBoxClone:Clone(false)
				-- self.m_SkillGrid:AddChild(oOptionBtn)
			else
				oSummonSkillBox = GridList[i]
			end
			self:SetSummonSkillBox(oSummonSkillBox, self.m_SkillList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_SkillGrid:Reposition()
	self.m_SkillScrollView:ResetPosition()
end

function CSummonComposePreView.SetSummonSkillBox(self, oSummonSkillBox, oData)
	oSummonSkillBox:SetActive(true)
	oSummonSkillBox.m_IconSp = oSummonSkillBox:NewUI(1, CSprite)
	oSummonSkillBox.m_LevelLbl = oSummonSkillBox:NewUI(2, CLabel)
	oSummonSkillBox.m_KuangSp = oSummonSkillBox:NewUI(3, CSprite)
	oSummonSkillBox.m_TagSp = oSummonSkillBox:NewUI(4, CSprite)
	oSummonSkillBox.m_TagSp:SetSpriteName("h7_tianfu_1")
	oSummonSkillBox.m_TagSp:SetLocalRotation(Vector3.zero)

	oSummonSkillBox.m_LevelLbl:SetActive(false)
	if oData.sk == self.m_SkillEmptySk then
		oSummonSkillBox.m_IconSp:SetActive(false)
		oSummonSkillBox.m_TagSp:SetActive(false)
	else
		-- printc("66666666 ", oData.sk)
		oSummonSkillBox.m_IconSp:SetActive(true)
		local dSkill = SummonDataTool.GetSummonSkillInfo(oData.sk)
		local spriteInfo = dSkill.iconlv
		oSummonSkillBox.m_IconSp:SpriteSkill(spriteInfo[1].icon)
		local iQuality = dSkill.quality
		if iQuality == 0 then
			iQuality = 2
		end
		oSummonSkillBox.m_KuangSp:SetItemQuality(iQuality)
		if oData.talent or table.index(self.m_TalentList, oData.sk) then
			oSummonSkillBox.m_TagSp:SetActive(true)
		else
			oSummonSkillBox.m_TagSp:SetActive(false)
		end
	end
	oSummonSkillBox:AddUIEvent("click", callback(self, "OnClickSkillBox", oData, oSummonSkillBox))

	self.m_SkillGrid:AddChild(oSummonSkillBox)
	self.m_SkillGrid:Reposition()
end

function CSummonComposePreView.SetScoreL(self)
    local iScore = g_SummonCtrl:GetSummonComposeScore()
    if iScore then
        self.m_JifenLbl:SetText(string.format("[244b4e]合成最多会返还[af302a]%d[-]积分[-]", iScore))
    else
        self.m_JifenLbl:SetText("[244b4e]合成会返还一定积分")
    end
end

---------------- 珍兽神兽合成，显示固定宠物 -------------------
function CSummonComposePreView.ShowSpecificSumm(self, id)
	self.m_SpcSummonId = id
	local dSummon = SummonDataTool.GetSummonInfo(id)
	self.m_SkillList = SummonDataTool.GetConfigSkillInfo(dSummon)
	self:SetSummonSkillList()
	self:AddSpcSummonBox(dSummon)
	self:RefreshSpcAttr(dSummon)
	self.m_JifenLbl:SetActive(false)
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickSpcCompose"))
end

function CSummonComposePreView.AddSpcSummonBox(self, dSummon)
	local dBoxData = {}
	dBoxData.rate = 100
	dBoxData.typeid = dSummon.id
	local oBox = self.m_SummonBoxClone:Clone()
	oBox:SetActive(true)
	self:SetSummonBox(oBox, dBoxData)
	self.m_SummonGrid:AddChild(oBox)
	self.m_SummonGrid:Reposition()
	self.m_SummonScrollView:ResetPosition()
end

function CSummonComposePreView.RefreshSpcAttr(self, dSummon)
	local bGod = SummonDataTool.IsExpensiveSumm(dSummon.type)
	for k,v in ipairs(self.m_AttrOrderList) do
		local oBox = self.m_AttrGrid:GetChild(k)
		local iVal = dSummon.aptitude[v]
		if bGod then
			oBox.m_CountLbl:SetText(iVal)
		else
			local iMaxVal = math.floor(iVal*125/100)
			oBox.m_CountLbl:SetText(string.format("%d-%d",iVal,iMaxVal))
		end
		oBox.m_TypeLbl:SetText(self.m_AttrList[v])
	end
	self:RefreshSpcGrow(dSummon.grow, bGod)
end

function CSummonComposePreView.RefreshSpcGrow(self, iGrow, bGod)
	local oGrowBox = self.m_AttrGrid:GetChild(6)
	oGrowBox.m_TypeLbl:SetText("成长")
	if oGrowBox.m_BgSp then
		oGrowBox.m_BgSp:SetActive(false)
	end
    if bGod then
        oGrowBox.m_CountLbl:SetText(string.format("%0.3f", iGrow/1000))
    else
    	local GrowMin, GrowMax = SummonDataTool.GetSummonGrowRange()
	    local maxGrow = string.format("%0.4f", GrowMax * iGrow * 0.00001)
	    local num2 = string.sub(tostring(maxGrow),0,-2)
        local minGrow = string.format("%0.4f", GrowMin * iGrow * 0.00001)
        local num1 = string.sub(tostring(minGrow),0,-2)
        oGrowBox.m_CountLbl:SetText(num1.."～"..num2)
    end
end

---------------以下是点击事件-----------------

function CSummonComposePreView.OnClickCancel(self)
	self:CloseView()
end

function CSummonComposePreView.OnClickSpcCompose(self)
	local oView = CSummonSpcComposeView:GetView()
	if oView and oView:GetActive() then
		oView:OnClickCompound()
	end
end

function CSummonComposePreView.OnClickCompose(self)
	local oView = CSummonMainView:GetView()
	if oView and oView:GetActive() then
		oView.m_AdjustPart.m_CompoundPart:OnClickCompound()
	end
end

function CSummonComposePreView.OnClickSkillBox(self, oData, oSummonSkillBox)
	if oData.sk == self.m_SkillEmptySk then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetData(oData, oSummonSkillBox:GetPos(), nil, nil, nil)	
	end)
end

return CSummonComposePreView