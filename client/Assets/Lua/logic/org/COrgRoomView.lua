local COrgRoomView = class("COrgRoomView", CViewBase)

function COrgRoomView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgRoomView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main2"
    self.m_ExtendClose = "ClickOut"
end

function COrgRoomView.OnCreateView(self)
    self:InitContent()
end

function COrgRoomView.InitContent(self)
end

return COrgRoomView