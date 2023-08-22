local CJieBaiDeclarationText = class("CJieBaiDeclarationText", CBox)

function CJieBaiDeclarationText.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Des = self:NewUI(2, CLabel)

    self.m_IsInAni = false

end

function CJieBaiDeclarationText.SetText(self, tex)
	
	self.m_Des:SetText(tex)
	self:SetActive(false)

end

function CJieBaiDeclarationText.Show(self, cb)

	self:SetActive(true)
	self.m_IsInAni = true
	local typetween = self.m_Des:GetComponent(classtype.TypewriterEffect)
	typetween.enabled = true
	typetween.charsPerSecond = 3
	typetween:ResetToBeginning()
	typetween.onFinished = function ()
		if cb then 
			self.m_IsInAni = true
			cb()
		end 
	end

end

function CJieBaiDeclarationText.IsInAni(self)
	
	return self.m_IsInAni

end

return CJieBaiDeclarationText