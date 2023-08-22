local CTestViewNew = class("CTestViewNew", CViewBase)

CTestViewNew.GROUP_NAME = 'Test'

function CTestViewNew.ctor(self)
	CViewBase.ctor(self, "UI/TestView2.prefab")
end

function CTestViewNew.OnCreateView(self)
	self.m_CloseBtn = self:GetButton(1)
	self:InitContent()
end

function CTestViewNew.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CTestViewNew.OnClose(self, obj)
	self:Close()
end
return CTestViewNew