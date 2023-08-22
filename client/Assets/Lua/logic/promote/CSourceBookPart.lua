local CSourceBookPart = class("CSourceBookPart", CPageBase)

function CSourceBookPart.ctor(self, obj)
	-- body
	CPageBase.ctor(self, obj)
	self.m_TabDic = {}
	self.m_CurrStype = nil
	self.m_TimeCount = 0
	self.m_Timer = {}
end

function CSourceBookPart.OnInitPage(self)
	-- body
	--self.m_MainCatalogneSV = self:NewUI(1, CScrollView)
	-- self.m_MainCatalognGrid = self:NewUI(2, CGrid)
	-- self.m_MainBatalognBtn = self:NewUI(3, CBox)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Table = self:NewUI(2, CTable)
	self.m_MenuBoxClone = self:NewUI(3, CSourceBookMenuBox)
	self.m_RightPart  = self:NewUI(4, CBox)

	self.m_EquipPart = self.m_RightPart:NewUI(1, CSourceEquipBox) --装备大全
	self.m_UpgroupStrategyPart =self.m_RightPart:NewUI(2, CSourceUpgroupStrategyBox)  --升级攻略 == 玩法大全
	self.m_SummonPart = self.m_RightPart:NewUI(3, CSourceSummonBox) -- 宠物说明
	self.m_GameTechPart =self.m_RightPart:NewUI(4, CSourceGameTechBox)  --游戏技巧
	self.m_CamBatSkillPart =self.m_RightPart:NewUI(5, CSourceCamBatSkillBox)  -- 战斗技能
	self.m_PartnerPart =self.m_RightPart:NewUI(6, CSourcePartnerBox)  -- 伙伴说明
	self.m_HelpSkillPart =self.m_RightPart:NewUI(7, CSourceHelpSkillBox)  -- 辅助技能

	self.m_TabDic = {
					SOURCE_EQUIP = self.m_EquipPart,
					SOURCE_UPGRADE_TECH = self.m_UpgroupStrategyPart,
					SOURCE_SUMMON = self.m_SummonPart,
					SOURCE_GAME_TECH = self.m_GameTechPart,
					SOURCE_CAMBAT_SKILL = self.m_CamBatSkillPart,
					SOURCE_PARTNER = self.m_PartnerPart,
					SOURCE_HELP_SKILL = self.m_HelpSkillPart,
				}
	self:InitContent()
end

-- function CSourceBookPart.InitContent(self)
-- 	-- body
-- 	local SourceBookList =  g_PromoteCtrl:GetSysOpenSourceBook()
-- 	self.m_MainCatalognGrid:Clear()
-- 	local btnlist = self.m_MainCatalognGrid:GetChildList()
-- 	for i,v in ipairs(SourceBookList) do
-- 		local box = nil
-- 		if i> #btnlist then
-- 			box = self.m_MainBatalognBtn:Clone()
-- 			box:SetActive(true)
-- 			self.m_MainCatalognGrid:AddChild(box)
-- 			box.btn =  box:NewUI(1, CButton)
-- 			box.btn:SetGroup(self.m_MainCatalognGrid:GetInstanceID())

-- 			box.normname = box:NewUI(2, CLabel)
-- 			box.flagname = box:NewUI(3, CLabel)
-- 			box.normname:SetText(v.name)
-- 			box.flagname:SetText(v.name)
-- 			box.btn:AddUIEvent("click", callback(self, "OnClickMainBtn" , v.stype))
-- 		end
-- 	end
-- 	self.m_MainCatalognGrid:Reposition()
-- 	--self.m_MainCatalogneSV:ResetPosition()
-- 	self.m_MainCatalognGrid:GetChild(1).btn:SetSelected(true)
-- 	self:OnClickMainBtn(SourceBookList[1].stype)
-- end

function CSourceBookPart.InitContent(self)
	local SourceBookList =  g_PromoteCtrl:GetSysOpenSourceBook()

	local btnlist = self.m_Table:GetChildList()
	local groupID = self.m_Table:GetInstanceID()
	for i, v in ipairs(SourceBookList) do
		local box = nil
		if i> #btnlist then
			box = self.m_MenuBoxClone:Clone()

			box.m_IsClick = false
			box:RefMenuBox(v)
			box.m_MenuBtn:SetGroup(groupID)
			box.m_MenuBtn:AddUIEvent("click", callback(self, "OnClickMenuBtn", i, v.stype))

			box:SetActive(true)
			self.m_Table:AddChild(box)
		end
	end
	self.m_Table:Reposition()
	self.m_ScrollView:ResetPosition()

	self:OnClickMenuBtn(1, "SOURCE_CAMBAT_SKILL") --默认选择第一个
end

function CSourceBookPart.OnClickMenuBtn(self, idx, stype)

	local btnlist = self.m_Table:GetChildList()
	for i, oBtn in ipairs(btnlist) do
		if idx ~= i then
			oBtn.m_TweenRotation:Play(false)
			oBtn.m_SelTweenRotation:Play(false)
			self:TweenHeightAndFinished(oBtn, false)
			oBtn.m_IsClick = false
		else
			local bPlay = not oBtn.m_IsClick

			oBtn.m_TweenRotation:Play(not bPlay)
			oBtn.m_SelTweenRotation:Play(bPlay)
			self:TweenHeightAndFinished(oBtn, bPlay)

			oBtn.m_IsClick = bPlay
			oBtn.m_MenuBtn:SetSelected(true)
			oBtn:SetDefaultSelect()
		end
	end

	if self.m_CurrStype == stype then
		return
	end
	self.m_CurrStype = stype

	for k, v in pairs(self.m_TabDic) do
		v:SetActive(stype == k)
	end
end

function CSourceBookPart.TweenHeightAndFinished(self, box, bPlay)

	box.m_TweenHeight:Play(bPlay)

	if bPlay then
		box.m_SubMenuBgSpr:SetActive(true) 
		return 
	end

	self.m_TimeCount = self.m_TimeCount + 1
	local function progress()
		box.m_SubMenuBgSpr:SetActive(false)
		return false
	end
	self.m_Timer[self.m_TimeCount] = Utils.AddTimer(progress, 0, 0.3)
end

function CSourceBookPart.Destroy(self)
	CPageBase.Destroy(self)
	self.m_Timer = nil
end

return CSourceBookPart