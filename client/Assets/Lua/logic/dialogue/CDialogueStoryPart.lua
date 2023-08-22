local CDialogueStoryPart = class("CDialogueStoryPart", CPageBase)

function CDialogueStoryPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_closeCB = nil
	self.m_DialogData = nil
	self.m_DialogIdx = 1
end

function CDialogueStoryPart.OnInitPage(self)
	self.m_BottomSpr = self:NewUI(1, CSprite)
	self.m_NpcNameSpr = self:NewUI(2, CSprite)
	self.m_NpcNameLabel = self:NewUI(3, CLabel)
	self.m_NpcFaceTexture = self:NewUI(4, CTexture)
	self.m_MsgLabel = self:NewUI(5, CLabel)
end

function CDialogueNormalPart.SetMsgContent(self, pMsg)
	
end

return CDialogueStoryPart