local CDayTaskInfoView = class("CDayTaskInfoView", CViewBase)

function CDayTaskInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/DayTaskInfoView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "ClickOut"
end

function CDayTaskInfoView.OnCreateView(self)
	self.m_TitleLbl = self:NewUI(1, CLabel)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_BgSp = self:NewUI(3, CSprite)

	self:InitContent()
end

function CDayTaskInfoView.InitContent(self)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self.m_BgSp:AddUIEvent("click", callback(self, "OnClose"))
end

function CDayTaskInfoView.RefreshUI(self, config)
	self.m_TitleLbl:SetText(config.title)
	self.m_DescLbl:SetText(config.desc)
end

return CDayTaskInfoView