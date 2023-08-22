local CMainMenuRT = class("CMainMenuRT", CBox)

function CMainMenuRT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SummonEmptyHintId = 1030 
	self.IsHeroRedPoint = false
	self.m_HeroBox = self:NewUI(1, CBox)
	self.m_PetBox = self:NewUI(2, CBox)
	self.m_ExpandBox = self:NewUI(3, CMainMenuExpandBox)
	-- HeroBox
	self.m_HeroBox.m_HeroIconSpr = self.m_HeroBox:NewUI(1, CSprite)
	self.m_HeroBox.m_HeroHpSlider = self.m_HeroBox:NewUI(2, CSlider)
	self.m_HeroBox.m_HeroMpSlider = self.m_HeroBox:NewUI(3, CSlider)
	self.m_HeroBox.m_HeroSpSlider = self.m_HeroBox:NewUI(4, CSlider)
	self.m_HeroBox.m_HeroGradeLab = self.m_HeroBox:NewUI(5, CLabel)
	self.m_HeroBox.m_MainMenuBuffBox = self.m_HeroBox:NewUI(6, CMainMenuBuffBox)
	-- PetBox
	self.m_PetBox.m_PetIconSpr = self.m_PetBox:NewUI(1, CSprite)
	self.m_PetBox.m_PetHpSlider = self.m_PetBox:NewUI(2, CSlider)
	self.m_PetBox.m_PetMpSlider = self.m_PetBox:NewUI(3, CSlider)
	self.m_PetBox.m_PetExpSlider = self.m_PetBox:NewUI(4, CSlider)
	self.m_PetBox.m_PetGradeLab = self.m_PetBox:NewUI(5, CLabel)
	self.m_PetBox.m_PetIconRed = self.m_PetBox:NewUI(6, CSprite)
	self.m_PetBox.m_PetRedPointSpr = self.m_PetBox:NewUI(7, CSprite)
	self:InitContent()
end

function CMainMenuRT.SwitchEnv(self, bWar)
	if bWar then
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Task)
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.PopBtn)
		self.m_HeroBox:SetActive(false)
		self.m_PetBox:SetActive(false)
		self.m_ExpandBox:SetActive(true)
	else
		self.m_HeroBox:SetActive(true)
		self.m_PetBox:SetActive(true)
		self.m_ExpandBox:SetActive(true)
	end
end

function CMainMenuRT.Destroy(self)
	self.m_ExpandBox:Destroy()
	g_SysUIEffCtrl:UnRegister("ROLE_S", self.m_HeroBox)
	CBox.Destroy(self)
end

function CMainMenuRT.InitContent(self)
	g_GuideCtrl:AddGuideUI("petview_open_btn", self.m_PetBox)
	g_GuideCtrl:AddGuideUI("mainmenu_task_btn", self.m_ExpandBox.m_TaskBtn)
	self.m_ExpandBox:SetWarModel(g_WarCtrl:IsWar())
	self.m_ExpandBox:RefreshPop()

	self.m_HeroBox:AddUIEvent("click", callback(self, "OnShowAttr"))
	self.m_PetBox:AddUIEvent("click", callback(self, "OnShowPetView"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonEvent"))
	g_EngageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEngageEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarCtrlEvent"))
	
	self:BindMenuArea()
	self:RefreshRolePanel()
	self:RefreshPetPanel()
	self:RefreshPetRedPoint()
	g_SysUIEffCtrl:Register("ROLE_S", self.m_HeroBox)
end

function CMainMenuRT.BindMenuArea(self)
	local tweenPos_1 = self.m_HeroBox:GetComponent(classtype.TweenPosition)
	local tweenPos_2 = self.m_PetBox:GetComponent(classtype.TweenPosition)

	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.HeroIcon, tweenPos_1)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.PetIcon, tweenPos_2)
end

function CMainMenuRT.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshRolePanel()
		self:RefreshPetPanel()
	end
end

function CMainMenuRT.OnSummonEvent(self, oCtrl)
	if (oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and 
		oCtrl.m_EventData.id == g_SummonCtrl:GetFightid()) or
		oCtrl.m_EventID == define.Summon.Event.SetFightId then
		-- printc("刷新宠物")
		self:RefreshPetPanel()
	end
	if oCtrl.m_EventID == define.Summon.Event.UpdateRedPoint then
		self:RefreshPetRedPoint()
	end
end

function CMainMenuRT.OnEngageEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Engage.Event.EngageSuccess then
		if self.m_HeroBox.m_HeroIconSpr then
			self.m_HeroBox.m_HeroIconSpr:AddEffect("RedDot", 26, Vector2.New(-20, -20))
			self.IsHeroRedPoint = true
		end
	end
end

function CMainMenuRT.OnWarCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart or oCtrl.m_EventID == define.War.Event.WarEnd then
		self.m_ExpandBox:SetWarModel(g_WarCtrl:IsWar())
		if g_WarCtrl:IsWar() then
			g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Task)
		else
			g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Task)
		end	
	end
end

function CMainMenuRT.OnShowAttr(self)

	if self.IsHeroRedPoint then
		self.m_HeroBox.m_HeroIconSpr:DelEffect("RedDot")
		self.IsHeroRedPoint = false
	end

	CAttrMainView:ShowView()
end

function CMainMenuRT.OnShowBuffView(self, oCtrl)
	printc("============== 显示特效啊 =============")
end

function CMainMenuRT.OnShowPetView(self)
	if g_OpenSysCtrl:GetOpenSysState(define.System.Summon, true) then
		CSummonMainView:ShowView()
		if next(g_SummonCtrl.m_SummonsDic) == nil then
			return
		end
		self:RefreshPetPanel()
	end	
end

function CMainMenuRT.RefreshRolePanel(self)
	self.m_HeroBox.m_HeroIconSpr:SpriteAvatar(g_AttrCtrl.icon)
	self.m_HeroBox.m_HeroHpSlider:SetValue(g_AttrCtrl.hp/g_AttrCtrl.max_hp)
	self.m_HeroBox.m_HeroMpSlider:SetValue(g_AttrCtrl.mp/g_AttrCtrl.max_mp)
	self.m_HeroBox.m_HeroSpSlider:SetValue(g_AttrCtrl.sp/g_AttrCtrl.max_sp)
	self.m_HeroBox.m_HeroGradeLab:SetText(g_AttrCtrl.grade)
end

function CMainMenuRT.RefreshPetRedPoint(self)
	local bRed = g_SummonCtrl:IsHasRedPoint()
	self.m_PetBox.m_PetRedPointSpr:SetActive(bRed)
end

function CMainMenuRT.RefreshPetPanel(self)
	local dInfo = g_SummonCtrl:GetCurFightSummonInfo()
	self.m_PetBox.m_PetIconSpr:SetActive(dInfo ~= nil)
	self.m_PetBox.m_PetGradeLab:SetActive(dInfo ~= nil)
	self.m_PetBox.m_PetHpSlider:SetActive(dInfo ~= nil)
	self.m_PetBox.m_PetMpSlider:SetActive(dInfo ~= nil)
	if dInfo then
		self.m_PetBox.m_PetIconSpr:SpriteAvatar(dInfo.model_info.shape)
		self.m_PetBox.m_PetHpSlider:SetValue(dInfo.hp/dInfo.max_hp)
		self.m_PetBox.m_PetMpSlider:SetValue(dInfo.mp/dInfo.max_mp)
		self.m_PetBox.m_PetGradeLab:SetText(dInfo.grade)
	end
end

return CMainMenuRT