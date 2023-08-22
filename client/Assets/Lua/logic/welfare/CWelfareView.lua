local CWelfareView = class("CWelfareView", CViewBase)

function CWelfareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/WelfareView.prefab", cb)

	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"	

    self.m_PartDict = {}
    self.m_TabDict = {}
    --用于处理八日登陆按钮选中时的黄色选中框
    self.m_LastSelectBtn = nil
end

function CWelfareView.LoadDone(self)
    CViewBase.LoadDone(self)
    g_ViewCtrl:ShowByGroup(self.m_GroupName)
end

function CWelfareView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)

	self.m_BtnBox = self:NewUI(5, CBox)

	self:InitContent()

	g_UpgradePacksCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpgradePackEvent"))

	--监听签到数据更新事件
	g_SignCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateSignEvent"))

    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateWelfareEvent"))

    g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineGiftEvent"))
end

function CWelfareView.InitContent(self)
	g_GuideCtrl:AddGuideUI("welfareview_close_btn", self.m_CloseBtn)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))

    self.m_TabC = g_WelfareCtrl:GetTabInfo()
    --self.m_TabC = define.WelFare.Tab
	self:CreatePage()
	self:CreateBtnGrid()

    self:ShowSignRedPoint(g_SignCtrl:IsHadRedPoint())
    self:ShowUpgradePacksRedPoint(g_UpgradePacksCtrl:IsHadRedPoint())
    self:ShowChargeRedPoints()
    --self:SetYoukaLoginViewRedPoint()

    self:InitRedDotPriority()
    self:SelDefaultPage()
    self.m_BtnScrollView:ResetPosition()
end

--创建page
function CWelfareView.CreatePage(self)
	-- 顺序由define.WelFare.Tab控制
	self.m_CSignPart = self:NewPage(3,CSignPart)
	self.m_UpgradePacks = self:NewPage(4,CUpgradePacksPart) 
    self.m_BigProfitPart = self:NewPage(6,CWelfareBigProfitPart)
    self.m_LuckyPresentPart = self:NewPage(7,CWelfareLuckyPresentPart)
    self.m_YuanbaoPart = self:NewPage(8,CWelfareYuanbaoPart)
    self.m_ExchangePart = self:NewPage(9,CWelfareExchangePart)
    self.m_FirstPayPart = self:NewPage(10,CFirstPayPage)--CWelfareFirstChargePart)
    -- self.m_RebateExplainPart = self:NewPage(11,CRebateExplainPart)
    -- self.m_CollectGiftPart = self:NewPage(12,CWelfareCollectPart)
    -- self.m_LotteryPart = self:NewPage(13,CWelfareLotteryPart)
    self.m_ReturnGift = self:NewPage(14, CWelfareReturnGiftPart)
    self.m_OnlineGiftPart = self:NewPage(15, COnlineGiftPage)
    self.m_BtnScrollView = self:NewUI(16, CScrollView)
    self.m_FightGiftPart = self:NewPage(17, CWelfareFightGiftPart)
    self.m_SecondPayPart = self:NewPage(18, CWelfareSecondChargePart)
    self.m_EightLoginPart = self:NewPage(19, CWelfareEightLoginPart)
    self.m_ExpRecyclePart = self:NewPage(20, CExpRecyclePage)
    self.m_WelfareGuideWidget = self:NewUI(21, CWidget)

    g_GuideCtrl:AddGuideUI("welfare_guide_widget", self.m_WelfareGuideWidget)

    self.m_PartDict =
    {
        [self.m_TabC.Sign] = self.m_CSignPart,
        [self.m_TabC.UpgradePack] = self.m_UpgradePacks,
        [self.m_TabC.YoukaLogin] = self.m_EightLoginPart,
        [self.m_TabC.GiftGrade] = self.m_BigProfitPart,
        [self.m_TabC.GiftDay] = self.m_LuckyPresentPart,
        [self.m_TabC.GiftGoldcoin] = self.m_YuanbaoPart,
        [self.m_TabC.Exchange] = self.m_ExchangePart,
        [self.m_TabC.FirstPay] = self.m_FirstPayPart,
        -- [self.m_TabC.RebateExplain] = self.m_RebateExplainPart,
        -- [self.m_TabC.CollectGift] = self.m_CollectGiftPart,
        -- [self.m_TabC.ColorfulLamp] = { []},
        -- [self.m_TabC.CaiShen] = self.m_LotteryPart,
        [self.m_TabC.ReturnGift] = self.m_ReturnGift,
        [self.m_TabC.OnlineGift] = self.m_OnlineGiftPart,
        [self.m_TabC.FightGift] = self.m_FightGiftPart,
        [self.m_TabC.SecondPay] = self.m_SecondPayPart,
        [self.m_TabC.ExpRecycle] = self.m_ExpRecyclePart,
    }
    local iBigProfit2 = self.m_TabC.GiftGrade2
    if iBigProfit2 then
        self.m_PartDict[iBigProfit2] = self.m_BigProfitPart
    end
end

function CWelfareView.InitRedDotPriority(self)
    self.m_RedDotPrioritys = {
        [self.m_TabC.Sign] = 1,
        [self.m_TabC.OnlineGift] = 2,
        [self.m_TabC.UpgradePack] = 3,
        [self.m_TabC.FightGift] = 4,
        [self.m_TabC.FirstPay] = 5,
        [self.m_TabC.SecondPay] = 6,
        [self.m_TabC.GiftGoldcoin] = 7,
        [self.m_TabC.GiftDay] = 8,
        [self.m_TabC.GiftGrade] = 9,
    }
end

--创建btn列表 , 判断开启等级
function CWelfareView.CreateBtnGrid(self, bNotSelectFirst)
    self.m_Index = 900000
    local huodongList = g_WelfareCtrl:GetOpenHuodong()
    table.print(huodongList)
	for i,v in ipairs(huodongList) do
        local box = self.m_TabDict[v.idx]
        if box == nil then
           box = self.m_BtnBox:Clone()
           box:SetActive(true)
           box.name = box:NewUI(1,CLabel)
           box.redPoint = box:NewUI(2,CSprite)
           box.colorName = box:NewUI(3, CLabel)
           box:SetGroup(self.m_BtnGrid:GetInstanceID())
           self.m_BtnGrid:AddChild(box)
           self.m_TabDict[v.idx] = box
        end
        self.m_BtnBox:SetActive(false)
        self.m_Index = self.m_Index + 1
        box:SetName(tostring(self.m_Index))
        local info = g_WelfareCtrl:GetViewOpenData(v.key)
        if not info then
            info = g_WelfareCtrl:GetUnLockViewData(v.key)
        end
        if info then
            box.name:SetText(info.name)
            box.colorName:SetText(info.name)
            box.key = v.idx
            box:AddUIEvent("click",callback(self, "OnClickBtn", v.idx))

            if info.stype and info.stype == define.System.Sign then
                g_GuideCtrl:AddGuideUI("sign_tab_btn", box)
            end
            if info.stype and info.stype == define.System.UpgradePack then
            	g_GuideCtrl:AddGuideUI("upgradepack_tab_btn", box)
            end
            if info.stype and info.stype == define.System.YoukaLogin then
                g_GuideCtrl:AddGuideUI("eightlogin_tab_btn", box)
            end
        end
    end
    self.m_BtnGrid:Reposition()
end


--显示升级礼包小红点
function CWelfareView.ShowUpgradePacksRedPoint(self, isShow)
	
	local upgradePackBtn = self.m_TabDict[self.m_TabC.UpgradePack]
	if upgradePackBtn ~= nil then
		upgradePackBtn.redPoint:SetActive(isShow)
	end
end

--显示签到小红点
function CWelfareView.ShowSignRedPoint(self, isShow)
	
	local signBtn = self.m_TabDict[self.m_TabC.Sign]
	if signBtn ~= nil then
		signBtn.redPoint:SetActive(isShow)
	end
end

function CWelfareView.OnClickBtn(self, tabIndex)
    -- 八日登陆特殊处理
    -- if tabIndex then
    --     if tabIndex ~=  define.WelFare.Tab.YoukaLogin then
    --         self.m_LastSelectBtn = self.m_TabDict[tabIndex]
    --     elseif self.m_LastSelectBtn then
    --         self.m_LastSelectBtn:ForceSelected(true)
    --         CYoukaLoginView:ShowView()
    --         return
    --     end
    -- end
    if not self.m_TabDict[tabIndex] then
        return
    end
    self.m_TabDict[tabIndex]:ForceSelected(true)
    if self.m_CurSelIdx then
        local oCurPage = self.m_PartDict[self.m_CurSelIdx]
        if oCurPage then
            oCurPage:HidePage()
        end
    end
    self.m_CurSelIdx = tabIndex
    if tabIndex == self.m_TabC.GiftDay and g_WelfareCtrl:IsHadDailyRedPoint() then
        self:ShowRedPoint(tabIndex, false)
        g_WelfareCtrl:SetHasClickDailyTab()
    elseif tabIndex == self.m_TabC.FirstPay and g_FirstPayCtrl:IsShow() then
        if not g_FirstPayCtrl.m_HasClickTab then
            g_FirstPayCtrl:SetHasClickTab()
            self:ShowRedPoint(tabIndex, g_WelfareCtrl:IsHadFirstPayRedPoint())
        end
    elseif tabIndex == self.m_TabC.GiftGoldcoin and not g_WelfareCtrl.m_HasClickGoinGiftTab then
        g_WelfareCtrl:SetHasClickGoldGiftTab()
        self:ShowRedPoint(tabIndex, false)
    elseif tabIndex == self.m_TabC.GiftGrade then
        if not g_WelfareCtrl.m_HasClkGradeGiftTab then
            g_BigProfitCtrl:SetHasClkGradeGiftTab()
            -- self:ShowRedPoint(tabIndex, false)
        end
        if g_BigProfitCtrl.m_IsShowBoth then
            self.m_BigProfitPart:ShowForceLv(1)
        end
    --elseif tabIndex == self.m_TabC.OnlineGift then
        --g_OnlineGiftCtrl:SetHasClk()
        --self:ShowRedPoint(tabIndex, false)
    elseif tabIndex == self.m_TabC.FightGift then
        g_WelfareCtrl:FightGiftbagGetInfo()
    elseif tabIndex == self.m_TabC.GiftGrade2 then
        self.m_BigProfitPart:ShowForceLv(2)
    end
	-- CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
    local oPage = self.m_PartDict[tabIndex]
    if oPage then
        oPage:ShowPage()
    end
end


function CWelfareView.OnUpgradePackEvent(self, oCtrl)
	--更新小红点
	if oCtrl.m_EventID == define.UpgradePacks.Event.GetReward then
		self:ShowUpgradePacksRedPoint(oCtrl:IsHadRedPoint())
	end

end

function CWelfareView.OnUpdateSignEvent(self, oCtrl)
	
	--更新小红点
	if oCtrl.m_EventID == define.WelFare.Event.AddSignInfo then 

		self:ShowSignRedPoint(oCtrl:IsHadRedPoint())

	end

end

function CWelfareView.ShowChargeRedPoints(self)
    self:ShowRedPoint(self.m_TabC.GiftGrade, g_WelfareCtrl:IsHadGradeRedPoint())
    self:ShowRedPoint(self.m_TabC.GiftDay,g_WelfareCtrl:IsHadDailyRedPoint())
    self:ShowRedPoint(self.m_TabC.GiftGoldcoin, g_WelfareCtrl:IsHadYuanbaoRedPoint())
    self:ShowRedPoint(self.m_TabC.FirstPay, g_WelfareCtrl:IsHadFirstPayRedPoint())
    -- self:ShowRedPoint(self.m_TabC.CollectGift,g_WelfareCtrl:IsHadCollectRedPoint())
    -- self:ShowRedPoint(self.m_TabC.ColorfulLamp, g_WelfareCtrl.m_ColorfulLampInfo)
    self:ShowRedPoint(self.m_TabC.ReturnGift, g_WelfareCtrl:IsHadReturnGiftRedPoint())
    self:ShowRedPoint(self.m_TabC.OnlineGift, g_OnlineGiftCtrl:IsHasRedPoint())
    self:ShowRedPoint(self.m_TabC.FightGift, g_WelfareCtrl:IsHasFightGiftRedPoint())
    self:ShowRedPoint(self.m_TabC.SecondPay, g_WelfareCtrl:IsHadSecondPayRedPoint())
    self:ShowRedPoint(self.m_TabC.YoukaLogin, g_WelfareCtrl:IsHadReturnYoukaLoginRedPoint())
    self:ShowRedPoint(self.m_TabC.ExpRecycle, g_WelfareCtrl:IsHasExpRecycleRedDot())
end

function CWelfareView.ShowRedPoint(self, tagIdx, bState)
    local tagBtn = self.m_TabDict[tagIdx]
    if tagBtn then
        tagBtn.redPoint:SetActive(bState)
    end
end

-- function CWelfareView.SetYoukaLoginViewRedPoint(self)
--     if not next(g_WelfareCtrl.m_ColorfulData) then
--         local list = self.m_BtnGrid:GetChildList()
--         for i,btn in ipairs(list) do
--             if btn.key == 1 then
--                 btn:SetActive(false)
--                 self.m_BtnGrid:Reposition()
--                 break
--             end
--         end
--     end

--     local btnlist = self.m_BtnGrid:GetChildList()
--     for i,box in ipairs(btnlist) do
--         if box.key == define.WelFare.Tab.YoukaLogin then
--             box.redPoint:SetActive(g_WelfareCtrl:IsHadReturnYoukaLoginRedPoint())
--         end
--     end
-- end

function CWelfareView.SelDefaultPage(self)
    local btnList = self.m_BtnGrid:GetChildList()
    -- 优先级: 签到->第一个红点(不算八日)
    local oSign = self.m_TabDict[self.m_TabC.Sign]
    if oSign and (oSign.redPoint:GetActive() or 0 == g_SignCtrl.m_today or g_SignCtrl.m_OpenSign) then
        oSign:SetSelected(true)
        self:OnClickBtn(oSign.key)
        if g_SignCtrl.m_OpenSign then
            g_SignCtrl.m_OpenSign = false
        end
        return
    end
    local oTopRed, oTop
    for i, oBtn in ipairs(btnList) do
        if oBtn.key ~= self.m_TabC.YoukaLogin then
            if not oTop then
                oTop = oBtn
            end
            if oBtn.redPoint:GetActive() then
                if oTopRed then
                    if self:GetRedDotPriority(oTopRed.key) > self:GetRedDotPriority(oBtn.key) then
                        oTopRed = oBtn
                    end
                else
                    oTopRed = oBtn
                end
            end
        end
    end
    local oSel = oTopRed or oTop
    if oSel then
        oSel:SetSelected(true)
        self:OnClickBtn(oSel.key)
    end
end

-- 原有的define.WelFare.Tab的数据不在使用，这里使用一个新的映射表作为过渡
-- 原有的传参方式不用改变
function CWelfareView.ForceSelPage(self, iTab)
    local dTab = define.WelFare.Tab

    local tName
    for k, v in pairs(dTab) do
        if v == iTab then
            tName = k
            break
        end
    end

    if not tName then
        return
    end

    local iTab = self.m_TabC[tName]

    if not self.m_TabDict[iTab] then
        return
    end
    self.m_TabDict[iTab]:SetSelected(true)
    self:OnClickBtn(iTab)
end

-- 隐藏界面
function CWelfareView.HidePage(self, iTab)
    if not self.m_PartDict[iTab] then return end
    local iCurPageId = self.m_CurSelIdx
    local oTab = self.m_TabDict[iTab]
    if oTab then
        oTab:SetSelected(false)
        oTab:SetActive(false)
    end
    if iCurPageId == iTab then
        local iCount = 0
        local iTabCnt = #g_WelfareCtrl.m_huodongConfig
        while iCount < iTabCnt - 1 do
            iCurPageId = iCurPageId + 1
            if iCurPageId > iTabCnt then
                iCurPageId = 1
            end
            iCount = iCount + 1
            local oNextTab = self.m_TabDict[iCurPageId]
            if oNextTab and oNextTab:GetActive() and oNextTab.key ~= define.WelFare.Tab.YoukaLogin then
                self:OnClickBtn(iCurPageId)
                self.m_TabDict[iCurPageId]:SetSelected(true)
                break
            end
        end
    end
    self.m_BtnGrid:Reposition()
end

function CWelfareView.GetRedDotPriority(self, iTab)
    return self.m_RedDotPrioritys[iTab] or 1000
end

function CWelfareView.OnUpdateWelfareEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateDailyPnl then
        --self:ShowRedPoint(4, oCtrl:IsHadDailyRedPoint())
        -- 不隐藏
        -- if not self.m_IsHideDailyPnl then
        --     self.m_IsHideDailyPnl = oCtrl:IsGetAllDailyReward()
        --     if self.m_IsHideDailyPnl then
        --         self:HidePage(self.m_TabC.GiftDay)
        --     end
        -- end
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateBigProfitPnl then
        self:ShowRedPoint(self.m_TabC.GiftGrade, oCtrl:IsHadGradeRedPoint())
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateYuanbaoPnl then
        self:ShowRedPoint(self.m_TabC.GiftGoldcoin, oCtrl:IsHadYuanbaoRedPoint())
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateBigProfitTab then
        local sTitle = "一本万利贰"
        local oTab = self.m_TabDict[self.m_TabC.GiftGrade]
        if oTab then
            oTab.name:SetText(sTitle)
            oTab.colorName:SetText(sTitle)
        end
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateFirstPayPnl then
        if not g_FirstPayCtrl:IsShow() then
            self:HidePage(self.m_TabC.FirstPay)
        else
            self.m_FirstPayPart:Refresh()
            self:ShowRedPoint(self.m_TabC.FirstPay, g_WelfareCtrl:IsHadFirstPayRedPoint())
        end
    -- elseif oCtrl.m_EventID == define.WelFare.Event.UpdateCollectPnl then
    --     self:ShowRedPoint(self.m_TabC.CollectGift, oCtrl:IsHadCollectRedPoint())
    --     if g_WelfareCtrl:GetCollectGiftStatus() == 0 then
    --         self:HidePage(self.m_TabC.CollectGift)
    --     end
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdataColorLamp then
        --self:SetYoukaLoginViewRedPoint()
        self:ShowRedPoint(self.m_TabC.YoukaLogin, g_WelfareCtrl:IsHadReturnYoukaLoginRedPoint())
    elseif oCtrl.m_EventID == define.WelFare.Event.ReturnGift then
        self:ShowRedPoint(self.m_TabC.ReturnGift, g_WelfareCtrl:IsHadReturnGiftRedPoint())
        self:CreateBtnGrid(true)
    elseif oCtrl.m_EventID == define.WelFare.Event.RefreshFightGift then
         self:ShowRedPoint(self.m_TabC.FightGift, g_WelfareCtrl:IsHasFightGiftRedPoint())
    elseif oCtrl.m_EventID == define.WelFare.Event.RefreshExpRecycle then
        if g_ExpRecycleCtrl:IsShow() then
            self:ShowRedPoint(self.m_TabC.ExpRecycle, g_WelfareCtrl:IsHasExpRecycleRedDot())
            self.m_ExpRecyclePart:RefreshAll()
        else
            self:HidePage(self.m_TabC.ExpRecycle)
        end
    end
end

function CWelfareView.OnOnlineGiftEvent(self, oCtrl)
    if oCtrl.m_EventID == define.OnlineGift.Event.UpdateRedPoint then
        self:ShowRedPoint(self.m_TabC.OnlineGift, g_OnlineGiftCtrl:IsHasRedPoint())
    end
end

function CWelfareView.OnClickClose(self)
	self:CloseView()
    self.m_ExchangePart:Clean()
	CFortuneView:CloseView()
end

return CWelfareView