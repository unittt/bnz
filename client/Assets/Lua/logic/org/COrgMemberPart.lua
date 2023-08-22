local COrgMemberPart = class("COrgMemberPart", CPageBase)

function COrgMemberPart.ctor(self, cb)
    CPageBase.ctor(self, cb)
end

function COrgMemberPart.OnInitPage(self)
	self.m_MemberBtn        = self:NewUI(1, CButton)
	self.m_ApplyBtn         = self:NewUI(2, CButton)
	self.m_MemberListBox    = self:NewUI(3, COrgMemberListBox)
	self.m_ApplyListBox     = self:NewUI(4, COrgApplyListBox)
    self.m_ApplyBtnRedPoint = self:NewUI(5, CSprite)
	self:InitContent()
	self.m_IsFirstRequest = true
end

function COrgMemberPart.InitContent(self)
	self.m_MemberBtn:AddUIEvent("click", callback(self, "ShowMemberList"))
	self.m_ApplyBtn:AddUIEvent("click", callback(self, "ShowApplyList"))
	self:ShowMemberList()
	self:RefreshJoinApplyRedPoint()
end

function COrgMemberPart.OnShowPage(self)
	if self.m_IsFirstRequest then
		self.m_IsFirstRequest = false
		return
	end
	if self.m_MemberBtn:GetSelected() then
		netorg.C2GSOrgMemberList()
	else
		netorg.C2GSOrgApplyJoinList()
	end
end

function COrgMemberPart.ShowMemberList(self)
	netorg.C2GSOrgMemberList()	
	self.m_MemberBtn:SetSelected(true)
	self.m_MemberListBox:SetActive(true)
	self.m_ApplyListBox:SetActive(false)
end

function COrgMemberPart.ShowApplyList(self)
	netorg.C2GSOrgApplyJoinList()
	self.m_ApplyBtn:SetSelected(true)
	self.m_MemberBtn:SetSelected(false)
	self.m_MemberListBox:SetActive(false)
	self.m_ApplyListBox:SetActive(true)
end

function COrgMemberPart.RefreshJoinApplyRedPoint(self)
    local showRedPoint = (g_OrgCtrl.m_LoginOrgRedPontInfo.has_apply == 1)
    self.m_ParentView.m_MemberRedPoint:SetActive(showRedPoint)
    if self.m_ApplyBtnRedPoint then
	    self.m_ApplyBtnRedPoint:SetActive(showRedPoint)
	end
end

return COrgMemberPart