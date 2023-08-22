local SummonFreeSureView = class("SummonFreeSureView", CViewBase)

function SummonFreeSureView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonFreeSureView.prefab", cb)
	--界面设置
	self.m_DepthType = "Notify"
	self.m_ExtendClose = "Black"
end

function SummonFreeSureView.OnCreateView(self)
	self.m_SummonName = self:NewUI(1, CLabel)
	self.m_SummonGrade = self:NewUI(2, CLabel)
	self.m_Verify = self:NewUI(3, CLabel)	
	self.m_Number_1 = self:NewUI(4, CLabel)
	self.m_Number_2 = self:NewUI(5, CLabel)
	self.m_Number_3 = self:NewUI(6, CLabel)
	self.m_Number_4 = self:NewUI(7, CLabel)
	self.m_CloseBtn = self:NewUI(8, CButton)
	self.m_GridItem = self:NewUI(9, CGrid)
	self.m_SummonPic = self:NewUI(10, CSprite)
    self:InitContent()
end

function SummonFreeSureView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SureCode = math.random(1000, 9999)
	self.m_Verify:SetText("确认码   "..self.m_SureCode)
	self.m_Number_1:SetText("")
	self.m_Number_2:SetText("")
	self.m_Number_3:SetText("")
	self.m_Number_4:SetText("")
	self:InitGrid()	
end

function SummonFreeSureView.InitGrid(self)
	local function init(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn:SetGroup(self.m_GridItem:GetInstanceID())
		return oBtn
	end
	self.m_GridItem:InitChild(init)
	for i = 1, 9 do
		--self.m_GridItem:GetChild(1):NewUI(1,CLabel):GetText()
		self.m_GridItem:GetChild(i):AddUIEvent("click", callback(self, "SetInput", i))
	end
end

function SummonFreeSureView.SetInput(self, number)

end

return SummonFreeSureView