local CFlopPart = class("CFlopPart", CPageBase)

function CFlopPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

    self.m_TipsBtn = self:NewUI(1, CButton)
    self.m_TimeLbl = self:NewUI(2, CLabel)
    self.m_NilTipObj = self:NewUI(3, CObject)
    self.m_NilMsgLbl = self:NewUI(4, CLabel)
    self.m_StartBtn = self:NewUI(5, CButton)
    self.m_ResetBtn = self:NewUI(6, CButton)
    self.m_AddCountBtn = self:NewUI(7, CButton)
    self.m_LeftCountLbl = self:NewUI(8, CLabel)
    self.m_OneKeyBtn = self:NewUI(9, CButton)
    self.m_MoneyLbl = self:NewUI(10, CLabel)
    self.m_SelectWidget = self:NewUI(11, CBox)
    self.m_PrizeTotalBox = self:NewUI(12, CBox)
    self.m_PrizeTotalCount = 6
    self.m_PrizeBoxList = {}
    for i=1, self.m_PrizeTotalCount do
        local oBox = self.m_PrizeTotalBox:NewUI(i, CBox)
        oBox.m_NormalTex = oBox:NewUI(1, CTexture)
        oBox.m_BackTex = oBox:NewUI(2, CTexture)
        oBox.m_DescLbl = oBox:NewUI(3, CLabel)
        oBox.m_MoneyLbl = oBox:NewUI(4, CLabel)
        oBox.m_MoneyIconSp = oBox:NewUI(5, CSprite)
        oBox.m_ItemBox = oBox:NewUI(6, CBox)
        oBox.m_NoLbl = oBox:NewUI(7, CLabel)
        oBox.m_ItemIconSp = oBox.m_ItemBox:NewUI(1, CSprite)
        oBox.m_CountLbl = oBox.m_ItemBox:NewUI(2, CLabel)
        oBox.m_QualitySp = oBox.m_ItemBox:NewUI(3, CSprite)
        oBox.m_OriginPos = oBox:GetLocalPos()
        oBox.m_CenterPos = Vector3.New(229, -107, 0)
        oBox.m_IsFloping = false
        oBox.m_NormalTex:AddUIEvent("click", callback(self, "OnClickNormalTex", i))
        table.insert(self.m_PrizeBoxList, oBox)
    end
    self.m_PrizeAnimator = self.m_PrizeTotalBox:GetComponent(classtype.Animator)
    self.m_PrizeAnimator.enabled = false
    self.m_ContentObj = self:NewUI(13, CObject)
    self.m_Hint = self:NewUI(14, CLabel)
    self.m_IsFlopReseting = false
    self.m_IsClickShowAllEffect = false
    self.m_CardCostGoldCoin = data.flopdata.CONFIG.reward.draw_cost

    self:InitContent()
end

function CFlopPart.OnInitPage(self)
    
end

function CFlopPart.OnShowPage(self)
    -- self:ReSetAllFlop()
    g_TimelimitCtrl.m_IsFlopHasRedPoint = false
    g_TimelimitCtrl:OnEvent(define.Timelimit.Event.RefreshRedPoint)
end

function CFlopPart.OnHidePage(self)
    if self.m_PrizeShowTimer then
        Utils.DelTimer(self.m_PrizeShowTimer)
        self.m_PrizeShowTimer = nil
    end
    self.m_IsFlopReseting = false
    self.m_IsClickShowAllEffect = false
    if self.m_PrizeAnimator then
        self.m_PrizeAnimator.enabled = false
    end
    self:CheckIsProtoInit()
    self:CheckCard()
end

function CFlopPart.InitContent(self)
    self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))
    self.m_StartBtn:AddUIEvent("click", callback(self, "OnClickStartBtn"))
    self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickResetBtn"))
    self.m_AddCountBtn:AddUIEvent("click", callback(self, "OnClickAddCountBtn"))
    self.m_OneKeyBtn:AddUIEvent("click", callback(self, "OnClickOneKeyBtn"))
    self.m_SelectWidget:AddUIEvent("click", callback(self, "OnClickSelectBtn"))

    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWelfareEvent"))
    g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTimeLimitEvent"))

    self:RefreshUI()
end

function CFlopPart.OnCtrlWelfareEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        if g_TimelimitCtrl.m_FlopEndTime == 0 then
            return
        end
        if (g_TimeCtrl:GetTimeS() - g_TimelimitCtrl.m_FlopEndTime) > 0 then
            self.m_ContentObj:SetActive(false)
            self.m_Hint:SetActive(true)
            self.m_Hint:SetText("疯狂翻牌活动已结束，谢谢您的参与。")
            return
        end
        self:CheckLeftTime()
    end
end

function CFlopPart.OnCtrlTimeLimitEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.UpdateFlopOpenState then
        if g_TimelimitCtrl.m_FlopEndTime == 0 then
            return
        end
        self.m_ContentObj:SetActive(true)
        self.m_Hint:SetActive(false)
        if (g_TimeCtrl:GetTimeS() - g_TimelimitCtrl.m_FlopEndTime) > 0 then
            self.m_ContentObj:SetActive(false)
            self.m_Hint:SetActive(true)
            self.m_Hint:SetText("疯狂翻牌活动已结束，谢谢您的参与。")
            return
        end
        self:CheckIsProtoInit()
        self:CheckLeftTime()
    elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateFlopCardTimes then
        self:CheckIsProtoInit()
        self:CheckResetTime()
    elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateFlopCardList then
        self:CheckIsProtoInit()
        self:CheckCard()
    elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateFlopShowCardEffect then
        for k,v in ipairs(g_TimelimitCtrl.m_FlopCardShowEffectList) do
            local oBox = self.m_PrizeBoxList[v]
            if not(not oBox or oBox.m_IsFloping) then
                self:SetFlopEach(oBox)
            end            
        end
        self:CheckCardMoney()
    end
end

function CFlopPart.RefreshUI(self)
    if g_TimelimitCtrl.m_FlopEndTime == 0 then
        return
    end
    self.m_ContentObj:SetActive(true)
    self.m_Hint:SetActive(false)
    if (g_TimeCtrl:GetTimeS() - g_TimelimitCtrl.m_FlopEndTime) > 0 then
        self.m_ContentObj:SetActive(false)
        self.m_Hint:SetActive(true)
        self.m_Hint:SetText("疯狂翻牌活动已结束，谢谢您的参与。")
        return
    end
    self:CheckIsProtoInit()
    self:CheckLeftTime()
    self:CheckResetTime()
    self:CheckCard()
    self:CheckSelectNotify()
end

function CFlopPart.CheckIsProtoInit(self)
    if g_TimelimitCtrl.m_FlopCardInit and g_TimelimitCtrl.m_FlopCardResetInit then
        self.m_ContentObj:SetActive(true)
        self.m_Hint:SetActive(false)
    else
        self.m_ContentObj:SetActive(false)
        self.m_Hint:SetActive(true)
        self.m_Hint:SetText("请稍等，加载中...")
    end
end

function CFlopPart.CheckSelectNotify(self)
    local oSelect = IOTools.GetRoleData("flopselect")
    if not oSelect or oSelect == 0 then
        self.m_SelectWidget:SetSelected(false)
    else
        self.m_SelectWidget:SetSelected(true)
    end
end

function CFlopPart.CheckCardMoney(self)
    local oNeedCostNum = 0
    if g_TimelimitCtrl.m_FlopTotal <= g_TimelimitCtrl.m_NotFlopCardCount then
        oNeedCostNum = (g_TimelimitCtrl.m_FlopTotal - 1)*self.m_CardCostGoldCoin
    else
        oNeedCostNum = g_TimelimitCtrl.m_NotFlopCardCount*self.m_CardCostGoldCoin
    end
    self.m_OneKeyBtn:SetText("一键翻牌 "..oNeedCostNum)
    if oNeedCostNum <= 0 then
        self.m_OneKeyBtn:SetActive(false)
    else
        self.m_OneKeyBtn:SetActive(true)
    end

    local bNotShowMoney = g_TimelimitCtrl.m_FlopTotal <= g_TimelimitCtrl.m_NotFlopCardCount
    for k,v in ipairs(self.m_PrizeBoxList) do
        if not v.m_IsFloping then
            if bNotShowMoney then
                v.m_NoLbl:SetActive(true)
                v.m_MoneyLbl:SetActive(false)
                v.m_MoneyIconSp:SetActive(false)
            else
                v.m_NoLbl:SetActive(false)
                v.m_MoneyLbl:SetActive(true)
                v.m_MoneyIconSp:SetActive(true)
                v.m_MoneyLbl:SetText(self.m_CardCostGoldCoin)
            end
        end
    end
end

function CFlopPart.CheckCard(self)
    if not g_TimelimitCtrl.m_FlopCardInit then
        return
    end
        
    if next(g_TimelimitCtrl.m_FlopCardList) then
        self.m_NilTipObj:SetActive(false)
        self.m_StartBtn:SetActive(false)
        self.m_ResetBtn:SetActive(true)
        self.m_AddCountBtn:SetActive(true)
        self.m_LeftCountLbl:SetActive(true)

        self.m_OneKeyBtn:SetActive(false)
        self.m_SelectWidget:SetActive(false)

        self.m_PrizeTotalBox:SetActive(true)

        if self.m_IsClickShowAllEffect then
            self:ReSetAllFlop()
        else
            self.m_OneKeyBtn:SetActive(true)
            self.m_SelectWidget:SetActive(true)
            self:CheckAllCardUI()
        end
    else
        self.m_NilTipObj:SetActive(true)
        self.m_StartBtn:SetActive(true)
        self.m_ResetBtn:SetActive(true)
        self.m_AddCountBtn:SetActive(true)
        self.m_LeftCountLbl:SetActive(true)
        self.m_OneKeyBtn:SetActive(false)
        self.m_SelectWidget:SetActive(false)
        self.m_PrizeTotalBox:SetActive(false)
    end
    self.m_IsClickShowAllEffect = false

    self:CheckCardMoney()
end

function CFlopPart.CheckAllCardUI(self)
    if not next(g_TimelimitCtrl.m_FlopCardList) then
        return
    end
    for k,v in ipairs(self.m_PrizeBoxList) do
        v:SetLocalPos(v.m_OriginPos)
        local oData = g_TimelimitCtrl.m_FlopCardList[k]
        v.m_CardData = oData
        if oData.card_state == 0 then
            v.m_BackTex:SetLocalEulerAngles(Vector3.New(0, 90, 0))
            v.m_NormalTex:SetLocalEulerAngles(Vector3.New(0, 0, 0))
        else
            v.m_BackTex:SetLocalEulerAngles(Vector3.New(0, 0, 0))
            v.m_NormalTex:SetLocalEulerAngles(Vector3.New(0, 90, 0))
        end
        local oPrizeItemData = g_GuideHelpCtrl:GetRewardList("DRAWCARD", oData.card_info)
        if oPrizeItemData and next(oPrizeItemData) then
            v.m_ItemIconSp:SpriteItemShape(oPrizeItemData[1].item.icon)
            v.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oPrizeItemData[1].item.id, oPrizeItemData[1].item.quality or 0 ))
            if oPrizeItemData[1].amount > 0 then
                v.m_CountLbl:SetActive(true)
                v.m_CountLbl:SetText(oPrizeItemData[1].amount)
            else
                v.m_CountLbl:SetActive(false)
            end
            v.m_ItemIconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrizeItemData[1].item, v, oPrizeItemData[1]))
        end
    end
end

function CFlopPart.CheckResetTime(self)
    self.m_LeftCountLbl:SetText("[244B4E]剩余参与次数："..g_TimelimitCtrl.m_FlopCouldResetTime)
end

function CFlopPart.CheckLeftTime(self)
    if g_TimelimitCtrl.m_FlopEndTime == 0 then
        return
    end
    local oLeftTime = g_TimelimitCtrl.m_FlopEndTime - g_TimeCtrl:GetTimeS()
    if oLeftTime > 0 then
        -- self.m_TimeLbl:SetActive(true)
        local oTime = g_TimeCtrl:GetLeftTimeDHM(oLeftTime)
        self.m_TimeLbl:SetText("[63432C]活动剩余时间：\n[1d8e00]"..oTime)
    else
        -- self.m_TimeLbl:SetActive(false)
        self.m_TimeLbl:SetText("已过期")
    end
end

function CFlopPart.ReSetAllFlop(self)
    self.m_IsFlopReseting = true
    self.m_NilTipObj:SetActive(false)
    self.m_PrizeTotalBox:SetActive(true)
    for k,v in pairs(self.m_PrizeBoxList) do
        v.m_MoneyLbl:SetActive(false)
        v.m_MoneyIconSp:SetActive(false)
        v.m_NoLbl:SetActive(true)
        local oPrizeItemData = g_GuideHelpCtrl:GetRewardList("DRAWCARD", g_TimelimitCtrl.m_FlopRandomCardList[k].card_info)
        if oPrizeItemData and next(oPrizeItemData) then
            v.m_ItemIconSp:SpriteItemShape(oPrizeItemData[1].item.icon)
            v.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oPrizeItemData[1].item.id, oPrizeItemData[1].item.quality or 0 ))
            if oPrizeItemData[1].amount > 0 then
                v.m_CountLbl:SetActive(true)
                v.m_CountLbl:SetText(oPrizeItemData[1].amount)
            else
                v.m_CountLbl:SetActive(false)
            end
        end
        DOTween.DOKill(v.m_Transform, false)
        DOTween.DOKill(v.m_BackTex.m_Transform, false)
        DOTween.DOKill(v.m_NormalTex.m_Transform, false)
        v.m_BackTex:SetLocalEulerAngles(Vector3.New(0, 0, 0))
        v.m_NormalTex:SetLocalEulerAngles(Vector3.New(0, 90, 0))
        v:SetLocalPos(v.m_OriginPos)
    end

    for k,v in pairs(self.m_PrizeBoxList) do
        v.m_BackTex:SetLocalEulerAngles(Vector3.New(0, 0, 0))
        v.m_NormalTex:SetLocalEulerAngles(Vector3.New(0, 90, 0))
        
        local function onBackRotateEnd()
            local function onNormalRotateEnd()

                -- local function onOriToCenterTweenEnd()

                --     local function onCenterToOriTweenEnd()
                --         self.m_IsFlopReseting = false
                --         self.m_OneKeyBtn:SetActive(true)
                --         self.m_SelectWidget:SetActive(true)
                --         self:CheckAllCardUI()
                --     end
                --     v:SetLocalPos(v.m_CenterPos)
                --     local oMoveList = {v.m_CenterPos, v.m_OriginPos} 
                --     v.m_CenterToOriTween = DOTween.DOLocalPath(v.m_Transform, oMoveList, 1, 0, 0, 10, nil)
                --     DOTween.OnComplete(v.m_CenterToOriTween, onCenterToOriTweenEnd)
                --     DOTween.SetDelay(v.m_CenterToOriTween, 0)
                --     DOTween.SetEase(v.m_CenterToOriTween, 1)
                -- end
                -- v:SetLocalPos(v.m_OriginPos)
                -- local oMoveList = {v.m_OriginPos, v.m_CenterPos} 
                -- v.m_OriToCenterTween = DOTween.DOLocalPath(v.m_Transform, oMoveList, 1, 0, 0, 10, nil)
                -- DOTween.OnComplete(v.m_OriToCenterTween, onOriToCenterTweenEnd)
                -- DOTween.SetDelay(v.m_OriToCenterTween, 0)
                -- DOTween.SetEase(v.m_OriToCenterTween, 1)

                local function onFlopMoveEnd()
                    self.m_IsFlopReseting = false
                    self.m_OneKeyBtn:SetActive(true)
                    self.m_SelectWidget:SetActive(true)
                    self:CheckAllCardUI()
                end

                self.m_PrizeAnimator.enabled = true
                -- self.m_PrizeAnimator:Play("fanpai")
                self.m_PrizeAnimator.applyRootMotion = not self.m_PrizeAnimator.applyRootMotion
                if self.m_PrizeShowTimer then
                    Utils.DelTimer(self.m_PrizeShowTimer)
                    self.m_PrizeShowTimer = nil
                end
                local function onShow()
                    if Utils.IsNil(self) then
                        return false
                    end
                    onFlopMoveEnd()
                    self.m_PrizeAnimator.enabled = false
                    return false
                end
                self.m_PrizeShowTimer = Utils.AddTimer(onShow, 0, 2.417)
            end
            
            v.m_NormalRotateTween = DOTween.DORotate(v.m_NormalTex.m_Transform, Vector3.New(0, 0, 0), 0.5, 1)
            DOTween.OnComplete(v.m_NormalRotateTween, onNormalRotateEnd)
            DOTween.SetDelay(v.m_NormalRotateTween, 0)
        end
        v.m_BackRotateTween = DOTween.DORotate(v.m_BackTex.m_Transform, Vector3.New(0, 90, 0), 0.5, 1)
        DOTween.OnComplete(v.m_BackRotateTween, onBackRotateEnd)
        DOTween.SetDelay(v.m_BackRotateTween, 1)
    end
end

function CFlopPart.SetFlopEach(self, oBox)
    oBox.m_IsFloping = true
    oBox.m_BackTex:SetLocalEulerAngles(Vector3.New(0, 90, 0))
    oBox.m_NormalTex:SetLocalEulerAngles(Vector3.New(0, 0, 0))
    local function onNormalRotateEnd()
        local function onBackRotateEnd()
            oBox.m_IsFloping = false
        end
        oBox.m_BackRotateTween = DOTween.DORotate(oBox.m_BackTex.m_Transform, Vector3.New(0, 0, 0), 0.5, 1)
        DOTween.OnComplete(oBox.m_BackRotateTween, onBackRotateEnd)
        DOTween.SetDelay(oBox.m_BackRotateTween, 0)
    end
    oBox.m_NormalRotateTween = DOTween.DORotate(oBox.m_NormalTex.m_Transform, Vector3.New(0, 90, 0), 0.5, 1)
    DOTween.OnComplete(oBox.m_NormalRotateTween, onNormalRotateEnd)
    DOTween.SetDelay(oBox.m_NormalRotateTween, 0)
end

--------------以下是点击事件--------------

function CFlopPart.OnClickTipsBtn(self)
    local zContent = {title = data.instructiondata.DESC[13003].title, desc = data.instructiondata.DESC[13003].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CFlopPart.OnClickStartBtn(self)
    if not g_TimelimitCtrl.m_FlopCardInit then
        return
    end
    if g_TimelimitCtrl.m_FlopCouldResetTime <= 0 then
        self:OnShowResetAddCountCost()
        return
    end
    self.m_IsClickShowAllEffect = true
    nethuodong.C2GSDrawCardStart()
end

function CFlopPart.OnClickResetBtn(self)
    if not g_TimelimitCtrl.m_FlopCardInit then
        return
    end
    if not next(g_TimelimitCtrl.m_FlopCardList) then
        g_NotifyCtrl:FloatMsg(data.flopdata.TEXT[1013].content)
        return
    end
    if g_TimelimitCtrl.m_FlopTotal - g_TimelimitCtrl.m_NotFlopCardCount <= 0 then
        g_NotifyCtrl:FloatMsg(data.flopdata.TEXT[1002].content)
        return
    end
    if g_TimelimitCtrl.m_FlopCouldResetTime <= 0 then
        self:OnShowResetAddCountCost()
        return
    end
    nethuodong.C2GSDrawCardReset()
end

function CFlopPart.OnClickAddCountBtn(self)
    if not g_TimelimitCtrl.m_FlopCardInit then
        return
    end
    if g_TimelimitCtrl.m_FlopHasPurchaseTime >= data.flopdata.TIMECOST[#data.flopdata.TIMECOST].times_interval[2] then
        g_NotifyCtrl:FloatMsg(string.gsub(data.flopdata.TEXT[1007].content, "#value", data.flopdata.TIMECOST[#data.flopdata.TIMECOST].times_interval[2]))
        return
    end
    local oNeedCost = g_TimelimitCtrl:GetAddResetCost()
    if not oNeedCost then
        return
    end
    local oDescStr = string.gsub(data.flopdata.TEXT[1004].content, "#value", oNeedCost.goldcoin)
    local windowConfirmInfo = {
        msg = "#D"..oDescStr,
        pivot = enum.UIWidget.Pivot.Center,
        okCallback = function () 
            if oNeedCost.goldcoin > g_AttrCtrl.goldcoin then
                local text = data.flopdata.TEXT[1009].content
                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
            else
                nethuodong.C2GSDrawCardBuyTimes()
            end
        end,
        cancelCallback = function () 
            
        end,
        closeType = 1,
        color = Color.white,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFlopPart.OnShowResetAddCountCost(self)
    if g_TimelimitCtrl.m_FlopCouldResetTime <= 0 and g_TimelimitCtrl.m_FlopHasPurchaseTime >= data.flopdata.TIMECOST[#data.flopdata.TIMECOST].times_interval[2] then
        g_NotifyCtrl:FloatMsg("次数不足，并且今天已达购买最大次数")
        return
    end
    local oNeedCost = g_TimelimitCtrl:GetAddResetCost()
    if not oNeedCost then
        return
    end
    local oDescStr = string.gsub(data.flopdata.TEXT[1003].content, "#value", oNeedCost.goldcoin)
    local windowConfirmInfo = {
        msg = "#D"..oDescStr,
        pivot = enum.UIWidget.Pivot.Center,
        okCallback = function ()
            if oNeedCost.goldcoin > g_AttrCtrl.goldcoin then
                local text = data.flopdata.TEXT[1009].content
                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
            else
                nethuodong.C2GSDrawCardBuyTimes()
            end
        end,
        cancelCallback = function () 
            
        end,
        closeType = 1,
        color = Color.white,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFlopPart.OnClickOneKeyBtn(self)
    if not g_TimelimitCtrl.m_FlopCardInit then
        return
    end
    if g_TimelimitCtrl.m_NotFlopCardCount <= 0 then
        g_NotifyCtrl:FloatMsg("没有可翻的牌了哦，赶紧重置吧")
        return
    end
    if self.m_IsFlopReseting then
        g_NotifyCtrl:FloatMsg("请稍后!")
        return
    end
    for k,v in pairs(self.m_PrizeBoxList) do
        if v.m_IsFloping then
            g_NotifyCtrl:FloatMsg("请稍后!")
            return
        end
    end
    local oNeedCostNum = 0
    if g_TimelimitCtrl.m_FlopTotal <= g_TimelimitCtrl.m_NotFlopCardCount then
        oNeedCostNum = (g_TimelimitCtrl.m_FlopTotal - 1)*self.m_CardCostGoldCoin
    else
        oNeedCostNum = g_TimelimitCtrl.m_NotFlopCardCount*self.m_CardCostGoldCoin
    end
    local oSelect = IOTools.GetRoleData("flopselect")
    if not oSelect or oSelect == 0 then
        local oDescStr = string.gsub(data.flopdata.TEXT[1006].content, "#value", oNeedCostNum)
        local windowConfirmInfo = {
            msg = "#D"..oDescStr,
            pivot = enum.UIWidget.Pivot.Center,
            okCallback = function ()
                if oNeedCostNum > g_AttrCtrl.goldcoin then
                    local text = data.flopdata.TEXT[1009].content
                    g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
                else
                    nethuodong.C2GSDrawCardOpenList()
                end
            end,
            cancelCallback = function () 
                
            end,
            closeType = 1,
            color = Color.white,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    else
        if oNeedCostNum > g_AttrCtrl.goldcoin then
            local text = data.flopdata.TEXT[1009].content
            g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
        else
           nethuodong.C2GSDrawCardOpenList()
        end
    end
end

function CFlopPart.OnClickSelectBtn(self)
    local oSelect = 0
    if self.m_SelectWidget:GetSelected() then
        oSelect = 1
    end
    IOTools.SetRoleData("flopselect", oSelect)
end

function CFlopPart.OnClickNormalTex(self, oIndex)
    if self.m_IsFlopReseting then
        return
    end
    local oBox = self.m_PrizeBoxList[oIndex]
    if not oBox or oBox.m_IsFloping or not oBox.m_CardData or oBox.m_CardData.card_state == 1 then
        return
    end
    
    if g_TimelimitCtrl.m_FlopTotal <= g_TimelimitCtrl.m_NotFlopCardCount then
        nethuodong.C2GSDrawCardOpenOne(oBox.m_CardData.card_id)
    else
        local oSelect = IOTools.GetRoleData("flopselect")
        if not oSelect or oSelect == 0 then
            local oDescStr = string.gsub(data.flopdata.TEXT[1005].content, "#value", self.m_CardCostGoldCoin)
            local windowConfirmInfo = {
                msg = "#D"..oDescStr,
                pivot = enum.UIWidget.Pivot.Center,
                okCallback = function ()
                    if self.m_CardCostGoldCoin > g_AttrCtrl.goldcoin then
                        local text = data.flopdata.TEXT[1009].content
                        g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
                    else
                        nethuodong.C2GSDrawCardOpenOne(oBox.m_CardData.card_id)
                    end
                end,
                cancelCallback = function () 
                    
                end,
                closeType = 1,
                color = Color.white,
            }
            g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
        else
            if self.m_CardCostGoldCoin > g_AttrCtrl.goldcoin then
                local text = data.flopdata.TEXT[1009].content
                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(text)
            else
                nethuodong.C2GSDrawCardOpenOne(oBox.m_CardData.card_id)
            end
        end
    end
end

function CFlopPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

return CFlopPart