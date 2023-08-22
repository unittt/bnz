local CSourcePartnerBox = class("CSourcePartnerBox", CBox)

function CSourcePartnerBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_CTable = self:NewUI(2, CTable)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_Btn = self:NewUI(4, CButton)
	self:InitContent()
end

function CSourcePartnerBox.InitContent(self)
	-- body
	local parnterinfo = data.sourcebookdata.PARTNERBOOK
	self.m_CTable:Clear()
	for i,v  in ipairs(parnterinfo) do
		local  box  = nil
		box = self.m_BoxClone:Clone()
		box:SetActive(true)
		self.m_CTable:AddChild(box)
		box.title = box:NewUI(1, CLabel)
		box.des = box:NewUI(2, CLabel)
		box.title:SetText(v.title)
		box.des:SetText(v.des)
	end
	self.m_CTable:Reposition()
	self.m_ScrollView:ResetPosition()
	self.m_Btn:AddUIEvent("click", callback(self, "OnJumpToView"))
end

function CSourcePartnerBox.OnJumpToView(self)
	-- body
	CPartnerMainView:ShowView()
end

return CSourcePartnerBox