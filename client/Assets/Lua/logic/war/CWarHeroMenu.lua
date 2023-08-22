local CWarHeroMenu = class("CWarHeroMenu", CBox)

function CWarHeroMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_VBtnGrid = self:NewUI(1, CGrid) --竖着的按钮
	self.m_VBtnGrid:InitChild(function (obj, idx)  
		return CButton.New(obj)
	end)

	self.m_bZhenQiFull = false

	self.m_HBtnGrid = self:NewUI(2, CGrid) --横着的按钮
	self.m_QuickIcon = self:NewUI(3, CSprite)
	self.m_HBtnGrid:InitChild(function (obj, idx) return CButton.New(obj) end)

	self.m_QuickBtn = self.m_VBtnGrid:GetChild(1)
	self.m_MagicBtn = self.m_VBtnGrid:GetChild(2)
	self.m_SpecialSkillBtn = self.m_VBtnGrid:GetChild(3)
	self.m_AttackBtn = self.m_VBtnGrid:GetChild(4)
	self.m_ItemBtn = self.m_VBtnGrid:GetChild(5)

	self.m_EscapeBtn = self.m_HBtnGrid:GetChild(1)
	self.m_ProtectBtn = self.m_HBtnGrid:GetChild(2)
	self.m_DefendBtn = self.m_HBtnGrid:GetChild(3)
	self.m_FabaoBtn = self.m_HBtnGrid:GetChild(4)
	self.m_SummonBtn = self.m_HBtnGrid:GetChild(5)

	g_GuideCtrl:AddGuideUI("war_magic_btn", self.m_MagicBtn)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))

	self:InitContent()
end

function CWarHeroMenu.InitContent(self)
	self.m_QuickBtn:AddUIEvent("click", callback(self, "OnQuick"))
	self.m_QuickBtn:AddUIEvent("longpress", callback(self, "OnPressQuick"))
	self.m_QuickBtn:SetLongPressTime(0.5)
	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnItem"))
	self.m_MagicBtn:AddUIEvent("click", callback(self, "OnMagic"))
	self.m_AttackBtn:AddUIEvent("click", callback(self, "OnAttack"))
	self.m_SpecialSkillBtn:AddUIEvent("click", callback(self, "OnSpecialSkill"))

	self.m_FabaoBtn:AddUIEvent("click", callback(self, "OnFaBao"))

	self.m_EscapeBtn:AddUIEvent("click", callback(self, "OnEscape"))
	self.m_ProtectBtn:AddUIEvent("click", callback(self, "OnProtect"))
	self.m_DefendBtn:AddUIEvent("click", callback(self, "OnDefend"))
	self.m_SummonBtn:AddUIEvent("click", callback(self, "OnSummon"))
	self:RefreshQuickSkill()
	self:RefreshSpecialSkill()
	self:RefreshFaBaoSkill()
	self.m_VBtnGrid:Reposition()
end

function CWarHeroMenu.RefreshQuickSkill(self, refreshrid)

	local dData = DataTools.GetMagicData(g_WarCtrl.m_QuickMagicIDHero)
	if dData.magic_type == "fabao" then
		self.m_QuickBtn:SetActive(false)
		return
	end

	local showQuick = g_WarCtrl.m_QuickMagicIDHero ~= nil
	self.m_QuickBtn:SetActive(showQuick)
	if showQuick then
		self.m_QuickIcon:SpriteMagic(g_WarCtrl.m_QuickMagicIDHero)
		if refreshrid then
			self.m_VBtnGrid:Reposition()
		end
		local bGrey = not g_SkillCtrl:IsMagicCanUse(g_WarCtrl.m_QuickMagicIDHero)
		self.m_QuickIcon:SetGrey(bGrey)
	end

end

function CWarHeroMenu.RefreshSpecialSkill(self, refreshrid)
	local list = g_WarCtrl:GetHeroSpecialSkillList()
	self.m_SpecialSkillBtn:SetActive(#list > 0)
	if refreshrid then
		self.m_VBtnGrid:Reposition()
	end
end

function CWarHeroMenu.RefreshFaBaoSkill(self)
	local sklist = g_WarCtrl:GetFaBaoMagicList()
	self.m_FabaoBtn:SetActive(#sklist > 0)
	self.m_VBtnGrid:Reposition()
end

function CWarHeroMenu.RefreshFaBaoEffect(self)
	local maxZhenqi = data.fabaodata.CONFIG[1].zhenqi_limit
	local curZhenqi = g_SkillCtrl:GetCurZhenqi()
	if curZhenqi >= maxZhenqi then
		self.m_FabaoBtn:AddEffect("Circu", Vector2.New(-36, 0))
		--self.m_FabaoBtn.m_IgnoreCheckEffect = true
		self.m_bZhenQiFull = true
	else
		if self.m_bZhenQiFull == false then
			return
		end
		self.m_FabaoBtn:DelEffect("Circu")
		self.m_bZhenQiFull = false
	end
end

function CWarHeroMenu.OnQuick(self, oBtn)
	CMagicDescView:CloseView()
	if g_MarrySkillCtrl:IsMarryMagic(g_WarCtrl.m_QuickMagicIDHero) and not g_MarrySkillCtrl:IsMagicCanUse(g_WarCtrl.m_QuickMagicIDHero) then
		return
	end
	local cd = g_SkillCtrl:GetMagicCd(g_WarCtrl.m_QuickMagicIDHero, true)
	if cd and cd > 0 then
		g_NotifyCtrl:FloatMsg(string.format("还有%d个回合才能使用该技能", cd))
		return
	end
	g_WarOrderCtrl:SetHeroOrder("Magic", g_WarCtrl.m_QuickMagicIDHero)
end

function CWarHeroMenu.OnPressQuick(self, oBtn, bPress)
	if bPress then
		CMagicDescView:CloseView()
		CMagicDescView:ShowView(function (oView)
			oView:SetMagic(g_WarCtrl.m_QuickMagicIDHero, true)
			oView:RegisterTouch(oBtn)
		end)
	end
end

function CWarHeroMenu.OnItem(self, oBtn)
	CWarItemView:ShowView(function (oView)
		oView:SetIsHero(true)
	end)
end

function CWarHeroMenu.OnMagic(self, oBtn)
	if g_WarCtrl.m_IsFirstSpecityWar then
		local oView = CWarMainView:GetView()
		if oView then
			oView.m_Content:EnableTouch(false)
		end
	end
	CWarMagicView:ShowView(function(oView)
		oView:SetIsHero(true)
		oView:RefreshGrid()
		oView:SetNearTarget(oBtn)
	end)
end

function CWarHeroMenu.OnFaBao(self, oBtn)
	CWarMagicView:ShowView(function(oView)
		oView:SetFaBaoTitle()
		oView:RefreshFaBaoSkillGrid()
		oView:SetNearTargetBottom(oBtn)
	end)
end

function CWarHeroMenu.OnSpecialSkill(self, oBtn)
	CWarMagicView:ShowView(function(oView)
		oView:SetIsHero(true, true)
		oView:RefreshGrid()
		oView:SetNearTarget(oBtn)
	end)
end

function CWarHeroMenu.OnAttack(self, oBtn)
	g_WarOrderCtrl:SetHeroOrder("Attack")
end

function CWarHeroMenu.OnEscape(self, oBtn)
	g_WarOrderCtrl:SetHeroOrder("Escape")
end

function CWarHeroMenu.OnProtect(Self, oBtn)
	g_WarOrderCtrl:SetHeroOrder("Protect")
end

function CWarHeroMenu.OnDefend(self, oBtn)
	g_WarOrderCtrl:SetHeroOrder("Defend")
end

function CWarHeroMenu.OnSummon(self, oBtn)
	CWarSummonView:ShowView(function(oView)
		UITools.NearTarget(oBtn, oView.m_NearSpr, enum.UIAnchor.Side.Top)
	end)
end

function CWarHeroMenu.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.UpdateZhenQi then
		self:RefreshFaBaoEffect()
	end
end

return CWarHeroMenu