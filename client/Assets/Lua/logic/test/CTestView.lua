local CTestView = class("CTestView", CViewBase)

function CTestView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TestView.prefab", cb)
end

function CTestView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, Button)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnGrid:InitChild(function (obj, idx) return CButton.New(obj) end)
	
	self.m_Page1Btn = self.m_BtnGrid:GetChild(1)
	self.m_Page2Btn = self.m_BtnGrid:GetChild(2)
	self.m_Page1Btn:AddUIEvent("click", callback(self, "ShowPage1"))
	self.m_Page2Btn:AddUIEvent("click", callback(self, "ShowPage2"))
	
	self.m_Part1 = self:NewPage(3, CTestPart1)
	self.m_Part2 = self:NewPage(4, CTestPart2)
	self:ShowPage1()
end

function CTestView.ShowPage1(self)
	self:ShowSubPage(self.m_Part1)
end

function CTestView.ShowPage2(self)
	self:ShowSubPage(self.m_Part2)
end

return CTestView