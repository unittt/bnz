local CWingCtrl = class("CWingCtrl", CCtrlBase)

function CWingCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:InitInfo()
    self:Reset()
end

function CWingCtrl.InitInfo(self)
    self.m_AttrKeyList = {"phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power",
    "speed", "seal_ratio", "res_seal_ratio", "phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio", "max_hp", "max_mp", "magic"}
    self.m_AttrSortDict = {}
    for i, k in ipairs(self.m_AttrKeyList) do
        self.m_AttrSortDict[k] = i
    end
    
    self.starCost = data.wingdata.CONFIG[1].star_cost
    self.activeCost = data.wingdata.CONFIG[1].wield_sid
    
    self.m_UpStarConfig = {}
    for i, v in ipairs(data.wingdata.UPSTAR) do
        local lvConfig = self.m_UpStarConfig[v.level]
        if not lvConfig then
            lvConfig = {}
            self.m_UpStarConfig[v.level] = lvConfig
        end
        table.insert(lvConfig, v)
    end
    for _, t in pairs(self.m_UpStarConfig) do
        local sort = function(a, b)
            return a.star < b.star
        end
        table.sort(t, sort)
    end
end

function CWingCtrl.Reset(self)
    self.m_AttrDict = {}
    self.m_TimeWingDict = {}
    self.id = 0
    self.exp = 0
    self.star = 0
    self.level = -1
    self.score = 0
    self.m_ShowWing = 0
    self.m_HideTimeWing = false
    self.m_IsShowMainBtn = false
    self.m_GuideFlags = {}
end

function CWingCtrl.RefreshWingInfo(self, dWingInfo)
    local bActive = self:HasActiveWing()
    for k, v in pairs(dWingInfo) do
        if self:GetAttrNameData(k) then
            self.m_AttrDict[k] = v
        elseif k == "time_wing_list" then
            self.m_TimeWingDict = {}
            for i, d in ipairs(v) do
                self.m_TimeWingDict[d.wing_id] = d
            end
        elseif k == "show_wing" then
            self.m_ShowWing = v
        else
            self[k] = v
        end
    end
    if bActive ~= self:HasActiveWing() then
        self:SetGuideFlag("wing_active", false)
    end
    self:OnEvent(define.Wing.Event.RefreshWing)
end

function CWingCtrl.GetEffectAttrs(self)
    -- local list = {}
    -- for k, v in pairs(self.m_AttrDict) do
    --     if v > 0 then
    --         table.insert(list, {key = k, val = g_AttrCtrl[k]})
    --     end
    -- end
    -- table.sort(list, function(a, b)
    --     return self.m_AttrSortDict[a.key] < self.m_AttrSortDict[b.key]
    -- end)
    -- return list
    return self:GetSortAttrList(self.m_AttrDict)
end

function CWingCtrl.GetNextEffectAttrs(self)
    local iLv, iStar
    if self:IsMaxStar() then
        if not self:GetCurUpLvConfig() then
            return nil
        end
        iStar = 0
        iLv = self.level + 1
    else
        iStar = self.star + 1
        iLv = self.level
    end
    return self:GetStateEffectAttrs(iLv, iStar)
end

function CWingCtrl.GetStateEffectAttrs(self, iLv, iStar, bEqualStar)
    local iEffectId = self:GetWingEffectId()
    local dEff = self:GetWingEffectInfo(iEffectId)
    local dAttr = string.eval(dEff.wing_effect, {level = iLv, star = iStar})
    if iLv > 0 or iStar > 0 then
        local iLastLv, iLastStar
        if iStar < 1 then
            iLastLv = math.max(iLv - 1, 0)
            if bEqualStar then
                iLastStar = iStar
            else
                iLastStar = iLastLv >= 0 and self:GetMaxStar() or 0
            end
        else
            iLastLv = iLv
            iLastStar = bEqualStar and iStar or (iStar-1)
        end
        local dLastAttr = string.eval(dEff.wing_effect, {level = iLastLv, star = iLastStar})
        local dEffAttr = {}
        for k, v in pairs(dAttr) do
            local e = v - (dLastAttr[k] or 0)
            if e > 0 then
                dEffAttr[k] = e
            end
        end
        return self:GetSortAttrList(dEffAttr)
    else
        return self:GetSortAttrList(dAttr)
    end
end

function CWingCtrl.GetSortAttrList(self, dAttr)
    local list = {}
    for k, v in pairs(dAttr) do
        if v ~= 0 then
            table.insert(list, {key = k, val = v})
        end
    end
    table.sort(list, function(a, b)
        return (self.m_AttrSortDict[a.key] or 0) < (self.m_AttrSortDict[b.key] or 0)
    end)
    return list
end

function CWingCtrl.GetWingEquipData(self)
    if self.id > 0 then
        return DataTools.GetItemData(self.id)
    end
end

function CWingCtrl.GetCurWingConfig(self)
    local iLv = math.max(self.level, 0)
    local dLv = self:GetLevelWingConfig(iLv)
    if dLv then
        return self:GetWingConfig(dLv.wing)
    end
end

function CWingCtrl.GetCurUpLvConfig(self)
    return self:GetUpLvConfig(self.level+1)
end

function CWingCtrl.GetWingFigureId(self, iWingId)
    local dWing = self:GetWingConfig(iWingId)
    local iFigureId = dWing and dWing.figureid
    iFigureId = iFigureId > 0 and iFigureId
    return iFigureId
end

function CWingCtrl.GetCurUpStarExp(self)
    return self:GetUpStarExp(self.level, self.star)
end

function CWingCtrl.GetUpStarExp(self, iLv, iStar)
    local iExp = 0
    local d = self:GetStarConfig(iLv)
    if d then
        local dNext = d[iStar+1]
        iExp = dNext and dNext.up_star_exp or 0
    end
    return iExp
end

function CWingCtrl.GetShowWingInfo(self)
    if self.m_ShowWing and self.m_ShowWing > 0 then
        return self:GetWingConfig(self.m_ShowWing)
    end
end

function CWingCtrl.GetBagWingConfig(self)
    if not self:HasActiveWing() then
        return
    end
    local dWing = self:GetShowWingInfo()
    if not dWing then
        dWing = self:GetCurWingConfig()
    end
    return dWing
end

function CWingCtrl.GetTimeWingExpireTime(self, iWing)
    local dTimeWing = self.m_TimeWingDict[iWing]
    return dTimeWing and (dTimeWing.expire or 0)
end

function CWingCtrl.GetWingItemData(self, iWing)
    local dWing = self:GetWingConfig(iWing)
    if dWing then
        local itemId
        if dWing.time_wing == 1 then
            local dCost = dWing.active_cost[1]
            itemId = dCost and dCost.sid
        else
            itemId = g_WingCtrl.activeCost
        end
        return DataTools.GetItemData(itemId)
    end
end

function CWingCtrl.GetWingInfoByItem(self, iSid)
    if self:IsTimeWingItem(iSid) then
        local timeWings = data.wingdata.WINGINFO
        for i, v in pairs(timeWings) do
            if v.time_wing == 1 then
                for _, dCost in ipairs(v.active_cost) do
                    if dCost.sid == iSid then
                        return v
                    end
                end
            end
        end
    end
    return false
end

function CWingCtrl.GetWingPieceNeed(self, iSid)
    local iCnt
    for _, d in pairs(data.wingdata.WINGINFO) do
        for _, c in ipairs(d.buy_times) do
            if c.money_type == iSid then
                iCnt = c.cost
                break
            end
        end
        if iCnt and iCnt > 0 then
            break
        end
    end
    return iCnt
end

function CWingCtrl.GetLvLimit(self, iLv)
    local lvLimits = data.wingdata.LEVELLIMIT
    for i, v in ipairs(lvLimits) do
        if v.level_limit == iLv then
            return v
        end
    end
end

function CWingCtrl.SetGuideFlag(self, key, bFlag)
    self.m_GuideFlags[key] = bFlag
end

function CWingCtrl.GetGuideFlag(self, key)
    return self.m_GuideFlags[key]
end

function CWingCtrl.IsMaxStar(self)
    return self.star >= self:GetMaxStar()
end

function CWingCtrl.HasActiveWing(self)
    return self.id > 0
end

function CWingCtrl.IsCanUpLevel(self)
    local dLimit = self:GetLvLimit(self.level + 1)
    if dLimit then
        if self:GetUpLvConfig(self.level + 1) then
            return g_AttrCtrl.grade >= dLimit.player_grade
        else
            return false
        end
    else
        return false
    end
end

function CWingCtrl.IsUnlockWingSys(self)
    return g_OpenSysCtrl:GetOpenSysState(define.System.Wing)
end

function CWingCtrl.IsWingItem(self, iSid)
    return iSid == 10164 or iSid == 10163 or iSid == self.activeCost
end

function CWingCtrl.IsTimeWingItem(self, iSid)
    return (iSid >= 10149 and iSid <= 10154) or self:IsTimeWingPiece(iSid)
end

function CWingCtrl.IsTimeWingPiece(self, iSid)
    return iSid == 10147
end

function CWingCtrl.IsShowMainBtn(self, bTrigger)
    do
        return self:IsUnlockWingSys()
    end
    if self.m_HideTimeWing then
        return self:IsUnlockWingSys()
    elseif self:IsUnlockWingSys() then
        return true
    end
    -- self.m_IsShowMainBtn = IOTools.GetRoleData("showwingmainmenu")
    if self.m_IsShowMainBtn and bTrigger then
        self:OnEvent(define.Wing.Event.RefreshWingBtn)
    end
    return self.m_IsShowMainBtn and true or false
end

function CWingCtrl.SetShowMainBtn(self, iFlag)
    if iFlag == 1 then
        self.m_IsShowMainBtn = true
    end
end

function CWingCtrl.IsCanActive(self)
    return g_ItemCtrl:GetBagItemAmountBySid(self.activeCost) > 0
end

function CWingCtrl.IsWingPieceEnough(self, iSid)
    local iNeed = self:GetWingPieceNeed(iSid)
    if iNeed then
        return iNeed <= g_ItemCtrl:GetBagItemAmountBySid(iSid)
    end
    return false
end

function CWingCtrl.IsActivatable(self)
    -- do return self.m_Activable end
    return self:IsUnlockWingSys() and not self:HasActiveWing() and self:IsCanActive()
end
---------------------- Protocol -----------------------

function CWingCtrl.GS2CRefreshWingInfo(self, dWingInfo)
    self:RefreshWingInfo(dWingInfo)
end

function CWingCtrl.GS2CLoginWing(self, dWingInfo)
    self:RefreshWingInfo(dWingInfo)
end

function CWingCtrl.GS2CRefreshOneTimeWing(self, dTimeWing)
    self.m_TimeWingDict[dTimeWing.wing_id] = dTimeWing
    self:OnEvent(define.Wing.Event.RefreshTimeWing, dTimeWing.wing_id)
end

---------------------- Config ------------------------
function CWingCtrl.GetAttrNameData(self, sKey)
    return data.attrnamedata.DATA[sKey]
end

function CWingCtrl.GetWingConfig(self, iWing)
    return data.wingdata.WINGINFO[iWing]
end

function CWingCtrl.GetUpLvConfig(self, iLv)
    if not iLv then
        return data.wingdata.UPLEVEL
    else
        return data.wingdata.UPLEVEL[iLv]
    end
end

function CWingCtrl.GetMaxStar(self)
    local d = self:GetStarConfig(self.level)
    return d and #d or 0
end

function CWingCtrl.GetStarConfig(self, iLv)
    return self.m_UpStarConfig[iLv]
end

function CWingCtrl.GetTimeWingConfigs(self)
    local wingInfos = {}
    for i, v in pairs(data.wingdata.WINGINFO) do
        if v.time_wing == 1 then
            table.insert(wingInfos, v)
        end
    end
    table.sort(wingInfos, function(a, b)
        return a.wing_id < b.wing_id
    end)
    return wingInfos
end

function CWingCtrl.GetWingEffectInfo(self, iWing)
    return data.wingdata.WINGEFFECT[iWing]
end

function CWingCtrl.GetWingEffectId(self)
    local dEff = data.wingdata.CONFIG[1].wing_effect[g_AttrCtrl.school]
    return dEff and dEff.effect_id or 0
end

function CWingCtrl.GetLevelWingConfig(self, iLv)
    local lvWings = data.wingdata.LEVELWING
    if iLv then
        local dWing
        for _, v in ipairs(lvWings) do
            if v.level > iLv then
                break
            end
            dWing = v
        end
        return dWing
    else
        return lvWings
    end
end

---------------------- UI ----------------------
function CWingCtrl.ShowWingTestView(self, iWing)
    CWingTestView:ShowView(function(oView)
        oView:SetWingId(iWing)
    end)
end

function CWingCtrl.ShowWingActiveView(self, iWing)
    CWingActiveView:ShowView(function(oView)
        oView:SetWingId(iWing)
    end)
end

function CWingCtrl.WingFloatMsg(self, id)
    g_NotifyCtrl:FloatMsg(data.wingdata.TEXT[id].content)
end

function CWingCtrl.ShowWingPropertyPage(self)
    local bShow = self:IsUnlockWingSys() -- not self.m_HideTimeWing
    if bShow then
        if not self.m_IsShowMainBtn then
            self.m_IsShowMainBtn = true
            -- IOTools.SetRoleData("showwingmainmenu", true)
            netwing.C2GSOpenWingUI()
            self:OnEvent(define.Wing.Event.RefreshWingBtn)
        end
        CWingMainView:ShowView()
    else
        self:WingFloatMsg(3005)
    end
    return bShow
end

function CWingCtrl.ShowTimeWingPage(self, iSid)
    if iSid and self:IsTimeWingPiece(iSid) then
        if not self:IsWingPieceEnough(iSid) then
            g_NotifyCtrl:FloatMsg("碎片不足，无法使用")
            return
        end
    end
    if not self:HasActiveWing() then
        self:WingFloatMsg(3006)
        return
    end
    CWingMainView:ShowView(function(oView)
        oView:ShowSubPageByIndex(2)
        oView.m_TimeWingPart:ShowTimeWingByItemSid(iSid)
    end)
end

function CWingCtrl.ShowWingTipView(self)
    if self:IsUnlockWingSys() then
        CWingTipView:ShowView()
    else
        self:WingFloatMsg(3005)
    end
end

return CWingCtrl