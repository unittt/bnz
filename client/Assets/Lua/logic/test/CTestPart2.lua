local CTestPart2 = class("CTestPart2", CPageBase)

function CTestPart2.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTestPart2.OnInitPage(self)
	self.m_Label = self:NewUI(1, CLabel)
	self.m_Label:SetText("已初始化2")
	--初始化各个子控件
end

return CTestPart2