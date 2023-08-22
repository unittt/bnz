local CWarriorTouchHud = class("CWarriorTouchHud", CAsynHud)

function CWarriorTouchHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorTouchHud.prefab", cb)
end

function CWarriorTouchHud.OnCreateHud(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Widget:AddUIEvent("click", callback(self, "OnClick"))
	self.m_Widget:AddUIEvent("longpress", callback(self, "OnShowBuffDetail"))
end

function CWarriorTouchHud.SetWarrior(self, oWarrior)
	self.m_WarriorRef = weakref(oWarrior)
end

function CWarriorTouchHud.GetWarrior(self)
	return getrefobj(self.m_WarriorRef)
end

function CWarriorTouchHud.OnClick(self)
	local oWarrior = self:GetWarrior()
	if oWarrior then
		if oWarrior:IsOrderTarget() then
			g_WarOrderCtrl:SetTargetID(oWarrior.m_ID)
		end
	end
end

function CWarriorTouchHud.OnShowBuffDetail(self)
	-- local oWarrior = self:GetWarrior()
	-- if not oWarrior then
	-- 	return
	-- end
	-- CWarTargetDetailView:ShowView(function(oView) 
	-- 		oView:SetWarrior(oWarrior)
	-- 	end)
end

return CWarriorTouchHud