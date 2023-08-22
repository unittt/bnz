local CAttrSkillMakePart = class("CAttrSkillMakePart", CViewBase)
function CAttrSkillMakePart.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/MakeDragView.prefab", cb)
    --self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CAttrSkillMakePart.OnCreateView(self)
    printc("---初始化炼药界面--")
    self.m_SkillLeftBox = self:NewUI(1, CAttrSkillMakeLeftBox)
    self.m_SkillRightBox = self:NewUI(2, CAttrSkillMakeRightBox)
    self.m_CloseBtn = self:NewUI(3, CButton)
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent")) 
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CAttrSkillMakePart.OnAttrEvent(self, oCtrl)

end

function CAttrSkillMakePart.InitContent(self, skill)
    self.m_SkillLeftBox:SetInfo(skill, function (v)
        return self.m_SkillRightBox:SetInfo(v)
    end)
    self.m_SkillRightBox:InitContent(skill)
end

return CAttrSkillMakePart