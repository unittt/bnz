local CGuideOpenBox = class("CGuideOpenBox", CBox)

function CGuideOpenBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Sprite = self:NewUI(1, CSprite)
	self.m_OpenLabel = self:NewUI(2, CLabel)
	self.m_HideWidget = self:NewUI(3, CWidget)
	self.m_OriginPos = self.m_Sprite:GetPos()
end

function CGuideOpenBox.SetOpen(self, sSpriteName, sOpen, oUI)
	self.m_Sprite:SetPos(self.m_OriginPos)
	self.m_Sprite:SetSpriteName(sSpriteName)
	self.m_OpenLabel:SetText(sOpen)
	self.m_HideWidget:SetActive(true)
	local time = 0.5
	if oUI then
		local function anim()
			if Utils.IsExist(self) then 
				self.m_HideWidget:SetActive(false)
				local tween = DOTween.DOMove(self.m_Sprite.m_Transform, oUI:GetPos(), 1)
			end

		end
		Utils.AddTimer(anim, 1, 1)
		time = time + 1.5
	end
	local function compelte()
		if Utils.IsExist(self) then 
			g_GuideCtrl:Continue()
		end
	end
	Utils.AddTimer(compelte, time, time)
end

return CGuideOpenBox