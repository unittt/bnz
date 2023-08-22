local COrgPalaceView = class("COrgPalaceView", CViewBase)

function COrgPalaceView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgPalaceView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main2"
    self.m_ExtendClose = "ClickOut"
end

function COrgPalaceView.OnCreateView(self)
    self.m_BuildTexture = self:NewUI(1, CTexture)
    self.m_BuildName = self:NewUI(2, CLabel)
    self.m_BuildGrade = self:NewUI(3, CLabel)
    self.m_DesLabel = self:NewUI(4, CLabel)
end

function COrgPalaceView.InitContent(self, buildInfo)
    local info = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level]
    if info == nil then 
        info = data.orgdata.BUILDLEVEL[buildInfo.bid][1]
    end 
    self.m_BuildTexture:SetChangeMainTexture("Org", info.texture)
    self.m_BuildName:SetText(info.name)
    -- self.m_BuildGrade:SetText(buildInfo.level.."/"..#data.orgdata.BUILDLEVEL[buildInfo.bid])
    self.m_BuildGrade:SetText(buildInfo.level.."级")
    self.m_DesLabel:SetText(info.updes)
end

return COrgPalaceView