local CTreasureBoxView = class("CTreasureBoxView", CViewBase)

function CTreasureBoxView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Item/TreasureBoxView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "ClickOut"
end

function CTreasureBoxView.OnCreateView(self)
    self.m_BoxIcon = self:NewUI(1, CSprite)
    self.m_BoxNum = self:NewUI(2, CLabel)
    self.m_KeyIcon = self:NewUI(3, CSprite)
    self.m_KeyNum = self:NewUI(4, CLabel)
    self.m_OpenBtn = self:NewUI(5, CButton)
    self.m_CloseBtn = self:NewUI(6, CButton)
    self.m_Reward = self:NewUI(7, CSprite)
    self.m_CloseBigBox = self:NewUI(8, CSprite)
    self.m_RewardNum = self:NewUI(9, CLabel)
    self.m_OpenBtnLabel = self:NewUI(10, CLabel)
    self.m_ItemQualitySpr = self:NewUI(11, CSprite)
    self.m_BoxTex = self:NewUI(12, CActorTexture)
    self.m_ItemInfo = {}

    self:InitContent()
end

function CTreasureBoxView.InitContent(self)
    self.m_BoxIcon:SetSpriteName("")
    self.m_BoxNum:SetText("")
    self.m_KeyIcon:SetSpriteName("")
    self.m_KeyNum:SetText("")
    self.m_Reward:SetActive(false)
    -- self.m_CloseBigBox:SetActive(true)
    self.m_TestPlay = false

    self.m_OpenBtn:AddUIEvent("click", callback(self, "OpenBox"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_BoxTex:AddUIEvent("click", callback(self, "OnClickBoxTex"))
    self.m_BoxTex:DelUIEvent("drag")
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlOpenBoxEvent"))
    -- g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CTreasureBoxView.InitInfo(self, iBoxId)
    local dBoxData = DataTools.GetItemData(iBoxId)
    local modelInfo = {
        shape = 8215,
        rendertexSize = 1.4,
        pos = Vector3(0, -1, 3),
    }
    self.m_BoxTex:ChangeShape(modelInfo)
    self.m_ItemInfo.boxId = iBoxId
    self.m_ItemInfo.boxName = dBoxData.name
    self.m_BoxIcon:SetSpriteName(dBoxData.icon)
    if dBoxData then
        local dOpenCost = dBoxData.open_cost[1]
        if dOpenCost then
            local iKeyCnt = g_ItemCtrl:GetBagItemAmountBySid(dOpenCost.sid)
            local dKeyInfo = DataTools.GetItemData(dOpenCost.sid)
            self.m_ItemInfo.keyId = dOpenCost.sid
            self.m_ItemInfo.keyNeedCnt = dOpenCost.amount
            self.m_ItemInfo.keyName = dKeyInfo.name
            self.m_KeyIcon:SetSpriteName(dKeyInfo.icon)
        end
    end
    self:UpdateItemsAmount()
end

function CTreasureBoxView.UpdateItemsAmount(self)
    local iBoxCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemInfo.boxId)
    self.m_BoxNum:SetText(iBoxCnt)
    self.m_ItemInfo.boxCnt = iBoxCnt
    if self.m_ItemInfo.keyId then
        local iKeyCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemInfo.keyId)
        self.m_KeyNum:SetText(iKeyCnt)
        self.m_ItemInfo.keyCnt = iKeyCnt
    end
end

function CTreasureBoxView.OpenBox(self)
    local iBoxCnt = self.m_ItemInfo.boxCnt
    local iKeyCnt = self.m_ItemInfo.keyCnt
    local iKeyNeedCnt = self.m_ItemInfo.keyNeedCnt
    if not iBoxCnt then
        return
    end
    if iBoxCnt < 1 then
        g_NotifyCtrl:FloatMsg(string.gsub(DataTools.GetMiscText(1004, "BOX").content, "#item", self.m_ItemInfo.boxName))
    elseif iKeyCnt and iKeyNeedCnt then
        if iKeyCnt >= iKeyNeedCnt then
            netopenui.C2GSOpenBox(self.m_ItemInfo.boxId)
        else
            --self:ShowQuickBuyView()
            local sMsg = DataTools.GetMiscText(1005, "BOX").content
            g_NotifyCtrl:FloatMsg(string.gsub(sMsg, "#item", self.m_ItemInfo.keyName))
        end
    else --没设置开启钥匙
        netopenui.C2GSOpenBox(self.m_ItemInfo.boxId)
    end
end

function CTreasureBoxView.ShowQuickBuyView(self)
    local dKeyData = {
        amount = self.m_ItemInfo.keyCnt,
        sid = self.m_ItemInfo.keyId,
        msg = DataTools.GetMiscText(1005, "BOX").content
    }
    CTradeVolumSubView:ShowView(function(oView)
        oView:SetTradeVolumSubView(dKeyData)
    end)
end

function CTreasureBoxView.OnCtrlOpenBoxEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.OpenTreasureBox then
        local dRewardItem = oCtrl.m_EventData.reward_item[1]
        if dRewardItem then
            local dItemInfo = DataTools.GetItemData(dRewardItem.sid)
            self.m_Reward:SpriteItemShape(dItemInfo.icon)
            self.m_RewardNum:SetText(dRewardItem.amount)
            -- self.m_CloseBigBox:SetActive(false)
            self.m_ItemQualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemInfo.id, dItemInfo.quality or 0 ))
            self:PlayBoxAnim("run")
            -- self.m_Reward:SetActive(true)
        end
        if not self.m_ItemInfo.open then
            self.m_ItemInfo.open = true
            self.m_OpenBtnLabel:SetText("继续开启")
        end
        self:UpdateItemsAmount()
    elseif oCtrl.m_EventID == define.Item.Event.QuickBuyItem then
        self:UpdateItemsAmount()
    end
end

function CTreasureBoxView.OnClickBoxTex(self)
    if not self.m_TestPlay then return end
    if self.m_Open then
        self:PlayBoxAnim("idleCity")
        self.m_Open = false
    else
        self:PlayBoxAnim("run")
        self.m_Open = true
    end
end

function CTreasureBoxView.PlayBoxAnim(self, sAnim)
    local oActor = self.m_BoxTex.m_ActorCamera:GetActor()
    if oActor then
        self.m_Reward:SetActive(false)
        if sAnim == "idleCity" then
            oActor:Play(sAnim)
        else
            local endCb = function()
                self.m_Reward:SetActive(true)
            end
            oActor:Play(sAnim, 0, 0.95, endCb)
        end
    end
end

return CTreasureBoxView