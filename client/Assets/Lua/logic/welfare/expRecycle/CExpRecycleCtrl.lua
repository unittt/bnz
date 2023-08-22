local CExpRecycleCtrl = class("CExpRecycleCtrl", CCtrlBase)

function CExpRecycleCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Reset()
end

function CExpRecycleCtrl.Reset(self)
    self.m_RecycleInfo = {}
end

function CExpRecycleCtrl.HasRedDot(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.ExpRecycle) then
        return false
    end
    return next(self.m_RecycleInfo) and true or false
end

function CExpRecycleCtrl.IsShow(self)
    return next(self.m_RecycleInfo) and true or false
end

function CExpRecycleCtrl.GetRecyleCnt(self, iSchedule)
    local dInfo = self.m_RecycleInfo[iSchedule]
    local iCnt = dInfo and dInfo.count
    return iCnt or 0
end

function CExpRecycleCtrl.GetTotalExp(self, idList)
    local iTotal = 0
    for _, id in ipairs(idList) do
        iTotal = iTotal + self:GetUnitExp(id)
    end
    -- printc("get total exp --------- ", iTotal, self:GetServerEffect())
    iTotal = iTotal * self:GetServerEffect()
    return iTotal
end

function CExpRecycleCtrl.GetUnitExp(self, iSchedule)
    local iCnt = self:GetRecyleCnt(iSchedule)
    local dConfig = self:GetRecycleConfig(iSchedule)
    local iExp = string.eval(dConfig.exp, {grade = g_AttrCtrl.grade, math = math}) or 0
    return iCnt * iExp
end

function CExpRecycleCtrl.GetTotalCost(self, idList)
    local dCost = {}
    for _, id in ipairs(idList) do
        self:GetUnitCost(id, dCost)
    end
    return dCost
end

function CExpRecycleCtrl.GetUnitCost(self, iSchedule, dRecord)
    local dConfig = self:GetRecycleConfig(iSchedule)
    if dConfig then
        local iCnt = self:GetRecyleCnt(iSchedule)
        local iGold = dConfig.gold * iCnt
        local iGoldCoin = dConfig.goldcoin * iCnt
        local dCost = {
            gold = iGold,
            goldcoin = iGoldCoin,
        }
        if dRecord then
            dRecord.gold = (dRecord.gold or 0) + iGold
            dRecord.goldcoin = (dRecord.goldcoin or 0) + iGoldCoin
        end
        return dCost
    end
end

function CExpRecycleCtrl.GetAllInfo(self)
    local allInfo = {}
    for id, dInfo in pairs(self.m_RecycleInfo) do
        local dSchedule = g_ScheduleCtrl:GetScheduleInfo(id)
        local dRecycle = self:GetRecycleConfig(id)
        if dRecycle and dInfo.count > 0 then
            local bSys = string.len(dRecycle.sys) > 0
            local bOpen = bSys and g_OpenSysCtrl:GetOpenSysState(dRecycle.sys)
            if bOpen or not bSys then
                table.insert(allInfo, {
                    id = id,
                    schedule = dSchedule,
                    config = dRecycle,
                    cnt = dInfo.count,
                })
            end
        end
    end
    if next(allInfo) then
        table.sort(allInfo, function(a, b)
            return a.config.sort < b.config.sort
        end)
    end
    return allInfo
end

function CExpRecycleCtrl.GetRecycleConfig(self, iSchedule)
    return data.exprecycledata.retrieve[iSchedule]
end

function CExpRecycleCtrl.GetOtherConfig(self, sKey)
    return data.exprecycledata.config[1][sKey]
end

function CExpRecycleCtrl.GetServerEffect(self)
    local iGrade, iSGrade = g_AttrCtrl.grade, g_AttrCtrl.server_grade
    local eff = 1
    local iMore = iGrade - iSGrade
    if iMore >= 5 then
        eff = 1/3
    elseif iMore >= 3 then
        eff = 2/3
    elseif iMore >= 1 then
        eff = 0.8
    end
    return eff
end

function CExpRecycleCtrl.GS2CRetrieveExp(self, pbdata)
    local expList = pbdata.retrieves
    self.m_RecycleInfo = {}
    for i, v in ipairs(expList) do
        self.m_RecycleInfo[v.scheduleid] = v
    end
    g_WelfareCtrl:OnEvent(define.WelFare.Event.RefreshExpRecycle)
end

return CExpRecycleCtrl