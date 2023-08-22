local CWishBottleView = class("CWishBottleView", CViewBase)

function CWishBottleView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Activity/WishBottleView.prefab", cb)

    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
end

function CWishBottleView.OnCreateView(self)
    self.m_SenderLabel = self:NewUI(1, CLabel)
    self.m_MsgItem = self:NewUI(2, CWidget)
    self.m_MsgLabel = self:NewUI(3, CLabel)
    self.m_AudioItem = self:NewUI(4, CWidget)
    self.m_AudioTimeLabel = self:NewUI(5, CLabel)
    self.m_AudioSprite = self:NewUI(6, CSprite)
    self.m_SenderIcon = self:NewUI(7, CSprite)
    self.m_RewardGrid = self:NewUI(8, CGrid)
    self.m_RewardItem = self:NewUI(9, CBox)
    self.m_InputPart = self:NewUI(10, CWishBottleInputPart)
    self.m_CloseBtn = self:NewUI(11, CButton)
    self.m_AudioLabel = self:NewUI(12, CLabel)
    self.m_AudioFrame = self:NewUI(13, CSprite)

    self:InitContent()

    self.m_CloseBtn:AddUIEvent("click", callback(self,"OnClickClose"))
    self.m_AudioFrame:AddUIEvent("click", callback(self,"OnClickAudio"))

    g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSpeechEvent"))
    g_WishBottleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlBottleEvent"))
end

function CWishBottleView.InitContent(self)
    self.m_AudioSprite:SetSpriteName("#500_02")
    self.m_AudioSprite:PauseSpriteAnimation()
    self.m_RewardItem:SetActive(false)
    self.m_MsgItem:SetActive(false)
    self.m_AudioItem:SetActive(false)
end

function CWishBottleView.InitInfo(self, dInfo)
    local dbottleConfig = data.huodongdata.bottle[1]
    self.m_BottleInfo = dInfo
    if dbottleConfig then
        local dInputInfo = {}
        dInputInfo.timeOut = dInfo.send_time + dbottleConfig.bottle_time
        dInputInfo.bottleId = dInfo.bottle
        self.m_InputPart:SetInfo(dInputInfo)
        self:SetRewardItems(dbottleConfig.reward_idx)
    end
    self:SetReceiveMsg(dInfo.content, dInfo.send_id)
    self:SetSenderInfo(dInfo.name, dInfo.model_info, dInfo.send_id)
end

function CWishBottleView.SetReceiveMsg(self, sMsg, iSendId)
    local bSpeechMsg = false
    self.m_MsgLabel.m_UIWidget.maxLineCount = 2
    if iSendId == 0 then -- by system
        self.m_MsgLabel:SetRichText(DataTools.GetMiscText(1001, "BOTTLE").content)
    else
        local dLink = LinkTools.FindLink(sMsg, "SpeechLink")
        if dLink then
            bSpeechMsg = true
            self:HandleAudioItem(dLink)
        else
            self.m_MsgLabel:SetRichText(sMsg)
        end
    end
    self.m_MsgItem:SetActive(not bSpeechMsg)
    self.m_AudioItem:SetActive(bSpeechMsg)
end

function CWishBottleView.SetSenderInfo(self, sName, dModelInfo, iSendId)
    local icon
    if iSendId == 0 then
        sName = "系统"
        icon = g_AttrCtrl.icon
    else
        self.m_SenderIcon:AddUIEvent("click", callback(self, "OnClickSenderIcon", iSendId))
        self.m_SenderLabel:AddUIEvent("click", callback(self, "OnClickSenderIcon", iSendId))
        icon = dModelInfo.shape or dModelInfo.figure
    end
    self.m_SenderLabel:SetRichText(string.format("[334b4f]来自[018775]%s[-]的祝福瓶[-]", string.format("{link33,%d,%s}", iSendId, sName) ))
    self.m_SenderIcon:SpriteAvatar(icon)
end

function CWishBottleView.OnClickSenderIcon(self, iSendId)
    if iSendId then
        netplayer.C2GSGetPlayerInfo(iSendId)
    end
end

function CWishBottleView.SetRewardItems(self, iRewardId)
    local dReward = self:GetRewardInfo(iRewardId)
    for idx, info in ipairs(dReward) do
        local oItemBox = self.m_RewardGrid:GetChild(idx)
        local itemId = info.sid
        local dItemData = DataTools.GetItemData(itemId)
        if not oItemBox then
             oItemBox = self.m_RewardItem:Clone()
             oItemBox.iconSpr = oItemBox:NewUI(1,CSprite)
             oItemBox.countL = oItemBox:NewUI(2,CLabel)
             oItemBox.borderSpr = oItemBox:NewUI(3,CSprite)
             oItemBox:SetGroup(self.m_RewardGrid:GetInstanceID())
             self.m_RewardGrid:AddChild(oItemBox)
             oItemBox:AddUIEvent("click", callback(self, "OnClickItem"), oItemBox)
             oItemBox:SetActive(true)
        end
        oItemBox.itemId = itemId
        oItemBox.iconSpr:SpriteItemShape(dItemData.icon)
        if info.amount then
            local iGrade = g_AttrCtrl.grade
            local formula = string.gsub(info.amount, "lv", iGrade)
            formula = string.gsub(formula, "SLV", g_AttrCtrl.server_grade)
            local func = loadstring(string.format("return %s", formula))
            oItemBox.countL:SetText(math.floor(func()))
        end
        oItemBox.borderSpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemData.id, dItemData.quality or 0 ) )
    end
end

function CWishBottleView.GetRewardInfo(self, iRewardId)
    local dPackInfo = DataTools.GetReward("BOTTLE", iRewardId)
    local lRewards = {}
    if not dPackInfo then return lRewards end
    local addInfoFunc = function(id, num)
        if num and num ~= "0" then
            table.insert(lRewards, {sid = id, amount = num})
        end
    end
    addInfoFunc(1001, dPackInfo.gold)
    addInfoFunc(1002, dPackInfo.silver)
    addInfoFunc(1004, dPackInfo.goldcoin)
    addInfoFunc(1005, dPackInfo.exp)
    for _, info in ipairs(dPackInfo.item) do
        addInfoFunc(info.sid, info.amount)
    end
    table.print(lRewards)
    return lRewards
end

function CWishBottleView.HandleAudioItem(self, dLink)
    self.m_AudioKey = dLink["sKey"]
    --self.m_AudioLabel:SetRichText(dLink["sTranslate"])
    local iTime = 1
    if dLink["iTime"] then
        iTime = tonumber(dLink["iTime"])
        if iTime > 30 then
            iTime = 30
        end
    end
    -- local iMaxLen, iMinLen = 300, 120
    -- if iTime >= 30 then
    --     self.m_AudioFrame:SetWidth(iMaxLen)
    -- else
    --     if iMaxLen*(iTime/30) >= iMinLen then
    --         self.m_AudioFrame:SetWidth(iMaxLen*(iTime/iMinLen))
    --     else
    --         self.m_AudioFrame:SetWidth(iMinLen)
    --     end
    -- end
    self.m_AudioTimeLabel:SetText(string.format("%d″", iTime))
end

function CWishBottleView.OnClickAudio(self)
    if self.m_AudioKey then
        g_SpeechCtrl:PlayWithKey(self.m_AudioKey)
    end
end

function CWishBottleView.OnClickItem(self, oItemBox)
    local config = {widget = oItemBox}
    g_WindowTipCtrl:SetWindowItemTip(oItemBox.itemId, config)
end

function CWishBottleView.OnClickClose(self)
    self:CloseView()
end

function CWishBottleView.OnCtrlSpeechEvent(self, oCtrl)
    if not oCtrl.m_EventData or not self.m_AudioKey then
        return
    end
    if oCtrl.m_EventData ~= self.m_AudioKey then
        return
    elseif oCtrl.m_EventID == define.Chat.Event.PlayAudio then
        self.m_AudioSprite:SetSpriteName("#500_00")
        self.m_AudioSprite:StartSpriteAnimation()
    elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
        self.m_AudioSprite:SetSpriteName("#500_02")
        self.m_AudioSprite:PauseSpriteAnimation()
    end
end

function CWishBottleView.OnCtrlBottleEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WishBottle.Event.ReceiveBottle then
        if g_WishBottleCtrl:GetBottle() <= 0 then
            self:CloseView()
        end
    end
end

function CWishBottleView.CloseView(self)
    self.m_InputPart:Clean()
    CViewBase.CloseView(self)
end

return CWishBottleView