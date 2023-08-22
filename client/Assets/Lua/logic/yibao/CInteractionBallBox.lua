local CInteractionBallBox = class("CInteractionBallBox", CBox)

function CInteractionBallBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_BallTitleLbl = self:NewUI(1, CLabel)
	self.m_BallIcon = self:NewUI(2, CSprite)
	self.m_BallCountLbl = self:NewUI(3, CLabel)
	self.m_BallClone = self:NewUI(4, CSprite)
	self.m_SkyWidget = self:NewUI(5, CWidget)
	self.m_RiverWidget = self:NewUI(6, CWidget)
	self.m_BallBg = self:NewUI(7, CSprite)
end

function CInteractionBallBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

return CInteractionBallBox