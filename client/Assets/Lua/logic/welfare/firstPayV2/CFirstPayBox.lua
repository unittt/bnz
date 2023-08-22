local CFirstPayBox = class("CFirstPayBox", CBox)

CFirstPayBox.WeaponConfig = {
    [1110] = {
        pos = Vector3(-0.5, -0.2, 3),
        euler = Vector3(35.5, -105, -29),
        size = 0.85,
    },
    [1120] = {
        pos = Vector3(-0.2, -0.2, 3),
        euler = Vector3(61, -92.7, -39),
        size = 0.8,
    },
    [1210] = {
        pos = Vector3(-0.3, -0.3, 3),
        euler = Vector3(40, -100, -39),
        size = 0.5,
    },
    [1220] = {
        pos = Vector3(-0.15, -0.25, 3),
        euler = Vector3(61, -95.5, -47.9),
        size = 0.4,
    },
    [1310] = {
        pos = Vector3(-0.86, -0.2, 3),
        euler = Vector3(40, 176.45, -39),
    },
    [1320] = {
        pos = Vector3(1, -0.25, 3),
        euler = Vector3(28.2, 26.2, -39),
        size = 0.58,
    },
}

function CFirstPayBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_ActTimeL = self:NewUI(1, CLabel)
    self.m_MainNameL = self:NewUI(2, CLabel)
    self.m_ExtraRoot = self:NewUI(3, CObject)
    self.m_RewardGrid = self:NewUI(4, CGrid)
    self.m_RewardBox = self:NewUI(5, CBox)
    self.m_ExtraBox = self:NewUI(6, CBox)
    self.m_ExtraGrid = self:NewUI(7, CGrid)
    self.m_MainEffSpr = self:NewUI(8, CWidget)
    self.m_ActorTex = self:NewUI(9, CActorTexture)
    self.m_MainItemBox = self:NewUI(10, CBox)

    self.m_Idx = nil
end

function CFirstPayBox.RefreshAll(self, idx)
    if self.m_Idx == idx then
        return
    end
    self.m_Idx = idx
    local dReward = g_FirstPayCtrl:GetRewardInfo(idx, "gift_1")
    self.m_RewardBox:SetActive(false)
    self.m_ExtraBox:SetActive(false)
    self:RefreshMainReward(dReward)
    self:RefreshRewardItems(dReward)
    self:RefreshExtraReward()
end

function CFirstPayBox.RefreshMainReward(self, dReward)
    local bModel = true
    if dReward.summon and next(dReward.summon) then
        local iSummonId = tonumber(dReward.summon[1].idx)
        local dSummonInfo = DataTools.GetSummonInfo(iSummonId)
        if dSummonInfo then
            local modelInfo = {}
            modelInfo.shape = dSummonInfo.shape
            modelInfo.pos = Vector3(0, -0.72, 3)
            self.m_ActorTex:ChangeShape(modelInfo)
            self.m_ActorTex:AddUIEvent("click", callback(self, "OnClickSummonTex", iSummonId))
            self.m_MainNameL:SetText(dSummonInfo.name)

            local oEff = self.m_MainEffSpr:AddEffect("S", 0)
            oEff:SetLocalScale(Vector3(0.7,0.7,0.7))
            self.m_MainEffSpr:SetColor(Color.New(1,1,1,0.01))
        end
    elseif dReward.item and next(dReward.item) then
        local dItem = dReward.item[1]
        if g_WingCtrl:IsTimeWingItem(dItem.sid) then
            local dWingInfo = g_WingCtrl:GetWingInfoByItem(dItem.sid)
            if dWingInfo then
                local modelInfo = {
                    -- shape = dWingInfo.figureid,
                    show_wing = dWingInfo.wing_id,
                    -- ignoreClick = true,
                    pos = Vector3(0, -0.55, 3),
                    rendertexSize = 1.1,
                }
                self.m_ActorTex:ChangeShape(modelInfo)
                self.m_MainNameL:SetText(dWingInfo.name)
                self.m_ActorTex:AddUIEvent("click", callback(self, "OnClickWingTex", dWingInfo))
            end
        else
            bModel = self:RefreshWeapon(dItem)
        end
        table.remove(dReward.item, 1)
    end
    self.m_MainEffSpr:SetActive(self.m_Idx == 1)
    self.m_ActorTex:SetActive(bModel)
    self.m_MainItemBox:SetActive(not bModel)
end

function CFirstPayBox.RefreshWeapon(self, dItem)
    local bModel = false
    local id = dItem.sid
    if dItem.type and dItem.type > 0 then
        id = DataTools.GetItemFiterResult(id, g_AttrCtrl.roletype, g_AttrCtrl.sex)
    end
    local dItemConfig = DataTools.GetItemData(id)
    local iEquip = dItemConfig.soul_equip
    if iEquip and iEquip ~= 0 then
        local iShape = ModelTools.GetOriShape(g_AttrCtrl.model_info.shape)
        local sWeapon = string.format("%d_%d", iShape, iEquip)
        -- local sPath = IOTools.GetGameResPath("/" .. CActor.GetWeaponPath(nil, sWeapon))
        local bHas = true--IOTools.IsExist(sPath)
        if iShape and bHas then
            local dConfig = CFirstPayBox.WeaponConfig[iShape] or {}
            bModel = true
            local modelInfo = {
                weapon_shape = sWeapon,
                pos = dConfig.pos,
                rendertexSize = dConfig.size or 0.7,
                weapon = true,
            }
            self.m_ActorTex:ChangeShape(modelInfo)
            self.m_ActorTex:DelUIEvent("drag")
            self.m_MainItemBox.itemId = id
            self.m_ActorTex:AddUIEvent("click", callback(self, "OnClickItem", self.m_MainItemBox))
            local oActor = self.m_ActorTex.m_ActorCamera:GetActor()
            local euler = dConfig.euler
            if oActor and euler then
                local rot = Quaternion.Euler(euler.x, euler.y, euler.z)
                oActor:SetLocalRotation(rot)
            end
        end
    end
    if not bModel then
        self:RefreshRewardBox(self.m_MainItemBox, {
            icon = dItemConfig.icon,
            item = id,
            cnt = dItem.amount,
            quality = dItemConfig.quality,
        })
    end
    self.m_MainNameL:SetText(dItemConfig.name)
    return bModel
end

function CFirstPayBox.RefreshRewardItems(self, dReward)
    local rewardList = g_FirstPayCtrl:ConvertRewardInfo(dReward)
    for i, v in ipairs(rewardList) do
        local itemId = v.id
        local itemInfo = DataTools.GetItemData(itemId)
        if itemInfo then
            local oItemBox = self.m_RewardBox:Clone()
            local dItem = {
                icon = itemInfo.icon,
                item = itemId,
                cnt = v.cnt,
                quality = itemInfo.quality,
            }
            self:RefreshRewardBox(oItemBox, dItem)
            oItemBox:SetActive(true)
            self.m_RewardGrid:AddChild(oItemBox)
        end
    end
end

function CFirstPayBox.RefreshExtraReward(self)
    local dExtraReward = g_FirstPayCtrl:GetRewardInfo(self.m_Idx, "gift_2")
    local rewardList = g_FirstPayCtrl:ConvertExtraReward(dExtraReward)
    for i, v in ipairs(rewardList) do
        local oItemBox = self.m_ExtraBox:Clone()
        self:RefreshRewardBox(oItemBox, v)
        oItemBox:SetActive(true)
        oItemBox.iconSpr:AddEffect("partner", 0)
        self.m_ExtraGrid:AddChild(oItemBox)
    end
    local sDate = g_FirstPayCtrl:GetExtraTimeText(self.m_Idx)
    -- self.m_ActTimeL:SetActive(sDate and true or false)
    if sDate then
        self.m_ActTimeL:SetText(sDate)
    end
    self.m_ExtraRoot:SetActive(g_FirstPayCtrl:HasExtraReward(self.m_Idx))
end

function CFirstPayBox.RefreshRewardBox(self, oBox, info)
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.cntL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    if info.item then
        oBox.iconSpr:SpriteItemShape(info.icon)
        oBox.itemId = info.item
        oBox:AddUIEvent("click", callback(self, "OnClickItem"))
    else
        oBox.iconSpr:SpriteAvatar(info.avatar)
    end
    oBox.cntL:SetActive(info.cnt and info.cnt > 1 or false)
    if info.cnt then
        oBox.cntL:SetText(info.cnt)
    end
    oBox.qualitySpr:SetActive(info.quality and true or false)
    if info.quality then
        oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(info.item, info.quality or 0 ))
    end
end

function CFirstPayBox.OnClickSummonTex(self, iSummonId)
    g_SummonCtrl:ShowSummonLinkView(iSummonId, 4)
end

function CFirstPayBox.OnClickItem(self, oItemBox)
    local config = {widget = oItemBox}
    g_WindowTipCtrl:SetWindowItemTip(oItemBox.itemId, config)
end

function CFirstPayBox.OnClickWingTex(self, dWing)
    g_WingCtrl:ShowWingTestView(dWing.wing_id)
end

return CFirstPayBox