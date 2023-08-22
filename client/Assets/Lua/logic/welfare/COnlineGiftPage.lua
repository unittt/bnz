local COnlineGiftPage = class("COnlineGiftPage", CPageBase)

function COnlineGiftPage.ctor(self, cb)
    CPageBase.ctor(self,cb)
end

function COnlineGiftPage.OnInitPage(self)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_RewardGrid = self:NewUI(2, CGrid)
    self.m_RewardBox = self:NewUI(3, CBox)
    self.m_TimeL = self:NewUI(4, CLabel)
    self:InitContent()
end

function COnlineGiftPage.InitContent(self)
    self.m_RewardBox:SetActive(false)
    self.m_RewardBoxDict = nil
    self:CreateRewardBoxes()
    self:AddTimer()
    g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineGiftCtrl"))
end

function COnlineGiftPage.AddTimer(self)
    self:DelTimer()
    self.m_LoginTime = g_OnlineGiftCtrl.m_LoginTime
    self.m_Timer = Utils.AddTimer(callback(self, "CountTime"), 1, 0)
end

function COnlineGiftPage.CreateRewardBoxes(self)
    local rewardList = self:GetRewardData()
    self.m_RewardGrid:HideAllChilds()
    self.m_RewardBoxDict = {}
    local iMaxTime = 0
    for i, dReward in ipairs(rewardList) do
        local oBox = self:GetRewardBox(i)
        oBox:SetActive(true)
        oBox.info = dReward
        self.m_RewardBoxDict[dReward.key] = oBox
        self:SetRewardBoxInfo(oBox, dReward)
        oBox.bgSpr:SetSpriteName(i%2==0 and "h7_2di" or "h7_1di")
        if dReward.time and dReward.time > iMaxTime then
            iMaxTime = dReward.time
        end
    end
    self.m_MaxTime = iMaxTime * 60
end

function COnlineGiftPage.GetRewardBox(self, idx)
    local oBox = self.m_RewardGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_RewardBox:Clone()
        oBox.getBtn = oBox:NewUI(1, CButton)
        oBox.gotSpr = oBox:NewUI(2, CSprite)
        oBox.itemGrid = oBox:NewUI(3, CGrid)
        oBox.rewardItem = oBox:NewUI(4, CBox)
        oBox.rewardL = oBox:NewUI(5, CLabel)
        oBox.slider = oBox:NewUI(6, CSlider)
        oBox.bgSpr = oBox:NewUI(7, CSprite)
        oBox.rewardItem:SetActive(false)
        oBox.getBtn.m_ChildLabel:SetFontSize(22)
        oBox.getBtn.m_ChildLabel:SetSpacingX(0)
        oBox.getBtn:AddUIEvent("click", callback(self, "OnClickRewardBtn", oBox))
        self.m_RewardGrid:AddChild(oBox)
    end
    return oBox
end

function COnlineGiftPage.SetRewardBoxInfo(self, oBox, dInfo)
    oBox.info = dInfo
    self:RefreshRewardBtn(oBox, dInfo.status)
    self:RefreshItems(oBox, dInfo.reward)
    self:RefreshRewardSlider(oBox.slider, dInfo.time)
end

function COnlineGiftPage.RefreshRewardBtn(self, oBox, iStatus)
    local bGot = 2 == iStatus
    local bEnable = 1 == iStatus
    local oBtn = oBox.getBtn
    oBtn:SetActive(not bGot)
    oBox.gotSpr:SetActive(bGot)
    oBtn:SetEnabled(bEnable)
    oBtn:SetBtnGrey(not bEnable)
    oBtn:SetText(bEnable and "领 取" or "未达成")
end

function COnlineGiftPage.RefreshItems(self, oBox, iReward)
    oBox.rewardItem:SetActive(false)
    oBox.itemGrid:HideAllChilds()
    local itemList = DataTools.GetRewardItems("ONLINEGIFT", iReward)
    if not itemList then
        return
    end
    for i, dItem in ipairs(itemList) do
        local oItem = self:GetRewardItemBox(oBox, i)
        oItem:SetActive(true)
        self:SetRewardItemInfo(oItem, dItem)
    end
    if #itemList > 0 then
        local dItem = itemList[1]
        local dItemConfig = DataTools.GetItemData(dItem.sid)
        oBox.rewardL:SetWidth(305)
        oBox.rewardL:SetText(string.format("[63432c]在线%d分钟可领取[1d8e00]%sX%d[-][-]", oBox.info.time, dItemConfig.name, dItem.amount))
        -- if string.len(oBox.rewardL:GetText()) > 58 then
        --     oBox.rewardL:SetAlignment(2)
        --     oBox.rewardL:SetLocalPos(Vector3.New(-155, 0, 0))
        -- else
        --     oBox.rewardL:SetAlignment(1)
        --     oBox.rewardL:SetLocalPos(Vector3.New(-151, 0, 0))
        -- end
    else
        oBox.rewardL:SetText("")
    end
end

function COnlineGiftPage.RefreshRewardSlider(self, oSlider, iMax)
    --local iLoginTime = g_OnlineGiftCtrl.m_LoginTime
    oSlider:SetActive(false)
end

function COnlineGiftPage.SetRewardItemInfo(self, oItem, dInfo)
    oItem.itemId = dInfo.sid
    local dItem = DataTools.GetItemData(dInfo.sid)
    oItem.iconSpr:SpriteItemShape(dItem.icon)
    oItem.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(dItem.id, dItem.quality or 0))
    local iCnt = dInfo.amount
    if iCnt and iCnt >= 10000 then
        iCnt = math.floor(iCnt/10000).."万"
    end
    oItem.cntL:SetText(iCnt)
end

function COnlineGiftPage.GetRewardItemBox(self, oRewardBox, idx)
    local oBox = oRewardBox.itemGrid:GetChild(idx)
    if not oBox then
        oBox = oRewardBox.rewardItem:Clone()
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.qualitySpr = oBox:NewUI(2, CSprite)
        oBox.cntL = oBox:NewUI(3, CLabel)
        oRewardBox.itemGrid:AddChild(oBox)
        oBox:AddUIEvent("click", callback(self, "OnClickItem"))
    end
    return oBox
end

function COnlineGiftPage.GetRewardData(self)
    local dStatus = g_OnlineGiftCtrl:GetStatusInfo()
    local rewardList = {}
    for k, v in pairs(DataTools.GetOnlineGiftData()) do
        local dItem = table.copy(v)
        -- local iTime = k:match("online_gift_(%d+)")
        -- iTime = tonumber(iTime)
        dItem.time = k--iTime or 0
        dItem.status = dStatus[k] or 0
        table.insert(rewardList, dItem)
    end
    table.sort(rewardList, function(a, b)
        return a.time < b.time
    end)
    return rewardList
end

function COnlineGiftPage.CountTime(self)
    local iTime = g_TimeCtrl:GetTimeS() - self.m_LoginTime
    if iTime >= self.m_MaxTime then
        self.m_TimeL:SetText("在线条件全部达成")
        return false
    end
    self.m_TimeL:SetText("累计在线 "..g_TimeCtrl:GetLeftTime(iTime, true))
    return true
end

function COnlineGiftPage.OnClickRewardBtn(self, oBox)
    table.print(oBox.info)
    if not oBox.info then return end
    if 1 == oBox.info.status then
        nethuodong.C2GSOnlineGift(oBox.info.key)
    end
end

function COnlineGiftPage.OnClickItem(self, oItem)
    if not oItem.itemId then return end
    local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(oItem.itemId, config)
end

function COnlineGiftPage.OnOnlineGiftCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.OnlineGift.Event.UpdateStatus then
        local dUpdate = oCtrl.m_EventData
        local oBox = self.m_RewardBoxDict[dUpdate.key]
        if oBox then
            if oBox.info then
                oBox.info.status = dUpdate.status
            end
            self:RefreshRewardBtn(oBox, dUpdate.status)
            --self:RefreshRewardSlider(oBox.slider)
        end
    elseif oCtrl.m_EventID == define.OnlineGift.Event.UpdateAllStatus then
        self:CreateRewardBoxes()
        self:AddTimer()
    end
end

function COnlineGiftPage.DelTimer(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
end

function COnlineGiftPage.Destroy(self)
    self:DelTimer()
    CPageBase.Destroy(self)
end

return COnlineGiftPage