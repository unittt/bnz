local CWelfareFirstChargePart = class("CWelfareFirstChargePart", CPageBase)

function CWelfareFirstChargePart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_PetTex = self:NewUI(1, CActorTexture)
    self.m_PetNameL = self:NewUI(2, CLabel)
    self.m_ExtraPart = self:NewUI(3, CWidget)
    self.m_ActTime = self:NewUI(4, CLabel)
    self.m_ExtraGrid = self:NewUI(5, CGrid)
    self.m_DescNameL = self:NewUI(6, CLabel)
    self.m_DescContL = self:NewUI(7, CLabel)
    self.m_RewardGrid = self:NewUI(8, CGrid)
    self.m_BuyBtn = self:NewUI(9, CButton)
    self.m_BtnLabel = self:NewUI(10, CLabel)
    self.m_ExtraRewardItem = self:NewUI(11, CBox)
    -- self.m_ExtraPartBg = self:NewUI(12, CWidget)
    self.m_RewardItem = self:NewUI(13, CBox)
    self.m_sprite = self:NewUI(14, CSprite)
    self:InitContent()
end

function CWelfareFirstChargePart.InitContent(self)
    self.m_RewardItem:SetActive(false)
    self.m_ExtraRewardItem:SetActive(false)
    self.m_PetNameL:SetText("")
    self.m_ExtraPart:SetActive(false)

    self.m_PetTex:AddUIEvent("click", callback(self, "OnClickPetTex"))
end

function CWelfareFirstChargePart.OnInitPage(self)
    local sKey = "first_gift"
    local dConfig = DataTools.GetWelfareData("FIRSTPAY", sKey)
    if not dConfig then return end
    local dRewardInfo = DataTools.GetReward("WELFARE", dConfig.gift_1)
    self:SetRewardInfo(dRewardInfo)
    self:SetOtherInfo()
    if self.m_HasExtra then
        local dExtraRewardInfo = DataTools.GetReward("WELFARE", dConfig.gift_2)
        self:SetExtraInfo(dExtraRewardInfo)
    end
    self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBtn"))
end

function CWelfareFirstChargePart.SetRewardInfo(self, info)
    if #info.summon > 0 then
        local iSummonId = tonumber(info.summon[1].idx)
        local dSummonInfo = DataTools.GetSummonInfo(iSummonId)
        if dSummonInfo then
            local modelInfo = {}
            modelInfo.shape = dSummonInfo.shape
            self.m_PetTex:ChangeShape(modelInfo)
            self.m_PetId = iSummonId
            self.m_PetNameL:SetText(dSummonInfo.name)

            self.m_sprite:AddEffect("S", 0) --特效层级sortingOrder，暂时写死为0
            -- 暂时处理
            self.m_sprite:SetColor(Color.New(1,1,1,0.01))
        end
    end
    local gold = tonumber(info.gold)
    local goldCoin = tonumber(info.goldcoin)
    local silver = tonumber(info.silver)
    local lRewards = {}
    if gold and gold > 0 then
        table.insert(lRewards, {id = 1001, num = gold})
    end
    if silver and silver > 0 then
        table.insert(lRewards, {id = 1002, num = silver})
    end
    if goldCoin and goldCoin > 0 then
        table.insert(lRewards, {id = 1004, num = goldCoin})
    end
    for _, itemR in ipairs(info.item) do
        table.insert(lRewards, {id = itemR.sid, num = itemR.amount})
    end
    for _, reward in ipairs(lRewards) do
        local itemId = reward.id
        local itemInfo = DataTools.GetItemData(itemId)
        if itemInfo then
            local oItemBox = self.m_RewardItem:Clone()
            local dItem = {
                item = itemInfo.icon,
                cnt = reward.num,
                quality = itemInfo.quality,
            }
            self:InitRewardBox(oItemBox, dItem)
            oItemBox:SetActive(true)
            oItemBox.itemId = itemId
            oItemBox:AddUIEvent("click", callback(self, "OnClickItem"))
            self.m_RewardGrid:AddChild(oItemBox)
        end
    end
end

function CWelfareFirstChargePart.SetExtraInfo(self, info)
    local itemCnt = -1
    if #info.summon > 0 then
        local iSummonId = tonumber(info.summon[1].idx)
        local dSummonInfo = DataTools.GetSummonInfo(iSummonId)
        if dSummonInfo then
            local oSummonBox = self.m_ExtraRewardItem:Clone()
            local dPet = {
                avatar = dSummonInfo.shape,
                name = dSummonInfo.name,
            }
            self:InitRewardBox(oSummonBox, dPet)
            oSummonBox:SetActive(true)
            self.m_ExtraGrid:AddChild(oSummonBox)
            itemCnt = itemCnt + 1
        end
    end
    if string.len(info.partner) > 0 then
        local dPartnerInfo = DataTools.GetPartnerInfo(tonumber(info.partner))
        if dPartnerInfo then
            local oPartnerBox = self.m_ExtraRewardItem:Clone()
            local dP = {
                avatar = dPartnerInfo.shape,
                name = dPartnerInfo.name,
            }
            self:InitRewardBox(oPartnerBox, dP)
            oPartnerBox:SetActive(true)
            self.m_ExtraGrid:AddChild(oPartnerBox)
            itemCnt = itemCnt + 1
        end
    end
    for _, reward in ipairs(info.item) do
        local itemId = reward.sid
        local itemInfo = DataTools.GetItemData(itemId)
        if itemInfo then
            local oItemBox = self.m_ExtraRewardItem:Clone()
            local dItem = {
                item = itemInfo.icon,
                cnt = reward.amount,
                quality = itemInfo.quality,
            }
            self:InitRewardBox(oItemBox, dItem)
            oItemBox.itemId = itemId
            oItemBox:SetActive(true)
            oItemBox:AddUIEvent("click", callback(self, "OnClickItem"))
            self.m_ExtraGrid:AddChild(oItemBox)
            itemCnt = itemCnt + 1
        end
    end
    -- if itemCnt > 0 then
    --     local iWidth, iHeight = self.m_ExtraPartBg:GetSize()
    --     iHeight = iHeight + itemCnt * 82
    --     self.m_ExtraPartBg:SetSize(iWidth, iHeight)
    -- end
end

function CWelfareFirstChargePart.InitRewardBox(self, oBox, info)
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.cntL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    if info.item then
        oBox.iconSpr:SpriteItemShape(info.item)
    else  
        oBox.iconSpr:SpriteAvatar(info.avatar)
        oBox.iconSpr:AddEffect("partner", 0) --特效层级sortingOrder，暂时写死为0
    end
    oBox.cntL:SetActive(info.cnt and true or false)
    if info.cnt then
        oBox.cntL:SetText(info.cnt)
    end
    -- oBox.nameL:SetActive(info.name and true or false)
    -- if info.name then
    --     oBox.nameL:SetText(info.name)
    -- end
    oBox.qualitySpr:SetActive(info.quality and true or false)
    if info.quality then
        oBox.qualitySpr:SetItemQuality(info.quality)
    end
end

function CWelfareFirstChargePart.SetOtherInfo(self)
    local iCreateTime = g_WelfareCtrl:GetChargeItemInfo("create_time")
    if iCreateTime then
        local iCurTime = g_TimeCtrl:GetTimeS()
        local iEndTime = iCreateTime + 24*3600*7
        self.m_HasExtra = iCurTime < iEndTime
        self.m_ExtraPart:SetActive(self.m_HasExtra)
        if self.m_HasExtra then
            local sBegin = os.date("%m.%d", iCreateTime)
            if string.sub(sBegin, 1, 1) == "0" then
                sBegin = string.sub(sBegin, 2, -1)
            end
            local sEnd = os.date("%m.%d", iEndTime)
            if string.sub(sEnd, 1, 1) == "0" then
                sEnd = string.sub(sEnd, 2, -1)
            end
            self.m_ActTime:SetText(string.format("%s-%s", sBegin, sEnd))
        end
    end
    local dDescName = DataTools.GetWelfareData("TEXT", 1002)
    if dDescName then
        self.m_DescNameL:SetText(dDescName.content)
    end
    local dDescCont = DataTools.GetWelfareData("TEXT", 1003)
    if dDescCont then
        self.m_DescContL:SetText(dDescCont.content)
    end
    self:SetBtnState()
end

function CWelfareFirstChargePart.SetBtnState(self)
    local state = g_WelfareCtrl:GetChargeItemInfo("first_pay_reward")
    if state == define.WelFare.Status.Unobtainable then
        self.m_BtnLabel:SetText("立即领取")
    else
        self.m_BtnLabel:SetText("立即领取")
    end
end

function CWelfareFirstChargePart.OnClickBtn(self)
    local state = g_WelfareCtrl:GetChargeItemInfo("first_pay_reward")
    
    if state == define.WelFare.Status.Unobtainable then
        CNpcShopMainView:ShowView(function(oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
        end)
      
    elseif state == define.WelFare.Status.Got then
        --首充奖励已领取
        local dDescCont = DataTools.GetWelfareData("TEXT", 1008)
        if dDescCont then 
            g_NotifyCtrl:FloatMsg(dDescCont)
        end
        
    else
        nethuodong.C2GSRewardFirstPayGift()
    end

    CWelfareView:CloseView()
end

function CWelfareFirstChargePart.OnClickItem(self, oItemBox)
    local config = {widget = oItemBox}
    g_WindowTipCtrl:SetWindowItemTip(oItemBox.itemId, config)
end

function CWelfareFirstChargePart.OnClickPetTex(self)
    if not self.m_PetId then return end
    self:ShowSummonLinkView()
    -- CSummonMainView:ShowView(function (view)
    --     view.m_NotShowDetailDefault = true
    --     view:ShowSubPageByIndex(3)
    --     local part = view:GetCurrentPage()
    --     part:OnClickIcon(self.m_PetId)
    --     view.m_NotShowDetailDefault = nil
    -- end)
end

function CWelfareFirstChargePart.ShowSummonLinkView(self)
    g_SummonCtrl:ShowSummonLinkView(self.m_PetId, 4)
end

return CWelfareFirstChargePart