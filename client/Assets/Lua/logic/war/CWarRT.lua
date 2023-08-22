local CWarRT = class("CWarRT", CBox)

function CWarRT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SummonEmptyHintId = 1030
	self.m_HeroHpSlider = self:NewUI(1, CSlider)
	self.m_HeroMpSlider = self:NewUI(2, CSlider)
	self.m_HeroSpSlider = self:NewUI(3, CSlider)
	self.m_HeroGradeLabel = self:NewUI(4, CLabel)
	self.m_HeroAvatarSpr = self:NewUI(5, CSprite)
	self.m_HeroBuffGrid = self:NewUI(6, CGrid)
	self.m_BuffBox = self:NewUI(7, CMainMenuBuffBox)

	self.m_SummonHpSlider = self:NewUI(8, CSlider)
	self.m_SummonMpSlider = self:NewUI(9, CSlider)
	self.m_SummonGradeLabel = self:NewUI(10, CLabel)
	self.m_SummonAvatarSpr = self:NewUI(11, CSprite)
	self.m_SummonBuffGrid = self:NewUI(12, CGrid)

	self.m_HeroAvatarBg = self:NewUI(13, CSprite)
	self.m_SummonAvatarBg = self:NewUI(14, CSprite)	
	-- self.m_ExpandBox = self:NewUI(15, CMainMenuExpandBox)
	self.m_RedWidget = self:NewUI(16, CWidget)
	self.m_HeroHpClickW = self:NewUI(17, CWidget)
	self.m_SummonHpClickW = self:NewUI(18, CWidget)
	self:InitContent()
end

function CWarRT.Destroy(self)
	-- self.m_ExpandBox:Destroy()
	g_SysUIEffCtrl:UnRegister("ROLE_S", self.m_HeroAvatarBg)
	CBox.Destroy(self)
end

function CWarRT.InitContent(self)
	-- self.m_ExpandBox:SetWarModel(true)
	self.m_HeroHpClickW:AddUIEvent("click", callback(self, "OnShowDetailView", true))
	self.m_SummonHpClickW:AddUIEvent("click", callback(self, "OnShowDetailView", false))
	self.m_HeroAvatarBg:AddUIEvent("click", callback(self, "OnShowAttr"))
	self.m_SummonAvatarBg:AddUIEvent("click", callback(self, "OnShowSummon"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
	self:RefreshHeroState()
	self:RefreshHeroBuff()
	self:RefreshSummonState()
	self:RefreshSummonBuff()
	self:RefreshSummonRedPoint()
	g_SysUIEffCtrl:Register("ROLE_S", self.m_HeroAvatarBg)
end

function CWarRT.RefreshSummonRedPoint(self)
	local bRed = g_SummonCtrl:IsHasRedPoint()
	if bRed then
		self.m_SummonAvatarBg:AddEffect("RedDot",22,Vector2(-18,-21))
		self.m_SummonAvatarBg.m_IgnoreCheckEffect = true
	else
		self.m_SummonAvatarBg:DelEffect("RedDot")
	end
end

function CWarRT.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.HeroState then
		self:RefreshHeroState()
	elseif oCtrl.m_EventID == define.War.Event.SummonState then
		self:RefreshSummonState()
	elseif oCtrl.m_EventID == define.War.Event.HeroBuff then
		self:RefreshHeroBuff()
	elseif oCtrl.m_EventID == define.War.Event.SummonBuff then
		self:RefreshSummonBuff()
	end
end

function CWarRT.OnSummonCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Summon.Event.UpdateRedPoint then
		self:RefreshSummonRedPoint()
	end
end

function CWarRT.RefreshHeroState(self)
	local dState = g_WarCtrl:GetHeroState()
	self.m_HeroAvatarSpr:SpriteAvatar(g_AttrCtrl.icon)
	self.m_HeroHpSlider:SetValue(dState.hp/dState.max_hp)
	self.m_HeroHpSlider:SetSliderText("")--string.format("%d/%d", dState.hp, dState.max_hp))
	self.m_HeroMpSlider:SetValue(dState.mp/dState.max_mp)
	self.m_HeroMpSlider:SetSliderText("")--string.format("%d/%d", dState.mp, dState.max_mp))
	self.m_HeroSpSlider:SetValue(dState.sp/dState.max_sp)
	self.m_HeroSpSlider:SetSliderText("")--string.format("%d/%d", dState.sp, dState.max_sp))
	self.m_HeroGradeLabel:SetText(tostring(dState.grade))
end

function CWarRT.RefreshSummonState(self)
	local bIsViewer = g_WarCtrl:GetViewSide() ~= nil
	local bHasFightSummon = g_SummonCtrl:GetCurFightSummonInfo() ~= nil
	local bShow = (not bIsViewer and g_WarCtrl.m_SummonWid ~= nil) or (bIsViewer and bHasFightSummon)
	self.m_SummonAvatarSpr:SetActive(bShow)
	self.m_SummonHpSlider:SetActive(bShow)
	self.m_SummonMpSlider:SetActive(bShow)
	self.m_SummonGradeLabel:SetActive(bShow)
	if bShow then
		local dState = g_WarCtrl:GetSummonState()
		self.m_SummonAvatarSpr:SpriteAvatar(dState.shape)
		self.m_SummonHpSlider:SetValue(dState.hp/dState.max_hp)
		self.m_SummonHpSlider:SetSliderText("")--string.format("%d/%d", dState.hp, dState.max_hp))
		self.m_SummonMpSlider:SetValue(dState.mp/dState.max_mp)
		self.m_SummonMpSlider:SetSliderText("")--string.format("%d/%d", dState.mp, dState.max_mp))
		self.m_SummonGradeLabel:SetText(tostring(dState.grade))
	end
end

function CWarRT.RefreshHeroBuff(self)
	-- self:RefreshBuffGrid(self.m_HeroBuffGrid, g_WarCtrl.m_HeroWid)
end

function CWarRT.RefreshSummonBuff(self)
	-- self:RefreshBuffGrid(self.m_SummonBuffGrid, g_WarCtrl.m_SummonWid)
end

function CWarRT.OnShowAttr(self, oBtn)
	CAttrMainView:ShowView()
end

function CWarRT.OnShowSummon(self, oBtn)
	-- if next(g_SummonCtrl.m_SummonsDic) == nil then
	-- 	g_NotifyCtrl:FloatSummonMsg(self.m_SummonEmptyHintId)
	-- 	return
	-- end
	CSummonMainView:ShowView()
end

function CWarRT.OnShowDetailView(self, bIsHero)
	local oWarrior
	if bIsHero then
		oWarrior = g_WarCtrl:GetHero()
	else
		oWarrior = g_WarCtrl:GetSummon()
	end
	if not oWarrior then
		return
	end
	CWarTargetDetailView:ShowView(function(oView)
   		oView:SetWarrior(oWarrior)
    end)
end

return CWarRT