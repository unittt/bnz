local CSummonAddPointSchemeView = class("CSummonAddPointSchemeView", CViewBase)

function CSummonAddPointSchemeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonAddPointSchemeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "scheme"
	self.m_ExtendClose = "Black"
	self.m_MaxPoint = 5
	self.m_CurPoint = 5
	self.m_AddPointHintId = 1033
end

function CSummonAddPointSchemeView.OnCreateView(self)
	-- self.m_AttackBtn = self:NewUI(1, CButton)
	-- self.m_MagicBtn = self:NewUI(2, CButton)
	-- self.m_BloodBtn = self:NewUI(3, CButton)
	self.m_CurNumber = self:NewUI(4, CLabel)
	self.m_GridItem = self:NewUI(5, CGrid)
	self.m_ClearBtn = self:NewUI(6, CButton)
	self.m_OkBtn = self:NewUI(7, CButton)
	self.m_CloseBtn = self:NewUI(8, CButton)
	self.m_PhysiqueItem = self:NewUI(9, CBox)
	self.m_MagicItem = self:NewUI(10, CBox)
	self.m_StrengthItem = self:NewUI(11, CBox)
	self.m_EnduranceItem = self:NewUI(12, CBox)
	self.m_AgilityItem = self:NewUI(13, CBox)
	self:InitData()	  
end

function CSummonAddPointSchemeView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOk"))
	-- self.m_AttackBtn:AddUIEvent("click", function()
	-- 	self:Update(1)
	-- end)
	-- self.m_MagicBtn:AddUIEvent("click", function()
	-- 	self:Update(2)
	-- end)
	-- self.m_BloodBtn:AddUIEvent("click", function()
	-- 	self:Update(3)
	-- end)
	self.m_ClearBtn:AddUIEvent("click", function()
		self.m_CurPoint = 0
		self:RefreshTitleL()
		self:Update(4)
	end)
	self:InitGrid()
end

function CSummonAddPointSchemeView.Update(self,type)
	local itemList = {	self.m_PhysiqueItem,
						self.m_MagicItem,
						self.m_StrengthItem,
						self.m_EnduranceItem,
						self.m_AgilityItem
					 }
	for i = 1,#itemList do
    	itemList[i].count = self.m_SchemeData[type][i]
    	local text = itemList[i]:NewUI(2,CLabel)
		text:SetText(itemList[i].count)
    end
end

function CSummonAddPointSchemeView.InitGrid(self)
   local scheme = { ["physique"] = self.m_PhysiqueItem,
   					["magic"] = self.m_MagicItem,
					["strength"] = self.m_StrengthItem,
   					["endurance"] = self.m_EnduranceItem,
   					["agility"] = self.m_AgilityItem
				  }
	self.m_BtnList = {}
   for k,v in pairs(scheme) do
    	local sub = v:NewUI(1, CButton)
		sub:AddUIEvent("click", callback(self, "OnSub", v))	
		if self.m_CurScheme[k] ~= nil then 
    		v.count = self.m_CurScheme[k]
		else
			v.count = 0
		end   	
    	v.text = v:NewUI(2,CLabel)
    	v.text:SetText(v.count)    	
    	local btn = v:NewUI(3, CButton)
		btn:AddUIEvent("click", callback(self, "OnAdd", v))
		table.insert(self.m_BtnList, sub)
		table.insert(self.m_BtnList, btn)
    end
end

function CSummonAddPointSchemeView.OnSub(self,item)
	if item.count <= 0 then 
		return
	end
	item.count = item.count - 1
	self.m_CurPoint = self.m_CurPoint - 1
	self:RefreshTitleL()
    item.text:SetText(item.count)
end

function CSummonAddPointSchemeView.OnAdd(self,item)
	if self.m_CurPoint >= self.m_MaxPoint then 
		g_NotifyCtrl:FloatMsg("已分配满"..self.m_MaxPoint.."点")
		return
	end
	item.count = item.count + 1
	self.m_CurPoint = self.m_CurPoint + 1
	self:RefreshTitleL()
    item.text:SetText(item.count)
end

function CSummonAddPointSchemeView.InitData(self)
	local  attack = data.summondata.POINTDATA[1]
	local  magic = data.summondata.POINTDATA[2]
	local  blood = data.summondata.POINTDATA[3]
	self.m_SchemeData = {
	[1] = {attack.physique, attack.magic, attack.strength, attack.endurance, attack.agility},
	[2] = {magic.physique, magic.magic, magic.strength, magic.endurance, magic.agility},
	[3] = {blood.physique, blood.magic, blood.strength, blood.endurance, blood.agility},
	[4] = {0, 0, 0, 0, 0},
	}
	self:RefreshTitleL()
end

function CSummonAddPointSchemeView.RefreshTitleL(self)
	if self.m_CurPoint > 0 then
		self.m_CurNumber:SetText(string.format("[1d8e00ff]已分配点数%d/%d", self.m_CurPoint, self.m_MaxPoint))
	else
		self.m_CurNumber:SetText("[244b4eff]未分配潜力点")
	end
end

function CSummonAddPointSchemeView.SetData(self, id, scheme)
	self.m_CurSummonId = id
	self.m_CurScheme = scheme	
	self:InitContent()
end

function CSummonAddPointSchemeView.OnOk(self)
	local scheme = {
	["physique"] = self.m_PhysiqueItem.count,
	["magic"] = self.m_MagicItem.count,
	["strength"] = self.m_StrengthItem.count,
	["endurance"] = self.m_EnduranceItem.count,
	["agility"] = self.m_AgilityItem.count
	}	
	if self.m_CurPoint < self.m_MaxPoint then 
		g_NotifyCtrl:FloatSummonMsg(self.m_AddPointHintId)
		return
	end	
	g_SummonCtrl:UpdateScheme(self.m_CurSummonId, scheme)		
	self:OnClose()
end

return CSummonAddPointSchemeView