local CSummonPotentialView = class("CSummonPotentialView", CViewBase)

function CSummonPotentialView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/CSummonPotentialView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
	self.m_Items = {}
	self.m_DesId = 2006
	self.m_WashPointHintId_1 = 1037
	self.m_WashPointHintId_2 = 1038
	self.m_WashPointHintId_3 = 1039
	self.m_WashPointHintId_4 = 1040
	self.m_OkBtnSpr = { normal = "h7_an_1",disable = "h7_an_5",press = "h7_an_3"}
end

function CSummonPotentialView.OnCreateView(self)
	self.m_SummonName = self:NewUI(1, CLabel)
	self.m_SummonGrade = self:NewUI(2, CLabel)
	self.m_SummonPic = self:NewUI(3, CSprite)
	self.m_LifeItem = self:NewUI(4, CBox)
	self.m_MagicItem = self:NewUI(5, CBox)
	self.m_PhyAttackItem = self:NewUI(6, CBox)
	self.m_PhyDefItem = self:NewUI(7, CBox)
	self.m_MagicAttackItem = self:NewUI(8, CBox)
	self.m_MagicDefItem = self:NewUI(9, CBox)
	self.m_SpeedItem = self:NewUI(10, CBox)	
	self.m_DesBtn = self:NewUI(11, CButton)	
	self.m_AutoAddPointBtn = self:NewUI(12,CButton,false,false)
	self.m_RemainPoint = self:NewUI(13,CLabel)

	self.m_BodyItem = self:NewUI(14, CBox)
	self.m_MagicPItem = self:NewUI(15, CBox)
	self.m_PowerItem = self:NewUI(16, CBox)
	self.m_StaminaItem = self:NewUI(17, CBox)
	self.m_AgilityItem = self:NewUI(18, CBox)
	self.m_ResetBtn = self:NewUI(19, CButton)
	self.m_AddTypeBtn = self:NewUI(20, CButton)
	self.m_OkBtn = self:NewUI(21, CButton)
	self.m_CloseBtn = self:NewUI(22, CButton)
	self.m_LeftBtn = self:NewUI(23, CButton)
	self.m_RightBtn = self:NewUI(24, CButton)
	self.m_IsFight = self:NewUI(25, CSprite)
	self.m_DesText = self:NewUI(26, CSprite)
	self.m_AutoAddPointBtn.isSel = self:NewUI(27, CSprite)
	self.m_Body = self:InitItem(self.m_BodyItem)
	self.m_MagicP = self:InitItem(self.m_MagicPItem)
	self.m_Stamina = self:InitItem(self.m_StaminaItem)
	self.m_Power = self:InitItem(self.m_PowerItem)
	self.m_Agility = self:InitItem(self.m_AgilityItem)	
	self:InitEvent()
	self:DefAttrVar()
end

function CSummonPotentialView.SetContent(self)
	self.data = {}
	self.data = g_SummonCtrl:GetSummon(self.m_CurSummonId)
	--table.print(self.data)
	self.m_Summons = {}
	self.m_Items = {}
	for k,v in pairs(g_SummonCtrl.m_SummonsSort) do
		table.insert(self.m_Summons,v)
	end

	if g_SummonCtrl.m_FightId == self.m_CurSummonId then 
		self.m_IsFight:SetActive(true)
	else
		self.m_IsFight:SetActive(false)
	end

	if self.data["autoswitch"] == 1 then 		
		self.m_AutoAddPointBtn.isSel:SetActive(true)
		self.m_IsAuto = true
	else	
		self.m_AutoAddPointBtn.isSel:SetActive(false)
		self.m_IsAuto = false
	end
	--self.m_OkBtn:SetEnabled(false)
	self.m_OkBtn:SetSpriteName(self.m_OkBtnSpr.normal)
	self.m_OkBtn:SetText("[EEFFFB]确定[-]")
	self.m_CurAddPoint = 0
	self.m_RemainPointCount = self.data["point"]
	self.m_TempReamin = self.data["point"]	
	self.m_PointSum = self.data["point"]
	self.m_SummonName:SetText(self.data["name"])
	self.m_SummonGrade:SetText("等级:"..self.data["grade"])
	self.m_SummonPic:SpriteAvatar(self.data.model_info.shape)
	self.m_LifeItem:NewUI(2,CLabel):SetText(self.data["max_hp"])
	self.m_LifeItem:NewUI(3,CLabel):SetActive(false)	
	self.m_MagicItem:NewUI(2,CLabel):SetText(self.data["max_mp"])
	self.m_MagicItem:NewUI(3,CLabel):SetActive(false)
	self.m_PhyAttackItem:NewUI(2,CLabel):SetText(self.data["phy_attack"])
	self.m_PhyAttackItem:NewUI(3,CLabel):SetActive(false)
	self.m_PhyDefItem:NewUI(2,CLabel):SetText(self.data["phy_defense"])
	self.m_PhyDefItem:NewUI(3,CLabel):SetActive(false)
	self.m_MagicAttackItem:NewUI(2,CLabel):SetText(self.data["mag_attack"])
	self.m_MagicAttackItem:NewUI(3,CLabel):SetActive(false)
	self.m_MagicDefItem:NewUI(2,CLabel):SetText(self.data["mag_defense"])
	self.m_MagicDefItem:NewUI(3,CLabel):SetActive(false)
	self.m_SpeedItem:NewUI(2,CLabel):SetText(self.data["speed"])
	self.m_SpeedItem:NewUI(3,CLabel):SetActive(false)
	self.m_RemainPoint:SetText("剩余潜力:"..self.data["point"])	
	self:SetSlider(self.m_Body,"physique",self.data)	
	self:SetSlider(self.m_MagicP,"magic",self.data)	
	self:SetSlider(self.m_Power,"strength",self.data)
	self:SetSlider(self.m_Stamina,"endurance",self.data)	
	self:SetSlider(self.m_Agility,"agility",self.data)
	self:LAddPointShow()	
end

function CSummonPotentialView.SetSlider(self, item, type, data)
	item["oldCount"]:SetText(data["attribute"][type])
	if data["type"] == 1 then 
		item.maxValue = data["grade"]+10+data["carrygrade"]*3+50+data["grade"]*5
	else
		item.maxValue = data["grade"]+10+50+data["grade"]*5
	end	
	item["orange"]:SetValue((data["grade"]+10)/item.maxValue)
	item["blue"]:SetValue(((data["grade"]+10)+(data["attribute"][type]-(data["grade"]+10)))/item.maxValue)
	local test = (data["grade"]+10)+(data["attribute"][type]-(data["grade"]+10))
	item["green"]:SetMinValue(item["blue"]:GetValue())--先设置最大值和最小值
	item["green"]:SetMaxValue(1)
	item["green"]:SetValue(item["blue"]:GetValue())
	item.add = 0
	item.blueValue = (data["grade"]+10)+(data["attribute"][type]-(data["grade"]+10))	
	item["addCount"]:SetActive(false)
	table.insert(self.m_Items,item)
end

function CSummonPotentialView.InitEvent(self)
	self.m_DesBtn:AddUIEvent("click",callback(self,"OnDesBtn"))
	self.m_AutoAddPointBtn:AddUIEvent("click",callback(self,"OnAutoAddPoint"))
	self.m_ResetBtn:AddUIEvent("click",callback(self,"OnReset"))
	self.m_AddTypeBtn:AddUIEvent("click",callback(self,"OnAddType"))
	self.m_OkBtn:AddUIEvent("click",callback(self,"OnOk"))
	self.m_CloseBtn:AddUIEvent("click",callback(self,"OnClose"))
	self.m_LeftBtn:AddUIEvent("click",callback(self,"OnLeft"))
	self.m_RightBtn:AddUIEvent("click",callback(self,"OnRight"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonPotentialView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and self.m_CurSummonId == oCtrl.m_EventData.id then
		self:SetContent()
	end		
	if oCtrl.m_EventID == define.Summon.Event.GetSummonSecProp then 
		self:SetContent()
	end 	
end

function CSummonPotentialView.OnLeft(self)
	for k,v in pairs(self.m_Summons) do
		if v.id == self.m_CurSummonId and self.m_Summons[k-1] ~= nil then
			self.m_CurSummonId = self.m_Summons[k-1].id
			self:SetContent()
			return
		end
	end	
end

function CSummonPotentialView.OnDesBtn(self)
	local zContent = {title = "加点",desc = data.summondata.TEXT[self.m_DesId].content}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CSummonPotentialView.OnRight(self)
	for k,v in pairs(self.m_Summons) do
		if v.id == self.m_CurSummonId and self.m_Summons[k+1] ~= nil then
			self.m_CurSummonId = self.m_Summons[k+1].id
			self:SetContent()
			return
		end
	end	
end

--洗点
function CSummonPotentialView.OnReset(self)
	local summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
	if summon.grade < 10 then
		g_NotifyCtrl:FloatSummonMsg(self.m_WashPointHintId_1)
		return
	end
	if summon.type == 1 then
		g_NotifyCtrl:FloatSummonMsg(self.m_WashPointHintId_2)
		return
	end	
 	CSummonWashPointView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)		
	end)
end

function CSummonPotentialView.OnAddType(self)
	g_SummonCtrl:C2GSSummonRequestAuto(self.m_CurSummonId)
end

function CSummonPotentialView.OnOk(self)
	if self.m_TempReamin == self.data["point"] then
		return
	end 
	local scheme = {
	["physique"] = self.m_Body.add,
	["magic"] = self.m_MagicP.add,
	["strength"] = self.m_Power.add,
	["endurance"] = self.m_Stamina.add,
	["agility"] = self.m_Agility.add
	}	
	g_SummonCtrl:UpdatePoint(self.m_CurSummonId, scheme)
	for k,v in pairs(scheme) do
		v = 0
	end
end

function CSummonPotentialView.OnSub(self, item, oBtn, bPrees)
	if not bPrees then
		return
	end	

	if item.add == nil or item.add < 1 then 
		return 
	end	
	item.add = item.add - 1
	self.m_TempReamin = self.m_TempReamin + 1
	if self.data["point"] - self.m_TempReamin == 0 then 
		self.m_OkBtn:SetSpriteName(self.m_OkBtnSpr.normal)
		self.m_OkBtn:SetText("[EEFFFB]确定[-]")
		self.m_OkBtn:SetEnabled(false)
	end
	self.m_RemainPoint:SetText("剩余潜力:"..self.m_TempReamin)	
	item["green"]:SetValue(item["blue"]:GetValue()+item.add / item.maxValue)
	if item.add > 0 then
		item["addCount"]:SetActive(true)
		item["addCount"]:SetText("+"..item.add)	
	else
		item["addCount"]:SetActive(false)
	end	
	self:LAddPointShow()
end

--属性计算变量定义,定义宠物属性的计算需要用到哪些基本变量
function CSummonPotentialView.DefAttrVar(self)

	self.m_AttrVarDef = {}
	--气血
	local max_hp = {"health", "grade", "physique", "grow"}
	--法力
	local max_mp = {"grade", "magic", "strength"}
	--物攻
	local phy_attack = {"attack", "grade", "grow", "strength"}
	--物防
	local phy_defense = {"defense", "grade", "grow", "endurance"}
	--法攻
	local mag_attack = {"mana", "grade", "grow", "magic"}
	--法防
	local mag_defense = {"physique", "magic", "strength", "endurance", "grow", "grade", "mana"}
	--速度
	local speed = {"speed", "physique", "mana", "strength", "endurance", "grow", "grade", "agility", "magic"}
	self.m_AttrVarDef.max_hp = max_hp
	self.m_AttrVarDef.max_mp = max_mp
	self.m_AttrVarDef.phy_attack = phy_attack
	self.m_AttrVarDef.phy_defense = phy_defense
	self.m_AttrVarDef.mag_attack = mag_attack
	self.m_AttrVarDef.mag_defense = mag_defense
	self.m_AttrVarDef.speed = speed

end

--刷新属性数据
function CSummonPotentialView.RefreshAttrData(self)
	
	--基本属性
	self.m_AttrData = {}
	self.m_AttrData.health = self.data["curaptitude"].health
	self.m_AttrData.grade = self.data["grade"]
	self.m_AttrData.physique =  self.data["attribute"].physique + self.m_Body.add
	self.m_AttrData.grow = self.data["grow"]
	self.m_AttrData.magic = self.data["attribute"].magic + self.m_MagicP.add
	self.m_AttrData.strength = self.data["attribute"].strength + self.m_Power.add
	self.m_AttrData.defense = self.data["curaptitude"].defense
	self.m_AttrData.endurance = self.data["attribute"].endurance + self.m_Stamina.add
	self.m_AttrData.mana = self.data["curaptitude"].mana
	self.m_AttrData.speed = self.data["curaptitude"].speed
	self.m_AttrData.agility = self.data["attribute"].agility +self.m_Agility.add
	self.m_AttrData.attack = self.data["curaptitude"].attack

	self.m_AttrCalVar = {}
	for k, v in pairs(self.m_AttrVarDef) do 
		local tmp = {}
		for i, j in pairs(v) do 
			tmp[j] = self.m_AttrData[j]
		end 
		self.m_AttrCalVar[k] = tmp
	end 
	
end

--获取某个属性的计算结果
function CSummonPotentialView.GetAttrCalResult(self, attr)

	self:RefreshAttrData()
	local result = 0
	if data.summondata.calformula[attr] then 	
		local formula = data.summondata.calformula[attr].formula
		result = self:CalFormula(formula, attr)
	end 
	return result

end

--公式计算
function CSummonPotentialView.CalFormula(self, formula, attr)
	
     local val = 0
     if self.m_AttrCalVar[attr] then 
     	for k, v in pairs(self.m_AttrCalVar[attr]) do 
     		formula = string.gsub(formula, k, v)
     	end
     	local func = loadstring("return " .. formula)
     	val = func()
     end 
     return val

end

function CSummonPotentialView.CalcAttrFinalVal(self, sAttr)
	local iVal = self:GetAttrCalResult(sAttr)
	local dExtra = self.data[sAttr.."_unit"]
	if dExtra then
		iVal = (iVal + dExtra.extra)*(1 + dExtra.ratio/100)
	end
	return iVal
end

function CSummonPotentialView.LAddPointShow(self)
	local attrList = {
		{key = "max_hp", item = self.m_LifeItem},
		{key = "max_mp", item = self.m_MagicItem},
		{key = "phy_attack", item = self.m_PhyAttackItem},
		{key = "phy_defense", item = self.m_PhyDefItem},
		{key = "speed", item = self.m_SpeedItem},
		{key = "mag_attack", item = self.m_MagicAttackItem},
		{key = "mag_defense", item = self.m_MagicDefItem},
	}
	for i, dAttr in ipairs(attrList) do
		if dAttr.item then
			local sKey = dAttr.key
			local iVal = self:CalcAttrFinalVal(sKey)
			iVal = math.floor(iVal - self.data[sKey])
			local oItem = dAttr.item:NewUI(3, CLabel)
			if iVal > 0 then
				if sKey == "blood" and self.m_Body.add <= 0 then
					oItem:SetActive(false)
				else
					oItem:SetActive(true)
					oItem:SetText("+"..iVal)
				end
			else
				oItem:SetActive(false)
			end
		end
	end
	self:SetBtnsEnable()
end

function CSummonPotentialView.SetBtnsEnable(self)
	local list = {self.m_Body, self.m_MagicP, self.m_Power, self.m_Stamina, self.m_Agility}
	local addenable = true
	if self.m_TempReamin <= 0 then
		addenable = false
	end
	for k,v in pairs(list) do
		if v.add > 0 then
			v.subBtn:SetColor(Color.New(1,1,1,1))
		else
			v.subBtn:SetColor(Color.New(0,0,0,1))
		end
		if addenable then
			v.addBtn:SetColor(Color.New(1,1,1,1))
		else
			v.addBtn:SetColor(Color.New(0,0,0,1))	
		end	
	end
end

function CSummonPotentialView.OnAdd(self, item, oBtn , bPrees)
	if not bPrees then
		return
	end
	if item.add == nil or self.m_TempReamin < 1 then 
		g_NotifyCtrl:FloatSummonMsg(self.m_WashPointHintId_3)
		return
	end
	item.add = item.add + 1
	self.m_OkBtn:SetEnabled(true)
	self.m_OkBtn:SetSpriteName(self.m_OkBtnSpr.normal)
	self.m_OkBtn:SetText("[EEFFFB]确定[-]")
	self.m_TempReamin = self.m_TempReamin - 1
	item["green"]:SetValue(item["blue"]:GetValue() + item.add / item.maxValue)
	self.m_RemainPoint:SetText("剩余潜力:"..self.m_TempReamin)
	if item.add > 0 then
		item["addCount"]:SetActive(true)
		item["addCount"]:SetText("+"..item.add)	
	else
		item["addCount"]:SetActive(false)
	end
	self:LAddPointShow()
end

function CSummonPotentialView.InitItem(self, item)
	local  go = {}
	go["green"] = item:NewUI(2, CSlider)
	go["blue"] = item:NewUI(3, CSlider)
	go["orange"] = item:NewUI(4, CSlider)
	go["subBtn"] = item:NewUI(5, CButton)
	go["addBtn"] = item:NewUI(6, CButton)
	go["oldCount"] = item:NewUI(7, CLabel)
	go["addCount"] = item:NewUI(8, CLabel)
	go["thumb"] = item:NewUI(9, CSprite)
	go["thumb"]:AddUIEvent("drag", callback(self, "OnDrag", go))
	go["thumb"]:AddUIEvent("dragstart", callback(self, "OnDragStart", go))	
	go["thumb"]:AddUIEvent("dragend", callback(self, "OnDragEnd", go))	
	go["subBtn"]:AddUIEvent("repeatpress", callback(self, "OnSub", go))
	go["addBtn"]:AddUIEvent("repeatpress", callback(self, "OnAdd", go))	
	return go
end

function CSummonPotentialView.OnDrag(self, item, obj, move)
	if move.x > 0 then 
		self.m_MoveDir = "right"
	else
		self.m_MoveDir = "left"
	end
end

function CSummonPotentialView.MathRound(self, data)	
	local num,modf = math.modf(data)
	num = (modf >= 0.5 and math.ceil(data)) or math.floor(data)
	return num 
end

function CSummonPotentialView.OnDragStart(self, item)	
	self.m_ChangePoint = 0	
	local sum = 0
	for k,v in pairs(self.m_Items) do
		sum = sum + v.add
	end
	self.m_RemainPointCount = self.data["point"] - sum	
	item["green"]:SetMaxValue(item["green"]:GetValue() + self.m_RemainPointCount / item.maxValue)
	local function update()
		self:CalculateData(item)
		return true
	end
	self.m_SliderTimer = Utils.AddTimer(update, 0.1, 0)
end

function CSummonPotentialView.CalculateData(self, item)
	if self.m_MoveDir == "right" and self.m_RemainPointCount <= 0 then
		return
	end
	if self.m_MoveDir == "left" and item.add <= 0 then 
		return
	end 
	local sliderValue = item["green"]:GetValue() * item.maxValue	
	self.m_ChangePoint = self:MathRound(sliderValue - item.blueValue)	
	--self.m_ChangePoint = math.floor(sliderValue - item.blueValue)	
	if self.m_MoveDir == "right" then
		self.m_TempReamin = self.m_RemainPointCount - self.m_ChangePoint
	else
		local sum = 0
		for k,v in pairs(self.m_Items) do
			if v ~= item then
				sum = sum + v.add
			end
		end
		self.m_RemainPointCount = self.data["point"] - sum	
		self.m_TempReamin =self.m_RemainPointCount - self.m_ChangePoint
	end
	if self.m_TempReamin <= 0 then 
		self.m_TempReamin = 0
	end	
	if self.data["point"] - self.m_TempReamin <= 0 then
		self.m_TempReamin = self.data["point"]		
		--self.m_OkBtn:SetEnabled(false)
		self.m_OkBtn:SetSpriteName(self.m_OkBtnSpr.normal)
		self.m_OkBtn:SetText("[EEFFFB]确定[-]")
	else
		--self.m_OkBtn:SetEnabled(true)
		self.m_OkBtn:SetSpriteName(self.m_OkBtnSpr.press)
		self.m_OkBtn:SetText("[bd5733]确定[-]")
	end
	self.m_RemainPoint:SetText("剩余潜力:"..self.m_TempReamin)
	if self.m_ChangePoint <= 0 then 
		item["addCount"]:SetActive(false)
	else
		item["addCount"]:SetActive(true)

		item["addCount"]:SetText("+"..self.m_ChangePoint)	
	end
	if self.m_ChangePoint <= 0 then 
		item.add = 0
	else
		item.add = self.m_ChangePoint
	end
	self:LAddPointShow()
end

function CSummonPotentialView.OnDragEnd(self, item)
	if self.m_SliderTimer then
		Utils.DelTimer(self.m_SliderTimer)
		self.m_SliderTimer = nil		
	end
	self:CalculateData(item)
end

function CSummonPotentialView.OnAutoAddPoint(self)
	 if self.m_IsAuto  then
	 	g_SummonCtrl:IsOpenAutoAssign(self.m_CurSummonId, 0)
	 	self.m_IsAuto = false
		self.m_AutoAddPointBtn.isSel:SetActive(false)
	 	g_NotifyCtrl:FloatSummonMsg(self.m_WashPointHintId_4)
	 else
	 	self:OnAddType()
 	end
end

function CSummonPotentialView.SetData(self, data)
	self.m_CurSummonId = data
	self:SetContent()	
end


return CSummonPotentialView