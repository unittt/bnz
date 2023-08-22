local CSchoolMatchTipView = class("CSchoolMatchTipView", CViewBase)

function CSchoolMatchTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SchoolMatch/SchoolMatchTipView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
end

function CSchoolMatchTipView.OnCreateView(self)
	self.m_PreTimeL = self:NewUI(1, CLabel)
	self.m_PointTimeL = self:NewUI(2, CLabel)
	self.m_KnockoutTimeL = self:NewUI(3, CLabel)
	self.m_TipL = self:NewUI(4, CLabel)

	self:InitContent()
end

function CSchoolMatchTipView.InitContent(self)
	local dData = data.textdata.SCHOOLMATCH
	self.m_PreTimeL:SetText(dData[1018].content)
	self.m_PointTimeL:SetText(dData[1019].content)
	self.m_KnockoutTimeL:SetText(dData[1020].content)
	self.m_TipL:SetText(dData[1009].content)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSchoolMatchTipView.CloseView(self)
	CViewBase.CloseView(self)
	g_SchoolMatchCtrl.m_ShowTip = false
end

return CSchoolMatchTipView