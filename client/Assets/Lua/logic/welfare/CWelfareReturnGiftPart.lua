CWelfareReturnGiftPart = class("CWelfareReturnGiftPart", CPageBase)

function CWelfareReturnGiftPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_FirstPack = self:NewUI(1, CBox)
    self.m_SecondPack = self:NewUI(2, CBox)

    self.m_GiftBoxList = {}
    for i = 1, 3 do
        local oBox = self:NewUI(i, CBox)
        oBox.m_TitleLbl = oBox:NewUI(1, CLabel)
        oBox.m_IconSp = oBox:NewUI(2, CSprite)
        oBox.m_BuyButton = oBox:NewUI(3, CButton)
        
        oBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", i, oBox.m_IconSp))
        table.insert(self.m_GiftBoxList, oBox)
    end
    self.m_DescLbl = self:NewUI(4, CLabel)
    self.m_GradeLbl = self:NewUI(5, CLabel)
    self.m_GetBtn = self:NewUI(6, CButton)
    self.m_TimeLbl1 = self:NewUI(7, CLabel)
    self.m_TimeLbl2 = self:NewUI(8, CLabel)
    self.m_ContentObj = self:NewUI(9, CObject)
    self.m_Hint = self:NewUI(10, CLabel)
    self.m_TipsBtn = self:NewUI(11, CButton)

    self.m_ContentObj:SetActive(false)
    self.m_Hint:SetActive(true)
    self.m_TimeLbl1:SetActive(false)
    self.m_TimeLbl2:SetActive(false)
end

function CWelfareReturnGiftPart.OnInitPage(self)
    self:RefreshUI()
    for k,v in ipairs(self.m_GiftBoxList) do
        v.m_BuyButton:AddUIEvent("click", callback(self, "OnClickGiftBuyBtn", k))
    end
    self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickGetGradeBtn"))
    self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CWelfareReturnGiftPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.ReturnGift then
        self:RefreshUI()
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
        if not next(oReturnData) then
            return
        end
        if not g_WelfareCtrl:CheckReturnGradeIsNotGet() and oReturnData.free_gift ~= 0 and (oReturnData.gift_1_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_1_time) > 0) 
        and (oReturnData.gift_2_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_2_time) > 0) then
            -- CWelfareView:CloseView()
            self.m_ContentObj:SetActive(false)
            self.m_Hint:SetActive(true)
            return
        end
        self:CheckGiftTime()
    end
end

function CWelfareReturnGiftPart.OnCtrlAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change and oCtrl.m_EventData.dAttr.grade then
        self:CheckGradeReward()
    end
end

function CWelfareReturnGiftPart.RefreshUI(self)
    self.m_ContentObj:SetActive(false)
    self.m_Hint:SetActive(true)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    if not g_WelfareCtrl:CheckReturnGradeIsNotGet() and oReturnData.free_gift ~= 0 and (oReturnData.gift_1_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_1_time) > 0) 
    and (oReturnData.gift_2_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_2_time) > 0) then
        return
    end
    self.m_ContentObj:SetActive(true)
    self.m_Hint:SetActive(false)
  
    self.m_GiftConfig = g_WelfareCtrl:GetReturnGiftConfig()

    local oAllMoney = load(string.format("return (%s)", string.gsub(data.huodongdata.RETURNFORMULA.all.formula, "money", tostring(oReturnData.cbtpay)) ))()
    self.m_DescLbl:SetText(string.format("    感谢您对《s%》的支持，您在封测期间充值的元宝我们将按一定规则返还给你，一共将返还"..oAllMoney.."#cur_1给您，并给您准备了一份神秘礼物。祝您游戏愉快！", g_GameDataCtrl:GetGameName()))

    self:CheckGradeReward()

    self.m_GiftBoxList[1].m_TitleLbl:SetText("荣誉礼包I")
    if oReturnData.free_gift ~= 0 then
        self.m_GiftBoxList[1].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GiftBoxList[1].m_BuyButton:SetBtnGrey(true)
        self.m_GiftBoxList[1].m_BuyButton:SetText("已领取")
        self.m_GiftBoxList[1].m_BuyButton.m_ChildLabel:SetSpacingX(7)
    else
        self.m_GiftBoxList[1].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = true
        self.m_GiftBoxList[1].m_BuyButton:SetBtnGrey(false)
        self.m_GiftBoxList[1].m_BuyButton:SetText("领取")
        self.m_GiftBoxList[1].m_BuyButton.m_ChildLabel:SetSpacingX(34)
    end

    self.m_GiftBoxList[2].m_TitleLbl:SetText("5折壕礼I")
    self.m_GiftBoxList[3].m_TitleLbl:SetText("5折壕礼II")
    self:CheckGiftTime()
end

function CWelfareReturnGiftPart.CheckGradeReward(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    local oGradeConfig = g_WelfareCtrl:GetGradeRewardConfig(oReturnData.cbtpay)

    self.m_GradeLbl:SetText("您没有元宝可领取哦")
    self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
    self.m_GetBtn:SetBtnGrey(true)
    self.m_GetBtn:SetText("领取")
    self.m_GradeIndex = nil
    if oGradeConfig.first_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[3] == "0" then
        -- if g_AttrCtrl.grade >= oGradeConfig.first_reward.grade then
            local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.first_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
            self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.first_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
            self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = true
            self.m_GetBtn:SetBtnGrey(false)
            self.m_GetBtn:SetText("领取")
            self.m_GradeIndex = 1
        -- else
        --     self.m_GradeLbl:SetText("等级不足"..oGradeConfig.first_reward.grade.."级，无法领取。")
        --     self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        --     self.m_GetBtn:SetBtnGrey(true)
        --     self.m_GetBtn:SetText("领取")
        -- end
        return
    elseif oGradeConfig.first_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[3] ~= "0" and oGradeConfig.second_reward.grade == 0 and oGradeConfig.third_reward.grade == 0 then
        local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.first_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
        self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.first_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
        self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GetBtn:SetBtnGrey(true)
        self.m_GetBtn:SetText("已领取")
        self.m_GradeIndex = nil
        return
    end
    if oGradeConfig.second_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[2] == "0" then
        -- if g_AttrCtrl.grade >= oGradeConfig.second_reward.grade then
            local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.second_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
            self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.second_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
            self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = true
            self.m_GetBtn:SetBtnGrey(false)
            self.m_GetBtn:SetText("领取")
            self.m_GradeIndex = 2
        -- else
        --     self.m_GradeLbl:SetText("等级不足"..oGradeConfig.second_reward.grade.."级，无法领取。")
        --     self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        --     self.m_GetBtn:SetBtnGrey(true)
        --     self.m_GetBtn:SetText("领取")
        -- end
        return
    elseif oGradeConfig.second_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[2] ~= "0" and oGradeConfig.third_reward.grade == 0 then
        local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.second_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
        self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.second_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
        self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GetBtn:SetBtnGrey(true)
        self.m_GetBtn:SetText("已领取")
        self.m_GradeIndex = nil
        return
    end
    if oGradeConfig.third_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[1] == "0" then
        -- if g_AttrCtrl.grade >= oGradeConfig.third_reward.grade then
            local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.third_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
            self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.third_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
            self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = true
            self.m_GetBtn:SetBtnGrey(false)
            self.m_GetBtn:SetText("领取")
            self.m_GradeIndex = 3
        -- else
        --     self.m_GradeLbl:SetText("等级不足"..oGradeConfig.third_reward.grade.."级，无法领取。")
        --     self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        --     self.m_GetBtn:SetBtnGrey(true)
        --     self.m_GetBtn:SetText("领取")
        -- end
        return
    elseif oGradeConfig.third_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[1] ~= "0" then
        local oMoney = load(string.format([[return (%s)]], string.gsub(data.huodongdata.RETURNFORMULA[oGradeConfig.third_reward.reward].formula, "money", tostring(oReturnData.cbtpay)) ))()
        self.m_GradeLbl:SetText("[44757B]等级达到"..oGradeConfig.third_reward.grade.."级可领取[a64e00]"..oMoney.."#cur_1")
        self.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GetBtn:SetBtnGrey(true)
        self.m_GetBtn:SetText("已领取")
        self.m_GradeIndex = nil
        return
    end
end

function CWelfareReturnGiftPart.CheckGiftTime(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    self.m_GiftBoxList[2].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = true
    self.m_GiftBoxList[2].m_BuyButton:SetBtnGrey(false)
    self.m_GiftBoxList[2].m_BuyButton:SetText(self.m_GiftConfig.gift_1.cost.."元宝购买")
    self.m_GiftBoxList[3].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = true
    self.m_GiftBoxList[3].m_BuyButton:SetBtnGrey(false)
    self.m_GiftBoxList[3].m_BuyButton:SetText(self.m_GiftConfig.gift_2.cost.."元宝购买")
    local oLeftTime1 = oReturnData.gift_1_time - g_TimeCtrl:GetTimeS()
    if oLeftTime1 > 0 then
        local oTime = g_TimeCtrl:GetTimeInfo(oLeftTime1)
        self.m_TimeLbl1:SetText("神秘大礼包将于"..oTime.hour.."小时"..oTime.min.."分钟后失效，无法购买")
    else
        self.m_TimeLbl1:SetText("已过期")
        self.m_GiftBoxList[2].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GiftBoxList[2].m_BuyButton:SetBtnGrey(true)
        self.m_GiftBoxList[2].m_BuyButton:SetText("已过期")
    end
    local oLeftTime2 = oReturnData.gift_2_time - g_TimeCtrl:GetTimeS()
    if oLeftTime2 > 0 then
        local oTime = g_TimeCtrl:GetTimeInfo(oLeftTime2)
        self.m_TimeLbl2:SetText("神秘大礼包将于"..oTime.hour.."小时"..oTime.min.."分钟后失效，无法购买")
    else
        self.m_TimeLbl2:SetText("已过期")
        self.m_GiftBoxList[3].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GiftBoxList[3].m_BuyButton:SetBtnGrey(true)
        self.m_GiftBoxList[3].m_BuyButton:SetText("已过期")
    end
    if oReturnData.gift_1_buy ~= 0 then
        self.m_GiftBoxList[2].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GiftBoxList[2].m_BuyButton:SetBtnGrey(true)
        self.m_GiftBoxList[2].m_BuyButton:SetText("已购买")
    end
    if oReturnData.gift_2_buy ~= 0 then
        self.m_GiftBoxList[3].m_BuyButton:GetComponent(classtype.BoxCollider).enabled = false
        self.m_GiftBoxList[3].m_BuyButton:SetBtnGrey(true)
        self.m_GiftBoxList[3].m_BuyButton:SetText("已购买")
    end
end

------------------以下是点击事件------------------

function CWelfareReturnGiftPart.OnClickGiftBuyBtn(self, oIndex)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    if oIndex == 1 then
        if oReturnData.free_gift ~= 0 then
            return
        end
        nethuodong.C2GSReturnGoldCoinGetFreeGift()
    elseif oIndex == 2 then
        if oReturnData.gift_1_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_1_time) > 0 then
            return
        end
        nethuodong.C2GSReturnGoldCoinBuyGift(1)
    elseif oIndex == 3 then
        if oReturnData.gift_2_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oReturnData.gift_2_time) > 0 then
            return
        end
        nethuodong.C2GSReturnGoldCoinBuyGift(2)
    end
end

function CWelfareReturnGiftPart.OnClickGetGradeBtn(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    if not self.m_GradeIndex then
        return
    end
    nethuodong.C2GSReturnGoldCoinGetReturn(self.m_GradeIndex)
end

function CWelfareReturnGiftPart.OnClickTips(self)
    local zContent = {title = data.instructiondata.DESC[10045].title, desc = data.instructiondata.DESC[10045].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CWelfareReturnGiftPart.OnClickPrizeBox(self, oIndex, oPrizeItemBox)
    if not next(g_WelfareCtrl.m_WelfareReturnGiftData) then
        return
    end
    local oConfig = g_WelfareCtrl:GetReturnGiftConfig()
    local oPrize
    if oIndex == 1 then
        oPrize = g_GuideHelpCtrl:GetRewardList("RETURNGOLDCOIN", oConfig.reward_idx)[1].item
    elseif oIndex == 2 then
        oPrize = g_GuideHelpCtrl:GetRewardList("RETURNGOLDCOIN", oConfig.gift_1.reward_idx)[1].item
    elseif oIndex == 3 then
        oPrize = g_GuideHelpCtrl:GetRewardList("RETURNGOLDCOIN", oConfig.gift_2.reward_idx)[1].item
    end

    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

return CWelfareReturnGiftPart