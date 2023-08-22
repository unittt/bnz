local CWarMagicView = class("CWarMagicView", CViewBase)

function CWarMagicView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarMagicView.prefab", cb)
	--界面设置
	self.m_GroupName = "WarOrder"
	self.m_ExtendClose = "ClickOut"
end

function CWarMagicView.OnCreateView(self)
	self.m_BoxClone = self:NewUI(1, CBox)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_NearSpr = self:NewUI(3, CSprite)
	self.m_TitleL = self:NewUI(4, CLabel)
	self.m_ZhenqiL = self:NewUI(5, CLabel)
	self.m_BoxClone:SetActive(false)
end

function CWarMagicView.SetIsHero(self, bHero, bSpecialSkill)
	self.m_IsHero = bHero
	self.m_IsSpecialSKill = bSpecialSkill
	if self.m_IsHero then
		self.m_TitleL:SetText("选择人物自动技能")
	else
		self.m_TitleL:SetText("选择宠物自动技能")
	end
end

function CWarMagicView.SetFaBaoTitle(self)
	self.m_IsHero = true
	self.m_TitleL:SetText("选择法宝技能")
end

function CWarMagicView.RefreshFaBaoSkillGrid(self)
	-- 获取所有已佩戴法宝的主动技能 --
	local lSkills = g_WarCtrl:GetFaBaoMagicList()

	self.m_Grid:Clear()
	for i, magicid in ipairs(lSkills) do
		local oBox = self:NewMagicBox(magicid)
		self.m_Grid:AddChild(oBox)
	end

	local zhenqi = g_SkillCtrl:GetCurZhenqi()
	self.m_ZhenqiL:SetActive(true)
	self.m_ZhenqiL:SetText("真气: "..zhenqi)

	local iRowCnt = math.ceil(#lSkills/3)
	if iRowCnt > 1 then
		local height = self.m_NearSpr:GetHeight()
		local _, cellHeight = self.m_Grid:GetCellSize()
		self.m_NearSpr:SetHeight(height + (iRowCnt-1)*cellHeight)
	end
	self.m_RowCnt = iRowCnt
end

function CWarMagicView.RefreshGrid(self)
	self.m_Grid:Clear()
	local lSkills = self:GetMagicList()
	for i, magicid in ipairs(lSkills) do
		local oBox = self:NewMagicBox(magicid)
		self.m_Grid:AddChild(oBox)

		if i == 1 then
			g_GuideCtrl:AddGuideUI("war_magic_box1_btn", oBox)
		end
	end
	local iRowCnt = math.ceil(#lSkills/3)
	if iRowCnt > 1 then
		local height = self.m_NearSpr:GetHeight()
		local _, cellHeight = self.m_Grid:GetCellSize()
		self.m_NearSpr:SetHeight(height + (iRowCnt-1)*cellHeight)
	end
	self.m_RowCnt = iRowCnt
end

function CWarMagicView.SetNearTarget(self, oTarget)
	if self.m_RowCnt > 1 then
		UITools.NearTarget(oTarget, self.m_NearSpr, enum.UIAnchor.Side.TopLeft, Vector2.New(0, -200))
	else
		UITools.NearTarget(oTarget, self.m_NearSpr, enum.UIAnchor.Side.BottomLeft, Vector2.New(0, 100))
	end
end

function CWarMagicView.SetNearTargetBottom(self, oTarget)
	UITools.NearTarget(oTarget, self.m_NearSpr, enum.UIAnchor.Side.TopLeft, Vector2.New(160, 20))
end

function CWarMagicView.NewMagicBox(self, magicid)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_MaigID = magicid
	oBox:SetActive(true)
	local oIconSpr = oBox:NewUI(1, CSprite)
	local oNameLabel = oBox:NewUI(2, CLabel)
	local oDescLabel = oBox:NewUI(5, CLabel)
	local dData = DataTools.GetMagicData(magicid)
	oIconSpr:SpriteSkill(dData.skill_icon)
	oNameLabel:SetText(dData.name)
	oDescLabel:SetText(dData.type_desc)
	if not g_SkillCtrl:IsMagicCanUse(magicid) then
		local oLCol = Color.RGBAToColor("AF302AFF")
		oIconSpr:SetGrey(true)
		oNameLabel:SetColor(oLCol)
		oDescLabel:SetColor(oLCol)
	end
	oBox:AddUIEvent("click", callback(self, "OnChooseMagic"))
	if not g_WarCtrl.m_IsFirstSpecityWar then
		oBox:AddUIEvent("longpress", callback(self, "OnMagicDetail"))
		oBox:SetLongPressTime(0.5)
	end
	return oBox
end

function CWarMagicView.ShowTipEffect(self, oBox, bShow)
	local oArrow = oBox.m_Arrow
	if bShow then
		if not oArrow then
			oArrow = self:CreateTipEffect(self, oBox)
		else
			oArrow:SetActive(true)			
		end
	else
		if oArrow then
			oArrow:SetActive(false)
		end
	end
end

function CWarMagicView.CreateTipEffect(self, oBox)
	-- local 
	local oArrow = CObject

	return oArrow
end

function CWarMagicView.OnChooseMagic(self, oBox)
	if g_MarrySkillCtrl:IsMarryMagic(oBox.m_MaigID) and not g_MarrySkillCtrl:IsMagicCanUse(oBox.m_MaigID) then
		return
	end
	local cd = g_SkillCtrl:GetMagicCd(oBox.m_MaigID, self.m_IsHero)
	if cd and cd > 0 then
		g_NotifyCtrl:FloatMsg(string.format("还有%d个回合才能使用该技能", cd))
		return
	end
	if self.m_IsHero then
		g_WarOrderCtrl:SetHeroOrder("Magic", oBox.m_MaigID)
	else
		g_WarOrderCtrl:SetSummonOrder("Magic", oBox.m_MaigID)
	end
	self:CloseView()
end


function CWarMagicView.GetMagicList(self)
	if self.m_IsHero then
		if self.m_IsSpecialSKill then
			return g_WarCtrl:GetHeroSpecialSkillList()
		else
			return g_WarCtrl:GetHeroMagicList()
		end
	else
		return g_WarCtrl:GetSummonMagicList()
	end
end

function CWarMagicView.OnMagicDetail(self, oBox, bPress)
	if bPress then
		CMagicDescView:CloseView()
		CMagicDescView:ShowView(function (oView)
			oView:SetMagic(oBox.m_MaigID, self.m_IsHero)
			UITools.NearTarget(self.m_NearSpr, oView.m_Bg, enum.UIAnchor.Side.Left, Vector2.New(-10, 0))
			oView:RegisterTouch(oBox)
		end)
	end
end

-- 处理g_ViewCtrl:CloseGroup
function CWarMagicView.Destroy(self)
	CMagicDescView:CloseView()
	CViewBase.Destroy(self)
end

return CWarMagicView
