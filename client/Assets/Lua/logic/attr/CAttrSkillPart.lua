local CAttrSkillPart = class("CAttrSkillPart", CPageBase)
function CAttrSkillPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CAttrSkillPart.OnInitPage(self)
    self.m_SkillLeftBox = self:NewUI(1, CAttrSkillLeftBox)
    self.m_SkillRightBox = self:NewUI(2, CAttrSkillRightBox)
    self:InitContent()
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CAttrSkillPart.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.UpdateOrgSkills then
        self:InitContent()
    end
end

function CAttrSkillPart.InitContent(self)
    self.m_SkillLeftBox:SetInfo(g_AttrCtrl.org_skill, function (v)
        self.m_SkillRightBox:SetCallBack(v)
    end)
    --self.m_SkillRightBox:SetInfo()
end

function CAttrSkillPart.JumpToSkillByItem(self, iItemid, skillid)
    self.m_SkillLeftBox:JumpToSkillByItem(iItemid, skillid)
end

return CAttrSkillPart