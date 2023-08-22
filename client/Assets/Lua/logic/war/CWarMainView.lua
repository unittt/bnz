local CWarMainView = class("CWarMainView", CViewBase)

function CWarMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarMainView.prefab", cb)

	self.m_GroupName = "WarMain"
	self.m_DepthType = "Base"
end

function CWarMainView.OnCreateView(self)
	self.m_LT = self:NewUI(1, CWarLT)
	self.m_LB = self:NewUI(2, CWarLB)
	self.m_RT = self:NewUI(3, CWarRT)
	self.m_RB = self:NewUI(4, CWarRB)
	self.m_CT = self:NewUI(5, CWarCT)
	self.m_Content = self:NewUI(6, CWidget)
	self.m_Content:SetDepth(10)

	UITools.ResizeToRootSize(self.m_Content)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:CheckShow()
	self:RefreshFormation()

	self:RefreshBarrageUI()

	self.m_IsShowChat = g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Chat)
	g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Chat)
	-- 屏幕适配（针对iphonx）
    self:ResizeWindow()
    g_ScreenResizeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "ResizeWindow"))
end

function CWarMainView.ResizeWindow(self)
	g_ScreenResizeCtrl:ResizePanel(self.m_GameObject)
end

function CWarMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.BoutStart then
		self:Bout()
	elseif oCtrl.m_EventID == define.War.Event.Formation then
		self:RefreshFormation()
	elseif oCtrl.m_EventID == define.War.Event.WarStart then 
		self:RefreshBarrageUI()
	end
end

function CWarMainView.CheckShow(self)
	if g_WarCtrl.m_IsFirstSpecityWar and ((g_WarCtrl.m_FirstSpecityWarStep == 1 and g_WarCtrl:GetBout() == 1) or g_GuideHelpCtrl:IsNoGuide()) then
		self.m_Content:EnableTouch(true)
		self.m_RB:SetActive(false)
	else
		self.m_Content:EnableTouch(false)
		self.m_RB:SetActive(true)
		self.m_RB:CheckShow()
	end
end

function CWarMainView.Bout(self)
	self.m_CT:Bout()
	self.m_RB:Bout()
end

function CWarMainView.RefreshFormation(self)
	self.m_CT:RefreshFormation()
end

function CWarMainView.RefreshBarrageUI(self)
	
	if g_WarCtrl.m_ViewSide then 
		--观战
		self:OpenWatchWarBarrageUI()
	else
		--战斗弹幕
		self:OpenWarBarrageUI()
	end 

end

--打开战斗弹幕相关界面
function CWarMainView.OpenWarBarrageUI(self)

	if g_WarCtrl.m_bullet_send == 2 then 
		g_BarrageCtrl:OpenBarrageView()
		self.m_LB:OpenBarrageWarUI(true)
	else
		self.m_LB:OpenBarrageWarUI(false)
	end 

	self.m_RB:OpenWatchWarSwitch(false)

end

--打开观战弹幕相关界面
function CWarMainView.OpenWatchWarBarrageUI(self)

	if g_WarCtrl.m_bullet_send == 1 or g_WarCtrl.m_bullet_send == 2 then 
		g_BarrageCtrl:OpenBarrageView()
		self.m_RB:OpenWatchWarSwitch(true)
	else
		self.m_RB:OpenWatchWarSwitch(false)
	end 

end

function CWarMainView.Destroy(self)
	self.m_LT:Destroy()
	self.m_RT:Destroy()
	self.m_RB:Destroy()
	if not self.m_IsShowChat then
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Chat)
	end
	CViewBase.Destroy(self)
end

return CWarMainView