local CBonfireAnswerBox = class("CBonfireAnswerBox", CBox)

function CBonfireAnswerBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Answer = self:NewUI(2, CLabel)
end

function CBonfireAnswerBox.SetText(self, text)
    self.m_Answer:SetText(text)
end

function CBonfireAnswerBox.SetInfo(self, info)
    self.m_Icon:SetActive(true)
    if info then
        self.m_Icon:SetSpriteName("h7_gougou_1")
    else
        self.m_Icon:SetSpriteName("h7_chacha_1")
    end
end

function CBonfireAnswerBox.NoShowIcon(self)
    self.m_Icon:SetActive(false)
end

return CBonfireAnswerBox