local CMainMenuView = class("CMainMenuView", CViewBase)

function CMainMenuView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MainMenu/MainMenuView.prefab", cb)
	self.m_DepthType = "Base"
	self.m_GroupName = "main"
end

function CMainMenuView.OnCreateView(self)
	self.m_LT = self:NewUI(1, CMainMenuLT)
	self.m_LB = self:NewUI(2, CMainMenuLB)
	self.m_RT = self:NewUI(3, CMainMenuRT)
	self.m_RB = self:NewUI(4, CMainMenuRB)
	self.m_Center = self:NewUI(5, CMainMenuCenter)
	self.m_Container = self:NewUI(6, CWidget)
	UITools.ResizeToRootSize(self.m_Container)
	g_MainMenuCtrl:SetMainMenu(self)
	self:SwitchEnv(g_WarCtrl:IsWar())
	-- 屏幕适配（针对iphonx）
    self:ResizeWindow()
    g_ScreenResizeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "ResizeWindow"))

    self.m_LB.m_ChatBox:RefreshAllMsg()
end

function CMainMenuView.ResizeWindow(self)
	g_ScreenResizeCtrl:ResizePanel(self.m_GameObject)
end

function CMainMenuView.ShowAllArea(self, b)
	self.m_LB:SetActive(b)
	self.m_LT:SetActive(b)
	self.m_RT:SetActive(b)
	self.m_RB:SetActive(b)
	self.m_Center:SetActive(b)
end

function CMainMenuView.SwitchEnv(self, bWar)
	self:SetActive(true)
	self.m_LB:SetActive(true)
	self.m_LT:SetActive(not bWar)
	self.m_RT:SwitchEnv(bWar)
	self.m_RB:SetActive(not bWar)
	self.m_LB.m_ChatBox:RefreshQuickAppoint()
	-- TODO:临时屏蔽，Tips不可以在战斗中显示
	-- self.m_Center:RefrehNotifyTip()
	if not bWar and g_MapCtrl:IsInOrgMatchMap() then
		for i,area in ipairs(define.MainMenu.HideConfig.OrgMatch) do
			g_MainMenuCtrl:HideArea(area)
		end
    end
    if not bWar and g_MainMenuCtrl.m_MaskHandle.IsSysUI() then
    	g_MainMenuCtrl:ShowAllArea()
    end
    --g_SystemSettingsCtrl:StartCheckClick()  --主界面显示后，开启省电模式检测
    if not bWar and g_MainMenuCtrl.m_MaskHandle.IsPlot() then
    	g_MainMenuCtrl:ShowMainMenu(false)
    end
end

function CMainMenuView.JoinBonfire(self)
	self.m_RT.m_ExpandBox:ShowActivityBtn("bonfire")
end

function CMainMenuView.EndBonfire(self)
	self.m_RT.m_ExpandBox:HideActivityBtn("bonfire")
end

function CMainMenuView.OnShowView(self)
	--暂时屏蔽
	-- self.m_LB.m_ChatBox:RefreshAllMsg()
end

function CMainMenuView.SetActive(self, b)
	if b and g_MainMenuCtrl.m_MaskHandle.IsPlot() then
		return
	end
	CViewBase.SetActive(self, b)
	if not g_WarCtrl:IsWar() then
		self:ShowAllArea(b)
	end
	g_MainMenuCtrl.m_IsActive = b
end

function CMainMenuView.Destroy(self)
	self.m_LT:Destroy()
	self.m_RT:Destroy()
	self.m_RB:Destroy()
	CViewBase.Destroy(self)
	g_MainMenuCtrl:Reset()
end

function CMainMenuView.InHFDMMapHideTopUI(self, isBool)
	self.m_RT:SetActive(isBool)
	self.m_LT:SetActive(isBool)
end

return CMainMenuView