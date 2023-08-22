local CWarriorSelectHud = class("CWarriorSelectHud", CAsynHud)

function CWarriorSelectHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorSelectHud.prefab", cb)
end

function CWarriorSelectHud.OnCreateHud(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Widget:AddUIEvent("click", callback(self, "OnClick"))
	self.m_Widget:AddUIEvent("longpress", callback(self, "OnShowBuffDetail"))
	self:SetLocalScale(Vector3.one*1.3)
end

function CWarriorSelectHud.SetWarrior(self, oWarrior, showSprite)
	self.m_Widget:SetActive(showSprite)
	self.m_WarriorRef = weakref(oWarrior)
end

function CWarriorSelectHud.GetWarrior(self)
	return getrefobj(self.m_WarriorRef)
end

function CWarriorSelectHud.OnClick(self)
	local oWarrior = self:GetWarrior()
	if oWarrior then
		if oWarrior:IsOrderTarget() then
			g_WarOrderCtrl:SetTargetID(oWarrior.m_ID)
		end
	end
end

function CWarriorSelectHud.OnShowBuffDetail(self)
	local oWarrior = self:GetWarrior()
	if oWarrior then
		CWarTargetDetailView:ShowView(function(oView)
			oView:SetWarrior(oWarrior)
		end)
	end
end

return CWarriorSelectHud