local CGuideFocusTipBox = class("CGuideFocusTipBox", CBox)

function CGuideFocusTipBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_FocusSpr = self:NewUI(1, CSprite)
	self.m_TopSpr = self:NewUI(2, CSprite)
	self.m_BottomSpr = self:NewUI(3, CSprite)
	self.m_LeftSpr = self:NewUI(4, CSprite)
	self.m_RightSpr = self:NewUI(5, CSprite)
	self.m_CoverTexture = self:NewUI(6, CTexture)
	self.m_Collider = self:NewUI(7, CObject)
	self.m_Collider:SetActive(false)
	-- self.m_FocusSpr:SetActive(false)
	self.m_Mat = self.m_CoverTexture:GetMaterial()
	self.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 1, 1))
	self:SimulateOnEnable()
	g_GuideCtrl:AddGuideUI("guide_focus_spr",self.m_FocusSpr)

	self.m_TopSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_BottomSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_LeftSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_RightSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
end

function CGuideFocusTipBox.SetFocusCommon(self, x, y, w, h)
	local rootw, rooth = UITools.GetRootSize()
	self.m_Mat:SetVector("_SkipRange", Vector4.New(x, y, w, h))
	self.m_FocusSpr:SetPos(g_GuideCtrl:View2WorldPos(x, y))
	self.m_FocusSpr:SetSize(w*rootw*2, h*rooth*2)
	self:SimulateOnEnable()
	self.m_Collider:SetActive(true)
end

function CGuideFocusTipBox.SetEffect(self, sEffect, isParticle, offsetpos, rotate)
	if sEffect then
		if isParticle then
			self.m_FocusSpr:AddEffect(sEffect, nil, (offsetpos and {Vector2.New(offsetpos.x, offsetpos.y)} or {nil})[1], rotate or 0)
		else
			self.m_FocusSpr:AddEffect(sEffect)
		end
	else
		self.m_FocusSpr:ClearEffect()
	end
end

function CGuideFocusTipBox.Black(self)
	self.m_Mat:SetVector("_SkipRange", Vector4.zero)
	self:SimulateOnEnable()
	self.m_FocusSpr:ClearEffect()
	self.m_Collider:SetActive(false)
end

return CGuideFocusTipBox