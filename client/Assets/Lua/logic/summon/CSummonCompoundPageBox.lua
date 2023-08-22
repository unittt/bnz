local CSummonCompoundPageBox = class("CSummonCompoundPageBox", CBox)

function CSummonCompoundPageBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_SkillStudyItemId = 10033 --技能学习
    self.m_SkillUpToolItemId = 10032 --技能升级物品ID   
    self.m_SummonCompoundDesId = 2003
	self.m_SummonCompoundHintId = 1031
	self.m_SummonCompoundSelHintId = 1032	
    self:InitContent()
end

function CSummonCompoundPageBox.InitContent(self)

    self.m_LeftAddSummon = self:NewUI(1, CBox)
	self.m_RightAddSummon = self:NewUI(2, CBox)
	self.m_SummonCompoundBtn = self:NewUI(3, CButton)
	self.m_SummonCompoundDesBtn = self:NewUI(4, CButton)
    self.m_LeftSummonInfo = self:NewUI(5, CSummonRSkillPageBox, true, "com")
	self.m_RightSummonInfo = self:NewUI(6, CSummonRSkillPageBox, true, "com")
	self.m_LeftComHintText = self:NewUI(7, CLabel)
	self.m_RightComHintText = self:NewUI(8, CLabel) 
	self.m_CompoundSummonType = self:NewUI(9, CBox)
	self.m_CompoundBottomGrid = self:NewUI(10, CGrid)

    self.m_SummonCompoundBtn:AddUIEvent("click", callback(self, "OnCompoundOutShow"))
    self.m_SummonCompoundDesBtn:AddUIEvent("click",function ()
		local zContent = {title = "合成",desc = data.summondata.TEXT[self.m_SummonCompoundDesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
    self:InitAddSummon("Left")
    self:InitAddSummon("Right")
    self:InitComBottomGrid()

    g_GuideCtrl:AddGuideUI("petview_compoundfinalcomfirm_btn", self.m_SummonCompoundBtn)
end

function CSummonCompoundPageBox.InitAddSummon(self, dir)
    self["m_"..dir.."SummonIcon"] = self["m_"..dir.."AddSummon"]:NewUI(1, CSprite)
	self["m_"..dir.."SummonNation"] = self["m_"..dir.."AddSummon"]:NewUI(2, CSprite)
	self["m_"..dir.."SummonName"] = self["m_"..dir.."AddSummon"]:NewUI(3, CLabel)		
	self["m_"..dir.."SummonScore"] = self["m_"..dir.."AddSummon"]:NewUI(4, CLabel)
    self["m_"..dir.."SummonGrade"] = self["m_"..dir.."AddSummon"]:NewUI(5, CLabel)
    self["m_"..dir.."SummonType"] = self["m_"..dir.."AddSummon"]:NewUI(6, CSprite)
	self["m_"..dir.."SummonText"] = self["m_"..dir.."AddSummon"]:NewUI(7, CLabel)
	self["m_"..dir.."SummonRank"] = self["m_"..dir.."AddSummon"]:NewUI(8, CSprite)
	self["m_"..dir.."AddSummonBtn"] = self["m_"..dir.."AddSummon"]:NewUI(9, CSprite)
	self["m_"..dir.."AddSummonBox"] = self["m_"..dir.."AddSummon"]:NewUI(10, CButton)
	self["m_"..dir.."AddSummonBox"]:AddUIEvent("click", callback(self, "OnSummonSelShow", dir))
	self["m_"..dir.."AddSummonBtn"]:AddUIEvent("click", callback(self, "OnSummonSelShow", dir))

	if dir == "Left" then
		g_GuideCtrl:AddGuideUI("petview_compoundselectleft_btn", self["m_"..dir.."AddSummonBtn"])
	else
		g_GuideCtrl:AddGuideUI("petview_compoundselectright_btn", self["m_"..dir.."AddSummonBtn"])
	end
end

function CSummonCompoundPageBox.InitComBottomGrid(self)
	local function Init(obj,idx)
		local go = CBox.New(obj)
		go.pic = go:NewUI(1, CSprite)
		go.count = go:NewUI(2, CLabel)
		go.count:SetActive(false)
		return go
    end
	self.m_CompoundBottomGrid:InitChild(Init)
	local itempic = self.m_CompoundBottomGrid:GetChild(1).pic
	itempic:AddUIEvent("click", function ()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_SkillUpToolItemId)
	end)
    local itempic2 = self.m_CompoundBottomGrid:GetChild(2).pic
	itempic2:AddUIEvent("click", function ()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_SkillStudyItemId)
	end)
end

function CSummonCompoundPageBox.InitCompoundSummonType(self)
	self.m_CompoundSummonTypePic = self.m_CompoundSummonType:NewUI(1, CSprite)
	self.m_CompoundSummonTypeNation = self.m_CompoundSummonType:NewUI(2, CSprite)
	self.m_CompoundSummonTypeName = self.m_CompoundSummonType:NewUI(3, CLabel)
	self.m_CompoundSummonTypeIcon = self.m_CompoundSummonType:NewUI(4, CSprite)	
end

function CSummonCompoundPageBox.CompoundHide(self)
	for i=1,8 do
		self.m_LeftAddSummon:GetChild(i).gameObject:SetActive(false)
		self.m_RightAddSummon:GetChild(i).gameObject:SetActive(false)
	end
	self.m_ComLeftSelId = nil
	self.m_ComRightSelId = nil
	local child_01 = self.m_CompoundBottomGrid:GetChild(1)
	child_01.pic:SpriteItemShape(DataTools.GetItemData(self.m_SkillUpToolItemId).icon)
	child_01.count:SetActive(false)
	local child_02 = self.m_CompoundBottomGrid:GetChild(2)
	child_02.pic:SpriteItemShape(DataTools.GetItemData(self.m_SkillStudyItemId).icon)
	child_02.count:SetActive(false)	
	self.m_LeftSummonInfo:SetActive(false)
	self.m_RightSummonInfo:SetActive(false)
	self.m_LeftComHintText:SetActive(true)
	self.m_RightComHintText:SetActive(true)
	self.m_LeftAddSummonBtn:SetActive(true)
	self.m_RightAddSummonBtn:SetActive(true)
end


function CSummonCompoundPageBox.ShowCompoundSummonType(self, data)
	self.m_CompoundSummonTypePic:SetSpriteName(data.pic)
	self.m_CompoundSummonTypeName:SetText(data.name)
	self.m_CompoundSummonTypeIcon:SpriteItemShape(data.icon)
	self.m_CompoundSummonTypeNation:SetSpriteName(data.nation)
end

--显示符合合成条件宠物
function CSummonCompoundPageBox.OnSummonSelShow(self, dir)
	local count = 0	
	for k,v in pairs(g_SummonCtrl.m_SummonsDic) do
	  	if k ~= g_SummonCtrl.m_FightId and v.key ~= 1 and v.type ~= 1 and g_SummonCtrl.m_CompoundRank[v.rank] == true then 
	  		count = count + 1 
        end
	end
	-- if count <= 0 then
	--  	g_NotifyCtrl:FloatSummonMsg(self.m_SummonCompoundHintId)
	-- 	return
	-- end
	if (self.m_ComLeftSelId ~= nil or self.m_ComRightSelId ~= nil) then 
		if count < 2 then 
			g_NotifyCtrl:FloatSummonMsg(self.m_SummonCompoundHintId)
			return
		end
		if self.m_ComLeftSelId ~= nil and self.m_ComRightSelId ~= nil then 
			if count < 3 then 
				g_NotifyCtrl:FloatSummonMsg(self.m_SummonCompoundHintId)
				return
			end
		end
	end

	local function isEmpty()
		for k,v in pairs(g_SummonCtrl.m_SummonsSort) do
			if (self.m_ComLeftSelId == nil or v.id ~= self.m_ComLeftSelId) and 
				(self.m_ComRightSelId == nil or v.id ~= self.m_ComRightSelId) and 
				v.id ~= g_SummonCtrl.m_FightId and v.type ~= 1 and v.key ~= 1 and g_SummonCtrl.m_CompoundRank[v.rank] == true then
				return false
			end
		end
		return true
	end

	if isEmpty() then
		g_NotifyCtrl:FloatMsg("没有可合成宠物")
		return
	end

	local function fun(id, dir)
		self:ComSelSummonInfo(id, dir)
	end
	CSummonCompoundSelView:ShowView(function(oView)
		oView:SetCallBack(fun, dir, self.m_ComLeftSelId, self.m_ComRightSelId)
	end)

end

--合成结果页面显示
function CSummonCompoundPageBox.OnCompoundOutShow(self)
	if not self.m_ComLeftSelId or  not self.m_ComRightSelId then 
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonCompoundSelHintId)
		return		
	end
	if not g_GuideCtrl.m_Flags["SummonCompose"] and g_GuideHelpCtrl:CheckNecessaryCondition("SummonCompose") 
	and g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_OpenSysCtrl:GetOpenSysState(define.System.SummonHc) and g_SummonCtrl:GetIsNeedSummonComposeGuide() then
		netsummon.C2GSCombineSummonLead(self.m_ComLeftSelId, self.m_ComRightSelId)
	else
		g_SummonCtrl:SendCombineSummon(self.m_ComLeftSelId, self.m_ComRightSelId)
	end
end

function CSummonCompoundPageBox.ComBottomSelSummonInfo(self, leftSummon, rightSummon)
	local leftSkillAmount = 0
	local rightSkillAmount = 0
	local function AmountFun(skill)
		local amount = 0
		for k,v in pairs(skill) do
			for i=v.level,1,-1 do
				amount = amount + data.summondata.SKILLCOST[i].amount
			end		
		end
		return amount
	end
	leftSkillAmount = AmountFun(leftSummon.skill)
	rightSkillAmount = AmountFun(rightSummon.skill)
	local avg = math.floor((leftSummon.grade+rightSummon.grade) / 2)
	local exp = 0
	if avg ~= 0 then
		local cum1 = g_SummonCtrl:GetCumulativeSummonExp(leftSummon.grade)
		local cum2 = g_SummonCtrl:GetCumulativeSummonExp(rightSummon.grade)
		exp = math.floor(cum1 + leftSummon.exp + cum2 + rightSummon.exp) * 0.5
	end	
	local child_01 = self.m_CompoundBottomGrid:GetChild(1)
	child_01.pic:SetActive(true)
	printc(self.m_SkillUpToolItemId,DataTools.GetItemData(self.m_SkillUpToolItemId).icon)
	child_01.pic:SpriteItemShape(DataTools.GetItemData(self.m_SkillUpToolItemId).icon)
	child_01.pic:AddUIEvent("click",function ()
		local config = {widget = child_01.pic}
		g_WindowTipCtrl:SetWindowItemTip(self.m_SkillUpToolItemId, config)
	end)
	child_01.count:SetActive(true)
	child_01.count:SetText(math.floor((leftSkillAmount+rightSkillAmount) * 0.9))
	local child_02 = self.m_CompoundBottomGrid:GetChild(2)
	child_02.pic:SetActive(true)
	child_02.pic:AddUIEvent("click",function ()
		local config = {widget = child_02.pic}
		g_WindowTipCtrl:SetWindowItemTip(self.m_SkillStudyItemId, config)
	end)
	child_02.pic:SpriteItemShape(DataTools.GetItemData(self.m_SkillStudyItemId).icon)
	child_02.count:SetActive(true)
	child_02.count:SetText(math.floor(exp/40000))
end

function CSummonCompoundPageBox.ComSelSummonInfo(self, id, dir)
    self["m_Com"..dir.."SelId"] = id
    local dp = g_SummonCtrl:GetSummon(id)
	self["m_"..dir.."ComHintText"]:SetActive(false)
	self["m_"..dir.."SummonInfo"]:SetActive(true)
	self["m_"..dir.."SummonIcon"]:SpriteAvatar(dp.model_info.shape)
	self["m_"..dir.."SummonIcon"]:SetActive(true)
	--self["m_"..dir.."SummonNation"]:SetSpriteName(tostring(data.summondata.RACE[dp["race"]].icon))
	--self["m_"..dir.."SummonNation"]:SetActive(true)
	self["m_"..dir.."SummonName"]:SetText(dp["name"])
	self["m_"..dir.."SummonName"]:SetActive(true)
	if data.summondata.SUMMTYPE[dp["type"]] ~= nil then 
		self["m_"..dir.."SummonType"]:SetSpriteName(data.summondata.SUMMTYPE[dp["type"]].icon)
	end
	self["m_"..dir.."SummonType"]:SetActive(true)
	self["m_"..dir.."SummonGrade"]:SetText(dp["grade"])
	self["m_"..dir.."SummonGrade"]:SetActive(true)
	self["m_"..dir.."SummonScore"]:SetText(dp["score"])
	self["m_"..dir.."SummonScore"]:SetActive(true)
	self["m_"..dir.."SummonText"]:SetActive(true)
	self["m_"..dir.."SummonRank"]:SetActive(true)
	self["m_"..dir.."AddSummonBtn"]:SetActive(false)
	for k,v in pairs(data.summondata.SCORE) do --设置评分等级
		if v.rank == dp["rank"] then 
			self["m_"..dir.."SummonRank"]:SetSpriteName(data.summondata.SCORE[k].icon)
			break	
		end
	end	
	local reDir = "Right" 
	if dir == "Right" then 
		reDir = "Left"
	else
		reDir = "Right"	
	end 
	if self["m_Com"..reDir.."SelId"] ~= nil then 
		self:ComBottomSelSummonInfo(g_SummonCtrl:GetSummon(self["m_Com"..reDir.."SelId"]), dp)
	end
    self["m_"..dir.."SummonInfo"]:SetInfo(id, "com")
end

return CSummonCompoundPageBox