local CWarRB = class("CWarRB", CBox)

function CWarRB.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_HeroMenu = self:NewUI(1, CWarHeroMenu)
	self.m_SummonMenu = self:NewUI(2, CWarSummonMenu)
	self.m_AutoMenu = self:NewUI(3, CWarAutoMenu)
	self.m_Observer = self:NewUI(4, CSprite)
	self.m_BarrageWatchUI = self:NewUI(5, CBarrageWarUI)
	self.m_TempGridBox = self:NewUI(6, CWarTempGridBox)

	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_Observer:AddUIEvent("click", callback(self, "OnExitObserver"))

end

function CWarRB.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.AutoWar then
		if not g_WarOrderCtrl:IsCanOrder() and not oCtrl:IsAutoWar() then
			g_NotifyCtrl:FloatMsg("已取消自动战斗，下回合可操作")
		end
		self:CheckShow()
	elseif oCtrl.m_EventID == define.War.Event.AutoMagic then
		self.m_AutoMenu:UpdateMenu()
	elseif oCtrl.m_EventID == define.War.Event.RefreshQuick then
		self.m_HeroMenu:RefreshQuickSkill(true)
	elseif oCtrl.m_EventID == define.War.Event.RefreshQuickSummon then
		self.m_SummonMenu:RefreshQuickSkill(true)
	elseif oCtrl.m_EventID == define.War.Event.RefreshSpecialSkill then
		self.m_HeroMenu:RefreshSpecialSkill()
	elseif oCtrl.m_EventID == define.War.Event.SummonState then
		self.m_AutoMenu:SetMagicIconGrey(false)
		self.m_SummonMenu:RefreshQuickSkill(true)
	elseif oCtrl.m_EventID == define.War.Event.HeroState then
		self.m_AutoMenu:SetMagicIconGrey(true)
		self.m_HeroMenu:RefreshQuickSkill(true)
	end
end

function CWarRB.OnExitObserver(self)
	netplayer.C2GSLeaveObserverWar(g_WarCtrl.m_WarID)
end

--打开观战控制按钮
function CWarRB.OpenWatchWarSwitch(self, isOpen)

 	self.m_BarrageWatchUI:ShowUI(isOpen)

end


function CWarRB.CheckShow(self)
	if g_WarCtrl:GetViewSide() then
		self.m_AutoMenu:SetActive(false)
		self.m_HeroMenu:SetActive(false)
		self.m_SummonMenu:SetActive(false)
		self.m_Observer:SetActive(true)
		-- self.m_TempGridBox:SetActive(false)
		return
	end

	self.m_AutoMenu:SetActive(true)
	self.m_Observer:SetActive(false)
	self.m_AutoMenu:UpdateMenu()

	if g_WarCtrl:IsChallengeType() then
		self.m_HeroMenu:SetActive(false)
		self.m_SummonMenu:SetActive(false)
		self.m_AutoMenu:SetActive(true)
		-- self.m_TempGridBox:SetActive(false)
		return
	end

	local showHeroMenu = false
	local showSummonMenu = false
	local bOrder = g_WarOrderCtrl:IsCanOrder()
	local bAutoWar = g_WarCtrl:IsAutoWar()
	if bOrder and not bAutoWar then
		if not g_WarOrderCtrl:IsOrderDone("hero") then
			showHeroMenu = true
		elseif not g_WarOrderCtrl:IsOrderDone("summon") then
			showSummonMenu = true
		end
	end
	self.m_HeroMenu:SetActive(showHeroMenu)
	self.m_SummonMenu:SetActive(showSummonMenu)
	-- self.m_TempGridBox:SetActive(showHeroMenu or showSummonMenu or false)
end

function CWarRB.Bout(self)
	self.m_AutoMenu:Bout()
end

function CWarRB.Destroy(self)
	self.m_TempGridBox:Destroy()
	CBox.Destroy(self)
end

return CWarRB