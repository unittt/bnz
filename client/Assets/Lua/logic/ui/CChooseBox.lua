local CChooseBox = class("CChooseBox", CBox)

function CChooseBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_LeftBtn = self:NewUI(1, CButton)
	self.m_RightBtn = self:NewUI(2, CButton)
	self.m_NameL = self:NewUI(3, CLabel)
	self.m_SchoolSpr = self:NewUI(4, CSprite)	
	self.m_ChooseListBox = self:NewUI(5, CChooseListBox)

	self.m_CurChoose = 1
	self:InitContent()
end

function CChooseBox.SetCallback(self, cb)
	self.m_cb = cb
end

function CChooseBox.SetChooseData(self, tData, iIndex)
	self.m_ChooseData = tData
	self.m_CurChoose = iIndex ~= nil and iIndex or 1
	self.m_ChooseCount = #tData
	self:ChangeChoose(0)
end

function CChooseBox.InitContent(self)
	self.m_ChooseListBox:SetActive(false)
	self:AddUIEvent("click", callback(self, "ShowChooseListBox"))
	self.m_LeftBtn:AddUIEvent("click", callback(self, "ChangeChoose", -1))
	self.m_RightBtn:AddUIEvent("click", callback(self, "ChangeChoose", 1))
end

function CChooseBox.ShowChooseListBox(self)
	local oBox = self.m_ChooseListBox 
	oBox:SetActive(true)
	oBox:SetChooseData(self.m_ChooseData)
	oBox:SetCallback(callback(self, "JumpToTarget"))
end

function CChooseBox.HideChooseListBox(self)
	self.m_ChooseListBox:SetActive(false)
end

function CChooseBox.ChangeChoose(self, iChangeValue)
	self.m_CurChoose = (self.m_CurChoose + iChangeValue)%(self.m_ChooseCount + 1)
	self.m_CurChoose = (self.m_CurChoose == 0 and iChangeValue < 0 ) and self.m_ChooseCount or math.max(1, self.m_CurChoose)
	
	local dData = self.m_ChooseData[self.m_CurChoose]
	local vPos = self.m_NameL:GetLocalPos()
	self.m_NameL:SetText(dData.name)
	if dData.icon then
		vPos.x = -17.4
		self.m_SchoolSpr:SpriteSchool(dData.icon)
	else
		vPos.x = -44
	end
	self.m_NameL:SetLocalPos(vPos)
	self.m_SchoolSpr:SetActive(dData.icon ~= nil)
	if self.m_cb then
		self.m_cb(self.m_CurChoose)
	end
end

function CChooseBox.JumpToTarget(self, iIndex)
	local iChangeValue = iIndex - self.m_CurChoose
	self:ChangeChoose(iChangeValue)
end

return CChooseBox