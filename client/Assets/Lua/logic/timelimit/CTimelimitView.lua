local CTimelimitView = class("CTimelimitView", CViewBase)

function CTimelimitView.ctor(self, cb)
    CViewBase.ctor(self, "UI/TimeLimit/TimeLimitView.prefab", cb)
    --界面设置
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
    self.m_CurPageKey = nil
    self.m_TabDict = {} --tab按钮
    self.m_PageDict = {}  --tab按钮对应的子界面
end

function CTimelimitView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_BtnGrid = self:NewUI(2, CGrid)
    self.m_BtnBox = self:NewUI(3, CBox)

    self.m_IsNotCheckOnLoadShow = true
	
    self:InitContent()
end

function CTimelimitView.OnShowView(self)
    -- if g_TimelimitCtrl.m_FlopOpenState == 1 then
    --     g_TimelimitCtrl.m_FlopCardInit = false
    --     g_TimelimitCtrl.m_FlopCardResetInit = false
    --     nethuodong.C2GSDrawCardOpenView()
    -- end
end

function CTimelimitView.OnHideView(self)
    self.m_FlopPage:OnHidePage()
end

function CTimelimitView.InitContent(self)
    self.m_BtnBox:SetActive(false)

    self:CreatePages()
    self:CreateTabs()
	
    g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimelimitCtrl"))
    g_EveryDayChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEveryDayChargeCtrl"))
	g_ActiveGiftBagCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActiveGiftBagCtrl"))
    g_AccumChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAccumChargeCtrl"))
    --g_LotteryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLotteryCtrlEvent"))
    g_HeShenQiFuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHeShenQiFuEvent"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateWelfareEvent"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
    g_ItemInvestCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemInvestEvent"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    self:SelDefaultPage()
end

function CTimelimitView.CreatePages(self)
	self.m_EveryDayChargePage = self:NewPage(4, CEveryDayChargePart)
    self.m_SevenDayPage = self:NewPage(5, CTimelimitSevenDayPage)
    self.m_AccumulativeCon = self:NewPage(6, CAccumulativeConsume)
    self.m_AccumCharge = self:NewPage(7, CAccumChargePage)
	self.m_ActiveGiftBagPage = self:NewPage(8, CActiveGiftBagPage)
    self.m_FlopPage = self:NewPage(9, CFlopPart)
    self.m_HeShenQiFuPage = self:NewPage(10, CHeShenQiFuPage)
    self.m_CollectGiftPart = self:NewPage(11, CWelfareCollectPart)
    self.m_ContChargePart = self:NewPage(12, CContChargePage)
    self.m_ContConsumePart = self:NewPage(13, CContConsumePage)
    self.m_ItemInvestPart = self:NewPage(14, CItemInvestPage)

    self.m_PageDict = {
        ["EveryDayCharge"] = self.m_EveryDayChargePage,
        ["SevenDay"] = self.m_SevenDayPage,
        ["AccConsume"] = self.m_AccumulativeCon,
        ["AccCharge"] = self.m_AccumCharge,
		["ActiveGiftBag"] = self.m_ActiveGiftBagPage,
        ["Flop"] = self.m_FlopPage,
        ["HeShenQiFu"] = self.m_HeShenQiFuPage,
        ["CollectGift"] = self.m_CollectGiftPart,
        ["ContCharge"] = self.m_ContChargePart,
        ["ContConsume"] = self.m_ContConsumePart,
        ["ItemInvest"] = self.m_ItemInvestPart,
    }

end

function CTimelimitView.CreateTabs(self)
    local tabList = g_TimelimitCtrl:GetOpenTabList()
    for i, dTab in ipairs(tabList) do
        local oTab = self.m_BtnGrid:GetChild(i)
        if not oTab then
            oTab = self:CreateTabBox()
        end
        oTab:SetActive(true)
        self.m_TabDict[dTab.sys] = oTab
        oTab.nameL:SetText(dTab.name)
        oTab.colNameL:SetText(dTab.name)
        local bShowRedPt = g_TimelimitCtrl:IsHasRedPoint(dTab.sys) and true or false
        oTab.redPtSpr:SetActive(bShowRedPt)
        oTab.key = dTab.sys
        oTab.idx = i
        oTab:AddUIEvent("click", callback(self, "OnClickTab", dTab.sys))
        -- if oTab.key == "CaiShen" then
        --     oTab:SetGroup(-1)
        --     oTab.m_UIToggle.activeSprite = nil
        -- end
    end
    self.m_BtnGrid:Reposition()
end

function CTimelimitView.CreateTabBox(self)
    local oTab = self.m_BtnBox:Clone()
    oTab.nameL = oTab:NewUI(1, CLabel)
    oTab.redPtSpr = oTab:NewUI(2, CSprite)
    oTab.colNameL = oTab:NewUI(3, CLabel)
    oTab:SetGroup(self.m_BtnGrid:GetInstanceID())
    self.m_BtnGrid:AddChild(oTab)
    return oTab
end

--刷新tab栏红点显示
function CTimelimitView.RefreshBtnRedPoint(self)
    local tabDict = self.m_TabDict
    for sys, oTab in pairs(tabDict) do
        local bRedPt = g_TimelimitCtrl:IsHasRedPoint(sys)
        oTab.redPtSpr:SetActive(bRedPt)
    end
end

function CTimelimitView.RefreshSysBtnRedPoint(self, sys)
    local oTab = self.m_TabDict[sys]
    if oTab then
        local bRedPt = g_TimelimitCtrl:IsHasRedPoint(sys)
        oTab.redPtSpr:SetActive(bRedPt)
    end
end

function CTimelimitView.ShowTab(self, sys)
	local oTab = self.m_TabDict[sys]
	if not oTab then
		local tabList = g_TimelimitCtrl:GetOpenTabList()
		for i, dTab in ipairs(tabList) do
			if dTab.sys == sys then
				if not oTab then
					oTab = self:CreateTabBox()
				end
				oTab:SetActive(true)
				self.m_TabDict[dTab.sys] = oTab
				oTab.nameL:SetText(dTab.name)
				oTab.colNameL:SetText(dTab.name)
				local bShowRedPt = g_TimelimitCtrl:IsHasRedPoint(dTab.sys) and true or false
				oTab.redPtSpr:SetActive(bShowRedPt)
				oTab.key = dTab.sys
				oTab.idx = i
				oTab:AddUIEvent("click", callback(self, "OnClickTab", dTab.sys))
				break
			end
		end
    else
		local oldTab = self.m_TabDict[self.m_CurPageKey]
		if oldTab then
			oldTab:ForceSelected(false)
		end
	
		oTab:SetActive(true)
		oTab:ForceSelected(true)
		self:ForceSelPage(sys)
		self.m_CurPageKey = sys
		--printc("CTimelimitView.ShowTab 22222222222")
	end
	self.m_BtnGrid:Reposition()
end

function CTimelimitView.SetTabVisible(self, sys, isVisible)
	local oTab = self.m_TabDict[sys]
    if oTab then
        oTab:SetActive(isVisible)
    end
end

function CTimelimitView.SetTabSelected(self, sys, isSelected)
	local oTab = self.m_TabDict[sys]
    if oTab then
        oTab:SetSelected(isSelected)
    end
end

-- 选择默认的页签，规则：第一个红点
function CTimelimitView.SelDefaultPage(self)
    local btnList = self.m_BtnGrid:GetChildList()
    local oTopRed, oTop
    for i, oBtn in ipairs(btnList) do
        if oBtn.key ~= "CaiShen" then
            if not oTop then
                oTop = oBtn
            end
            if oBtn.redPtSpr and oBtn.redPtSpr:GetActive() then
                oTopRed = oBtn
                break
            end
        end
    end
    local oSel = oTopRed or oTop or btnList[1]
    if oSel then
        oSel:SetSelected(true)
        self:OnClickTab(oSel.key)
    end
end

-- 外部接口，打开选中特定页面
function CTimelimitView.ForceSelPage(self, sKey)
    if self.m_TabDict[sKey] then
        self.m_TabDict[sKey]:SetSelected(true)
        self:OnClickTab(sKey)
    end
end

function CTimelimitView.GetTabCount(self)
    return #self.m_BtnGrid:GetChildList()
end

function CTimelimitView.HidePage(self, sKey)
    if not self.m_TabDict[sKey] then 
		return 
	end

	local oTab = self.m_TabDict[sKey]
    if oTab then
        oTab:SetSelected(false)
        oTab:SetActive(false)
    end
	
	local iCurIdx = oTab.idx
	local sCurPage = self.m_CurPageKey
    if sCurPage == sKey then
        local oPage = self.m_PageDict[sKey]
        if oPage then
            oPage:HidePage()
        end
        local btnList = self.m_BtnGrid:GetChildList()
        local iTabCnt = #btnList
		if iTabCnt > 1 then
            local iCnt = 0
			while iCnt < iTabCnt do
				iCurIdx = iCurIdx + 1
				if iCurIdx > iTabCnt then
					iCurIdx = 1
				end
                iCnt = iCnt + 1
				local oNextTab = btnList[iCurIdx]
				if oNextTab and oNextTab:GetActive() and oNextTab.key ~= "CaiShen" then
					self:OnClickTab(oNextTab.key)
					oNextTab:SetSelected(true)
					self.m_CurPageKey = oNextTab.key
					break
				end
			end
        else
            self:CloseView() --最后一个活动关闭时关闭整个显示活动界面
            return
		end
    end
    self.m_BtnGrid:Reposition()
end

function CTimelimitView.OnClickTab(self, sKey)
    if not self.m_TabDict[sKey] then
        return
    end

    local oPage = self.m_PageDict[sKey]
    -- if sKey == "CaiShen" then
    --     CCaishenGiftView:ShowView()
    --     return
    -- end
    if oPage and self.m_CurPageKey ~= sKey then
        if self.m_CurPageKey then
            local curPage = self.m_PageDict[self.m_CurPageKey]
            curPage:HidePage()
        end

        self.m_CurPageKey = sKey
        oPage:ShowPage()
    end
end

function CTimelimitView.OnClose(self)
    self:CloseView()
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

function CTimelimitView.OnTimelimitCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.RefreshRedPoint then
        self:RefreshBtnRedPoint()
    elseif oCtrl.m_EventID == define.Timelimit.Event.RefreshDayExpense then
        self.m_AccumulativeCon:InitContent()
    end
    if oCtrl.m_EventID == define.Timelimit.Event.SevenDayEnd then
        self:HidePage("SevenDay")
    end

end

function CTimelimitView.OnEveryDayChargeCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeStart then
		self:ShowTab("EveryDayCharge")
    elseif oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeNotifyRefreshRedPoint then
        self:RefreshBtnRedPoint()
    elseif oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeEnd then
        self:HidePage("EveryDayCharge")
    end
end

function CTimelimitView.OnActiveGiftBagCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagStart then
		self:ShowTab("ActiveGiftBag")
    elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagInfoChanged then
        self:RefreshBtnRedPoint()
    elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagEnd then
        self:HidePage("ActiveGiftBag")
    end
end 

function CTimelimitView.OnAccumChargeCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.RefreshAccCharge then
        self:RefreshSysBtnRedPoint("AccCharge")
    end
end

-- function CTimelimitView.OnLotteryCtrlEvent(self, oCtrl)
--     if oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenRedPoint or oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
--         self:RefreshSysBtnRedPoint("CaiShen")
--     end
-- end

function CTimelimitView.OnHeShenQiFuEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.HeShenQiFu.Event.QiFuReward then
        self:RefreshSysBtnRedPoint("HeShenQiFu")
    end

end

function CTimelimitView.OnUpdateWelfareEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateCollectPnl then
        self:RefreshSysBtnRedPoint("CollectGift")
        if oCtrl:GetCollectGiftStatus() == 0 then
            self:HidePage("CollectGift")
        end
    end
end

function CTimelimitView.OnContActCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.UpdateContConsume then
        self:RefreshSysBtnRedPoint("ContConsume")
    -- elseif oCtrl.m_EventID == define.Timelimit.Event.EndContConsume then
    --     self:HidePage("ContConsume")
    -- elseif oCtrl.m_EventID == define.Timelimit.Event.EndContCharge then
    --     self:HidePage("ContCharge")
    elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateContCharge then
        self:RefreshSysBtnRedPoint("ContCharge")
    end
end

function CTimelimitView.OnItemInvestEvent(self, oCtrl)
    if oCtrl.m_EventID == define.ItemInvest.Event.RefreshItemInvestState then
        local bOpen = g_ItemInvestCtrl:IsItemInvestOpen()
        if not bOpen then
            self:HidePage("ItemInvest")
        end
    elseif oCtrl.m_EventID == define.ItemInvest.Event.RefreshItemInvestUnit then
        self:RefreshSysBtnRedPoint("ItemInvest")
    elseif oCtrl.m_EventID == define.ItemInvest.Event.RefreshRedPtSpr then
        self:RefreshSysBtnRedPoint("ItemInvest")
    end
end

return CTimelimitView