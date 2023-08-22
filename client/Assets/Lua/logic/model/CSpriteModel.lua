local CSpriteModel = class("CSpriteModel", CModelBase, CGameObjContainer)

function CSpriteModel.ctor(self, obj)

	CModelBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self:CheckState()

end

function CSpriteModel.CheckState(self)
	
	local fun = function ()

		if Utils.IsNil(self) then 
			return false
		end 

		if g_WarCtrl:IsWar() then 
			return false
		end 

		if not self.m_CurQiLingState then 
			self.m_CurQiLingState = "idleCity"
		end 
		if self.m_CurQiLingState == "idleCity" then 
			self.m_CurQiLingState = "show"
		elseif  self.m_CurQiLingState == "show" then 
			 self.m_CurQiLingState = "idleCity"
		end 
		if not self.m_IsWalking then 
			self:CrossFade(self.m_CurQiLingState)
		end 
		return true
	end

	if not self.m_QiLingTimer then 
		self.m_QiLingTimer = Utils.AddTimer(fun, 2, 1)
	end 

end

function CSpriteModel.SetWalkingState(self, isWalking)
	
	self.m_IsWalking = isWalking

end

return CSpriteModel