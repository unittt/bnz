local CMainMenuLT = class("CMainMenuLT", CBox)

function CMainMenuLT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TopGrid = self:NewUI(1, CGrid)
	self.m_LeftGrid = self:NewUI(2, CGrid)
	-- self.m_FriendBtn = self:NewUI(3, CButton)
	-- self.m_MsgAmountBtn = self:NewUI(4, CButton)
	-- self.m_MailUnopen = self:NewUI(5, CSprite)
	self.m_MapInfoBox = self:NewUI(6, CBox)
	self.m_WelfareRedPoint = self:NewUI(7, CSprite)
	self.m_SchedulwRedPoint = self:NewUI(8, CSprite)
	self.m_SeviceObj = self:NewUI(9, CObject)
	self.m_GuideGrid = self:NewUI(10, CGrid)
	self.m_GuideBox = self:NewUI(11, CBox)
	self.m_FirstPayBtn = self:NewUI(12, CSprite)
	self.m_EcononmyRedPoint = self:NewUI(13, CSprite)
	--策划临时加了活动图标下实时显示领取的双倍点数
	self.m_DoublePointLbl = self:NewUI(14, CLabel)
	self.m_DoublePointSpr = self:NewUI(15, CSprite)
	self.m_PromoteRedPointSp = self:NewUI(16, CSprite)

	self.m_HelpBtn = self:NewUI(17, CButton)
	self.m_RankBtn = self:NewUI(18, CButton)
	self.m_WelfareBtn = self:NewUI(19, CButton)
	self.m_ScheduleBtn = self:NewUI(20, CButton)
	self.m_PromoteBtn = self:NewUI(21, CButton)
	self.m_CelebrationBtn = self:NewUI(22, CButton)
	self.m_BianQiangRedPoint = self:NewUI(23, CSprite)
	self.m_ShopBtn = self:NewUI(24, CButton)
	
	self.m_YoukaLoginBox = self:NewUI(25, CBox)
	self.m_newTip = self:NewUI(27, CSprite)
	self.m_TimeLimitBtn = self:NewUI(28, CButton)
	self.m_CaishenBtn = self:NewUI(29, CButton)

	self.m_SuperReBateBtn = self:NewUI(30, CButton)
	self.m_SuperrebateRedPot = self:NewUI(31, CSprite)

	self.m_SecondPayBtn = self:NewUI(32, CButton)

	self.m_AssembleTreasureBtn = self:NewUI(33, CButton)
	self.m_AssembleTreasurePt = self:NewUI(34, CSprite)
	self.m_EverydayRankBtn = self:NewUI(35, CButton)
	self.m_DiscountTip = self:NewUI(36, CSprite)

	self.m_YuanBaoJoyBtn = self:NewUI(37, CButton)
	self.m_YuanBaoJoyRedPoint = self:NewUI(38, CSprite)

	self.m_MysticalBoxBtn = self:NewUI(39, CButton)
	self.m_MysticalBoxRedPoint = self:NewUI(40, CSprite)
	self.m_MysticalBoxTime = self:NewUI(41, CLabel)
	self.m_GuideRoot = self:NewUI(42, CObject)
	self.m_MysticalBoxLingQu = self:NewUI(43, CLabel)

	self.m_RebateJoyBtn = self:NewUI(44, CButton)
	self.m_RebateJoyRedPoint = self:NewUI(45, CSprite)

	self.m_ShopYouhuiSp = self:NewUI(46, CSprite)
	self.m_DiscountSaleBtn = self:NewUI(47, CButton)

	self.m_ZeroBuyBtn = self:NewUI(48, CButton)
	self.m_ZeroBuyyRedPoint = self:NewUI(49, CSprite)

	self.m_ScheduleNotifyBtn = self:NewUI(50, CButton)
	self.m_ScheduleNameL = self:NewUI(51, CLabel)

	self.m_DuanWuBtn = self:NewUI(52, CButton)
	self.m_DuanWuBtnRedPoint = self:NewUI(53, CSprite)

	self.m_WorldCupBtn = self:NewUI(54, CButton)
	self.m_WorldCupBtnRedPoint = self:NewUI(55, CSprite)

	self.m_GuideTwoGrid = self:NewUI(56, CGrid)
	self.m_YoukaIcon = self.m_YoukaLoginBox:NewUI(1, CSprite)
	self.m_YoukaTimeLab = self.m_YoukaLoginBox:NewUI(2, CLabel)
	self.m_YoukaTipsLab = self.m_YoukaLoginBox:NewUI(3, CLabel)
	self.m_YoukaTimeSpr = self.m_YoukaLoginBox:NewUI(4, CSprite)
	self.m_YoukaGetTipsLab = self.m_YoukaLoginBox:NewUI(5, CLabel)
	
	self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.5, 0)
	self.m_DeviceTimer = Utils.AddTimer(callback(self, "RefreshDeviceStatus"), 5, 1)
	self:InitContent()	
end

function CMainMenuLT.InitContent(self)
	self.m_SuperrebateRedPot:SetActive(false) 

	self.m_YoukaLoginBox:SetActive(false)
	self.m_GuideBox:SetActive(false)
	self:InitGuideConfig()
	self:RealTimeDoublePoint(g_ScheduleCtrl.m_SvrDoublePoint.current)
	self:InitMapInfoBox()
	self:InitGuideGrid()
	self:InitTopGrid()
	self:InitLeftGrid()
	self:InitFirstPayBtn()
	self:InitSecondPayBtn()
	
	self:InitCtrlEvent()

	self:RefreshMapName(g_MapCtrl.m_SceneName)
	self:InitNetWork()
	self:BindMenuArea()
	self:RefreshMinMap()
	self:RefreshButton()
	self:CheckSysOpenBtn()

	--self:CheckNpcShop()
	self:UpdateNpcShopDiscount()

	self:RefreshScheduleBtnUITip()
	-- self:RefreshMsgAmount()
	-- self:RefreshMailUnopen()
	self:RefreshPromoteEvent()
	self:SetPreOpenList()
	self:RefreshEcononmyRedPoint(g_EcononmyCtrl.m_StallNotify or g_EcononmyCtrl.m_AuctionNotify)
	-- self:JudgeHideYoukaIcon()
	self.m_PromoteRedPointSp:SetActive(g_PromoteCtrl:CheckIsHasRedPoint())
	self:RegisterSysEffs()

	self:RefreshShopYouhuiSp()
end

function CMainMenuLT.InitGuideGrid(self)
	self.m_ShopBtn:AddUIEvent("click", callback(self, "OpenShopView"))
	self.m_SuperReBateBtn:AddUIEvent("click", callback(self, "OnSuperBateBtnClick"))
	self.m_YoukaLoginBox:AddUIEvent("click", callback(self, "OpenYoukaView"))
	self.m_TimeLimitBtn:AddUIEvent("click", callback(self, "OpenTimeLimitView"))
	self.m_CaishenBtn:AddUIEvent("click", callback(self, "OpenCaishenView"))
	self.m_AssembleTreasureBtn:AddUIEvent("click", callback(self, "OnAssembleTreasureView"))
	self.m_EverydayRankBtn:AddUIEvent("click", callback(self, "OPenEverydayRankView"))
	self.m_YuanBaoJoyBtn:AddUIEvent("click", callback(self, "OnClickYuanBaoJoyBtn"))
	self.m_MysticalBoxBtn:AddUIEvent("click", callback(self, "OnClickMysticalBoxBtn"))
	self.m_RebateJoyBtn:AddUIEvent("click", callback(self, "OnClickRebateJoyBtn"))
	self.m_DiscountSaleBtn:AddUIEvent("click", callback(self, "OnClickDiscountSaleBtn"))
	self.m_ZeroBuyBtn:AddUIEvent("click", callback(self, "OnClickZeroBuyBtn"))
	self.m_DuanWuBtn:AddUIEvent("click", callback(self, "OnClickDuanWuBtn"))
	self.m_WorldCupBtn:AddUIEvent("click", callback(self, "OnClickWorldCupBtn"))
end

function CMainMenuLT.InitGuideConfig(self)
	g_GuideCtrl:AddGuideUI("mainmenu_zhiyin_btn", self.m_HelpBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_welfare_btn", self.m_WelfareBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_schedule_btn", self.m_ScheduleBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_promote_btn", self.m_PromoteBtn)
	g_GuideCtrl:AddGuideUI("mainmenu_mysticalBox_btn", self.m_MysticalBoxBtn)
end

function CMainMenuLT.InitCtrlEvent(self)
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLoginEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSchduleEvent"))
	-- g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	-- g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBadgeEvent"))
	g_UpgradePacksCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpgradePackEvent"))
	g_SignCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSignEvent"))
	g_GuideHelpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnGuideHelpEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self,"OnWelfareEvent"))
	g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateCelebrationEvent"))
	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEcononmyEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNpcShopEvent"))
	g_LotteryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLotteryCtrlEvent"))
	g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineGiftEvent"))
	g_SuperRebateCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSuperRebateEvent"))
	g_AccumChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAccumChargeEvent"))
	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimeLimitCtrlEvent"))
	g_EveryDayChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEveryDayChargeCtrlEvent"))
	g_ActiveGiftBagCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActiveGiftBagCtrlEvent"))
	-- self.m_FriendBtn:AddUIEvent("click", callback(self, "OpenFriendInfoView"))
	g_AssembleTreasureCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAssembleTreasureCtrlEvent"))
	g_HeShenQiFuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHeShenQiFuEvent"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
    g_YuanBaoJoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlYuanBaoJoyEvent"))
    g_MysticalBoxCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMysticalBoxEvent"))
    g_RebateJoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRebateJoyEvent"))
    g_ItemInvestCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemInvestEvent"))
    g_ZeroBuyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnZeroBuyEvent"))
    g_DuanWuHuodongCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDuanWuHuodongEvent"))
    g_SoccerWorldCupGuessCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSoccerWorldCupGuessEvent"))
end

function CMainMenuLT.BindMenuArea(self)
	local tweenPos = self.m_TopGrid:GetComponent(classtype.TweenPosition)
	local tweenPos_1 = self.m_LeftGrid:GetComponent(classtype.TweenPosition)
	local tweenPos_2 = self.m_SeviceObj:GetComponent(classtype.TweenPosition)
	local tweenPos_3 = self.m_MapInfoBox:GetComponent(classtype.TweenPosition)
	local tweenPos_4 = self.m_GuideRoot:GetComponent(classtype.TweenPosition)
	local tweenAlpha_1 = self.m_GuideRoot:GetComponent(classtype.TweenAlpha)
	-- local tweenAlpha = self.m_FriendBtn:GetComponent(classtype.TweenAlpha)

	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Active, tweenPos)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Other, tweenPos_1)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Sevice, tweenPos_2)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.MinMap, tweenPos_3)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Guide, tweenPos_4)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.GuideAlpha, tweenAlpha_1)
	-- g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Friend, tweenAlpha)
end

function CMainMenuLT.InitMapInfoBox(self)
	local oBox = self.m_MapInfoBox
	oBox.m_BatterySlider = oBox:NewUI(1, CSlider)
	oBox.m_NetSprBox = oBox:NewUI(2, CBox)
	oBox.m_TimeLabel = oBox:NewUI(3, CLabel)
	oBox.m_MapLabel = oBox:NewUI(4, CLabel)
	oBox.m_PosLabel = oBox:NewUI(5, CLabel)
	oBox.m_WorldMapBtn = oBox:NewUI(6, CSprite)
	oBox.m_MiniMapBtn = oBox:NewUI(7, CWidget)

	oBox.m_WorldMapBtn:AddUIEvent("click", callback(self, "OnOpenMapView", 1))
	oBox.m_MiniMapBtn:AddUIEvent("click", callback(self, "OnOpenMapView", 2))
end

function CMainMenuLT.InitTopGrid(self)
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnPromote"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnRankBtn"))
	self.m_WelfareBtn:AddUIEvent("click", callback(self,"OnClickWelfareBtn"))
	self.m_ScheduleBtn:AddUIEvent("click", callback(self, "OpenScheduleView"))
	self.m_PromoteBtn:AddUIEvent("click", callback(self, "OnGuide"))
	self.m_ScheduleNotifyBtn:AddUIEvent("click", callback(self, "OnClickScheduleNotify"))
	-- self.m_DoublePointSpr:AddUIEvent("click", callback(self, "OpenScheduleView"))
	self.m_CelebrationBtn:AddUIEvent("click", callback(self, "OnClickCelebration"))
	self.m_CelebrationBtn.m_IgnoreCheckEffect = true
	self.m_ScheduleBtn.m_IgnoreCheckEffect = true
	self.m_WelfareBtn.m_IgnoreCheckEffect = true
	self.m_TimeLimitBtn.m_IgnoreCheckEffect = true
	self.m_RebateJoyBtn.m_IgnoreCheckEffect = true
	self.m_ShopBtn.m_IgnoreCheckEffect = true
end

function CMainMenuLT.InitLeftGrid(self)
	-- self.m_LeftGrid:InitChild(function (obj, idx) 
	-- 	if idx == 1 then
	-- 		return CButton.New(obj) 
	-- 	else
	-- 		return CBox.New(obj) 
	-- 	end
	-- end)
	-- self.m_ShopBtn = self.m_LeftGrid:GetChild(1)
	self.m_EcononmyBtn = self:NewUI(26, CButton)

	self.m_EcononmyBtn:AddUIEvent("click", callback(self, "OpenEcononmyView"))
end

function CMainMenuLT.InitNetWork(self)
	self.m_CurNetWork = 0
	local oBox = self.m_MapInfoBox
	local normalspr = oBox.m_NetSprBox:NewUI(1, CSprite)
	local wifispr1 = oBox.m_NetSprBox:NewUI(2, CSprite)
	local wifispr2 = oBox.m_NetSprBox:NewUI(3, CSprite)
	local wifispr3 = oBox.m_NetSprBox:NewUI(4, CSprite)
	self.m_NetWorkSpr = {normalspr, wifispr1, wifispr2, wifispr3}
end

function CMainMenuLT.InitFirstPayBtn(self)
	self.m_FirstPayBtn.m_IgnoreCheckEffect = true
	self.m_FirstPayBtn:AddUIEvent("click", callback(self, "OpenFirstPay"))
end

function CMainMenuLT.InitSecondPayBtn(self)
	local firstPayState = g_FirstPayCtrl:GetChargeStatus(1)
	--g_WelfareCtrl:GetChargeItemInfo("first_pay_reward")
	local secondPayState = g_WelfareCtrl:GetChargeItemInfo("second_pay_reward")
	--if firstPayState == nil then return end
	if firstPayState > 0 and secondPayState < 1 then
		self.m_SecondPayBtn:SetActive(true)
		self.m_SecondPayBtn.m_IgnoreCheckEffect = true
		self.m_SecondPayBtn:AddUIEvent("click", callback(self, "OpenSecondPay"))
	end
end

function CMainMenuLT.InitSuperRebateBtn(self)
	self.m_SuperReBateBtn:DelEffect("Circu")
	self.m_SuperReBateBtn:SetActive(false)
	if g_SuperRebateCtrl.m_SuperrebateTime and  g_SuperRebateCtrl.m_SuperrebateTime > 0 then
		if g_OpenSysCtrl:GetOpenSysState("SUPERREBATE") then
			self.m_SuperReBateBtn:SetActive(true)
			self.m_SuperReBateBtn:AddEffect("Circu")
		end
		-- self.m_SuperReBateBtn.m_IgnoreCheckEffect = true
	end
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.InitAssembleTreasureBtn(self)
	self.m_AssembleTreasureBtn:SetActive(g_AssembleTreasureCtrl:CheckOpenState())
	self.m_AssembleTreasurePt:SetActive(g_AssembleTreasureCtrl:HasMainMenuRedPt()) 
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.InitTimer(self)
	-- body
	self.m_YoukaLoginTimer = nil
end
---------------------UI refresh-------------------------------------

function CMainMenuLT.CheckNpcShop(self)

	--检查301、302商店是否需要新商品提示
	local newGoodList = g_ShopCtrl:GetNewGoodInShop()
	if table.count(newGoodList) == 0 then
		self.m_newTip:SetActive(false)
	else
		self.m_newTip:SetActive(true)
	end
	
end

function CMainMenuLT.UpdateNpcShopDiscount(self)
	local discountTime = g_ShopCtrl:GetDiscountEndTime()
	local curtime = g_TimeCtrl:GetTimeS()
	local bShow = (discountTime - curtime) > 0
	self.m_DiscountTip:SetActive(bShow)
end

function CMainMenuLT.RefreshMapName(self, sMapName)
	self.m_MapInfoBox.m_MapLabel:SetText(sMapName)
end

function CMainMenuLT.RefreshDeviceStatus(self)
	self:RefreshNetWork()
	self:RefreshBattery()
	return true
end

function CMainMenuLT.Update(self)
	local oHero = g_MapCtrl:GetHero()
	if Utils.IsExist(oHero) then
		local pos = oHero:GetLocalPos()
		local sText = string.format("%d,%d", math.floor(pos.x), math.floor(pos.y))
		self.m_MapInfoBox.m_PosLabel:SetText(sText)
	end
	self:RefreshTime()
	return true
end

function CMainMenuLT.RefreshNetWork(self)
	local status = 1
	if C_api.Utils.GetNetworkType() == "WIFI" then
		status = math.ceil((C_api.Utils.GetWifiSignal()/40)) + 1	
	else
		status = 1
	end

	local netTable = {{1},{2},{2,3},{2,3,4}}
	if not self.m_NetWorkSpr then
		return
	end

	if self.m_CurNetWork ~= status then
		self.m_CurNetWork = status
		local showSprTable = netTable[status]
		for i,spr in ipairs(self.m_NetWorkSpr) do
			if table.index(showSprTable, i) then
				spr:SetActive(true)
			else
				spr:SetActive(false)
			end
		end
	end
end

function CMainMenuLT.RefreshBattery(self)
	local iBattery = C_api.Utils.GetBatteryLevel()
	-- printc("电量："..iBattery)
	self.m_MapInfoBox.m_BatterySlider:SetValue(iBattery/100)
end

function CMainMenuLT.RefreshMinMap(self)
	local mapid = g_MapCtrl:GetMapID()
	local mapData = DataTools.GetMapInfo(mapid)
	if mapData then
		local sprName = string.format("minimap_%d", mapData.resource_id)
		self.m_MapInfoBox.m_WorldMapBtn:SetSpriteName(sprName)
	end
end

function CMainMenuLT.RefreshTime(self)
	local seconds = g_TimeCtrl:GetTimeS()
	self.m_MapInfoBox.m_TimeLabel:SetText(os.date("%H:%M", seconds))
end

function CMainMenuLT.RefreshButton(self)
	self:SetPreOpenList()
	self:RefreshCelebrationBtn()
	self.m_PromoteBtn:SetActive(next(g_PromoteCtrl.m_PromoteList) ~= nil and g_OpenSysCtrl:GetOpenSysState(define.System.Improve))
	self.m_HelpBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Zhiyin))
	-- self.m_WelfareBtn:SetActive(g_WelfareCtrl:IsHadOpenHuodong())
	self.m_WelfareBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Welfare))
	self.m_WelfareRedPoint:SetActive(g_WelfareCtrl:IsHadRedPoint())
	self:InitSuperRebateBtn()
	self:InitAssembleTreasureBtn()
	self:RefreshCelebrationRedPoint()
	self:RefreshCelebrationCircle()
	self:RefreshFirstPayBtn()
	self:RefreshWelfareCircle()
	self:RefreshCaishenBtn()
	self:RefreshTimelimitBtn()
	self:RefreshEverydayBtn()
	self:RefreshYuanBaoJoyBtn()
	self:RefreshYuanBaoJoyRedPoint()
	self:RefreshWorldCupBtn()
	self:RefreshMysticalBoxBtn()
	self:RefreshMysticalBoxRedPoint()
	self:RefreshMysticalBoxTime()
	self:RefreshMysticalBoxLingQu()
	self:RefreshRebateJoyBtn()
	self:RefreshRebateJoyRedPoint()
	-- self:JudgeHideYoukaIcon()
	self:RefreshDiscountSaleBtn()
	self:RefreshZeroBuyBtn()
	self:RefreshZeroBuyRedPoint()
	self:RefreshScheduleNotifyButton()
	self:RefreshDuanWuBtn()
	self:RefreshDuanWuBtnRedPoint()
	self.m_TopGrid:Reposition()
	self.m_GuideTwoGrid:Reposition()
end

function CMainMenuLT.RefreshCelebrationBtn(self)
	self.m_CelebrationBtn:SetActive(g_CelebrationCtrl:CheckKaifuOpenState())
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshCaishenBtn(self)
	local bOpen = g_LotteryCtrl:IsCaishenOpen()
	self.m_CaishenBtn:SetActive(bOpen)
	self.m_GuideGrid:Reposition()
	if not bOpen then return end
	local bRedPoint = g_LotteryCtrl:GetIsHasCaishenRedPoint()
	if bRedPoint then
		self.m_CaishenBtn:AddEffect("RedDot", 22, Vector2(-25, -17))
	else
		self.m_CaishenBtn:DelEffect("RedDot")
	end
end

function CMainMenuLT.RefreshTimelimitBtn(self)
	local bOpen = #g_TimelimitCtrl:GetOpenTabList() > 0
	self.m_TimeLimitBtn:SetActive(bOpen)
	self.m_GuideGrid:Reposition()
	if not bOpen then return end
	local bRedDot = g_TimelimitCtrl:IsHasRedPoint()
	if bRedDot then
		self.m_TimeLimitBtn:AddEffect("RedDot", 22, Vector2(-25, -17))
	else
		self.m_TimeLimitBtn:DelEffect("RedDot")
	end
	self.m_GuideGrid:Reposition()
end

--限时活动按钮特效(道具投资特殊处理)
function CMainMenuLT.ShowTimelimitBtnEffect(self)

	if not self.m_TimeLimitBtn:GetActive() then
		return
	end

	local bShowEff = g_ItemInvestCtrl:IsShowFirstEffect()
	if bShowEff then
		self.m_TimeLimitBtn:AddEffect("Circu")
		self.m_TimeLimitBtn:AddEffect("RedDot", 22, Vector2(-25, -17))
	else
		self.m_TimeLimitBtn:DelEffect("Circu")
		self.m_TimeLimitBtn:DelEffect("RedDot")
	end

end

--检查是需要系统开放效果的按钮
function CMainMenuLT.CheckSysOpenBtn(self)
	self.m_RankBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Rank))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Rank) then
		self.m_RankBtn:SetActive(false)
	end

	self.m_ScheduleBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Schedule))
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Schedule) then
		self.m_ScheduleBtn:SetActive(false)
	end

	local bShopOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Shop)
	self.m_ShopBtn:SetActive(bShopOpen)
	if bShopOpen then
		self:RefreshShopRectEff()
		if g_ShopCtrl:HasLimitGoodsRedPoint() then
			self.m_ShopBtn:AddEffect("RedDot", 22, Vector2(-25, -17))
		end
	end
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Shop) then
		self.m_ShopBtn:SetActive(false)
	end

	local econonmyDefaultTabIndex = g_EcononmyCtrl:GetDefaultTabIndex()
	if econonmyDefaultTabIndex then
		-- self.m_EcononmyBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Stall))
		self.m_EcononmyBtn:SetActive(true)
	else
		self.m_EcononmyBtn:SetActive(false)
	end
	if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.Stall) then
		self.m_EcononmyBtn:SetActive(false)
	end
	-- self.m_YoukaLoginBox:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.YoukaLogin))
	-- if g_OpenSysCtrl:GetIsNeedLoginShow(define.System.YoukaLogin) then
	-- 	self.m_YoukaLoginBox:SetActive(false)
	-- end
	
	self.m_TopGrid:Reposition()
	self.m_LeftGrid:Reposition()

	if g_AttrCtrl.pid ~= 0 and not Utils.IsNil(self) then
		g_OpenSysCtrl:AddUIInfo(define.System.Rank, self.m_RankBtn, function ()
			if not Utils.IsNil(self.m_TopGrid) then
				self.m_TopGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Schedule, self.m_ScheduleBtn, function ()
			if not Utils.IsNil(self.m_TopGrid) then
				self.m_TopGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Shop, self.m_ShopBtn, function ()
			if not Utils.IsNil(self.m_GuideGrid) then
				self.m_GuideGrid:Reposition()
			end
		end)
		g_OpenSysCtrl:AddUIInfo(define.System.Stall, self.m_EcononmyBtn, function ()
			if not Utils.IsNil(self.m_LeftGrid) then
				self.m_LeftGrid:Reposition()
			end
		end)
	end	
end

function CMainMenuLT.RefreshScheduleBtnUITip(self)
	
	--ctrl保存当前限时活动的环绕特效
	if g_ScheduleCtrl:IsExistRectEffect() then
		self.m_ScheduleBtn:AddEffect("Circu")
	else
		self.m_ScheduleBtn:DelEffect("Circu")
	end
	self.m_SchedulwRedPoint:SetActive(g_ScheduleCtrl.m_MainUIRedPointSta)
end

-- --刷新主界面好友图标上的红点通知ui
-- function CMainMenuLT.RefreshMsgAmount(self)
-- 	g_TalkCtrl:GetRecentNotifySaveData()
-- 	local iAmount = g_TalkCtrl:GetTotalNotify()
-- 	if iAmount > 0 then
-- 		self.m_MailUnopen:SetActive(false)
-- 		self.m_MsgAmountBtn:SetActive(true)
-- 		self.m_MsgAmountBtn:SetText(iAmount)
-- 	else
-- 		self.m_MsgAmountBtn:SetActive(false)
-- 	end
-- end

-- function CMainMenuLT.RefreshMailUnopen(self)
-- 	local nUnopenMail = g_MailCtrl:GetUnOpenedMailsNum()
-- 	if nUnopenMail > 0 then
-- 		self.m_MsgAmountBtn:SetActive(false)
-- 		self.m_MailUnopen:SetActive(true)
-- 	else
-- 		self.m_MailUnopen:SetActive(false)
-- 	end
-- end

function CMainMenuLT.RefreshPromoteEvent(self)
	local tSys = g_PromoteCtrl.m_PromoteList
    if next(tSys) ~= nil and g_OpenSysCtrl:GetOpenSysState(define.System.Improve) then
	   self.m_PromoteBtn:SetActive(true)
	else
	   self.m_PromoteBtn:SetActive(false)
	end
	self.m_TopGrid:Reposition()
	self.m_BianQiangRedPoint:SetActive(g_PromoteCtrl.m_GrowRedPoint)
end

function CMainMenuLT.RefreshFirstPayBtn(self)
	local bRewardAll = g_FirstPayCtrl:HasRewardAll()
	local showBtn = g_OpenSysCtrl:GetOpenSysState(define.System.FirstPay) and not bRewardAll
	if showBtn then
		self.m_FirstPayBtn:SetActive(true)
		self.m_FirstPayBtn:AddEffect("Circu")
	else
		self.m_FirstPayBtn:DelEffect("Circu")
		self.m_FirstPayBtn:SetActive(false)
	end
	self:RefreshSecondPayBtn()
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshSecondPayBtn(self)
	local iFirstPay = g_FirstPayCtrl:GetChargeStatus(1)
	local iSecondPay = g_WelfareCtrl:GetChargeItemInfo("second_pay_reward")
	local iOpen = g_OpenSysCtrl:GetOpenSysState(define.System.SecondPay)
	local showBtn = iOpen and iFirstPay > 1 and iSecondPay < 2
	if showBtn then
		self.m_SecondPayBtn:SetActive(true)
		self.m_SecondPayBtn:AddEffect("Circu")
		self.m_SecondPayBtn:AddUIEvent("click", callback(self, "OpenSecondPay"))
	else
		self.m_SecondPayBtn:DelEffect("Circu")
		self.m_SecondPayBtn:SetActive(false)
	end
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshEcononmyRedPoint(self)
	local bShow = g_EcononmyCtrl.m_AuctionNotify or g_EcononmyCtrl.m_StallNotify
	self.m_EcononmyRedPoint:SetActive(bShow)
end

function CMainMenuLT.RefreshCelebrationRedPoint(self)
	if g_CelebrationCtrl:IsHadRedPoint() then
		self.m_CelebrationBtn:AddEffect("RedDot", 22, Vector2(-25, -17))
	else
		self.m_CelebrationBtn:DelEffect("RedDot")
	end
end

function CMainMenuLT.RefreshCelebrationCircle(self)
	if not g_CelebrationCtrl.m_IsHasClickMainMenu or g_CelebrationCtrl:IsHadRedPoint() then
		self.m_CelebrationBtn:AddEffect("Circu")
	else
		self.m_CelebrationBtn:DelEffect("Circu")
	end
end

function CMainMenuLT.RefreshWelfareCircle(self)
	if g_WelfareCtrl:IsCircleShow() then
		self.m_WelfareBtn:AddEffect("Circu")
	else
		self.m_WelfareBtn:DelEffect("Circu")
	end
end

function CMainMenuLT.RefreshEverydayBtn(self)
	local bIsShow = g_TimelimitCtrl:CheckEverydayRankOpen()
	self.m_EverydayRankBtn:SetActive(bIsShow)
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshYuanBaoJoyBtn(self)
	local bIsShow = g_YuanBaoJoyCtrl:CheckIsYuanBaoJoyOpen()
	self.m_YuanBaoJoyBtn:SetActive(bIsShow)
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshYuanBaoJoyRedPoint(self)
	local bIsShow = g_YuanBaoJoyCtrl:CheckIsYuanBaoJoyRedPoint()
	self.m_YuanBaoJoyRedPoint:SetActive(bIsShow)
end

function CMainMenuLT.RefreshWorldCupBtn(self)
	local bIsOpen1 = g_OpenSysCtrl:GetOpenSysState(define.System.SoccerWorldCupGuess)
	local bIsOpen2 = g_OpenSysCtrl:GetOpenSysState(define.System.SoccerTeamSupport)
	local bIsShow = g_SoccerWorldCupCtrl:IsOpening()
	--printc("######### g_SoccerWorldCupCtrl:CheckIsSoccerWorldCupOpen:", bIsShow)
	local bIsFinalShow = (bIsOpen1 or bIsOpen2) and bIsShow
	self.m_WorldCupBtn:SetActive(bIsFinalShow)
	self.m_GuideTwoGrid:Reposition()
end

function CMainMenuLT.RefreshMysticalBoxBtn(self)
	local bIsShow = g_MysticalBoxCtrl:CheckIsMysticalBoxOpen()
	--printc("######### g_MysticalBoxCtrl:CheckIsMysticalBoxOpen:", bIsShow)
	self.m_MysticalBoxBtn:SetActive(bIsShow)
	self.m_GuideGrid:Reposition()
	self.m_GuideTwoGrid:Reposition()
end

function CMainMenuLT.RefreshMysticalBoxTime(self)
	--printc("********* g_MysticalBoxCtrl.RefreshMysticalBoxTime:", g_MysticalBoxCtrl.m_time)
	local bIsShow = g_MysticalBoxCtrl:CheckIsMysticalBoxTime()
	--printc("^^^^^^^^^^^ g_MysticalBoxCtrl:RefreshMysticalBoxTime:", bIsShow)
	self.m_MysticalBoxTime:SetActive(bIsShow)

	if bIsShow then
		self.m_MysticalBoxTime:SetText(g_MysticalBoxCtrl.m_time)
	else
		self.m_MysticalBoxTime:SetText("")
	end
end

function CMainMenuLT.RefreshMysticalBoxLingQu(self)
	--printc("********* g_MysticalBoxCtrl.RefreshMysticalBoxLingQu")
	local bIsShow = g_MysticalBoxCtrl:CheckIsMysticalBoxLingQu()
	--printc("^^^^^^^^^^^ g_MysticalBoxCtrl:RefreshMysticalBoxLingQu:", bIsShow)
	self.m_MysticalBoxLingQu:SetActive(bIsShow)
end

function CMainMenuLT.RefreshMysticalBoxRedPoint(self)
	local bIsShow = g_MysticalBoxCtrl:CheckIsMysticalBoxRedPoint()
	--printc("@@@@@@@@@ g_MysticalBoxCtrl:RefreshMysticalBoxRedPoint:", bIsShow)
	self.m_MysticalBoxRedPoint:SetActive(bIsShow)
end

function CMainMenuLT.RefreshRebateJoyBtn(self)
	local bIsShow = g_RebateJoyCtrl:CheckIsRebateJoyOpen()
	self.m_RebateJoyBtn:SetActive(bIsShow)
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshRebateJoyRedPoint(self)
	local bIsShow = g_RebateJoyCtrl:CheckIsRebateJoyRedPoint()
	local bIsShowCircu = g_RebateJoyCtrl:CheckIsRebateCircu(bIsShow)
	self.m_RebateJoyRedPoint:SetActive(bIsShow)

	self.m_RebateJoyBtn:DelEffect("Circu")
	if bIsShowCircu then self.m_RebateJoyBtn:AddEffect("Circu") end
end

function CMainMenuLT.RefreshShopYouhuiSp(self)
	local bIsShow = g_RebateJoyCtrl:CheckIsShopYouhui()
	self.m_ShopYouhuiSp:SetActive(bIsShow)
end

function CMainMenuLT.RefreshShopRectEff(self)
	local bHasRect = g_WelfareCtrl:IsHadRebateRedPoint()
	if bHasRect then
		self.m_ShopBtn:AddEffect("Circu")
	else
		self.m_ShopBtn:DelEffect("Circu")
	end
end

function CMainMenuLT.RefreshDiscountSaleBtn(self)
	local bIsOpen = g_TimelimitCtrl:CheckDiscountSaleOpen()
	self.m_DiscountSaleBtn:SetActive(bIsOpen)
	if bIsOpen and g_TimelimitCtrl.m_FirstOpenDiscount then
		self.m_DiscountSaleBtn:AddEffect("Circu")
		g_TimelimitCtrl.m_FirstOpenDiscount = false
	end
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.RefreshZeroBuyBtn(self)
	local bIsShow = g_ZeroBuyCtrl:CheckIsZeroBuyOpen()
	self.m_ZeroBuyBtn:SetActive(bIsShow)
	self.m_GuideGrid:Reposition()

	if not g_ZeroBuyCtrl.m_IsHasClickMainMenu then
		self.m_ZeroBuyBtn:AddEffect("Circu")
	else
		self.m_ZeroBuyBtn:DelEffect("Circu")
	end
end

function CMainMenuLT.RefreshZeroBuyRedPoint(self)
	local bIsShow = g_ZeroBuyCtrl:CheckIsZeroBuyRedPoint()
	self.m_ZeroBuyyRedPoint:SetActive(bIsShow)
end

function CMainMenuLT.RefreshScheduleNotifyButton(self)
	if gameconfig.Issue.Releases then
		self.m_ScheduleNotifyBtn:SetActive(false)
		return 
	end
	local dSchedule = g_ScheduleCtrl:GetNotifySchedule()
	local bShow = dSchedule ~= nil 

	self.m_ScheduleNotifyBtn:SetActive(bShow)
	if bShow then
		local sScheduleName = data.scheduledata.SCHEDULE[dSchedule.scheduleid].name
		self.m_ScheduleNameL:SetText(sScheduleName)
		self.m_ScheduleNotifyBtn:AddEffect("Circu")
	else
		self.m_ScheduleNotifyBtn:DelEffect("Circu")
	end
end

function CMainMenuLT.RefreshDuanWuBtn(self)
	
	local isMatchOpen = g_DuanWuHuodongCtrl:IsMatchHuodongOpen()
	local isQiFuOpen = g_DuanWuHuodongCtrl:IsQiFuHuoDongOpen()
	self.m_DuanWuBtn:SetActive(isMatchOpen or isQiFuOpen)

	self.m_GuideTwoGrid:Reposition()
end

function CMainMenuLT.RefreshDuanWuBtnRedPoint(self)
	
	local isHadQiFuReward = g_DuanWuHuodongCtrl:IsHadQiFuReward()
	local isFirstOpenQifu = g_DuanWuHuodongCtrl:IsFirstOpenQiFu()
	local isFirstOpenMatch = g_DuanWuHuodongCtrl:IsFirstOpenMatch()

	local isQiFuOpen = g_DuanWuHuodongCtrl:IsQiFuHuoDongOpen() 
	local isMatchOpen = g_DuanWuHuodongCtrl:IsMatchHuodongOpen()

	self.m_DuanWuBtnRedPoint:SetActive(isHadQiFuReward or (isFirstOpenQifu and isQiFuOpen) or (isFirstOpenMatch and isMatchOpen))

end

----------------------Excute CtrlEvent---------------------------------
function CMainMenuLT.OnUpgradePackEvent(self, oCtrl)
	if oCtrl.m_EventID == define.UpgradePacks.Event.GetReward or  oCtrl.m_EventID == define.UpgradePacks.Event.UpgradePacksDataChange  then
		if not Utils.IsNil(self) then
			self.m_WelfareRedPoint:SetActive(g_WelfareCtrl:IsHadRedPoint())
		end
	end
end

function CMainMenuLT.OnSignEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.AddSignInfo then 
		self.m_WelfareRedPoint:SetActive(g_WelfareCtrl:IsHadRedPoint())
	end
end

function CMainMenuLT.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateYuanbaoPnl or oCtrl.m_EventID == define.WelFare.Event.UpdateBigProfitPnl then
		self.m_WelfareRedPoint:SetActive(oCtrl:IsHadRedPoint())
		self:RefreshCelebrationRedPoint()
		self:RefreshCelebrationCircle()
		self:RefreshWelfareCircle()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateDailyRedDot or oCtrl.m_EventID == define.WelFare.Event.UpdateCollectPnl then
		self.m_WelfareRedPoint:SetActive(oCtrl:IsHadRedPoint())
		self:RefreshTimelimitBtn()
		self:RefreshWelfareCircle()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateFirstPayRedDot then
		self.m_WelfareRedPoint:SetActive(oCtrl:IsHadRedPoint())
		self:RefreshFirstPayBtn()
		self:RefreshCelebrationRedPoint()
		self:RefreshCelebrationCircle()
	elseif oCtrl.m_EventID == define.WelFare.Event.RefreshSecondPay then
		self.m_WelfareRedPoint:SetActive(oCtrl:IsHadRedPoint())
		self:RefreshSecondPayBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
		self:RefreshCelebrationBtn()
		self:RefreshZeroBuyBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
		self:RefreshShopRectEff()
	elseif oCtrl.m_EventID == define.WelFare.Event.RefreshExpRecycle then
		self.m_WelfareRedPoint:SetActive(oCtrl:IsHadRedPoint())
		--暂时屏蔽
		-- self:RefreshCelebrationRedPoint()
		-- self:RefreshCelebrationCircle()
	-- elseif oCtrl.m_EventID == define.WelFare.Event.UpdataColorLamp  then
	-- 	self:JudgeHideYoukaIcon()
	-- elseif oCtrl.m_EventID == define.WelFare.Event.UpdataYoukaLoginTime then
	-- 	self:RefreshYoukaTime(oCtrl.m_EventData)
	end
end

function CMainMenuLT.OnUpdateCelebrationEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Celebration.Event.UpdateRankReward then
    	self:RefreshCelebrationBtn()
        self:RefreshCelebrationRedPoint()
		self:RefreshCelebrationCircle()
    end
end

function CMainMenuLT.OnMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.ShowScene then
		self.m_MapInfoBox.m_MapLabel:SetText(oCtrl.m_SceneName)
	elseif oCtrl.m_EventID == define.Map.Event.HeroPatrol then
		-- 挂机按钮删掉了
		-- self:RefreshAutoState(oCtrl.m_EventData.bPatrol)
	end
	self:RefreshMinMap()
end

function CMainMenuLT.OnLoginEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Login or oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:CheckSysOpenBtn()
		self:RefreshButton()
	end
end

function CMainMenuLT.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		-- self:RefreshButton()
		self:CheckNpcShop()
		self:RefreshDuanWuBtn()
		self:RefreshDuanWuBtnRedPoint()
		self:RefreshZeroBuyRedPoint()

		local dData = oCtrl.m_EventData
		if dData.dAttr.grade then
			self:RefreshScheduleNotifyButton()
			self.m_GuideTwoGrid:Reposition()
		end
	end
	if oCtrl.m_EventID == define.Attr.Event.AddPoint or oCtrl.m_EventID == define.Attr.Event.Change then
       -- self:RefreshPromoteEvent()
	end
end

function CMainMenuLT.OnSchduleEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Schedule.Event.RefreshUITip then
		self:RefreshScheduleBtnUITip()
	elseif oCtrl.m_EventID == define.Schedule.Event.ClearEffect then
		self:RefreshScheduleBtnUITip()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshHuodong  then
		self:RefreshScheduleBtnUITip()
		self:RefreshScheduleNotifyButton()
		self.m_GuideTwoGrid:Reposition()
	elseif  oCtrl.m_EventID ==define.Schedule.Event.RefreshDouble then
		self:RealTimeDoublePoint(oCtrl.m_SvrDoublePoint.current)
	end
end

-- function CMainMenuLT.OnTalkEvent(self, oCtrl)
-- 	self:RefreshMsgAmount()
-- end

-- function CMainMenuLT.OnMailEvent(self, callbackBase)
-- 	local eventID = callbackBase.m_EventID
--     if eventID == define.Mail.Event.Sort
--     	or eventID == define.Mail.Event.OpenMails then
--     	self:RefreshMailUnopen()
--     end
-- end

function CMainMenuLT.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.UpdatePromoteData then
		self:RefreshPromoteEvent()
	elseif oCtrl.m_EventID == define.Promote.Event.RedPoint  then
		self.m_PromoteRedPointSp:SetActive(g_PromoteCtrl:CheckIsHasRedPoint())
	elseif oCtrl.m_EventID == define.Promote.Event.RefreshGrowRedPoint  then
		self.m_BianQiangRedPoint:SetActive(g_PromoteCtrl.m_GrowRedPoint)
	end
end

function CMainMenuLT.OnBadgeEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or oCtrl.m_EventID == define.Item.Event.AddBagItem then
	   -- self:RefreshPromoteEvent()
    end
end

function CMainMenuLT.OnSummonEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo or oCtrl.m_EventID == define.Summon.Event.SetFightId then
	   -- self:RefreshPromoteEvent()
	end
end

function CMainMenuLT.OnGuideHelpEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Guide.Event.PreOpen then
		self:SetPreOpenList()
	end
end

function CMainMenuLT.OnEcononmyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallNotify or oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionNotify then
		self:RefreshEcononmyRedPoint()
	end
end

function CMainMenuLT.OnNpcShopEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.RefreshNpcShop then
		self:CheckNpcShop()
	elseif oCtrl.m_EventID == define.Shop.Event.NpcShopDiscount then
		self:UpdateNpcShopDiscount()
	elseif oCtrl.m_EventID == define.Shop.Event.RefreshShopItem then
		self:CheckNpcShop()
	elseif oCtrl.m_EventID == define.Shop.Event.RemoveLimitRedDot then
		self.m_ShopBtn:DelEffect("RedDot")
	end
end

function CMainMenuLT.OnLotteryCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenRedPoint or oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
    	self:RefreshCaishenBtn()
    	--self:RefreshTimelimitBtn()
	end
end

function CMainMenuLT.OnOnlineGiftEvent(self, oCtrl)
	if oCtrl.m_EventID == define.OnlineGift.Event.UpdateRedPoint then
		self.m_WelfareRedPoint:SetActive(g_WelfareCtrl:IsHadRedPoint())
	end
end

function CMainMenuLT.OnAccumChargeEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshAccCharge then
		self:RefreshTimelimitBtn()
	end
end

function CMainMenuLT.OnTimeLimitCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshRedPoint or oCtrl.m_EventID == define.Timelimit.Event.UpdateFlopOpenState then
		self:RefreshTimelimitBtn()   --todo--
	elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateEverydayRank then
		self:RefreshEverydayBtn()
	elseif oCtrl.m_EventID == define.Timelimit.Event.RefreshDiscountSale then
		self:RefreshDiscountSaleBtn()
	end
end

function CMainMenuLT.OnEveryDayChargeCtrlEvent(self, oCtrl)
	--printc(oCtrl.m_EventID, "CMainMenuLT.OnEveryDayChargeCtrlEvent")
	if oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeNotifyRefreshRedPoint then
        self:RefreshTimelimitBtn()
    end
end

function CMainMenuLT.OnActiveGiftBagCtrlEvent(self, oCtrl)
	-- printc(oCtrl.m_EventID, "CMainMenuLT.OnActiveGiftBagCtrlEvent")
	if oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagInfoChanged or oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagStart or oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagEnd then
        self:RefreshTimelimitBtn()
    end
end

function CMainMenuLT.OnHeShenQiFuEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.HeShenQiFu.Event.Start or oCtrl.m_EventID == define.HeShenQiFu.Event.End then
	   self:RefreshTimelimitBtn()
	end

end

function CMainMenuLT.OnAssembleTreasureCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshExtraAndScore
	or  oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshState then
		self:InitAssembleTreasureBtn()
	end

end

function CMainMenuLT.OnContActCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.UpdateContConsume or oCtrl.m_EventID == define.Timelimit.Event.EndContConsume then
		self:RefreshTimelimitBtn()
	elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateContCharge or oCtrl.m_EventID == define.Timelimit.Event.EndContCharge then
		self:RefreshTimelimitBtn()
	end
end

function CMainMenuLT.OnCtrlYuanBaoJoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.YuanBaoJoy.Event.RefreshOpenState then
		self:RefreshYuanBaoJoyBtn()
	elseif oCtrl.m_EventID == define.YuanBaoJoy.Event.RefreshInfo then
		self:RefreshYuanBaoJoyRedPoint()
	end
end

function CMainMenuLT.OnCtrlMysticalBoxEvent(self, oCtrl)
	--printc("aaaaaaa CMainMenuLT.OnCtrlMysticalBoxEvent  oCtrl.m_timeForMainBtn:" , oCtrl.m_timeForMainBtn, " oCtrl.m_EventID:", oCtrl.m_EventID)
	if oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxStart then
		--printc("bbbbbb CMainMenuLT.C2GSMysticalboxOperateBox")
		self:RefreshMysticalBoxBtn()
		self:RefreshMysticalBoxTime()	
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxRefreshMainBtn then
		--printc("cccccc CMainMenuLT.MysticalBoxRefreshMainBtn")
		self:RefreshMysticalBoxBtn()
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxRefreshTime then
		--printc("dddddd CMainMenuLT.MysticalBoxRefreshTime")
		self:RefreshMysticalBoxTime()			
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxRefreshRedPoint then
		--printc("eeeeee CMainMenuLT.MysticalBoxRefreshRedPoint")
		self:RefreshMysticalBoxRedPoint()
		self:RefreshMysticalBoxLingQu()
	end
end

function CMainMenuLT.OnCtrlSoccerWorldCupGuessEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessOpen or 
		oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessClose then
		self:RefreshWorldCupBtn()
	end
end

function CMainMenuLT.OnCtrlRebateJoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseState then
		self:RefreshRebateJoyBtn()
	elseif oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseRewardState then
	elseif oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseGoldCoin then
	elseif oCtrl.m_EventID == define.RebateJoy.Event.JoyExpenseRedPoint then
		self:RefreshRebateJoyRedPoint()
	elseif oCtrl.m_EventID == define.RebateJoy.Event.RelGoldCoinGift then
		self:RefreshShopYouhuiSp()
	end
end

function CMainMenuLT.OnItemInvestEvent(self, oCtrl)

	local iEventState = define.ItemInvest.Event.RefreshItemInvestState
	local iEventUnit = define.ItemInvest.Event.RefreshItemInvestUnit

	if oCtrl.m_EventID == iEventState then
		self:RefreshTimelimitBtn()
		self:ShowTimelimitBtnEffect()
	elseif oCtrl.m_EventID == iEventUnit then
		self:RefreshTimelimitBtn()
	end

end

function CMainMenuLT.OnZeroBuyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ZeroBuy.Event.UpdateInfo then
		self:RefreshZeroBuyBtn()
		self:RefreshZeroBuyRedPoint()
	end
end

function CMainMenuLT.OnDuanWuHuodongEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.DuanWuHuodong.Event.QiFuState or oCtrl.m_EventID == define.DuanWuHuodong.Event.MatchState then
		self:RefreshDuanWuBtn()
		self:RefreshDuanWuBtnRedPoint()
	end 

	if oCtrl.m_EventID == define.DuanWuHuodong.Event.QiFuDataChange then 
		self:RefreshDuanWuBtnRedPoint()
	end 

end

-------------------Click Event--------------------------------
function CMainMenuLT.OnOpenMapView(self, idx)
	if g_KuafuCtrl:IsInKS(true) then
		return
	end
	CMapMainView:ShowView(function (oView)
		oView:ShowMapSpecificPart(idx)
	end)
end

function CMainMenuLT.OpenShopView(self)

	CNpcShopMainView:ShowView()
end

function CMainMenuLT.OpenYoukaView(self)
	-- CYoukaLoginView:ShowView()
	CWelfareView:ShowView(function (oView)
		oView:ForceSelPage(define.WelFare.Tab.YoukaLogin)
	end)
end
-- function CMainMenuLT.OpenFriendInfoView(self)
-- 	local msgActive = self.m_MsgAmountBtn:GetActive()
-- 	local mailActive = self.m_MailUnopen:GetActive()

-- 	if msgActive and not mailActive then
-- 		if g_TalkCtrl:GetRecentTalkRoleCount() == 1 then
-- 			local pid = g_TalkCtrl:GetRecentTalk()
-- 			if g_TalkCtrl:GetTotalNotify() and pid then
-- 				CFriendInfoView:ShowView(function (oView)
-- 				oView:ShowTalk(pid)
-- 				end)
-- 			end
-- 		else
-- 			CFriendInfoView:ShowView(function (oView)
-- 				oView:ShowRecent()
-- 			end)
-- 		end
-- 	elseif not msgActive and mailActive then
-- 		CFriendInfoView:ShowView(function (oView)	
-- 			oView:ShowMail()
-- 			local oMainView = CMainMenuView:GetView()
-- 			oMainView.m_RB.m_QuickMsgBox.m_MailBtn:SetActive(false)
-- 		end)

-- 	else
-- 		CFriendInfoView:ShowView(function (oView)
-- 			oView:ShowRecent()
-- 		end)
-- 	end
-- end

function CMainMenuLT.OpenScheduleView(self)
	g_ScheduleCtrl:InitData()
	CScheduleMainView:ShowView()
end

function CMainMenuLT.OpenEcononmyView(self)
	local econonmyDefaultTabIndex = g_EcononmyCtrl:GetDefaultTabIndex()
	if econonmyDefaultTabIndex then
		-- if not g_OpenSysCtrl:GetOpenSysState(define.System.Stall, true) then
		-- 	return
		-- end
		CEcononmyMainView:ShowView(function(oView)
			if g_EcononmyCtrl.m_StallNotify then
				oView:ShowSubPageByIndex(oView:GetPageIndex("Stall"))
				oView.m_CurPage:ChangeTab(2)
			end
		end)
	end
end

function CMainMenuLT.OnPromote(self)
	CGaideMainView:ShowView()
	--CSystemSettingsMainView:ShowView()
end

function CMainMenuLT.OnGuide(self)
	CPromoteBtnView:ShowView()
end

function CMainMenuLT.OnClickWelfareBtn(self)
	CWelfareView:ShowView()
end

function CMainMenuLT.OnRankBtn(self)
	if g_SoccerWorldCupCtrl:IsOpening() then 
		nethuodong.C2GSWorldCupHistory()  --为了界面的数据刷新
	end

	CRankListView:ShowView()
end

function CMainMenuLT.OpenFirstPay(self)
	CWelfareView:ShowView(function (oView)
		oView:ForceSelPage(define.WelFare.Tab.FirstPay)
	end)
end

function CMainMenuLT.OpenSecondPay(self)
	CWelfareView:ShowView(function(oView)
		oView:ForceSelPage(define.WelFare.Tab.SecondPay)
	end)
end

function CMainMenuLT.OnClickCelebration(self)
	g_CelebrationCtrl.m_IsHasClickMainMenu = true
	g_CelebrationCtrl:OnEvent(define.Celebration.Event.UpdateRankReward)
	CCelebrationView:ShowView()
end

function CMainMenuLT.OpenCaishenView(self)
	CCaishenGiftView:ShowView()
end

function CMainMenuLT.OPenEverydayRankView(self)
	CEverydayRankView:ShowView()
end

function CMainMenuLT.OnClickYuanBaoJoyBtn(self)
	g_YuanBaoJoyCtrl:OnShowYuanBaoMainView()
end

function CMainMenuLT.OnClickMysticalBoxBtn(self)
	--printc("1111111 CMainMenuLT.OnClickMysticalBoxBtn m_open_state:", g_MysticalBoxCtrl.m_open_state)
	if g_MysticalBoxCtrl.m_open_state == 1 then
		nethuodong.C2GSMysticalboxOperateBox(1)
		g_MysticalBoxCtrl:OnShowMysticalBoxView()
	elseif g_MysticalBoxCtrl.m_open_state == 2 then
		g_MysticalBoxCtrl:OnShowMysticalBoxView()
	end
end

function CMainMenuLT.OnClickDuanWuBtn(self)

	local isMatchOpen = g_DuanWuHuodongCtrl:IsMatchHuodongOpen()
	local isQiFuOpen = g_DuanWuHuodongCtrl:IsQiFuHuoDongOpen()
	if isQiFuOpen then 
		g_DuanWuHuodongCtrl:SetFirstOpenQiFuState(1)
	end 

	if isMatchOpen then 
		g_DuanWuHuodongCtrl:SetFirstOpenMatchState(1)
	end 

	self:RefreshDuanWuBtnRedPoint()

	CDuanWuMainView:ShowView()

end 

function CMainMenuLT.OnClickWorldCupBtn(self)
	printc("CMainMenuLT.OnClickWorldCupBtn")
	g_SoccerWorldCupCtrl:OnShowWorldCupMainView()
end

function CMainMenuLT.OnClickRebateJoyBtn(self)
	g_RebateJoyCtrl.m_IsFirstInit = true
	g_RebateJoyCtrl:OnEvent(define.RebateJoy.Event.JoyExpenseRedPoint)
	CRebateJoyMainView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CMainMenuLT.OnClickDiscountSaleBtn(self)
	CDiscountSaleView:ShowView()
end

function CMainMenuLT.OnClickZeroBuyBtn(self)
	CZeroBuyView:ShowView(function (oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Chen"))
	end)
end

function CMainMenuLT.OnClickScheduleNotify(self)
	local hdlist = g_ScheduleCtrl:GetNotifySchedule()
	if hdlist.scheduleid == 1018 then
		g_BonfireCtrl:LocaFunc()
		return
	end
	g_ScheduleCtrl:OpenScheduleNotify(hdlist)
end
----------------功能预告相关-------------------

function CMainMenuLT.SetPreOpenList(self)
	self.m_PreOpenIndex = 70000
	self.m_LeftGrid:Clear()
	if not g_OpenSysCtrl:GetOpenSysState(define.System.PreOpen) then
		return
	end
	local preOpenList = g_GuideHelpCtrl:GetPreOpenNewList()
	local optionCount = #preOpenList
	local GridList = self.m_LeftGrid:GetChildList() or {}
	local oPreOpenBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPreOpenBox = self.m_GuideBox:Clone(false)
				-- self.m_LeftGrid:AddChild(oOptionBtn)
			else
				oPreOpenBox = GridList[i]
			end
			self:SetPreOpenBox(oPreOpenBox, preOpenList[i], i)
			oPreOpenBox:SetName(tostring(self.m_PreOpenIndex))
			self.m_PreOpenIndex = self.m_PreOpenIndex + 1
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end
	self.m_LeftGrid:Reposition()
end

function CMainMenuLT.SetPreOpenBox(self, oPreOpenBox, oData, oIndex)
	oPreOpenBox:SetActive(true)
	oPreOpenBox.m_IconSp = oPreOpenBox:NewUI(1, CSprite)
	oPreOpenBox.m_ActorTexture = oPreOpenBox:NewUI(2, CActorTexture)
	oPreOpenBox.m_LevelLbl = oPreOpenBox:NewUI(3, CLabel)
	oPreOpenBox.m_RedPointSp = oPreOpenBox:NewUI(4, CSprite)
	oPreOpenBox.m_NameLbl = oPreOpenBox:NewUI(5, CLabel)
	oPreOpenBox.m_NameSp = oPreOpenBox:NewUI(6, CSprite)
	oPreOpenBox.m_NameLbl:SetActive(false)
	oPreOpenBox.m_NameSp:SetActive(false)
	
	local isRedPoint = g_GuideHelpCtrl:GetIsHasNotRewardPreOpen() ~= nil
	if oIndex == 1 then	
		oPreOpenBox.m_RedPointSp:SetActive(isRedPoint)
	else
		oPreOpenBox.m_RedPointSp:SetActive(false)
	end

	if isRedPoint then
		oPreOpenBox.m_LevelLbl:SetText("[EEFFFB][0fff32]可领取[-]")
	else
		oPreOpenBox.m_LevelLbl:SetText("[EEFFFB][fb3636]"..oData.reward_grade.."级[-]开启")
	end
	local oNameType, oNameVal = g_GuideHelpCtrl:GetPreOpenNameText(oData.id)
	--暂时屏蔽
	-- if oNameType == 1 then
	-- 	oPreOpenBox.m_NameLbl:SetActive(false)
	-- 	oPreOpenBox.m_NameSp:SetActive(false)
	-- 	oPreOpenBox.m_NameSp:SetSpriteName(oNameVal)
	-- elseif oNameType == 2 then
	-- 	oPreOpenBox.m_NameLbl:SetActive(false)
	-- 	oPreOpenBox.m_NameSp:SetActive(false)
	-- 	oPreOpenBox.m_NameLbl:SetText(oNameVal)
	-- end

	if oData.icon.type == 1 then
		oPreOpenBox.m_ActorTexture:SetActive(true)
		oPreOpenBox.m_IconSp:SetActive(false)
		local model_info = {}
		model_info.figure = tonumber(oData.icon.args)
		model_info.horse = nil
		oPreOpenBox.m_ActorTexture:ChangeShape(model_info)
	else
		oPreOpenBox.m_ActorTexture:SetActive(false)
		oPreOpenBox.m_IconSp:SetActive(true)
		oPreOpenBox.m_IconSp:SetSpriteName(oData.icon.args)
		oPreOpenBox.m_IconSp:MakePixelPerfect()
	end

	-- if g_AttrCtrl.grade >= oData.reward_grade then
	-- 	oPreOpenBox:DelEffect("Rect")
	-- 	oPreOpenBox:AddEffect("Rect")
	-- else
	-- 	oPreOpenBox:DelEffect("Rect")
	-- end

	oPreOpenBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnClickPreOpenBox", oData))
	oPreOpenBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPreOpenBox", oData))

	if oIndex == 1 then
		g_GuideCtrl:AddGuideUI("preopen_box_btn", oPreOpenBox.m_IconSp)
	end

	self.m_LeftGrid:AddChild(oPreOpenBox)
	self.m_LeftGrid:Reposition()
end

function CMainMenuLT.OnClickPreOpenBox(self, oData)
	-- CGuideFuncNotifyView:ShowView(function (oView)
	-- 	oView:RefreshUI(oData)
	-- end)
	CFuncNotifyMainView:ShowView(function (oView)
		local sCondition = CGuideData["PreOpen"].necessary_condition
		local oRideCondition = [[ride_preopen_open]]
		if ( g_GuideHelpCtrl.m_GuideInfoInit and g_GuideHelpCtrl.m_GuideConfigList["PreOpen"] and g_GuideCtrl:CallGuideFunc(sCondition) and not g_GuideCtrl.m_Flags["PreOpen"]) 
		and g_GuideCtrl.m_UpdateInfo.guide_type == "PreOpen" then
			oView:RefreshUI(g_GuideHelpCtrl.m_PreOpenGuideIndex)
			oView.m_ScrollView.m_UIScrollView.enabled = false
		elseif ( g_GuideHelpCtrl.m_GuideInfoInit and g_GuideHelpCtrl.m_GuideConfigList["Ride"] and g_GuideCtrl:CallGuideFunc(oRideCondition) and not g_GuideCtrl.m_Flags["Ride"]) 
		and g_GuideCtrl.m_UpdateInfo.guide_type == "Ride" then
			oView:RefreshUI(g_GuideHelpCtrl.m_RideGuideIndex)
			oView.m_ScrollView.m_UIScrollView.enabled = false
		elseif ( g_GuideHelpCtrl.m_GuideInfoInit and g_GuideHelpCtrl.m_GuideConfigList["WingReward"] and not g_GuideCtrl.m_Flags["WingReward"]) 
		and g_GuideCtrl.m_UpdateInfo.guide_type == "WingReward" then
			oView:RefreshUI(g_GuideHelpCtrl.m_WingGuideIndex)
			oView.m_ScrollView.m_UIScrollView.enabled = false
		else			
			if g_AttrCtrl.grade >= oData.reward_grade and not g_GuideHelpCtrl:GetIsPreOpenHasRewarded(oData.id) then
				oView:RefreshUI(g_GuideHelpCtrl:GetPreOpenConfigKey(oData.id))
				if oData.showview ~= 0 then
					CFuncNotifyShowView:ShowView(function (oView)
						oView:RefreshUI(oData)
					end)
				end
			else
				local oFirstNotReward = g_GuideHelpCtrl:GetFirstNotRewardPreOpen()
				if oFirstNotReward then
					oView:RefreshUI(g_GuideHelpCtrl:GetPreOpenConfigKey(oFirstNotReward.id))
					if oFirstNotReward.showview ~= 0 then
						CFuncNotifyShowView:ShowView(function (oView)
							oView:RefreshUI(oFirstNotReward)
						end)
					end
				else
					oView:RefreshUI(g_GuideHelpCtrl:GetPreOpenConfigKey(oData.id))
					if oData.showview ~= 0 then
						CFuncNotifyShowView:ShowView(function (oView)
							oView:RefreshUI(oData)
						end)
					end
				end
			end			
		end
	end)
end

function CMainMenuLT.RealTimeDoublePoint(self, data)
	if data > 0 then
		self.m_DoublePointLbl:SetText(data.."点")
	else
		self.m_DoublePointLbl:SetText("领双")
	end
end

function CMainMenuLT.RefreshYoukaTime(self, timeinfo)
	-- body
    self.m_YoukaTimeLab:SetText(string.format("%02d:%02d:%02d", timeinfo.hours, timeinfo.minutes, timeinfo.seconds))
end

function CMainMenuLT.JudgeHideYoukaIcon(self)
	-- body
	if g_WelfareCtrl:IsHideYoukaIcon() == false  then  -- 1，刚建号，系统未开启。   2，领取过三次隐藏
		self.m_YoukaLoginBox:SetActive(false)
		return 
	end
	local idx,today = g_WelfareCtrl:CurrYoukaLoginIdx() --最小天数, 领取状态
	self.m_YoukaLoginBox:SetActive(true)
	if today == 1 then -- 可以领取
		if idx == 1 or idx == 2  or idx == 3 then
			self.m_YoukaTipsLab:SetText(data.welfaredata.TEXT[1009 + idx ].content)
			self.m_YoukaGetTipsLab:SetActive(true)
		else
			self.m_YoukaTipsLab:SetText("明日领取")
			self.m_YoukaGetTipsLab:SetActive(false)
		end 
		self.m_YoukaTimeLab:SetActive(false)
	elseif today == 0 then
		self.m_YoukaGetTipsLab:SetActive(false)
		if idx == 2 then
			self.m_YoukaTipsLab:SetText(data.welfaredata.TEXT[1011].content)
		elseif idx == 3  then
			self.m_YoukaTipsLab:SetText(data.welfaredata.TEXT[1012].content)
		else
			self.m_YoukaTipsLab:SetText("明日领取")
		end

		self.m_YoukaTimeLab:SetActive(true)
	end
	local giftid = data.welfaredata.LOGIN["login_gift_"..idx].gift
	local reward = table.copy(data.rewarddata.WELFARE[giftid])
	for i,v in pairs(reward) do
		if i == "item" and next(v) then
			local sid = v[1].sid
			local oItemData = DataTools.GetItemData(sid)
			self.m_YoukaIcon:SpriteItemShape(oItemData.icon)
			break
		elseif i == "exp" and tonumber(v) > 0 then
			self.m_YoukaIcon:SetSpriteName("h7_jingyan_3")
			break
		elseif i == "gold" and tonumber(v) > 0 then
			self.m_YoukaIcon:SetSpriteName("10002")
			break
		elseif i == "goldcoin" and tonumber(v) > 0 then
			self.m_YoukaIcon:SetSpriteName("10001")
			break
		elseif i == "partner" and tonumber(v) then
			local dPartnerData = data.partnerdata.INFO[tonumber(v)]
           	self.m_YoukaIcon:SpriteAvatar(dPartnerData.shape)

		elseif  i == "ride" and tonumber(v) then
			local dRideData = data.ridedata.RIDEINFO[tonumber(v)]
            self.m_YoukaIcon:SpriteAvatar(dRideData.shape)
		elseif i == "silver" and tonumber(v) >0 then
			self.m_YoukaIcon:SetSpriteName("10003")
			break
		elseif i == "summon" and next(v) then
			local dSummon = data.summondata.INFO[v[1].sid]
			self.m_YoukaIcon:SpriteAvatar(dSummon.shape)
			break
		end
	end
	self.m_YoukaIcon:MakePixelPerfect()
	self.m_GuideGrid:Reposition()
end

function CMainMenuLT.OpenTimeLimitView(self)
	self.m_TimeLimitBtn:DelEffect("Circu") --道具投资的特效处理

	-- 每日累计消费
	nethuodong.C2GSDayExpenseOpenRewardUI()
	CTimelimitView:ShowView()
end

function CMainMenuLT.OnAssembleTreasureView(self)
	netrank.C2GSGetRankInfo(211, 1)
	CAssembleTreasureView:ShowView()
end


function CMainMenuLT.OnSuperBateBtnClick(self)
	-- body
	nethuodong.C2GSSuperRebateGetRecord()
	CSuperRebateView:ShowView()
end

function CMainMenuLT.OnSuperRebateEvent(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.SuperRebate.Event.RereshSuperRebateValue or
		oCtrl.m_EventID == define.SuperRebate.Event.RefreshSuperRebateMul then
		self.m_SuperrebateRedPot:SetActive( g_SuperRebateCtrl:MainMenuSuperrebateRedPoint() )

	elseif  oCtrl.m_EventID == define.SuperRebate.Event.SuperRebateStart then
		self:InitSuperRebateBtn()
	elseif oCtrl.m_EventID == define.SuperRebate.Event.SuperRebateEnd then
		self:InitSuperRebateBtn()
	end
end

function CMainMenuLT.RegisterSysEffs(self)
	g_SysUIEffCtrl:Register("RANK_SYS", self.m_RankBtn)
	g_SysUIEffCtrl:Register("TRADE_S", self.m_EcononmyBtn)
	g_SysUIEffCtrl:Register("ZHIYIN", self.m_HelpBtn)
end

function CMainMenuLT.UnRegisterSysEffs(self)
	g_SysUIEffCtrl:UnRegister("RANK_SYS", self.m_RankBtn)
	g_SysUIEffCtrl:UnRegister("TRADE_S", self.m_EcononmyBtn)
	g_SysUIEffCtrl:UnRegister("ZHIYIN", self.m_HelpBtn)
end

function CMainMenuLT.Destroy(self)
	self:UnRegisterSysEffs()
end

return CMainMenuLT


