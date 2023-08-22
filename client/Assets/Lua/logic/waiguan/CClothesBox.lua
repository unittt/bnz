local CClothesBox = class("CClothesBox", CBox)

function CClothesBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Lock = self:NewUI(2, CSprite)
	self.m_Time = self:NewUI(3, CLabel)
	
end

function CClothesBox.SetInfo(self, info)

	if info.isDefaultSz then 
		self.m_Icon:SetSpriteName(info.icon)
		self.m_Icon:MakePixelPerfect()
		self.m_Lock:SetActive(false)
		self.m_Time:SetActive(false)
	else
		self.m_SzId = info.szId

		self.m_Icon:SetSpriteName(info.icon)
		self.m_Icon:MakePixelPerfect()

		self.m_Lock:SetActive(not info.isUnLock)

		if info.isForever == 1 then 
			self.m_Time:SetActive(false)
			if self.m_Timer then 
				Utils.DelTimer(self.m_Timer)
				self.m_Timer = nil
			end 
		else

			if info.isUnLock then 

				self.m_interval = info.time - g_TimeCtrl:GetTimeS()

				local refreshTime = function ()

					if Utils.IsNil(self) then 
						self.m_Timer = nil
						return false
					end 
					
					self.m_interval = self.m_interval - 1

					if self.m_interval > 0 then 
						local timeText = g_TimeCtrl:GetLeftTimeDHMAlone(self.m_interval)
						self.m_Time:SetText(timeText)
						self.m_Time:SetActive(true)
						return true
					else
						self.m_Time:SetText("过期")
						self.m_Timer = nil
						return false
					end 

				end

				if not self.m_Timer then 
					self.m_Timer = Utils.AddTimer(refreshTime, 1, 0)
				end 

			else
				self.m_Time:SetActive(false)
			end 

		end 
	end 
   
end

return CClothesBox