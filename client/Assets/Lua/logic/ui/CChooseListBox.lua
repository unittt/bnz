local CChooseListBox = class("CChooseListBox", CBox)

function CChooseListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_SchoolBoxClone = self:NewUI(2, CBox)
	self.m_SchoolBoxClone:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
end

function CChooseListBox.SetCallback(self, cb)
	self.m_cb = cb
end

function CChooseListBox.SetChooseData(self, dData)
	self.m_ChooseData = dData
	self:InitGrid()
end

function CChooseListBox.InitGrid(self)
	self.m_Grid:Clear()
	for i,dData in ipairs(self.m_ChooseData) do
		local oBox = self:CreateBox(dData)
		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
	self:ResetBG()
end

function CChooseListBox.CreateBox(self, dData)
	local oBox = self.m_SchoolBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox:SetActive(true)
	oBox.m_IconSpr:SetActive(dData.icon ~= nil)
	oBox.m_NameL:SetText(dData.name)
	oBox.m_Index = dData.index
	if dData.icon ~= nil then
		oBox.m_IconSpr:SpriteSchool(dData.icon)
	else	
		local oPos = oBox.m_NameL:GetLocalPos()
		oPos.x = 25
		oBox.m_NameL:SetLocalPos(oPos)
	end 
	oBox:AddUIEvent("click", callback(self, "OnClickBox"))
	return oBox
end

function CChooseListBox.ResetBG(self)
	local _,iCellH = self.m_Grid:GetCellSize()
	local iCount = self.m_Grid:GetCount()
	local iWidth,iHeight = self:GetSize()
	iHeight = iCellH*math.ceil(iCount/3) + 20
	self:SetSize(iWidth, iHeight)
end

function CChooseListBox.OnClickBox(self, oBox)
	local m_Index = oBox.m_Index
	printc("切换选择",m_Index)
	if self.m_cb then
		self.m_cb(m_Index)
	end
	self:SetActive(false)
end

return CChooseListBox