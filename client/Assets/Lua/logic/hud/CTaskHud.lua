local CTaskHud = class("CTaskHud", CAsynHud)

function CTaskHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/TaskHud.prefab", cb)
	self.m_Effects = {}
end

function CTaskHud.OnCreateHud(self)
	self.m_TaskSpr = self:NewUI(1, CSprite)
end

function CTaskHud.SetTaskMark(self, spriteName)
	self:DelEffect("TaskAcceptMark")
	self:DelEffect("TaskDoneMark")
	self:DelEffect("TaskNotDoneMark")
	if spriteName == CTaskCtrl.g_NpcMarkSprName[1] then
		self.m_TaskSpr:SetSpriteName("spriteName")
		self.m_TaskSpr:SetSize(14, 44)		
		self:AddEffect("TaskAcceptMark", Vector3.New(125, 125, 125))
	elseif spriteName == CTaskCtrl.g_NpcMarkSprName[2] then
		self.m_TaskSpr:SetSpriteName("spriteName")
		self.m_TaskSpr:SetSize(14, 57)
		self:AddEffect("TaskNotDoneMark", Vector3.New(125, 125, 125))
	elseif spriteName == CTaskCtrl.g_NpcMarkSprName[3] then
		self.m_TaskSpr:SetSpriteName("spriteName")
		self.m_TaskSpr:SetSize(14, 57)
		self:AddEffect("TaskDoneMark", Vector3.New(125, 125, 125))
	else
		self.m_TaskSpr:SetSpriteName(spriteName)
	end
	self.m_TaskSpr:MakePixelPerfect()
end

function CTaskHud.AddEffect(self, sType, ...)
	if self.m_Effects[sType] then
		return self.m_Effects[sType]
	end
	local oEff = g_EffectCtrl:CreateUIEffect(sType, self,...)
	oEff:SetParent(self.m_Transform)
	self.m_Effects[sType] = oEff
	return oEff
end

function CTaskHud.DelEffect(self, sType)
	local oEff = self.m_Effects[sType]
	if oEff then
		oEff:Destroy()
		self.m_Effects[sType] = nil
	end
end

function CTaskHud.ClearEffect(self)
	for sType, oEffect in pairs(self.m_Effects) do
		self:DelEffect(sType)
	end
	self.m_Effects = {}
end

function CTaskHud.Destroy(self)
	self:ClearEffect()
	CAsynHud.Destroy(self)
end

return CTaskHud