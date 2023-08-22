local CFloatAudioBox = class("CFloatAudioBox", CBox)

function CFloatAudioBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_FloatLabel = self:NewUI(1, CLabel)
end

function CFloatAudioBox.SetMaxWidth(self, w)
	self.m_FloatLabel:SetOverflowWidth(w)
end

function CFloatAudioBox.ShowView(self)
	local tween = self:GetComponent(classtype.TweenAlpha)
	tween:ResetToBeginning()
	tween.from = 1
	tween.to = 0
	tween.delay = 0.5
	tween.duration = 1
	tween:Play(true)
end

function CFloatAudioBox.SetText(self, sText)
	self.m_FloatLabel:SetRichText(sText)
end

return CFloatAudioBox