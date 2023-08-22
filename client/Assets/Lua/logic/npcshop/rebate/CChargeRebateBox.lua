local CChargeRebateBox = class("CChargeRebateBox", CBox)

function CChargeRebateBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_RewardKey = nil

    self:InitContent()
end

function CChargeRebateBox.InitContent(self)
    self.m_ChargeL = self:NewUI(1, CLabel)
    self.m_OperateBtn = self:NewUI(2, CButton)
    self.m_GotSpr = self:NewUI(3, CSprite)
    self.m_RewardGrid = self:NewUI(4, CGrid)
    self.m_RewardBox = self:NewUI(5, CBox)
    self.m_ScrollView = self:NewUI(6, CScrollView)

    self.m_RewardBox:SetActive(false)
    self.m_OperateBtn:AddUIEvent("click", callback(self, "OnClickBtn"))
end

function CChargeRebateBox.RefreshAll(self, dRebate)
    self.m_RewardKey = dRebate.key
    self.m_Info = dRebate
    self:RefreshRewards(dRebate.gift)
    self:RefreshChargeCnt()
    self:RefreshBtnState(g_WelfareCtrl:GetChargeItemInfo(self.m_RewardKey))
end

function CChargeRebateBox.RefreshRewards(self, iReward)
    local dRewards = table.copy(DataTools.GetReward("WELFARE", iReward))
    if not dRewards then return end
    local lAllItems = {}
    for i,v in ipairs(dRewards.item) do
        v.sidType = "item"
        table.insert(lAllItems, v)
    end
    for i,v in ipairs(dRewards.summon) do
        v.sidType = "summ"
        table.insert(lAllItems, v)
    end
    if string.len(dRewards.ride)>0 then
        local v = {
            sid  = dRewards.ride,
            sidType = "ride",
        }
        table.insert(lAllItems, v)
    end
    local sTip = self.m_Info.tip_icon
    if sTip and string.len(sTip) > 0 then
        local dTipInfo = {
            title = self.m_Info.tip_title or "",
            desc = self.m_Info.tip_text or "",
            sidType = "tip",
        }
        table.insert(lAllItems, dTipInfo)
    end
    if #lAllItems <= 3 then
        self.m_RewardGrid:SetParent(self.m_Transform, true)
        local dragCpn = self.m_RewardBox:GetComponent(classtype.UIDragScrollView)
        dragCpn.scrollView = self.pageScrollView.m_UIScrollView
        self.m_ScrollView:SetActive(false)
    end
    for i, v in ipairs(lAllItems) do
        local oReward = self:GetRewardBox(i)
        self:RefreshRewardBox(oReward, v)
    end
end

function CChargeRebateBox.GetRewardBox(self, idx)
    local oBox = self.m_RewardGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_RewardBox:Clone()
        self.m_RewardGrid:AddChild(oBox)
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.qualitySpr = oBox:NewUI(2, CSprite)
        oBox.cntL = oBox:NewUI(3, CLabel)

        oBox:AddUIEvent("click", callback(self, "OnClickRewardBox"))
    end
    oBox:SetActive(true)
    return oBox
end

function CChargeRebateBox.RefreshRewardBox(self, oBox, dInfo)
    local sType, id = dInfo.sidType, dInfo.sid
    local bItem = sType == "item"
    oBox.sidType = sType
    oBox.id = id
    oBox.info = dInfo
    oBox.qualitySpr:SetActive(bItem)
    oBox.cntL:SetActive(bItem)
    if bItem then
        local dItemData = DataTools.GetItemData(id)
        oBox.iconSpr:SpriteItemShape(dItemData.icon)
        oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(id, dItemData.quality or 0))
        oBox.cntL:SetText(dInfo.amount)
    elseif sType == "summ" then
        local dSumm = data.summondata.INFO[id]
        if dSumm then
            oBox.iconSpr:SpriteAvatar(dSumm.shape)
        end
    elseif sType == "ride" then
        local dRide = data.ridedata.RIDEINFO[tonumber(id)]
        if dRide then
            oBox.iconSpr:SpriteAvatar(dRide.shape)
        end
    elseif sType == "tip" then
        local iIcon = tonumber(self.m_Info.tip_icon)
        if iIcon then
            oBox.iconSpr:SpriteItemShape(iIcon)
        else
            oBox.iconSpr:SetSpriteName(self.m_Info.tip_icon)
        end
    end
end

function CChargeRebateBox.RefreshChargeCnt(self)
    local iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    local iGoldcoin = self.m_Info.goldcoin
    iPayCnt = math.min(iPayCnt, iGoldcoin)
    self.m_ChargeL:SetText(string.format("%d/%d元宝", iPayCnt, iGoldcoin))
end

function CChargeRebateBox.RefreshBtnState(self, iState)
    local bGot = iState == define.WelFare.Status.Got
    self.m_OperateBtn:SetActive(not bGot)
    self.m_OperateBtn.m_IgnoreCheckEffect = true
    self.m_GotSpr:SetActive(bGot)
    self.m_State = iState

    local bRed = false
    if not bGot then
        local bEnable = iState == define.WelFare.Status.Get
        bRed = bEnable
        if bEnable then
            self.m_OperateBtn:SetSpriteName("h7_an_2")
            self.m_OperateBtn:SetText("领 取")
        else
            self.m_OperateBtn:SetSpriteName("h7_an_1")
            self.m_OperateBtn:SetText("充 值")
        end
    end
    if bRed then
        self.m_OperateBtn:AddEffect("RedDot", 20, Vector2.New(-15, -16))
    else
        self.m_OperateBtn:DelEffect("RedDot")
    end
end

function CChargeRebateBox.OnClickRewardBox(self, oBox)
    local sType = oBox.sidType
    if sType == "item" then
        self:OnClickItem(oBox)
    elseif sType == "summ" then
        self:OnClickSum(oBox.id)
    elseif sType == "ride" then
        self:OnClickRide(oBox.id)
    elseif sType == "tip" then
        self:OnClickTip(oBox.info)
    end
end

function CChargeRebateBox.OnClickItem(self, oItem)
    local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(oItem.id, config)
end

function CChargeRebateBox.OnClickSum(self, sid)
    CChargeRebateView:OnClose()
    local oView = CSummonMainView:ShowView(function(oView)
        oView:ShowSubPageByIndex(3)
        local dSumInfo = data.summondata.INFO[sid]
        oView.m_DetailPart:OnSelSummon(dSumInfo)
    end)
end

function CChargeRebateBox.OnClickRide(self, rideid)
    if g_OpenSysCtrl:GetOpenSysState("RIDE_SYS") then
        CChargeRebateView:CloseView()
        local oView = CHorseMainView:ShowView(function (oView)
            oView:ShowSpecificPart(3)
            oView:ChooseDetailPartHorse(rideid)
        end)
    else
        local str = data.welfaredata.TEXT[1006].content
        local sysop = data.opendata.OPEN["RIDE_SYS"].p_level
        local sys = data.opendata.OPEN["RIDE_SYS"].name
        g_NotifyCtrl:FloatMsg(string.FormatString(str, {grade = sysop, name = sys}))
    end 
end

function CChargeRebateBox.OnClickTip(self, dInfo)
    g_WindowTipCtrl:SetWindowInstructionInfo(dInfo)
end

function CChargeRebateBox.OnClickBtn(self)
    if self.m_State == define.WelFare.Status.Get then
        nethuodong.C2GSRewardWelfareGift("rebate", self.m_RewardKey)
    else
        CChargeRebateView:OnClose()
    end
end

return CChargeRebateBox