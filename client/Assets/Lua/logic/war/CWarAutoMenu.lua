local CWarAutoMenu = class("CWarAutoMenu", CBox)

function CWarAutoMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AutoBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_SelMagicBg = self:NewUI(3, CSprite)
	self.m_HeroMagicBtn = self:NewUI(4, CButton, true, false)
	self.m_SummonMagicBtn = self:NewUI(5, CButton, true, false)
	-- self.m_TimerLabel = self:NewUI(6, CLabel)
	self.m_AutoBattleBtn = self:NewUI(7, CButton)
	self.m_HeroMagicBg = self:NewUI(8, CSprite)
	self.m_SummonMagicBg = self:NewUI(9, CSprite)
	self.m_TimerLabel = self:NewUI(10, CLabel)

	g_GuideCtrl:AddGuideUI("war_auto_btn", self.m_AutoBtn)

	self.m_DelayUpdateTimer = nil
	self.m_CountDownTimer = nil
	self:InitContent()
end

function CWarAutoMenu.InitContent(self)
	self:SetActive(true)
	self.m_TimerLabel:SetActive(false)
	self.m_AutoBattleBtn:SetActive(false)
	self.m_AutoBtn:AddUIEvent("click", callback(self, "StartAuto"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "CancelAuto"))
	self.m_HeroMagicBtn:AddUIEvent("click", callback(self, "OnSelHeroMagic"))
	self.m_SummonMagicBtn:AddUIEvent("click", callback(self, "OnSelSummonMagic"))
	self.m_AutoBattleBtn:AddUIEvent("click", callback(self, "OnClickAutoBattle"))
	-- self:UpdateMenu()
	self:Bout()
end

function CWarAutoMenu.Bout(self)
	local bAuto = g_WarCtrl:IsAutoWar()
	self.m_TimerLabel:SetActive(bAuto)
	if self.m_CountDownTimer then
		Utils.DelTimer(self.m_CountDownTimer)
		self.m_CountDownTimer = nil
	end
	local iAutoEnd = g_WarOrderCtrl:GetAutoEndTime()
	local iCount = 3
	local fDelta = g_WarOrderCtrl:GetAutoOrderTime()/iCount
	if bAuto then
		self.m_TimerLabel:SetText(iCount)--"秒后自动")
		local function update()
			if Utils.IsNil(self) then
				return false
			end
			local iRemain = g_WarOrderCtrl:GetRemainTime()
			if iRemain then
				if iCount > 0 then
					self.m_TimerLabel:SetText(iCount)-- .. "秒后自动")
					iCount = iCount - 1
					return true
				else
					self.m_TimerLabel:SetText("")
					return false
				end
			end
			self.m_TimerLabel:SetActive(false)
			return false
		end
		self.m_CountDownTimer = Utils.AddTimer(update, fDelta, 0)
	end
end

function CWarAutoMenu.RefreshSummonBtn(self)
	local showSummonMagic = g_WarCtrl.m_SummonWid and g_WarCtrl.m_SummonWid > 0
	self.m_SummonMagicBtn:SetActive(showSummonMagic)
end

function CWarAutoMenu.StartAuto(self)
	if g_WarCtrl.m_IsFirstSpecityWar then
		if g_WarCtrl:GetBout() ~= 2 or g_WarCtrl.m_FirstSpecityWarStep ~= 3 then
			g_NotifyCtrl:FloatMsg("请道友按照新手指引操作")
			return
		end
	end

	g_WarCtrl:SetAutoWar(1, true)
	g_WarOrderCtrl:FinishOrder()
end

function CWarAutoMenu.CancelAuto(self)
	if g_WarCtrl.m_IsFirstSpecityWar then
		g_NotifyCtrl:FloatMsg("请道友按照新手指引操作")
		return
	end

	g_WarCtrl:SetAutoWar(0, true)
end

function CWarAutoMenu.DelayUpdateMenu(self)
	if self.m_DelayUpdateTimer then
		Utils.DelTimer(self.m_DelayUpdateTimer)
	end
	self.m_DelayUpdateTimer = Utils.AddTimer(callback(self, "UpdateMenu"), 0, 0)
end

function CWarAutoMenu.UpdateMenu(self)
	if g_WarCtrl:IsChallengeType() then
		self.m_AutoBtn:SetActive(false)
		self.m_CancelBtn:SetActive(false)
		self.m_SelMagicBg:SetActive(false)
		self.m_AutoBattleBtn:SetActive(true)
		return
	end
	if self.m_DelayUpdateTimer then
		Utils.DelTimer(self.m_DelayUpdateTimer)
		self.m_DelayUpdateTimer = nil
	end
	local bAuto = g_WarCtrl:IsAutoWar()
	self.m_AutoBtn:SetActive(not bAuto)
	self.m_CancelBtn:SetActive(bAuto)
	self.m_SelMagicBg:SetActive(bAuto)

	self:RefreshSummonBtn()
	local heroMaigcID = g_WarCtrl:GetHeroAutoMagic()
	self.m_HeroMagicBtn:SpriteMagic(heroMaigcID)
	if heroMaigcID and heroMaigcID > 110 then
		self.m_HeroMagicBg:SetStaticSprite("CommonAtlas", "h7_texiaotubiaokuang")
	else
		self.m_HeroMagicBg:SetStaticSprite("WarAtlas", "h7_di_32")
	end
	
	local summonMagicID = g_WarCtrl:GetSummonAutoMagic()
	self.m_SummonMagicBtn:SpriteMagic(summonMagicID)
	if summonMagicID and summonMagicID > 110 then
		self.m_SummonMagicBg:SetStaticSprite("CommonAtlas", "h7_texiaotubiaokuang")
	else
		self.m_SummonMagicBg:SetStaticSprite("WarAtlas", "h7_di_32")
	end

	self:SetMagicIconGrey(true)
	self:SetMagicIconGrey(false)
end

function CWarAutoMenu.SetMagicIconGrey(self, bHero)
	if bHero then
		local heroMaigcID = g_WarCtrl:GetHeroAutoMagic()
		if heroMaigcID then
			local bGrey = not g_SkillCtrl:IsMagicCanUse(heroMaigcID)
			self.m_HeroMagicBtn:SetGrey(bGrey)
		end
	else
		local summonMagicID = g_WarCtrl:GetSummonAutoMagic()
		if summonMagicID then
			local bGrey = not g_SkillCtrl:IsMagicCanUse(summonMagicID)
			self.m_SummonMagicBtn:SetGrey(bGrey)
		end
	end
end

function CWarAutoMenu.OnSelHeroMagic(self, oBtn)
	if g_WarCtrl.m_IsFirstSpecityWar then
		return
	end
	CWarSelAutoView:ShowView(function(oView)
		oView:SetIsHero(true)
		UITools.NearTarget(oBtn, oView.m_Bg, enum.UIAnchor.Side.Top)
	end)
end

function CWarAutoMenu.OnSelSummonMagic(self, oBtn)
	CWarSelAutoView:ShowView(function(oView)
		oView:SetIsHero(false)
		UITools.NearTarget(oBtn, oView.m_Bg, enum.UIAnchor.Side.Top)
	end)
end

function CWarAutoMenu.OnClickAutoBattle(self)
	g_NotifyCtrl:FloatMsg("该模式只能自动战斗")
end

return CWarAutoMenu