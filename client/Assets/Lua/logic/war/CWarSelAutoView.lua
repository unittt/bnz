local CWarSelAutoView = class("CWarSelAutoView", CViewBase)

function CWarSelAutoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarSelAutoView.prefab", cb)

	self.m_GroupName = "WarOrder"
	self.m_ExtendClose = "ClickOut"
end

function CWarSelAutoView.OnCreateView(self)
	self.m_MagicGrid = self:NewUI(1, CGrid)
	self.m_ExtraGrid = self:NewUI(2, CGrid)
	self.m_RepositionTable = self:NewUI(3, CTable)
	self.m_MagicBoxClone = self:NewUI(4, CBox)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_Bg = self:NewUI(6, CSprite)
	self.m_CurSelID = nil
	self.m_MagicBoxClone:SetActive(false)
end

function CWarSelAutoView.SetIsHero(self, bIsHero)
	self.m_IsHero = bIsHero
	if self.m_IsHero then
		self.m_NameLabel:SetText("选择人物自动技能")
		self.m_CurSelID = g_WarCtrl:GetHeroAutoMagic()
	else
		self.m_NameLabel:SetText("选择宠物自动技能")
		self.m_CurSelID = g_WarCtrl:GetSummonAutoMagic()
	end
	self:RefreshMagic()
end

function CWarSelAutoView.RefreshMagic(self)
	self.m_MagicGrid:Clear()
	local lMagics = self:GetMagicList()
	for i, magicid in ipairs(lMagics) do
		local oBox = self:CreateMagicBox(magicid)
		self.m_MagicGrid:AddChild(oBox)
	end
	self.m_MagicGrid:Reposition()
	local lExtraMagics = self:GetExtraMagicList()
	self.m_ExtraGrid:Clear()
	for i, magicid in ipairs(lExtraMagics) do
		local oBox = self:CreateMagicBox(magicid)
		oBox.m_Bg:SetActive(false)
		oBox.m_Panel:SetClipping(enum.UIDrawCall.Clipping.None)
		-- oBox.m_Bg:SetStaticSprite("WarAtlas", "h7_di_32")
		oBox.m_NameLabel:SetActive(false)
		self.m_ExtraGrid:AddChild(oBox)
	end
	self.m_ExtraGrid:Reposition()
	self.m_RepositionTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_RepositionTable.m_Transform)
	self.m_Bg:SetHeight(bounds.max.y-bounds.min.y+20)
end

function CWarSelAutoView.CreateMagicBox(self, magicid)
	local oBox = self.m_MagicBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_Icon = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_Bg = oBox:NewUI(3, CSprite)
	oBox.m_Panel = oBox:NewUI(4, CPanel)
	oBox.m_MaigID = magicid
	local mgdata = DataTools.GetMagicData(magicid)
	oBox.m_Icon:SpriteMagic(magicid)
	oBox.m_NameLabel:SetText(mgdata.name)
	oBox:AddUIEvent("click", callback(self, "OnSelMagic"))
	oBox:AddUIEvent("longpress", callback(self, "OnMagicDetail"))
	oBox:SetLongPressTime(0.5)
	oBox:SetSelected(self.m_CurSelID == magicid)
	if not g_SkillCtrl:IsMagicCanUse(magicid) then
		local oLCol = Color.RGBAToColor("AF302AFF")
		oBox.m_Icon:SetGrey(true)
		oBox.m_NameLabel:SetColor(oLCol)
		oBox.m_UIToggle.activeSprite = nil
	else
		oBox:SetGroup(self:GetInstanceID())		
	end
	return oBox
end

function CWarSelAutoView.GetMagicList(self)
	if self.m_IsHero then
		return g_WarCtrl:GetHeroMagicList()
	else
		return g_WarCtrl:GetSummonMagicList()
	end
end

function CWarSelAutoView.GetExtraMagicList(self)
	return {101, 102}
end

function CWarSelAutoView.OnSelMagic(self, oBox)
	if g_MarrySkillCtrl:IsMarryMagic(oBox.m_MaigID) and not g_MarrySkillCtrl:IsMagicCanUse(oBox.m_MaigID) then
		return
	end
	local cd = g_SkillCtrl:GetMagicCd(oBox.m_MaigID, self.m_IsHero)
	if cd and cd > 0 then
		g_NotifyCtrl:FloatMsg(string.format("还有%d个回合才能使用该技能", cd))
		return
	end
	g_WarCtrl:SetAutoMagic(oBox.m_MaigID, self.m_IsHero)
	local iWar = g_WarCtrl:GetWarID()
	if iWar then
		if self.m_IsHero then
			netwar.C2GSChangeAutoPerform(iWar, g_WarCtrl.m_HeroWid, oBox.m_MaigID)
		elseif g_WarCtrl.m_SummonWid and g_WarCtrl.m_SummonWid > 0 then
			netwar.C2GSChangeAutoPerform(iWar, g_WarCtrl.m_SummonWid, oBox.m_MaigID)
		end
	end
	self:CloseView()
end

function CWarSelAutoView.OnMagicDetail(self, oBox, bPress)
	if bPress then
		CMagicDescView:CloseView()
		CMagicDescView:ShowView(function (oView)
			oView:SetMagic(oBox.m_MaigID, self.m_IsHero)
			oView:RegisterTouch(oBox)
		end)
	end
end

function CWarSelAutoView.Destroy(self)
	CMagicDescView:CloseView()
	CViewBase.Destroy(self)
end

return CWarSelAutoView