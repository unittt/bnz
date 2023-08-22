local CWarSummonMenu = class("CWarSummonMenu", CBox)

function CWarSummonMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_VBtnGrid = self:NewUI(1, CGrid) --竖着的按钮
	self.m_VBtnGrid:InitChild(function (obj, idx) return CButton.New(obj) end)

	self.m_HBtnGrid = self:NewUI(2, CGrid) --横着的按钮
	self.m_QuickIcon = self:NewUI(3, CSprite)
	self.m_HBtnGrid:InitChild(function (obj, idx) return CButton.New(obj) end)

	self.m_QuickBtn = self.m_VBtnGrid:GetChild(1)
	self.m_MagicBtn = self.m_VBtnGrid:GetChild(2)
	self.m_AttackBtn = self.m_VBtnGrid:GetChild(3)
	self.m_ItemBtn = self.m_VBtnGrid:GetChild(4)

	self.m_EscapeBtn = self.m_HBtnGrid:GetChild(1)
	self.m_ProtectBtn = self.m_HBtnGrid:GetChild(2)
	self.m_DefendBtn = self.m_HBtnGrid:GetChild(3)

	self:RefreshQuickSkill(true)
	self:InitContent()
end

function CWarSummonMenu.InitContent(self)
	self.m_QuickBtn:AddUIEvent("click", callback(self, "OnQuick"))
	self.m_QuickBtn:AddUIEvent("longpress", callback(self, "OnPressQuick"))
	self.m_QuickBtn:SetLongPressTime(0.5)
	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnItem"))
	self.m_MagicBtn:AddUIEvent("click", callback(self, "OnMagic"))
	self.m_AttackBtn:AddUIEvent("click", callback(self, "OnAttack"))

	self.m_EscapeBtn:AddUIEvent("click", callback(self, "OnEscape"))
	self.m_ProtectBtn:AddUIEvent("click", callback(self, "OnProtect"))
	self.m_DefendBtn:AddUIEvent("click", callback(self, "OnDefend"))
end

function CWarSummonMenu.RefreshQuickSkill(self, refreshrid)
	local skillID = g_WarCtrl:GetSummonQuickSkill()
	local showQuick = skillID ~= nil
	self.m_QuickBtn:SetActive(showQuick)
	if showQuick then
		self.m_QuickIcon:SpriteMagic(skillID)
		if refreshrid then
			self.m_VBtnGrid:Reposition()
		end
		local bGrey = not g_SkillCtrl:IsMagicCanUse(skillID)
		self.m_QuickIcon:SetGrey(bGrey)
	end
end

function CWarSummonMenu.OnQuick(self, oBtn)
	CMagicDescView:CloseView()
	local skillID = g_WarCtrl:GetSummonQuickSkill()
	if skillID then
		local cd = g_SkillCtrl:GetMagicCd(skillID, false)
		if cd and cd > 0 then
			g_NotifyCtrl:FloatMsg(string.format("还有%d个回合才能使用该技能", cd))
			return
		end
		g_WarOrderCtrl:SetSummonOrder("Magic", skillID)
	end
end

function CWarSummonMenu.OnPressQuick(self, oBtn, bPress)
	if bPress then
		local skillID = g_WarCtrl:GetSummonQuickSkill()
		if skillID then
			CMagicDescView:CloseView()
			CMagicDescView:ShowView(function (oView)
				oView:SetMagic(skillID)
				oView:RegisterTouch(oBtn)
			end)
		end
	end
end

function CWarSummonMenu.OnItem(self, oBtn)
	CWarItemView:ShowView(function (oView)
		oView:SetIsHero(false)
	end)
end

function CWarSummonMenu.OnMagic(self, oBtn)
	local lSkills = g_WarCtrl:GetSummonMagicList()
	if next(lSkills) then
		CWarMagicView:ShowView(function(oView)
			oView:SetIsHero(false)
			oView:RefreshGrid()
			oView:SetNearTarget(oBtn)
		end)
		return
	end
	g_NotifyCtrl:FloatMsg("当前宠物没有主动技能")
end

function CWarSummonMenu.OnAttack(self, oBtn)
	g_WarOrderCtrl:SetSummonOrder("Attack")
end

function CWarSummonMenu.OnEscape(self, oBtn)
	g_WarOrderCtrl:SetSummonOrder("Escape")
end

function CWarSummonMenu.OnProtect(Self, oBtn)
	g_WarOrderCtrl:SetSummonOrder("Protect")
end

function CWarSummonMenu.OnDefend(self, oBtn)
	g_WarOrderCtrl:SetSummonOrder("Defend")
end

return CWarSummonMenu