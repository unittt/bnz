local CPKCtrl = class("CPKCtrl", CCtrlBase)

function CPKCtrl.ctor(self)
    CCtrlBase.ctor(self)
    
    self.m_MatchTime = 0
    self.m_MyRankInfo = nil
    self.m_ServerTime = nil
    self.m_pkMapId = 502000
    self.m_IsAutoTeam = false
    self.m_PKMatchLeftTime = 0
    self.m_PKMatchEndTimer = nil
end

--请求
--获取比武排行榜
function CPKCtrl.C2GSBWRank(self)
    nethuodong.C2GSBWRank()
end

--响应

--比武层级信息
function CPKCtrl.GS2CBWMyRank(self,myrankInfo)
    -- table.print(myrankInfo,"比武信息")
    self.m_MyRankInfo = myrankInfo
    self:SetBWMatchTime(self.m_MyRankInfo.starttime == 0 and self.m_MyRankInfo.matchtime or 0)
    self:StartMatchEndTimer()
    self:OnEvent(define.PkAction.Event.updateInfo)
end

--比武排行信息
function CPKCtrl.GS2CBWRank(self,ranklist)
    -- table.print(ranklist,"比武排行榜信息")
    CPKRankView:ShowView(function(oView) oView:InitContent(ranklist) end)
end

--匹配计时
function CPKCtrl.SetBWMatchTime(self,matchtime)
    -- printc("匹配倒计时：",matchtime)
    self.m_MatchTime = matchtime
    self.m_ServerTime = g_TimeCtrl:GetTimeS()
    -- self:ShowPKMathcingTime(matchtime)
    self:SetPKMatchCountTime(self.m_MatchTime)
end

--匹配双方信息,匹配结束
function CPKCtrl.GS2CBWBattle(self, match1, match2, time)
    -- table.print(match1,"------己方")
    -- table.print(match2,"-----对方")
    self:OnEvent(define.PkAction.Event.MatchEnd)
    CPKPrepareView:ShowView(function(oView)
        oView:ShowCountTime(time) 
        oView:InitContent(match1,match2)
    end)
end

--比武战斗结束，发放奖励
function CPKCtrl.GS2CBWReward(self, pbdata)
    -- table.print(pbdata.itemlist,"奖励列表")
    --printc("连胜次数：",wincount)
    if pbdata.wincount <= 0 then
       CPKFailView:ShowView( function(oView) oView:InitContent(pbdata) end)
    else
       CPKWinView:ShowView(function(oView) oView:InitContent(pbdata) end)
    end
end

--显示倒计时
function CPKCtrl.ShowPKMathcingTime(self, matchTime)
    if g_WarCtrl:IsWar() then
       return
    end
    self:OnEvent(define.PkAction.Event.updateMatchtime,matchTime)
end

--匹配的倒计时
function CPKCtrl.SetPKMatchCountTime(self, left_time) 
    -- printerror("SetPKMatchCountTime", left_time)
    self:ResetPKMatchTimer()
    local function progress()
        self.m_PKMatchLeftTime = self.m_PKMatchLeftTime - 1

        self:OnEvent(define.PkAction.Event.PKMatchCountTime)
        
        if self.m_PKMatchLeftTime <= 0 then
            self.m_PKMatchLeftTime = 0

            self:OnEvent(define.PkAction.Event.PKMatchCountTime)

            return false
        end
        return true
    end
    self.m_PKMatchLeftTime = left_time + 1
    self.m_PKMatchTimer = Utils.AddTimer(progress, 1, 0)
end

function CPKCtrl.ResetPKMatchTimer(self)
    if self.m_PKMatchTimer then
        Utils.DelTimer(self.m_PKMatchTimer)
        self.m_PKMatchTimer = nil           
    end
end

function CPKCtrl.SetAutoBuildTeam(self, op)
    self.m_IsAutoTeam = op == 1
end

function CPKCtrl.IsAutoBuildTeam(self)
    return self.m_IsAutoTeam
end

function CPKCtrl.GetHuodongNpcInfo(self)

    local config = data.biwutextdata.BIWUNPC
    local infoList = {}
    for k, v in pairs(config) do 
        if v.id <= 1004 then  
            local info = {}
            info.id = v.id
            info.name = v.name
            info.x = v.x
            info.y = v.y
            info.z = v.z
            table.insert(infoList, info)
        end
    end 
    return infoList

end 

function CPKCtrl.StartMatchEndTimer(self)
    if self.m_PKMatchEndTimer then
        Utils.DelTimer(self.m_PKMatchEndTimer)
        self.m_PKMatchEndTimer = nil
    end
    local iEndTime = self.m_MyRankInfo.matchendtime
    local function update()
        if g_TimeCtrl:GetTimeS() >= iEndTime then
            self:ResetPKMatchTimer()
            self:OnEvent(define.PkAction.Event.PKMatchCountTime)
            return
        end
        return true
    end
    self.m_PKMatchEndTimer = Utils.AddTimer(update, 1, 0)
end

function CPKCtrl.IsEndMatch(self)
    return g_TimeCtrl:GetTimeS() >= self.m_MyRankInfo.matchendtime
end

return CPKCtrl