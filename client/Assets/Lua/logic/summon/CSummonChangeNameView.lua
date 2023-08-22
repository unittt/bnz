local CSummonChangeNameView = class("CSummonChangeNameView", CViewBase)

function CSummonChangeNameView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonChangeNameView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
end

function CSummonChangeNameView.OnCreateView(self)
	self.m_InputText = self:NewUI(1,CInput)
	self.m_CancelBtn = self:NewUI(2,CButton)
	self.m_DefaultBtn = self:NewUI(3,CButton)
	self.m_OkBtn = self:NewUI(4,CButton)
    self.m_CloseBtn = self:NewUI(5,CButton)
    self:InitContent()
end

function CSummonChangeNameView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click",callback(self,"OnClose"))
		self.m_CancelBtn:AddUIEvent("click",function ()
		self:OnClose()
		self.m_InputText:SetText("")
	end)
	self.m_OkBtn:AddUIEvent("click",callback(self,"OnOk"))	
end

function CSummonChangeNameView.OnOk(self)
	local name = self.m_InputText:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
		return
	end
	g_SummonCtrl:ChangeName(self.m_CurSummonId,name)
	self:OnClose()
end

function CSummonChangeNameView.SetData(self,data)
	self.m_CurSummonId = data
	self.m_InputText:SetText(g_SummonCtrl.m_SummonsDic[self.m_CurSummonId]["name"])
	self.m_DefaultBtn:AddUIEvent("click",function ()
		self.m_InputText:SetText(g_SummonCtrl.m_SummonsDic[self.m_CurSummonId]["basename"])
	end)
end

return CSummonChangeNameView