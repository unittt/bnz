local CButton = class("CButton", CSprite)

function CButton.ctor(self, obj, bScale)
	CSprite.ctor(self, obj)
	self.m_ChildLabel = nil
	self.m_UIButton = self:GetComponent(classtype.UIButton)
	if bScale ~= false then
		self:InitButtonScale()
	end

	if self:IsLabelInChild() then
		self.m_RecordColor = self.m_ChildLabel:GetColor()
	end
	self.m_RecordSpName = self.m_UIButton.normalSprite
end

function CButton.SetGrey(self, bGrey)
	if bGrey then
		self.m_UIButton.tweenTarget = nil
	end
	CSprite.SetGrey(self, bGrey)
end

--只适用于普通的按钮变灰，就是矩形的那种按钮，第2个参数可不填，用于指定某个正常状态下的图片
function CButton.SetBtnGrey(self, bGrey, sNormalName)
	if bGrey then
		if self:IsLabelInChild() then
			self.m_ChildLabel:SetColor(Color.RGBAToColor("5C6163FF"))
		end
		self:SetSpriteName("h7_an_5")
	else
		
		if not sNormalName then
			if self:IsLabelInChild() then
				self.m_ChildLabel:SetColor(self.m_RecordColor)
			end
			self:SetSpriteName(self.m_RecordSpName)			
		else
			if self:IsLabelInChild() then
				self.m_ChildLabel:SetColor(Color.RGBAToColor("C8FFF1FF"))
			end
			self:SetSpriteName(sNormalName)
		end
	end
end

function CButton.InitButtonScale(self)
	if self.m_UIButton then
		self.m_ButtonScale = self:GetMissingComponent(classtype.UIButtonScale)
	end
end

function CButton.SetSpriteName(self, sSpriteName)
	if self.m_UIButton then
		self.m_UIButton.normalSprite = sSpriteName
	end
	CSprite.SetSpriteName(self, sSpriteName)
end

function CButton.SetEnabled(self,flag)
	self.m_UIButton.isEnabled = flag
end

function CButton.IsLabelInChild(self)
	if not self.m_ChildLabel then
		local mLabel = self:GetComponentInChildren(classtype.UILabel)
		if mLabel then
			self.m_ChildLabel = CLabel.New(mLabel.gameObject)
		end
	end
	return self.m_ChildLabel ~= nil
end

function CButton.SetText(self, sText, bChild)
	sText = sText or ""
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetText(sText)
	end
	if bChild then
		local sublist = self.m_GameObject:GetComponentsInChildren(classtype.UILabel)
		for i = 1, sublist.Length do
			sublist[i-1].text = sText
		end
	end
end

function CButton.GetText(self)
	if self:IsLabelInChild() then
		return self.m_ChildLabel:GetText()
	end
end

function CButton.GetTextColor(self)
	if self:IsLabelInChild() then
		return self.m_ChildLabel:GetColor()
	end
end

function CButton.SetTextColor(self, color)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetColor(color)
	end
end

function CButton.SetEffectColor(self, color)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetEffectColor(color)
	end
end

function CButton.SetLabelLocalPos(self, pos)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetLocalPos(pos)
	end
end

function CButton.SetLabelSpacingX(self, iSpacingX)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetSpacingX(iSpacingX)
	end
end

function CButton.SetLabelSpacingY(self, iSpacingY)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetSpacingY(iSpacingY)
	end
end

return CButton