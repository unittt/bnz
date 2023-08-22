local CPlotSkipView = class("CPlotSkipView", CViewBase)

function CPlotSkipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Plot/PlotSkipView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondTop"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CPlotSkipView.OnCreateView(self)
	self.m_SkipWidget = self:NewUI(1, CWidget)
	self.m_MaskWidget = self:NewUI(2, CWidget)
	self.m_TopSp = self:NewUI(3, CTexture)
	self.m_BottomSp = self:NewUI(4, CTexture)
	self:InitContent()
end

function CPlotSkipView.InitContent(self)
	if g_PlotCtrl.m_IsShowingDialogueView then
		self:SetBgActive(false)
	else
		self:SetBgActive(true)
	end
	UITools.ResizeToRootSize(self.m_MaskWidget, 0, 0)
	self.m_SkipWidget:AddUIEvent("click", callback(self, "OnClickSkip"))

	g_PlotCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CPlotSkipView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Plot.Event.SkipBg then
		if oCtrl.m_EventData == 1 then
			self:SetBgActive(true)
		else
			self:SetBgActive(false)
		end
	end
end

function CPlotSkipView.SetBgActive(self, bActive)
	self.m_TopSp:SetActive(bActive)
	self.m_BottomSp:SetActive(bActive)
end

function CPlotSkipView.SetSkipCallback(self, cb)
	self.m_SkipCb = cb
end

function CPlotSkipView.OnClickSkip(self)
	if self.m_SkipCb then
		self.m_SkipCb()
	end
end

return CPlotSkipView