local CWarLT = class("CWarLT", CBox)

function CWarLT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PopBtn = self:NewUI(1, CSprite)
	self.m_Content = self:NewUI(2, CObject)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_Bg = self:NewUI(4, CSprite)
	self.m_New = self:NewUI(5, CSprite)
	self.m_WarMatchLabel = self:NewUI(6, CLabel)
	self.m_WarMatchLabel:SetActive(false)

	self.m_TweenPos = self.m_Content:GetComponent(classtype.TweenPosition)
	self.m_TweenAlp = self.m_Content:GetComponent(classtype.TweenAlpha)
	self.m_TweenRotation = self.m_PopBtn:GetComponent(classtype.TweenRotation)

	self.m_PopBtn:AddUIEvent("click", callback(self, "OnPopBtn"))

	self:InitSysBtns()
	self:RegisterCtrls()
	self:RefreshBtns()
	self:RefreshWarObCount()
	self:RegisterSysEffs()
end

function CWarLT.InitSysBtns(self)
	self.m_BtnInfoList = {
		{name = "Item", view = "CItemMainView"},
		{name = "Welfare", view = "CWelfareView"},
		{name = "Schedule", view = "CScheduleMainView"},
		{name = "Timelimit", view = "CTimelimitView"},
		{name = "Guild", view = "CNpcShopMainView"},
		{name = "Stall", view = "CEcononmyMainView"},
		{name = "System", view = "CSystemSettingsMainView"},
		{name = "Zhiyin", view = "CGaideMainView"},
		{name = "Org", view = "COrgInfoView"},
		{name = "Rank", view = "CRankListView"},
		{name = "Skill", view = "CSkillMainView"},
		{name = "Partner", view = "CPartnerMainView"},
		{name = "Forge", view = "CForgeMainView"},
		{name = "Horse", view = "CHorseMainView"},
		{name = "Badge", view = "CBadgeView"},
		{name = "Wing", view = "CWingMainView"},
		{name = "Artifact", view = "CArtifactMainView"},
		{name = "FaBao", view = "CFaBaoView"},
		{name = "Kaifu", view = "CCelebrationView"},
	}

	local iCount = 0
	local function InitBtns(obj, idx)
		local name = self.m_BtnInfoList[idx].name
		local viewName = self.m_BtnInfoList[idx].view

		self["m_"..name] = CButton.New(obj)
		if viewName == "CNpcShopMainView" then
			self:CheckNpcShop()  --检查新品提示
		end
		self["m_"..name] = self["m_"..name]
		self["m_"..name]:AddUIEvent("click", callback(self, "OnClickSysBtn", viewName))
		local show = self:CheckBtnShow(name)
		self["m_"..name]:SetActive(show)
		if show then
			iCount = iCount + 1
		end
		self["m_"..name].m_IgnoreCheckEffect = true
		return self["m_"..name]
	end
	self.m_Grid:InitChild(InitBtns)
	self:ResetBgSize(iCount)
end

function CWarLT.RefreshBtns(self)
	self:RefreshItemBtn()
	self:RefreshOrgBtn()
	self:RefreshPartnerBtn()
	self:RefreshWelfareBtn()
	self:RefreshKaifuBtn()
	self:RefreshStallBtn()
	self:RefreshScheduleBtn()
	self:RefreshZhiyinBtn()
	self:RefreshTimelimitBtn()
	self:RefreshShopRect()
end

function CWarLT.RegisterCtrls(self)
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOpenSysCtrlEvent"))
	g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCelebtCtrlEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNpcShopEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleEvent"))
	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEcononmyEvent"))

	-- 福利相关
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnWelfareEvent"))
	g_SignCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSignEvent"))
	g_UpgradePacksCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpgradePackEvent"))
	g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineGiftEvent"))

	-- 限时活动
	g_LotteryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLotteryCtrlEvent"))
	g_AccumChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAccumChargeEvent"))
	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimeLimitCtrlEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarCtrlEvent"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
    g_ItemInvestCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemInvestEvent"))

end

--检查系统一些其他条件，是否开启的状态
function CWarLT.CheckOpenState(self, oSysName)
	if oSysName == define.System.Kaifu then
		return g_CelebrationCtrl:CheckKaifuOpenState()
	elseif oSysName == define.System.Timelimit then
		return #g_TimelimitCtrl:GetOpenTabList() > 0
	else
		return true
	end
end

function CWarLT.CheckBtnShow(self, name)
	local sysOpen = g_OpenSysCtrl:GetOpenSysState(define.System[name])
	local loginOpen = not g_OpenSysCtrl:GetIsNeedLoginShow(define.System[name])
	local otherOpen = self:CheckOpenState(define.System[name])
	local releOpen = false
	local releList = {"Item","System"}
	if table.index(releList, name) then
		releOpen = true
	end
	local show = (sysOpen and loginOpen and otherOpen) or releOpen
	return show
end

function CWarLT.ResetBgSize(self, iCount)
	if not iCount then
		iCount = 0
		for i, oBtn in ipairs(self.m_Grid:GetChildList()) do
			if oBtn:GetActive() then
				iCount = iCount + 1
			end
		end
	end
	local low = 1
	if iCount > 4 then
		low = math.ceil(iCount/4)
	end
	local _,cellH = self.m_Grid:GetCellSize()
	self.m_Bg:SetHeight(low*cellH + 10)
end

--------------- 刷新按钮 ----------------
function CWarLT.RefreshItemBtn(self)
	local oBtn = self.m_Item
	if not oBtn then return end
	local bRedPt = (g_ItemCtrl.m_ItemEffList and #g_ItemCtrl.m_ItemEffList > 0) or g_ItemCtrl.m_ShowRefineRedPoint
	self:ShowBtnRedPt(oBtn, bRedPt)
end

function CWarLT.RefreshOrgBtn(self)
	local oBtn = self.m_Org
	if not oBtn then return end
	self:ShowBtnRedPt(oBtn, self:CheckOrgRedPt())
end

function CWarLT.RefreshPartnerBtn(self)
	local oBtn = self.m_Partner
	if not oBtn then return end
	self:ShowBtnRedPt(oBtn, self:CheckPartnerRedPt())
end

function CWarLT.RefreshStallBtn(self)
	local oBtn = self.m_Stall
	if not oBtn then return end
	self:ShowBtnRedPt(oBtn, g_EcononmyCtrl.m_StallNotify)
end

function CWarLT.RefreshWelfareBtn(self)
	local oBtn = self.m_Welfare
	if not oBtn then return end
	self:ShowBtnRedPt(oBtn, g_WelfareCtrl:IsHadRedPoint())
	if g_WelfareCtrl:IsCircleShow() then
		oBtn:AddEffect("Circu")
	else
		oBtn:DelEffect("Circu")
	end
end

function CWarLT.RefreshKaifuBtn(self)
	local oBtn = self.m_Kaifu
	if not oBtn then return end
	local bRedPt = g_CelebrationCtrl:IsHadRedPoint()
	self:ShowBtnRedPt(oBtn, bRedPt, 22, Vector2(-25, -17))
	if not g_CelebrationCtrl.m_IsHasClickMainMenu or g_CelebrationCtrl:IsHadRedPoint() then
		oBtn:AddEffect("Circu")
	else
		oBtn:DelEffect("Circu")
	end
	local bCurActive = oBtn:GetActive()
	local bActive = self:CheckBtnShow("Kaifu") or false
	if bCurActive ~= bActive then
		oBtn:SetActive(bActive)
		self.m_Grid:Reposition()
		self:ResetBgSize()
	end
end

function CWarLT.RefreshScheduleBtn(self)
	local oBtn = self.m_Schedule
	if not oBtn then return end
	local bRedPt = g_ScheduleCtrl.m_MainUIRedPointSta
	self:ShowBtnRedPt(oBtn, bRedPt)
	if g_ScheduleCtrl:IsExistRectEffect() then
		oBtn:AddEffect("Circu")
	else
		oBtn:DelEffect("Circu")
	end
end

function CWarLT.RefreshZhiyinBtn(self)
	local oBtn = self.m_Zhiyin
	if not oBtn then return end
	self:ShowBtnRedPt(oBtn, g_PromoteCtrl.m_GrowRedPoint)
end

function CWarLT.CheckNpcShop(self)
	--检查301、302商店是否需要新商品提示
	local newGoodList = g_ShopCtrl:GetNewGoodInShop()
	local isShow = table.count(newGoodList) ~= 0
	if self.m_New then
		self.m_New:SetActive(isShow)
	end
	if g_ShopCtrl:HasLimitGoodsRedPoint() then
		self:ShowBtnRedPt(self.m_Guild, true)
	end
end

function CWarLT.RefreshShopRect(self)
	local bHasRect = g_WelfareCtrl:IsHadRebateRedPoint()
	if bHasRect then
		self.m_Guild:AddEffect("Circu")
	else
		self.m_Guild:DelEffect("Circu")
	end
end

function CWarLT.RefreshTimelimitBtn(self)
	local oBtn = self.m_Timelimit
	if not oBtn then return end
	
	local bCurActive = oBtn:GetActive()
	local bActive = #g_TimelimitCtrl:GetOpenTabList() > 0
	if bCurActive ~= bActive then
		oBtn:SetActive(bActive)
		self.m_Grid:Reposition()
		self:ResetBgSize()
	end

	local bRedPt = g_TimelimitCtrl:IsHasRedPoint()
	self:ShowBtnRedPt(oBtn, bRedPt)
end

function CWarLT.RefreshWarObCount(self, count)
	count = count or g_WarCtrl.m_WarObCount

	local show = count and count > 0
	self.m_WarMatchLabel:SetActive(show)
	if show then
		self.m_WarMatchLabel:SetText("#G" .. count .. "[-]人正在围观")
	end
end

function CWarLT.RefreshFabaoBtn(self, itemsid)
	local oBtn = self.m_FaBao
	if not oBtn then return end
	if itemsid then
		local slist = {10155, 10156, 10157, 10158}
		if table.index(slist, itemsid) then
			local bPromoteRed = g_FaBaoCtrl:GetFaBaoPromoteRedPot()
			local bAwakenRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
			if bPromoteRed or bAwakenRed then
				self:ShowBtnRedPt(oBtn, true)
			end
		end
	else
		local bPromoteRed = g_FaBaoCtrl:GetFaBaoPromoteRedPot()
		local bAwakenRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
		if bPromoteRed or bAwakenRed then
			self:ShowBtnRedPt(oBtn, true)
		end
	end
end

------------------- 红点 --------------------
function CWarLT.ShowBtnRedPt(self, oBtn, bShow, iSize, pos)
	if bShow then
		oBtn:AddEffect("RedDot", iSize or 22, pos or Vector2(-27,-26))
	else
		oBtn:DelEffect("RedDot")
	end
end

function CWarLT.CheckOrgRedPt(self)
	if g_AttrCtrl.org_id == 0 then
		return false
	end
	local bIsNotSign = g_OrgCtrl.m_LoginOrgRedPontInfo.sign_status == 0
    local bIsNotBonus = g_OrgCtrl.m_LoginOrgRedPontInfo.bonus_status == 1
    local bIsNotPos = g_OrgCtrl.m_LoginOrgRedPontInfo.pos_status == 1
    local bIsShopNotify = g_OrgCtrl.m_LoginOrgRedPontInfo.shop_status == 1

    local showRedPoint = bIsNotSign or bIsNotPos or bIsNotBonus or bIsShopNotify
	if g_RedPacketCtrl.m_ShowOrgRedPoint or showRedPoint then
		return false
	end
	local info = g_OrgCtrl.m_LoginOrgRedPontInfo
	if next(info) == nil then  -- 没有收到协议
		return false
	end
	-- 有入帮申请
	if info.has_apply == 1 then
		return true
	-- 有自荐为帮主信息（且不是我）
	elseif info.apply_leader_pid ~= 0 and info.apply_leader_pid ~= g_AttrCtrl.pid then
		return true
	-- 不显示红点
	else
		return false
	end
end

function CWarLT.CheckPartnerRedPt(self)
	if g_PromoteCtrl.m_IsHasNewPartnerCouldUnLock or g_PromoteCtrl.m_IsHasNewPartnerCouldUpgrade then
		return true
	else
		return false
	end
end

----------------- ctrlEvent ----------------
function CWarLT.OnOpenSysCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Login then
		local iCount = 0
		for i, info in ipairs(self.m_BtnInfoList) do
			local oBtn = self.m_Grid:GetChild(i)
			if oBtn then
				local sysOpen = self:CheckBtnShow(info.name)
				oBtn:SetActive(sysOpen)
				if sysOpen then
					iCount = iCount + 1
				end
			end
		end
		self.m_Grid:Reposition()
		self:ResetBgSize(iCount)
	end
end

function CWarLT.OnCelebtCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Celebration.Event.UpdateRankReward then
		self:RefreshKaifuBtn()
	end
end

function CWarLT.OnLotteryCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
		self:RefreshKaifuBtn()
	end
end

function CWarLT.OnNpcShopEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.RefreshNpcShop then
		self:CheckNpcShop()
	elseif oCtrl.m_EventID == define.Shop.Event.RemoveLimitRedDot then
		self.m_Guild:DelEffect("RedDot")
	end
end

function CWarLT.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:CheckNpcShop()
	end
end

function CWarLT.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgRedPoint then
        self:RefreshOrgBtn()
	end
end

function CWarLT.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.UpdatePromoteData then
        self:RefreshPartnerBtn()
        self:RefreshZhiyinBtn()
    elseif oCtrl.m_EventID == define.Promote.Event.RefreshGrowRedPoint then
    	self:RefreshZhiyinBtn()
	end
end

function CWarLT.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshRefineRedPoint then
		self:RefreshItemBtn()
	elseif oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local sid = oCtrl.m_EventData
		self:RefreshFabaoBtn(sid)
	end
end

function CWarLT.OnScheduleEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Schedule.Event.RefreshUITip then
		self:RefreshScheduleBtn()
	elseif oCtrl.m_EventID == define.Schedule.Event.ClearEffect then
		self:RefreshScheduleBtn()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshHuodong  then
		self:RefreshScheduleBtn()
	elseif  oCtrl.m_EventID ==define.Schedule.Event.RefreshDouble then
		--self:RealTimeDoublePoint(oCtrl.m_SvrDoublePoint.current)
	end
end

function CWarLT.OnEcononmyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallNotify then
		self:RefreshStallBtn()
	end
end

function CWarLT.OnLotteryCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenRedPoint or oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
    	self:RefreshTimelimitBtn()
	end
end

function CWarLT.OnOnlineGiftEvent(self, oCtrl)
	if oCtrl.m_EventID == define.OnlineGift.Event.UpdateRedPoint then
		self:RefreshWelfareBtn()
	end
end

function CWarLT.OnSignEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.AddSignInfo then 
		self:RefreshWelfareBtn()
	end
end

function CWarLT.OnUpgradePackEvent(self, oCtrl)
	if oCtrl.m_EventID == define.UpgradePacks.Event.GetReward or oCtrl.m_EventID == define.UpgradePacks.Event.UpgradePacksDataChange then
		if not Utils.IsNil(self) then
			self:RefreshWelfareBtn()
		end
	end
end

function CWarLT.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateYuanbaoPnl or oCtrl.m_EventID == define.WelFare.Event.UpdateBigProfitPnl then
		self:RefreshWelfareBtn()
		self:RefreshKaifuBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateDailyRedDot or oCtrl.m_EventID == define.WelFare.Event.UpdateCollectPnl then
		self:RefreshWelfareBtn()
		self:RefreshTimelimitBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateFirstPayRedDot then
		self:RefreshWelfareBtn()
		self:RefreshKaifuBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.RefreshSecondPay then
		self:RefreshWelfareBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
		self:RefreshKaifuBtn()
	elseif oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
		self:RefreshShopRect()
	elseif oCtrl.m_EventID == define.WelFare.Event.RefreshExpRecycle then
		self:RefreshWelfareBtn()
	end
end

function CWarLT.OnAccumChargeEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshAccCharge then
		self:RefreshTimelimitBtn()
	end
end

function CWarLT.OnTimeLimitCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshRedPoint then
		self:RefreshTimelimitBtn()
	end
end

function CWarLT.OnWarCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.MatchCount then
		self:RefreshWarObCount(oCtrl.m_EventData)
	end
end

function CWarLT.OnContActCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.UpdateContConsume or oCtrl.m_EventID == define.Timelimit.Event.EndContConsume then
		self:RefreshTimelimitBtn()
	elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateContCharge or oCtrl.m_EventID == define.Timelimit.Event.EndContCharge then
		self:RefreshTimelimitBtn()
	end
end

function CWarLT.OnItemInvestEvent(self, oCtrl)

	local iEventState = define.ItemInvest.Event.RefreshItemInvestState
	local iEventUnit = define.ItemInvest.Event.RefreshItemInvestUnit

	if oCtrl.m_EventID == iEventState or oCtrl.m_EventID == iEventUnit then
		self:RefreshTimelimitBtn()
	end
end

------------------- UIEvent --------------------
function CWarLT.OnPopBtn(self)
	self.m_TweenPos:Toggle()
	self.m_TweenAlp:Toggle()
	self.m_TweenRotation:Toggle()
end

function CWarLT.OnClickSysBtn(self, viewName)
	if viewName == "COrgInfoView" then
		-- 帮派
		g_OrgCtrl:OpenOrgView()
		return
	elseif viewName == "CScheduleMainView" then
		-- 日程
		g_ScheduleCtrl:InitData()
	elseif viewName == "CCelebrationView" then
		g_CelebrationCtrl.m_IsHasClickMainMenu = true
		g_CelebrationCtrl:OnEvent(define.Celebration.Event.UpdateRankReward)
	elseif viewName == "CArtifactMainView" then
		CArtifactMainView:ShowView(function (oView)		
			oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
		end)
		return
	elseif viewName == "CWingMainView" then
		g_WingCtrl:ShowWingPropertyPage()
		return
	end
	g_ViewCtrl:ShowView(_G[viewName])
end

function CWarLT.RegisterSysEffs(self)
	self.m_SysEffWidgets = {"Item","Forge","Partner","Horse","Stall","Skill","Rank","Badge","Zhiyin"}
	for i, s in ipairs(self.m_SysEffWidgets) do
		local oBtn = self["m_"..s]
		local sys = self:GetSysEffName(s)
		if oBtn and sys then
			g_SysUIEffCtrl:Register(sys, oBtn)
		end
	end
end

function CWarLT.UnRegisterSysEffs(self)
	if self.m_SysEffWidgets then
		for i, s in ipairs(self.m_SysEffWidgets) do
			local oBtn = self["m_"..s]
			local sys = self:GetSysEffName(s)
			if oBtn and sys then
				g_SysUIEffCtrl:UnRegister(sys, oBtn)
			end
		end
	end
end

function CWarLT.GetSysEffName(self, sBtn)
	if sBtn == "Stall" then
		return "TRADE_S"
	elseif sBtn == "Item" then
		return "BAG_S"
	else
		return define.System[sBtn]
	end
end

function CWarLT.Destroy(self)
	self.m_TweenPos:Destroy()
	self.m_TweenAlp:Destroy()
	self.m_TweenRotation:Destroy()
	self:UnRegisterSysEffs()
	CBox.Destroy(self)
end

return CWarLT