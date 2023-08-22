local CHudLabel = class("CHudLabel", CObject)

function CHudLabel.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_LabelHud = obj:GetComponent(classtype.UILabelHUD)
end

function CHudLabel.SetText(self, sText)
	self.m_LabelHud.text = sText
end

function CHudLabel.GetText(self)
	return self.m_LabelHud.text
end

function CHudLabel.InitEmoji(self)
	if not self.m_EmojiController then
		self.m_EmojiController = self:GetMissingComponent(classtype.EmojiAnimationController)
	end
end

function CHudLabel.SetFontSize(self, iSize)
	self.m_LabelHud.fontSize = iSize
end

function CHudLabel.SetRichText(self, sText)
	sText = sText or ""
	self:InitEmoji()
	self.m_EmojiController:SetEmojiText(sText)
end

function CHudLabel.SetEffectStyle(self, iStyle)
	self.m_LabelHud.effectStyle = iStyle
end

function CHudLabel.SetEffectDistance(self, v2)
	self.m_LabelHud.effectDistance = v2 or Vector2.one
end

function CHudLabel.SetEffectColor(self, color)
	self.m_LabelHud.effectColor = color
end

function CHudLabel.Destroy(self)
	if self.m_LabelHud then
		self.m_LabelHud = nil
	end
	if self.m_EmojiController then
		self.m_EmojiController = nil
	end
	CObject.Destroy(self)
end

return CHudLabel
