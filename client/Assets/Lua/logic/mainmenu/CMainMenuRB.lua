local CMainMenuRB = class("CMainMenuRB", CBox)

function CMainMenuRB.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_HBtnFirstGrid = self:NewUI(1, CGrid)
	self.m_HideBtn = self:NewUI(2, CButton)
	self.m_BagContent = self:NewUI(3, CObject)
	self.m_ItemBtn = self:NewUI(4, CButton)
	self.m_BagItemFullLabel = self:NewUI(5, CLabel)
	self.m_BagItemRedSpr = self:NewUI(6, CSprite)
	self.m_OrgRedPoint = self:NewUI(7, CSprite)
	-- self.m_OrgInviteBtn = self:NewUI(8, CButton)
	self.m_HBtnSecondGrid = self:NewUI(9, CGrid)
	self.m_QuickMsgBox = self:NewUI(10, CQuickMsgBox)
	self.m_ExpandBtn = self:NewUI(11, CButton)
	self.m_TempBagBtn = self:NewUI(12 ,CButton)
	self.m_WishBottleBtn = self:NewUI(13 ,CButton)
	self.m_WishBottleTimeLabel = self:NewUI(14 ,CLabel)
	self.m_BadgeBtn = self:NewUI(15, CButton)
	self.m_TempGrid = self:NewUI(16, CGrid)
	self.m_RideBtn = self:NewUI(17, CButton)
	self.m_ArtifactBtn = self:NewUI(18, CButton)
	self.m_WingBtn = self:NewUI(19, CButton)
	self.m_FabaoBtn = self:NewUI(20, CButton)
	self.m_CenterBox = self:NewUI(21, CBox)
	self.m_LingxiChuChongBtn = self.m_CenterBox:NewUI(1, CButton)
	self.m_LingxiJiaoShuiBtn = self.m_CenterBox:NewUI(2, CButton)

	self.m_HBtnFirstGrid:InitChild(function (obj, idx) return CButton.New(obj) end)
	self.m_HBtnSecondGrid:InitChild(function (obj, idx) return CButton.New(obj) end)
	self.m_TempGrid:InitChild(function (obj, idx) return CButton.New(obj) end)
		
	self.m_OrgBtn = self.m_HBtnFirstGrid:GetChild(1)
	self.m_SkillBtn = self.m_HBtnFirstGrid:GetChild(2)
	self.m_PartnerBtn = self.m_HBtnFirstGrid:GetChild(3)
	self.m_ForgeBtn = self.m_HBtnFirstGrid:GetChild(4)
	self.m_JjcBtn = self.m_HBtnFirstGrid:GetChild(5)

	self.m_HorseBtn = self.m_TempGrid:GetChild(4)

	
	self.m_SystemSettingsBtn = self.m_HBtnSecondGrid:GetChild(1)
	
	--屏蔽掉竞技场按钮
	-- self.m_JjcBtn:SetActive(false)

	self:InitContent()

	self.m_IsFade = false

end

function CMainMenuRB.InitContent(self)
	g_GuideCtrl:AddGuideUI("mainmenu_hide_btn", self.m_HideBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_skillbtn", self.m_SkillBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_org_btn", self.m_OrgBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_forge_btn", self.m_ForgeBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_horse_btn", self.m_HorseBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_partner_btn", self.m_PartnerBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_badge_btn", self.m_BadgeBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_wing_btn", self.m_WingBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_fabao_btn", self.m_FabaoBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_artifact_btn", self.m_ArtifactBtn)

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLoginEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendMsgEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))
	g_NotifyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyEvent"))
	g_ItemTempBagCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "RefreshTempBagItem"))
	g_WishBottleCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self,"OnWishBottleEvent"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
	g_WingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWingEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFormationEvent"))
	g_FeedbackCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFeedbackEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	
	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnItem"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnPartner"))
	self.m_SkillBtn:AddUIEvent("click", callback(self, "OnSkill"))
	self.m_ForgeBtn:AddUIEvent("click", callback(self, "OnForge"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "HideButton"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnOrgBtn"))
	self.m_JjcBtn:AddUIEvent("click", callback(self, "OnJjcBtn"))
	self.m_BadgeBtn:AddUIEvent("click", callback(self, "OnBadgeBtn"))
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OnExpandMenu"))
	self.m_RideBtn:AddUIEvent("click", callback(self, "OnRideBtn"))
	self.m_ArtifactBtn:AddUIEvent("click", callback(self, "OnArtifactBtn"))
	self.m_WingBtn:AddUIEvent("click", callback(self, "OnWingBtn"))
	self.m_FabaoBtn:AddUIEvent("click", callback(self, "OnFaBaoBtn"))
	self.m_LingxiChuChongBtn:AddUIEvent("click", callback(self, "OnLingxiChuChongBtn"))
	self.m_LingxiJiaoShuiBtn:AddUIEvent("click", callback(self, "OnLingxiJiaoShuiBtn"))
	
	self.m_HorseBtn:AddUIEvent("click", callback(self, "OnHorse"))
	self.m_SystemSettingsBtn:AddUIEvent("click", callback(self, "OnSystemSettingsBtnClicked"))
	self.m_TempBagBtn:AddUIEvent("click",callback(self,"OnC2GSMsg"))
	self.m_WishBottleBtn:AddUIEvent("click",callback(self,"OnClickWishBottle"))
	self.m_WishBottleBtn.m_IgnoreCheckEffect = true
	self.m_SystemSettingsBtn.m_IgnoreCheckEffect = true
	
	self:BindMenuArea()
	-- TODO:未实现功能的按钮暂时隐藏
	self:ResetBagItemTip()
	self:RefreshOrgRedPoint()
	self:InitFriendMsgBtn()
	self:CheckMenuBtnUnlock()
	self:CheckSysOpenBtn()
	self:CheckTempItemBtn()
	self:CheckWishBottleBtn()
	self:CheckFlyRideBtn()
	self:RefreshPartnerRedPoint()
	self:RefreshWingBtn()
	self:RegisterSysEffs()
	self:RefreshPartnerBtn()
	self:RefreshSystemSettingsBtn()
	self:RefreshLingxiQteBtn()
end


function CMainMenuRB.BindMenuArea(self)
	local tweenPos_1 = self.m_HBtnFirstGrid:GetComponent(classtype.TweenPosition)
	local tweenPos_2 = self.m_HBtnSecondGrid:GetComponent(classtype.TweenPosition)
	local tweenRotation = self.m_HideBtn:GetComponent(classtype.TweenRotation)
	local callback = function()
		tweenRotation:Toggle()
	end
	local tweenPos_3 = self.m_BagContent:GetComponent(classtype.TweenPosition)
	local tweenPos_4 = self.m_QuickMsgBox:GetComponent(classtype.TweenPosition)
	local tweenPos_5 =self.m_TempGrid:GetComponent(classtype.TweenPosition)

	local tweenAlpha_1 = self.m_ExpandBtn:GetComponent(classtype.TweenAlpha)
	local tweenAlpha_2 = self.m_HideBtn:GetComponent(classtype.TweenAlpha)

	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Function_1, tweenPos_1, callback)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Function_2, tweenPos_2, nil, false)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Bag, tweenPos_3)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.QuickMsg, tweenPos_4)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.ExpandBtn, tweenAlpha_1)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.HideMenuBtn, tweenAlpha_2)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Temp, tweenPos_5)
end

function CMainMenuRB.SetActive(self, b)
	CBox.SetActive(self, b)
	-- 显示时处理菜单状态
	if b then
		g_MainMenuCtrl:SetRBFunctionAreaShow()
	end
end

function CMainMenuRB.CheckTempItemBtn(self)
	if 	#g_ItemTempBagCtrl.m_TempBagList > 0 then 
		self.m_TempBagBtn:SetActive(true)
	else
		self.m_TempBagBtn:SetActive(false)
	end
	self.m_TempGrid:Reposition()
end
--临时背包
function CMainMenuRB.OnC2GSMsg(self)
	-- body
	nettempitem:C2GSOpenTempItemUI()
end
--------------------------Control Event处理---------------------------------------
function CMainMenuRB.RefreshTempBagItem(self,  oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshTempBag 
	or oCtrl.m_EventID == define.Item.Event.AddItemToTempBag then
	
		if #g_ItemTempBagCtrl.m_TempBagList > 0  then
			self.m_TempBagBtn:SetActive(true)
		else
			self.m_TempBagBtn:SetActive(false)
		end
		self.m_TempGrid:Reposition()
	end
	if oCtrl.m_EventID == define.Item.Event.AddItemToTempBag then
		self.m_TempBagBtn:AddEffect("Circu")
	end
end
function CMainMenuRB.OnNotifyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MainMenu.Event.BagIconEffect then
		local function onEnd()
			DOTween.DOScale(self.m_ItemBtn.m_Transform, 1, 0.2)
		end
		local tween = DOTween.DOScale(self.m_ItemBtn.m_Transform, 0.7, 0.2)
		DOTween.OnComplete(tween, onEnd)
	end
end

function CMainMenuRB.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		-- self:CheckMenuBtnUnlock()
		self:CheckFlyRideBtn()
		self:CheckFabaoBtn()
	end
end

function CMainMenuRB.OnLoginEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Login or oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:CheckSysOpenBtn()
		self:CheckMenuBtnUnlock()
		self:CheckWishBottleBtn()
	end
end

function CMainMenuRB.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshRefineRedPoint then
		self:ResetBagItemTip()
	elseif oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local sid = oCtrl.m_EventData
		self:CheckFabaoRedPoint(sid)
	end
end

function CMainMenuRB.OnMailEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Mail.Event.Sort or oCtrl.m_EventID == define.Mail.Event.OpenMails then
		self.m_QuickMsgBox:RefreshMailBtn()
	end
end

function CMainMenuRB.OnFriendMsgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Talk.Event.AddFriendMsg or oCtrl.m_EventID == define.Talk.Event.AddNotify then
		self.m_FriendPid = oCtrl.m_EventData
		local oView = CFriendInfoView:GetView()
		if oView then
			self.m_QuickMsgBox:RefreshFriendMsgBtn(false)
		else
			self.m_QuickMsgBox:RefreshFriendMsgBtn(true)
		end
	end
end

function CMainMenuRB.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgRedPoint then
        self:RefreshOrgRedPoint()
	end
end

function CMainMenuRB.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.UpdatePromoteData then
        self:RefreshPartnerRedPoint()
	end
end

function CMainMenuRB.OnMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene then
		self.m_QuickMsgBox:RefreshArenaBtn(false)
	elseif oCtrl.m_EventID == define.Map.Event.CheckHeroInArena then
		self.m_QuickMsgBox:RefreshArenaBtn(oCtrl.m_EventData)
	end
end

function CMainMenuRB.OnTeamEvent(self, oCtrl)
	if  oCtrl.m_EventID == define.Team.Event.NotifyApply or
		 oCtrl.m_EventID == define.Team.Event.NotifyInvite or
		 oCtrl.m_EventID == define.Team.Event.ClearApply or
		 oCtrl.m_EventID == define.Team.Event.AddTeam
		 then
		self.m_QuickMsgBox:RefrehTeamNotifyTip()
	end
end

function CMainMenuRB.OnWishBottleEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WishBottle.Event.ReceiveBottle then
		self:CheckWishBottleBtn()
	elseif oCtrl.m_EventID == define.WishBottle.Event.UpdateBottleTime then
		self:UpdateBottleBtnTime(oCtrl.m_EventData)
	end
end

function CMainMenuRB.OnWingEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Wing.Event.RefreshWingBtn then
		self:RefreshWingBtn()
	end
end

function CMainMenuRB.OnFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.RefreshGuildStatus then
		self:RefreshPartnerBtn()
	end
end

function CMainMenuRB.OnFeedbackEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Feedback.Event.RefreshFeedbackRedPt then
		self:RefreshSystemSettingsBtn()
	end
end

function CMainMenuRB.OnTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.LingxiQte then
		self:RefreshLingxiQteBtn()
	end
end

--------------------------按钮刷新----------------------------------
function CMainMenuRB.ResetBagItemTip(self)
	local list = g_ItemCtrl:GetBagItemListByType(g_ItemCtrl.m_BagTypeEnum.all)
	local dvalue = g_ItemCtrl.m_BagOpenCount - #list
	if dvalue < 0 then
		dvalue = 0
	end
	local showFullTip = dvalue < 6
	self.m_BagItemFullLabel:SetActive(showFullTip)
	if showFullTip then
		if dvalue > 0 then
			self.m_BagItemFullLabel:SetText(dvalue)
		else
			self.m_BagItemFullLabel:SetText("满")
		end
	end

	local showRedSpr = (g_ItemCtrl.m_ItemEffList and #g_ItemCtrl.m_ItemEffList > 0) or g_ItemCtrl.m_ShowRefineRedPoint
	self.m_BagItemRedSpr:SetActive(showRedSpr)
end

--初始化执行，根据本地保存的好友或陌生人的红点通知数据来设置消息通知按钮显不显示
function CMainMenuRB.InitFriendMsgBtn(self)
	g_TalkCtrl:GetRecentNotifySaveData()
	local iAmount = g_TalkCtrl:GetTotalNotify()
	if iAmount > 0 then
		self.m_QuickMsgBox:RefreshFriendMsgBtn(true)
	else
		self.m_QuickMsgBox:RefreshFriendMsgBtn(false)
	end
end

-- 刷新帮派红点
function CMainMenuRB.RefreshOrgRedPoint(self)
	if g_AttrCtrl.org_id == 0 then
		self.m_OrgRedPoint:SetActive(false)
		return
	end

	local info = g_OrgCtrl.m_LoginOrgRedPontInfo
	local bIsNotSign = info.sign_status == 0
    local bIsNotBonus = info.bonus_status == 1
    local bIsNotPos = info.pos_status == 1
    local bIsShopNotify = info.shop_status == 1

    local showRedPoint = bIsNotSign or bIsNotPos or bIsNotBonus or bIsShopNotify
	if g_RedPacketCtrl.m_ShowOrgRedPoint or showRedPoint then
		self.m_OrgRedPoint:SetActive(true)
		return
	end
	if next(info) == nil then  -- 没有收到协议
		self.m_OrgRedPoint:SetActive(false)
		return
	end

	-- 有入帮申请
	if info.has_apply == 1 then
		self.m_OrgRedPoint:SetActive(true)
	-- 有自荐为帮主信息（且不是我）
	elseif info.apply_leader_pid ~= 0 and info.apply_leader_pid ~= g_AttrCtrl.pid then
		self.m_OrgRedPoint:SetActive(true)
	-- 不显示红点
	else
		self.m_OrgRedPoint:SetActive(false)
	end
end

function CMainMenuRB.RefreshPartnerRedPoint(self)
	if g_PromoteCtrl.m_IsHasNewPartnerCouldUnLock or g_PromoteCtrl.m_IsHasNewPartnerCouldUpgrade then
		self.m_PartnerBtn.m_IgnoreCheckEffect = true
		self.m_PartnerBtn:AddEffect("RedDot", 22, Vector2(-18, -21))
	else
		self.m_PartnerBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.CheckFabaoRedPoint(self, itemsid)

	if not self.m_FabaoBtn:GetActive() then
		return
	end

	if itemsid then
		local slist = {10155, 10156, 10157, 10158}
		if table.index(slist, itemsid) then
			local bPromoteRed = g_FaBaoCtrl:GetFaBaoPromoteRedPot()
			local bAwakenRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
			if bPromoteRed or bAwakenRed then
				self.m_FabaoBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
			end
		end
	else
		local bPromoteRed = g_FaBaoCtrl:GetFaBaoPromoteRedPot()
		local bAwakenRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
		if bPromoteRed or bAwakenRed then
			self.m_FabaoBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
		end
	end
end

-- 显示解锁菜单
function CMainMenuRB.CheckMenuBtnUnlock(self)	
	
	self.m_HBtnFirstGrid:Reposition()
	self.m_HBtnSecondGrid:Reposition()
end

--检查是需要系统开放效果的按钮
function CMainMenuRB.CheckSysOpenBtn(self)
	self.m_SkillBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Skill))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Skill) then
		self.m_SkillBtn:SetActive(false)
	end
	self.m_ForgeBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Forge))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Forge) then
		self.m_ForgeBtn:SetActive(false)
	end
	self.m_OrgBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Org))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Org) then
		self.m_OrgBtn:SetActive(false)
	end
	self.m_PartnerBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Partner))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Partner) then
		self.m_PartnerBtn:SetActive(false)
	end
	self.m_HorseBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Horse))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Horse) then
		self.m_HorseBtn:SetActive(false)
	end
	self.m_BadgeBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Badge))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Badge) then
		self.m_BadgeBtn:SetActive(false)
	end
	self.m_JjcBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.JJC))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.JJC) then
		self.m_JjcBtn:SetActive(false)
	end
	self.m_ArtifactBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Artifact))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Artifact) then
		self.m_ArtifactBtn:SetActive(false)
	end
	self.m_WingBtn:SetActive(g_WingCtrl:IsShowMainBtn())
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Wing) then
		self.m_WingBtn:SetActive(false)
	end

	self.m_FabaoBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.FaBao) and g_FaBaoCtrl:IsShowMainBtn())
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.FaBao) then
		self.m_FabaoBtn:SetActive(false)
	end

	self.m_HBtnFirstGrid:Reposition()
	self.m_HBtnSecondGrid:Reposition()
	self.m_TempGrid:Reposition()


	if g_AttrCtrl.pid ~= 0 and not Utils.IsNil(self) then
		g_OpenSysCtrl:AddUIInfo(define.System.Forge, self.m_ForgeBtn, function ()
			if not Utils.IsNil(self.m_HBtnFirstGrid) then
				self.m_HBtnFirstGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Org, self.m_OrgBtn, function ()
			if not Utils.IsNil(self.m_HBtnFirstGrid) then
				self.m_HBtnFirstGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Skill, self.m_SkillBtn, function ()
			if not Utils.IsNil(self.m_HBtnFirstGrid) then
				self.m_HBtnFirstGrid:Reposition()
			end
			-- self.m_HBtnFirstGrid.m_UIGrid.repositionNow = true
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Partner, self.m_PartnerBtn, function ()
			if not Utils.IsNil(self.m_HBtnFirstGrid) then
				self.m_HBtnFirstGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Horse, self.m_HorseBtn, function ()
			if not Utils.IsNil(self.m_TempGrid) then
				self.m_TempGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Badge, self.m_BadgeBtn, function ()
			if not Utils.IsNil(self.m_HBtnSecondGrid) then
				self.m_HBtnSecondGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.JJC, self.m_JjcBtn, function ()
			if not Utils.IsNil(self.m_HBtnFirstGrid) then
				self.m_HBtnFirstGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Artifact, self.m_ArtifactBtn, function ()
			if not Utils.IsNil(self.m_TempGrid) then
				self.m_TempGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Wing, self.m_WingBtn, function ()
			if not Utils.IsNil(self.m_TempGrid) then
				self.m_TempGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.FaBao, self.m_FabaoBtn, function ()
			if not Utils.IsNil(self.m_TempGrid) then
				self.m_TempGrid:Reposition()
			end
		end)
	end	

end

function CMainMenuRB.CheckWishBottleBtn(self)
	local iBottle = g_WishBottleCtrl:GetBottle()
	if iBottle > 0 then
		self.m_WishBottleBtn:SetActive(false)
		g_WishBottleCtrl:AskForBottleInfo()
	else
		self.m_WishBottleBtn:SetActive(iBottle ~= 0)
		self.m_WishBottleBtn:DelEffect("Rect")
	end
	self.m_TempGrid:Reposition()
end

function CMainMenuRB.UpdateBottleBtnTime(self, iTime)
	local bShow = self.m_WishBottleBtn:GetActive()
	if not bShow then
		self.m_WishBottleBtn:SetActive(true)
		self.m_TempGrid:Reposition()
	end
	self.m_WishBottleTimeLabel:SetActive(true)
	self.m_WishBottleBtn:AddEffect("Rect")
    self:RemoveTimer()
    local function update ()
        local iDiffTime = os.difftime(iTime, g_TimeCtrl:GetTimeS())
        if iDiffTime > 0 then
            self.m_WishBottleTimeLabel:SetText(os.date("%M:%S",iDiffTime))
            return true
        else
            self.m_WishBottleTimeLabel:SetText("00:00")
            g_WishBottleCtrl:UpdateBottleId(0)
            return false
        end
    end
    self.m_BottleBtnTimer = Utils.AddTimer(update, 1, 0)
end

function CMainMenuRB.RefreshWingBtn(self)
	self.m_WingBtn:SetActive(g_WingCtrl:IsShowMainBtn())
	self.m_TempGrid:Reposition()
end

function CMainMenuRB.RefreshPartnerBtn(self)
	if g_FormationCtrl.m_NeedGuideLearn then
		self.m_PartnerBtn.m_IgnoreCheckEffect = true
		self.m_PartnerBtn:AddEffect("Circu")
	else
		self.m_PartnerBtn:DelEffect("Circu")
	end
end

function CMainMenuRB.RefreshSystemSettingsBtn(self)
	if g_FeedbackCtrl.m_bShowRedpt then
		self.m_SystemSettingsBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
	else
		self.m_SystemSettingsBtn:DelEffect("RedDot")
	end
end

function CMainMenuRB.RefreshLingxiQteBtn(self)
	self.m_LingxiChuChongBtn:SetActive(false)
	self.m_LingxiJiaoShuiBtn:SetActive(false)
	if g_TaskCtrl.m_LingxiQteTypeDoing then
		if g_TaskCtrl.m_LingxiQteTypeDoing.type == 1 then
			self.m_LingxiChuChongBtn:SetActive(true)
		elseif g_TaskCtrl.m_LingxiQteTypeDoing.type == 2 then
			self.m_LingxiJiaoShuiBtn:SetActive(true)
		end
	end
end

--------------------------按钮响应----------------------------------

function CMainMenuRB.OnOrgBtn(self)
	printc("点击主界面右下角“帮派”按钮，g_AttrCtrl.org_status = " .. g_AttrCtrl.org_status)
	g_OrgCtrl:OpenOrgView()
end

--点击主界面竞技场按钮
function CMainMenuRB.OnJjcBtn(self)
	--跳舞允许操作
	-- if g_DancingCtrl.m_StateInfo then
	--    g_NotifyCtrl:FloatMsg("你正在舞会中，不可挑战")
	--    return
	-- end
	if g_BonfireCtrl.m_IsBonfireScene and (g_BonfireCtrl.m_CurActiveState == 2 or g_BonfireCtrl.m_CurActiveState == 1) then
	   g_NotifyCtrl:FloatMsg("你正在帮派篝火活动中，不可挑战")
	   return
	end
	g_JjcCtrl:OpenJjcMainView()
end

function CMainMenuRB.OnBadgeBtn(self)
	g_AttrCtrl:OpenBadgeView()
end

function CMainMenuRB.OnHorse(self)
	
	CHorseMainView:ShowView()

end

function CMainMenuRB.OnItem(self)
	CItemMainView:ShowView(function(oView)
		if g_ItemCtrl.m_ItemEffList and #g_ItemCtrl.m_ItemEffList > 0 then
			-- oView:ShowSubPageByIndex(oView:GetPageIndex("Bag"))
		elseif g_ItemCtrl.m_ShowRefineRedPoint then
			oView:ShowSubPageByIndex(oView:GetPageIndex("Refine"))
		end
	end)
end


function CMainMenuRB.DelFootCloudEffect(self)
	
	if self.m_FootCloudEffect then 
		self.m_FootCloudEffect:Destroy()
		self.m_FootCloudEffect = nil
	end 

end
function CMainMenuRB.OnRideBtn(self)

	if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
		g_NotifyCtrl:FloatMsg("归队状态下,只有队长可操作")
		return
	end

	local oCam = g_CameraCtrl:GetMapCamera()
	local oHero = g_MapCtrl:GetHero()

	if not oHero then 
		return
	end 

	if g_MapCtrl:CheckIsInWaterLine(oHero:GetPos()) then 
		local config = data.textdata.TEXT[3016]
		if config then 
			g_NotifyCtrl:FloatMsg(config.content)
		end 
		return
	end 

	if  oHero:IsInFlyState() then
		local mapData = DataTools.GetMapInfo(g_MapCtrl:GetMapID())
		if oHero and not oCam.curMap:IsWalkable(oHero:GetPos().x, oHero:GetPos().y) then
			g_NotifyCtrl:FloatMsg("请在陆地可以行走的区域降落")
			return
		end
	end

	if g_LimitCtrl:CheckIsCannotMove() or g_LimitCtrl:CheckIsCannotFly() then
		return
	end

	g_FlyRideAniCtrl:RequestFly(callback(self, "FlyDone"))
 
end

function CMainMenuRB.OnArtifactBtn(self)
	CArtifactMainView:ShowView(function (oView)		
		oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
	end)
end

function CMainMenuRB.OnWingBtn(self)
	g_WingCtrl:ShowWingPropertyPage()
end

function CMainMenuRB.OnFaBaoBtn(self)
	CFaBaoView:ShowView()
end

function CMainMenuRB.OnLingxiChuChongBtn(self)
	if not g_TaskCtrl.m_LingxiQteTypeDoing then
		return
	end
	nettask.C2GSTaskEvent(g_TaskCtrl.m_LingxiQteTypeDoing.taskid, g_TaskCtrl.m_LingxiQteTypeDoing.npcid)
end

function CMainMenuRB.OnLingxiJiaoShuiBtn(self)
	if not g_TaskCtrl.m_LingxiQteTypeDoing then
		return
	end
	nettask.C2GSTaskEvent(g_TaskCtrl.m_LingxiQteTypeDoing.taskid, g_TaskCtrl.m_LingxiQteTypeDoing.npcid)
end

function CMainMenuRB.CheckFabaoBtn(self)
	local opendata = DataTools.GetViewOpenData(define.System.FaBao)
	local openlevel = opendata.p_level
	if g_AttrCtrl.grade < openlevel or self.m_FabaoBtn:GetActive() then
		return
	end

	if g_OpenSysCtrl:GetOpenSysState(define.System.FaBao) then
		self.m_FabaoBtn:SetActive(g_AttrCtrl.grade >= openlevel)
		self.m_TempGrid:Reposition()  
	end
end 

function CMainMenuRB.FlyDone(self)
	if  g_AttrCtrl:GetHeroFlyState() == define.FlyRide.FlyState.Fly  then 
		self.m_RideBtn:SetSpriteName("h7_xiajiang")
	else
		self.m_RideBtn:SetSpriteName("h7_feixing")
	end 
end


function CMainMenuRB.CheckFlyRideBtn(self)

	if  g_AttrCtrl:GetHeroFlyState() == define.FlyRide.FlyState.Fly then 
		self.m_RideBtn:SetSpriteName("h7_xiajiang")
	else
		self.m_RideBtn:SetSpriteName("h7_feixing")
	end 
	
	self.m_RideBtn:SetActive(g_HorseCtrl:IsRideFly())
	self.m_TempGrid:Reposition()

end


function CMainMenuRB.HideFlyBtn(self)
	
	self.m_RideBtn:SetActive(false)

end


function CMainMenuRB.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Horse.Event.UseRide then
		self:CheckFlyRideBtn()
	end
end

function CMainMenuRB.OnPartner(self)
	CPartnerMainView:ShowView(function (oView)
		oView:ResetCloseBtn()
		--暂时屏蔽
		-- if g_GuideHelpCtrl:CheckPartner2UpgradeCondition() and not g_GuideCtrl.m_Flags["PartnerUpgrade"] then
		-- 	oView:SetSpecificPartnerIDNode(g_GuideHelpCtrl:GetPartner2())
		-- end

		if g_GuideHelpCtrl:GetPartner1() and g_GuideHelpCtrl:CheckNecessaryCondition("GetPartner") and not g_GuideCtrl.m_Flags["GetPartner"] 
			and not g_PartnerCtrl:GetRecruitPartnerDataByID(g_GuideHelpCtrl:GetPartner1()) then
			-- oView:SetSpecificPartnerIDNode(g_GuideHelpCtrl:GetPartner1())	
			local oTarget = oView.m_PartnerBoxNode.m_PartnerBoxGrid:GetChild(oView.m_PartnerBoxNode.m_GetPartnerIndex - 3)
			if oTarget then
				UITools.MoveToTarget(oView.m_PartnerBoxNode.m_PartnerBoxScroll, oTarget)
			end
		end
	end)
end

function CMainMenuRB.OnSkill(self)
	CSkillMainView:ShowView()
end

function CMainMenuRB.OnForge(self)
	CForgeMainView:ShowView()
end

function CMainMenuRB.HideButton(self)
	if g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Function_1) then
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Function_1)
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Temp)
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Function_2)
		g_MainMenuCtrl:SetCurrentFunctionArea({define.MainMenu.AREA.Function_2})
	else
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Function_2)
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Function_1)
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Temp)
		g_MainMenuCtrl:SetCurrentFunctionArea({define.MainMenu.AREA.Function_1, define.MainMenu.AREA.Temp})
	end
	g_SysUIEffCtrl:DelSysEff("JJC_SYS",2)
end

function CMainMenuRB.OnSystemSettingsBtnClicked(self)
	CSystemSettingsMainView:ShowView()
end

function CMainMenuRB.OnClickWishBottle(self)
	g_WishBottleCtrl:ShowBottleView()
end

function CMainMenuRB.OnExpandMenu(self)
	if g_MainMenuCtrl:IsMaskHandle() then
		printc("主界面操作禁止")
		return
	end
	g_MainMenuCtrl:ShowAllArea()
end

function CMainMenuRB.RemoveTimer(self)
    if self.m_BottleBtnTimer then
        Utils.DelTimer(self.m_BottleBtnTimer)
        self.m_BottleBtnTimer = nil
    end
end

function CMainMenuRB.Destroy(self)
	self:RemoveTimer()
	self:UnRegisterSysEffs()
end

function CMainMenuRB.RegisterSysEffs(self)
	g_SysUIEffCtrl:Register("PARTNER_SYS", self.m_PartnerBtn)
	g_SysUIEffCtrl:Register("RIDE_SYS", self.m_HorseBtn)
	g_SysUIEffCtrl:Register("SKILL_SYS", self.m_SkillBtn)
	g_SysUIEffCtrl:Register("EQUIP_SYS", self.m_ForgeBtn)
	g_SysUIEffCtrl:Register("BADGE", self.m_BadgeBtn)
	g_SysUIEffCtrl:Register("BAG_S", self.m_ItemBtn)
	g_SysUIEffCtrl:Register("JJC_SYS", self.m_HideBtn, 1, 2)
	g_SysUIEffCtrl:Register("JJC_SYS", self.m_JjcBtn)
	g_SysUIEffCtrl:Register("ARTIFACT", self.m_ArtifactBtn)
end

function CMainMenuRB.UnRegisterSysEffs(self)
	g_SysUIEffCtrl:UnRegister("PARTNER_SYS", self.m_PartnerBtn)
	g_SysUIEffCtrl:UnRegister("RIDE_SYS", self.m_HorseBtn)
	g_SysUIEffCtrl:UnRegister("SKILL_SYS", self.m_SkillBtn)
	g_SysUIEffCtrl:UnRegister("EQUIP_SYS", self.m_ForgeBtn)
	g_SysUIEffCtrl:UnRegister("BADGE", self.m_BadgeBtn)
	g_SysUIEffCtrl:UnRegister("BAG_S", self.m_ItemBtn)
	g_SysUIEffCtrl:UnRegister("JJC_SYS", self.m_JjcBtn)
	g_SysUIEffCtrl:UnRegister("ARTIFACT", self.m_ArtifactBtn)
end

function CMainMenuRB.SetHideBtnEffShow(self, bShow)
	local effs = self.m_HideBtn.m_Effects
	if effs and next(effs) then
		for i, oEff in pairs(effs) do
			oEff:SetActive(bShow)
		end
	end
end

return CMainMenuRB