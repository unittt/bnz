local CAttrPlanItemBox = class("CAttrPlanItemBox", CBox)

function CAttrPlanItemBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NowPointLabel = self:NewUI(1, CLabel)
	self.m_AddPointLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_Index = 0
	self.m_NowPoint = 0
	self.m_AddPoint = 0
	self.m_PlayerPlaneItemName = {"生命", "法力", "物攻", "法攻", "物防", "法防", "速度"}
	self.m_IndexList = {hp = 1, mp = 2, phy_attack = 3, mag_attack = 4, phy_defense = 5, mag_defense = 6, speed = 7}
	self.m_CData = data.rolepointdata.INIT
end

function CAttrPlanItemBox.SetInfo(self, text)
	self.m_NowPointLabel:SetText(math.floor(text))
	self:RefreshAddLabel(self.m_AddPoint)
end

function CAttrPlanItemBox.RefreshAddLabel(self, addpoint)
	addpoint = tonumber(string.format("%.1f",addpoint))
	if addpoint >= 1.0 then
		self.m_AddPointLabel:SetText("+"..math.floor(addpoint))
		self.m_AddPointLabel:SetActive(true)
	else
		self.m_AddPointLabel:SetActive(false)
	end
end

--切换方案时清空数据缓存
function CAttrPlanItemBox.DelateData(self)
	self.m_Index = 0
	self.m_AddPoint = 0
	self.m_NowPoint = 0
end

function CAttrPlanItemBox.MathRound(self, data)	
	local num,modf = math.modf(data)
	num = (modf >= 0.99 and math.ceil(num)) or math.floor(num)
	-- local num = data * 100
	-- num = (num % 1 >= 0.5 and math.ceil(num/100)) or math.floor(num/100)
	return num 
end

return CAttrPlanItemBox