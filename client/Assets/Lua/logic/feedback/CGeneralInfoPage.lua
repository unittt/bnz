local CGeneralInfoPage = class("CGeneralInfoPage", CPageBase)

function CGeneralInfoPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CGeneralInfoPage.OnInitPage(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_InfoBoxClone = self:NewUI(2, CBox)

	g_FeedbackCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFeedbackEvent"))
	self:InitContent()
end

function CGeneralInfoPage.InitContent(self)
	local dInfo = g_FeedbackCtrl:GetGeneralInfo()

	if not dInfo or table.count(dInfo) == 0 then
		printc("尚未配置官方联系信息")
		return
	end
	
	for i, v in ipairs(dInfo) do
		local oInfo = self.m_Grid:GetChild(i)
		if oInfo == nil then
			oInfo = self.m_InfoBoxClone:Clone()
			oInfo.m_Title = oInfo:NewUI(1, CLabel)
			oInfo.m_Content = oInfo:NewUI(2, CLabel)

			oInfo:SetActive(true)
			self.m_Grid:AddChild(oInfo)
		end
		oInfo.m_Title:SetText(v.title)
		oInfo.m_Content:SetText(v.content)
	end

	self.m_Grid:Reposition()
end

function CGeneralInfoPage.OnFeedbackEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Feedback.Event.RefreshFeedbackServInfo then
		self:InitContent()
	end
end

return CGeneralInfoPage
