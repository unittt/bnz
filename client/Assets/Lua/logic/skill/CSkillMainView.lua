local CSkillMainView = class("CSkillMainView", CViewBase)

function CSkillMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/SkillMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_IsFuzhuClick = false
end

function CSkillMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CTabGrid)
	
	self.m_SchoolPart = self:NewPage(3, CSkillSchoolPart)      --招式
	self.m_PassivePart = self:NewPage(4, CSkillPassivePart)      --心法
	self.m_CultivationPart = self:NewPage(5, CSkillCultivatePart) --修炼
	self.m_OrgPart = self:NewPage(6, CAttrSkillPart)
	self.m_TitleSpr = self:NewUI(7, CSprite)
	self.m_TalismanPart = self:NewPage(8, CSkillTalismanPart)
	self.m_ItemWealthBox = self:NewUI(9, CItemWealthBox)

	-- self.m_FourTabGrid = self:NewUI(9, CGrid)
	-- self.m_OrgSkillBtn = self:NewUI(10, CButton)
	-- self.m_TalismanBtn = self:NewUI(11, CButton)
	self.m_OrgBox = self:NewUI(12, CBox)
	self.m_TalismanBox = self:NewUI(13, CBox)
	self.m_OrgClickBtn = self.m_OrgBox:NewUI(1, CWidget)
	self.m_OrgArrowSp = self.m_OrgBox:NewUI(2, CSprite)
	self.m_OrgHeightTweenWidget = self.m_OrgBox:NewUI(3, CWidget)
	self.m_OrgTweenScrollView = self.m_OrgBox:NewUI(4, CScrollView)
	self.m_OrgSelArrowSp = self.m_OrgBox:NewUI(5, CSprite)
	-- self.m_OrgGrid = self.m_OrgBox:NewUI(5, CGrid)
	-- self.m_OrgBoxClone = self.m_OrgBox:NewUI(6, CBox)

	self.m_TalismanClickBtn = self.m_TalismanBox:NewUI(1, CWidget)
	self.m_TalismanArrowSp = self.m_TalismanBox:NewUI(2, CSprite)
	self.m_TalismanHeightTweenWidget = self.m_TalismanBox:NewUI(3, CWidget)
	self.m_TalismanTweenScrollView = self.m_TalismanBox:NewUI(4, CScrollView)
	self.m_TalismanSelArrowSp = self.m_TalismanBox:NewUI(5, CSprite)
	-- self.m_TalismanGrid = self.m_TalismanBox:NewUI(5, CGrid)
	-- self.m_TalismanBoxClone = self.m_TalismanBox:NewUI(6, CBox)

	self.m_TypeScrollView = self:NewUI(14, CScrollView)
	self.m_TypeTable = self:NewUI(15, CTable)

	-- 情缘技能
	self.m_QingYuanBox = self:NewUI(16, CBox)
	self.m_QingYuanClickBtn = self.m_QingYuanBox:NewUI(1, CWidget)
	self.m_QingYuanArrowSp = self.m_QingYuanBox:NewUI(2, CSprite)
	self.m_QingYuanHeightTweenWidget = self.m_QingYuanBox:NewUI(3, CWidget)
	self.m_QingYuanTweenScrollView = self.m_QingYuanBox:NewUI(4, CScrollView)
	self.m_QingYuanSelArrowSp = self.m_QingYuanBox:NewUI(5, CSprite)

	self.m_QingYuanPart = self:NewPage(17, CQingYuanPart)

	self.m_SkillGuideWidget = self:NewUI(18, CWidget)
	self.m_SkillGuideWidget2 = self:NewUI(19, CWidget)
	self.m_SkillGuideWidget3 = self:NewUI(20, CWidget)

	g_GuideCtrl:AddGuideUI("skill_guide_widget", self.m_SkillGuideWidget)
	g_GuideCtrl:AddGuideUI("skill_guide_widget2", self.m_SkillGuideWidget2)
	g_GuideCtrl:AddGuideUI("skill_guide_widget3", self.m_SkillGuideWidget3)

	self.m_OpenSysList = {
		define.System.SkillZD,
		define.System.SkillBD,
		define.System.Cultivation,
		define.System.OrgSkill,
		define.System.Talisman,
		define.System.QingYuan,
	}

	self.m_WidgetsList = {
		[4] = self.m_OrgHeightTweenWidget,
		[5] = self.m_TalismanHeightTweenWidget,
		[6] = self.m_QingYuanHeightTweenWidget,
	}

	self.m_ArrowTweenList = {
		[4] = {
			self.m_OrgArrowSp,
			self.m_OrgSelArrowSp,
		},
		[5] = {
			self.m_TalismanArrowSp,
			self.m_TalismanSelArrowSp,
		},
		[6] = {
			self.m_QingYuanArrowSp,
			self.m_QingYuanSelArrowSp,
		},
	}

	self.m_Pages = {"School", "Passive", "Cultivation", "Org", "Talisman", "QingYuan"}

	g_GuideCtrl:AddGuideUI("skill_close_btn", self.m_CloseBtn)

	self:InitContent()
end


function CSkillMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj, false, true)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)
	self.m_SchoolBtn = self.m_BtnGrid:GetChild(1)
	self.m_PassiveBtn = self.m_BtnGrid:GetChild(2)
	self.m_CultivateBtn = self.m_BtnGrid:GetChild(3)
	self.m_OrgBtn = self.m_BtnGrid:GetChild(4)

	-- self.m_OrgSkillBtn:SetGroup(self:GetInstanceID()-1)
	-- self.m_TalismanBtn:SetGroup(self:GetInstanceID()-1)
	self.m_OrgClickBtn:SetGroup(self:GetInstanceID()-1)
	self.m_TalismanClickBtn:SetGroup(self:GetInstanceID()-1)
	self.m_QingYuanClickBtn:SetGroup(self:GetInstanceID()-1)

	g_GuideCtrl:AddGuideUI("skill_passive_tab_btn", self.m_PassiveBtn)
	g_GuideCtrl:AddGuideUI("skill_cultivate_tab_btn", self.m_CultivateBtn)
	g_GuideCtrl:AddGuideUI("skill_org_tab_btn", self.m_OrgBtn)

	self:InitTab()

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- self.m_OrgSkillBtn:AddUIEvent("click", callback(self, "OnClickOrgSkillBtn"))
	-- self.m_TalismanBtn:AddUIEvent("click", callback(self, "OnClickTalismanBtn"))
	self.m_OrgClickBtn:AddUIEvent("click", callback(self, "OnOrgSkillClickBtn"))
	self.m_TalismanClickBtn:AddUIEvent("click", callback(self, "OnTalismanClickBtn"))
	self.m_QingYuanClickBtn:AddUIEvent("click", callback(self, "OnQingYuanClickBtn"))
	for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
		if i == 4 then
			oTab:AddUIEvent("click", callback(self, "OnClickFuzhuTab"))
		else
			oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
		end
	end

	if g_SkillCtrl.m_LastTab then
		self:ShowSubPageByIndex(g_SkillCtrl.m_LastTab)
	else
		for i, v in ipairs(self.m_OpenSysList) do
			if g_OpenSysCtrl:GetOpenSysState(v) then
				local page = self.m_Pages[i]
				self:ShowSubPageByIndex(self:GetPageIndex(page))
				break
			end
		end
	end

	-- if g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[1]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("School"))
	-- elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[2]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("Passive"))
	-- elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[3]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("Cultivation"))
	-- elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[4]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("Org"))
	-- elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[5]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("Talisman"))
	-- elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[6]) then
	-- 	self:ShowSubPageByIndex(self:GetPageIndex("QingYuan"))
	-- end

	self:RegisterSysEffs()
end

function CSkillMainView.InitTab(self)

	local bSkillZDOpen = g_OpenSysCtrl:GetOpenSysState(define.System.SkillZD)
	local bSkillBDOpen = g_OpenSysCtrl:GetOpenSysState(define.System.SkillBD)
	local bCultivationOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Cultivation)

	local bOrgSkillOpen = g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill)
	local bTalismanOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Talisman)
	local bQingYuanOpen = g_OpenSysCtrl:GetOpenSysState(define.System.QingYuan)

	self.m_SchoolBtn:SetActive(bSkillZDOpen)
	self.m_PassiveBtn:SetActive(bSkillBDOpen)
	self.m_CultivateBtn:SetActive(bCultivationOpen)
	self.m_OrgBtn:SetActive(bOrgSkillOpen or bTalismanOpen or bQingYuanOpen)
	-- self.m_OrgSkillBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill))
	-- self.m_TalismanBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Talisman))
	-- self.m_FourTabGrid:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill) or g_OpenSysCtrl:GetOpenSysState(define.System.Talisman))
	self.m_OrgBox:SetActive(bOrgSkillOpen)
	self.m_TalismanBox:SetActive(bTalismanOpen)
	self.m_QingYuanBox:SetActive(bQingYuanOpen)
	self.m_TypeScrollView:SetActive(bOrgSkillOpen or bTalismanOpen or bQingYuanOpen)

	self.m_BtnGrid:Reposition()
	-- self.m_FourTabGrid:Reposition()
	self.m_TypeTable:Reposition()
	self.m_TypeScrollView:ResetPosition()
end

function CSkillMainView.ShowSubPageByIndex(self, iIndex, ...)

	if iIndex < 4 then
		self.m_IsFuzhuClick = false
	end

	if not g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[iIndex], true) then
		return
	end
	local nameList = {"h7_manpaizhaoshi", "h7_menpaixinfa", "h7_xiulianjineng", "h7_bangpaijineng_2", "h7_bangpaijineng_2", "h7_bangpaijineng_2"}
	self.m_TitleSpr:SetSpriteName(nameList[iIndex])
	local oTab = self.m_BtnGrid:GetChild(iIndex <= 4 and iIndex or 4)
	oTab:SetSelected(true)
	if iIndex == 4 then
		self.m_TypeScrollView:SetActive(true)
		self.m_OrgClickBtn:SetSelected(true)
	elseif iIndex == 5 then
		self.m_TypeScrollView:SetActive(true)
		self.m_TalismanClickBtn:SetSelected(true)
	elseif iIndex == 6 then
		self.m_TypeScrollView:SetActive(true)
		self.m_QingYuanClickBtn:SetSelected(true)
	else
		self.m_TypeScrollView:SetActive(false)
	end
	self:OnSelectTab(iIndex)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
	g_SkillCtrl:RecordLastTab(iIndex)
end

function CSkillMainView.GetCultivatePart(self)
	return self.m_CultivationPart
end

function CSkillMainView.JumpToOrgSkillByItem(self, iItem, skillid)
	self.m_OrgPart:JumpToSkillByItem(iItem, skillid)
end

function CSkillMainView.OnClickOrgSkillBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Org"))
end

function CSkillMainView.OnClickTalismanBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Talisman"))
end

function CSkillMainView.OnSelectTab(self, iTab)
	local oWidget = self.m_WidgetsList[iTab]

	if not oWidget then
		return
	end

	local oHeight = oWidget:GetHeight()
	local bForward = oHeight > 50
	self:ArrowRotate(iTab, bForward)

	if bForward then --已展开，则回收
		for k, v in pairs(self.m_WidgetsList) do
			local talismanTween = v:GetComponent(classtype.TweenHeight)
			talismanTween.enabled = true
			talismanTween:PlayReverse()
			-- talismanTween.from = 2
			-- talismanTween.to = 420
			-- talismanTween.duration = 0.3
			-- talismanTween:ResetToBeginning()
			-- talismanTween.delay = 0
			-- talismanTween.onFinished = function ()
			-- end
		end
		return
	end

	local orgTween = oWidget:GetComponent(classtype.TweenHeight)
	orgTween.enabled = true
	orgTween.from = 2
	orgTween.to = (iTab == 4) and 380 or 420
	--orgTween.to = 380
	orgTween.duration = 0.3
	orgTween:ResetToBeginning()
	orgTween.delay = 0
	orgTween:PlayForward()
	orgTween.onFinished = function ()
		--剧情技能引导相关
		-- local sCondition = CGuideData["PlotSkill"].necessary_condition
		-- if g_GuideCtrl:IsNeedGuide("PlotSkill") and g_GuideCtrl:CallGuideFunc(sCondition) then
		-- 	if iTab == 5 then
		-- 		g_GuideCtrl:AddGuideUI("skill_guide_talisman_btn", self.m_TalismanClickBtn)
		-- 		g_GuideCtrl:Continue()
		-- 	elseif iTab == 4 then
				
		-- 	end
		-- end

		g_GuideCtrl:AddGuideUI("skill_guide_talisman_btn", self.m_TalismanClickBtn)
	end

	for k, v in pairs(self.m_WidgetsList) do
		if k ~= iTab then
			local talismanTween = v:GetComponent(classtype.TweenHeight)
			talismanTween.enabled = true
			talismanTween:PlayReverse()
			-- talismanTween.from = 2
			-- talismanTween.to = 420
			-- talismanTween.duration = 0.3
			-- talismanTween:ResetToBeginning()
			-- talismanTween.delay = 0
			-- talismanTween.onFinished = function ()
			-- end
		end
	end	
end

function CSkillMainView.ArrowRotate(self, idx, bForward)
	local oTweens = self.m_ArrowTweenList[idx]
	if not oTweens then
		return
	end

	for i, v in ipairs(oTweens) do
		local tweenRotation = v:GetComponent(classtype.TweenRotation)
		tweenRotation:Play(not bForward)
	end
end

function CSkillMainView.OnOrgSkillClickBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Org"))
end

function CSkillMainView.OnTalismanClickBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Talisman"))
end

function CSkillMainView.OnQingYuanClickBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("QingYuan"))
end

function CSkillMainView.OnClickFuzhuTab(self)
	if self.m_IsFuzhuClick then
		return
	end
	self.m_IsFuzhuClick = true
	--剧情引导的一些处理
	if g_SkillCtrl.m_IsPlotSkillGuide and g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[5]) then
		g_SkillCtrl.m_IsPlotSkillGuide = false
		self:ShowSubPageByIndex(self:GetPageIndex("Talisman"))
		return
	end

	if g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[4]) then
		self:ShowSubPageByIndex(self:GetPageIndex("Org"))
	elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[5]) then
		self:ShowSubPageByIndex(self:GetPageIndex("Talisman"))
	elseif g_OpenSysCtrl:GetOpenSysState(self.m_OpenSysList[6]) then
		self:ShowSubPageByIndex(self:GetPageIndex("QingYuan"))
	end
end

function CSkillMainView.CloseView(self)
	CViewBase.CloseView(self)
end

function CSkillMainView.RegisterSysEffs(self)
	g_SysUIEffCtrl:TryAddEff("HELPSKILL", self.m_OrgBtn)
	g_SysUIEffCtrl:TryAddEff("XIU_LIAN_SYS", self.m_CultivateBtn)
	g_SysUIEffCtrl:DelSysEff("SKILL_SYS")
end

return CSkillMainView
