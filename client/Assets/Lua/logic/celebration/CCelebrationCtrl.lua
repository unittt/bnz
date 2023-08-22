local CCelebrationCtrl = class("CCelebrationCtrl", CCtrlBase)

function CCelebrationCtrl.ctor(self)

	CCtrlBase.ctor(self)

	self.m_huodongConfig = {}
    self:InitTabConfig()
    self.m_OpenCollectKey = nil
    -- 关闭系统表
    self.m_BanSys = {
        -- "RebateExplain",
        -- "Exchange",
    }
    self.m_TouXianRankData = {}
    self.m_TouXianRankList = {}
    self.m_TouXianRankLen = 10
    self.m_IsHasClickMainMenu = false

    self:GetOrgTargetConfigList()
    self:GetGradeRewardConfig()
    self:GetScoreRewardConfig()
end

function CCelebrationCtrl.Clear(self)
    self.m_IsHasClickMainMenu = false
end

---------------协议返回-------------------

function CCelebrationCtrl.GS2CKFTouxianRank(self, pbdata)
    self.m_TouXianRankData = {}
    table.copy(pbdata.touxianrank, self.m_TouXianRankData)
    table.sort(self.m_TouXianRankData, function (a, b)
        if a.level ~= b.level then
            return a.level < b.level
        else
            return a.rank < b.rank
        end
    end)
    self:GetTouXianRankList()
    self:OnEvent(define.Celebration.Event.UpdateTouXianRank)
    table.print(pbdata, "CCelebrationCtrl.GS2CKFTouxianRank")
end

function CCelebrationCtrl.GetTouXianRankList(self)
    self.m_TouXianRankList = {}
    table.copy(self.m_TouXianRankData, self.m_TouXianRankList)
    local oLen = #self.m_TouXianRankData
    local oNeedLen = self.m_TouXianRankLen - oLen
    if oNeedLen > 0 then
        for i = 1, oNeedLen do
            table.insert(self.m_TouXianRankList, {rank = oLen + i})
        end
    end
end

function CCelebrationCtrl.GS2CKaiFuRankReward(self, pbdata)
    self.m_KaifuRankRewardData = pbdata
    self:OnEvent(define.Celebration.Event.UpdateRankReward)
    table.print(pbdata, "CCelebrationCtrl.GS2CKaiFuRankReward")
end

-----------------数据管理---------------

--检查开服典礼是否开启
function CCelebrationCtrl.CheckKaifuOpenState(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return false
    end
    if not g_OpenSysCtrl:GetOpenSysState(define.System.Kaifu) then
        return false
    end
    local oLeftTime1 = g_CelebrationCtrl.m_KaifuRankRewardData.playergrade.endtime - g_TimeCtrl:GetTimeS()
    local oLeftTime2 = g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime - g_TimeCtrl:GetTimeS()
    local oLeftTime3 = g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime - g_TimeCtrl:GetTimeS()
    local oLeftTime4 = g_CelebrationCtrl.m_KaifuRankRewardData.txendtime - g_TimeCtrl:GetTimeS()
    local oLeftTime5 = g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime - g_TimeCtrl:GetTimeS()
    if oLeftTime1 > 0 or oLeftTime2 > 0 or oLeftTime3 > 0 or oLeftTime4 > 0 or oLeftTime5 > 0 then
        return true
    else
        return false
    end
end

function CCelebrationCtrl.GetIsRankRewardExist(self, oRewardDataList, oKey)
    for k,v in pairs(oRewardDataList) do
        if v.flag == oKey then
            return v
        end
    end
end

function CCelebrationCtrl.GetOrgTargetConfigList(self)
    self.m_OrgTargetConfigList = {}
    self.m_OrgCntList = {}
    for k,v in pairs(data.huodongdata.KAIFUORGCNT) do
        table.insert(self.m_OrgCntList, v)
    end
    table.sort(self.m_OrgCntList, function (a, b) return a.count < b.count end)
    self.m_OrgLevelList = {}
    for k,v in pairs(data.huodongdata.KAIFUORGLEVEL) do
        table.insert(self.m_OrgLevelList, v)
    end
    table.sort(self.m_OrgLevelList, function (a, b) return a.count < b.count end)

    for k,v in ipairs(self.m_OrgCntList) do
        table.insert(self.m_OrgTargetConfigList, {type = 1, config = v})
    end
    for k,v in ipairs(self.m_OrgLevelList) do
        table.insert(self.m_OrgTargetConfigList, {type = 2, config = v})
    end
end

function CCelebrationCtrl.GetGradeRewardConfig(self)
    self.m_GradeRewardConfig = {}
    for k,v in pairs(data.huodongdata.KAIFUPLAYERGRADE) do
        table.insert(self.m_GradeRewardConfig, v)
    end
    table.sort(self.m_GradeRewardConfig, function (a, b) return a.grade < b.grade end)

    self.m_GradeRewardHashConfig = {}
    for k,v in pairs(self.m_GradeRewardConfig) do
        self.m_GradeRewardHashConfig[v.grade] = v
    end
end

function CCelebrationCtrl.GetScoreRewardConfig(self)
    self.m_ScoreRewardConfig = {}
    for k,v in pairs(data.huodongdata.KAIFUPLAYERSCORE) do
        table.insert(self.m_ScoreRewardConfig, v)
    end
    table.sort(self.m_ScoreRewardConfig, function (a, b) return a.score < b.score end)
end

function CCelebrationCtrl.GetLeftTime(self, iSec)
    local day = math.floor(iSec / (3600 * 24), true) 
    local hour = math.floor((iSec / 3600) % 24, true)
    local min = math.ceil((iSec / 60) % 60, true)

    if day > 0 then 
        return string.format("%d天%d小时", day, hour)
    elseif hour > 0 then 
        return string.format("%d小时", hour)
    elseif min >= 1 then
        return string.format("%d分钟", min)
    end
end

function CCelebrationCtrl.GetGradeHasOpenDay(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return 0
    end
    -- local oLeftTime = g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.createtime
    -- local day = math.floor(oLeftTime / (3600 * 24), true)
    -- return day+1 --data.huodongdata.KAIFUCONFIG.kaifu_grade.openday - day

    local oYear = os.date("%Y", g_CelebrationCtrl.m_KaifuRankRewardData.createtime)
    local oMonth = os.date("%m", g_CelebrationCtrl.m_KaifuRankRewardData.createtime)
    local oDay = os.date("%d", g_CelebrationCtrl.m_KaifuRankRewardData.createtime)

    local oDayEnd = os.time({year = oYear, month = oMonth, day = oDay, hour = 24, minute = 0, second = 0})
    if g_TimeCtrl:GetTimeS() > oDayEnd then
        local oLeftTime = g_TimeCtrl:GetTimeS() - oDayEnd
        return math.floor(oLeftTime / (3600 * 24), true) +1 + 1
    else
        return 1
    end
end

function CCelebrationCtrl.GetStrengthHasOpenDay(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return 0
    end
    local oLeftTime = g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.createtime
    local day = math.floor(oLeftTime / (3600 * 24), true)
    return day+1 --data.huodongdata.KAIFUCONFIG.kaifu_score.openday - day
end

function CCelebrationCtrl.GetOrgHasOpenDay(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return 0
    end
    local oLeftTime = g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.createtime
    local day = math.floor(oLeftTime / (3600 * 24), true)
    return day+1 --data.huodongdata.KAIFUCONFIG.kaifu_org.openday - day
end

---------------界面数据管理---------------

function CCelebrationCtrl.InitTabConfig(self)
    for k, v in pairs(define.Celebration.Tab) do
        table.insert(self.m_huodongConfig, {key = k, idx = v})
    end
    table.sort(self.m_huodongConfig, function(a, b)
        return a.idx < b.idx
    end)
end

 --是否有小红点(福利界面下的所有小红点)
 function CCelebrationCtrl.IsHadRedPoint(self)
    if self:GetIsHasGradeRedPoint() then
        return true
    end
    if self:GetIsHasScoreRedPoint() then
        return true
    end
    if self:GetIsHasOrgCntRedPoint() then
        return true
    end
    if self:GetIsHasOrgLevelRedPoint() then
        return true
    end
    return false
end

function CCelebrationCtrl.GetIsHasGradeRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.GradeRank) then
        return false
    end
    if self.m_KaifuRankRewardData then
        if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.playergrade.endtime) > 0 then
            return false
        end
        for k,v in pairs(self.m_KaifuRankRewardData.playergrade.rewarddata) do
            if v.reward == 1 then --and self.m_GradeRewardHashConfig[v.flag].openday >= g_CelebrationCtrl:GetGradeHasOpenDay()
                return true
            end
        end
    end
    return false
end

function CCelebrationCtrl.GetIsHasScoreRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.StrengthRank) then
        return false
    end
    if self.m_KaifuRankRewardData then
        for k,v in pairs(self.m_KaifuRankRewardData.playerscore.rewarddata) do
            if v.reward == 1 then
                return true
            end
        end
    end
    return false
end

function CCelebrationCtrl.GetIsHasOrgCntRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.StrengthRank) then
        return false
    end
    if self.m_KaifuRankRewardData then
        for k,v in pairs(self.m_KaifuRankRewardData.orgcnt.rewarddata) do
            if v.reward == 1 then
                return true
            end
        end
    end
    return false
end

function CCelebrationCtrl.GetIsHasOrgLevelRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.StrengthRank) then
        return false
    end
    if self.m_KaifuRankRewardData then
        for k,v in pairs(self.m_KaifuRankRewardData.orglevel.rewarddata) do
            if v.reward == 1 then
                return true
            end
        end
    end
    return false
end

--是否有开启的活动
 function CCelebrationCtrl.IsHadOpenHuodong(self)
 	
 	local huodong = self:GetOpenHuodong()

 	local isHad = false

 	if #huodong > 0 then 

 		isHad = true

 	end

 	return isHad

 end

function CCelebrationCtrl.GetViewOpenData(self, sView)
    -- 屏蔽的系统
    if table.index(self.m_BanSys, sView) then
        return
    end
    local sSysKey = define.System[sView]
    if sSysKey then
        local dOpenData = table.copy(DataTools.GetViewOpenData(sSysKey))
        return dOpenData
    end
end

function CCelebrationCtrl.GetUnLockViewData(self, sView)
    if sView == "CollectGift" then
        local status = g_WelfareCtrl.m_CollectGiftInfo.status
        if status and status == 1 then
            return {name = "集字换礼",}
        end
    end
end

--获取已开启活动列表
function CCelebrationCtrl.GetOpenHuodong(self)
 	
 	local openHuodongList = {}
 	for k , v in ipairs(self.m_huodongConfig) do
        local dOpenData = self:GetViewOpenData(v.key) 
        if dOpenData then
            if g_OpenSysCtrl:GetOpenSysState(dOpenData.stype) then
                local bOpen = true
                if v.key == "GradeRank" then
                    -- if self.m_KaifuRankRewardData and (g_TimeCtrl:GetTimeS() - self.m_KaifuRankRewardData.playergrade.endtime) > 0 then
                    --     bOpen = false
                    -- end
                elseif v.key == "OrgRank" then
                    -- if self.m_KaifuRankRewardData and (g_TimeCtrl:GetTimeS() - self.m_KaifuRankRewardData.orgcnt.endtime) > 0 then
                    --     bOpen = false
                    -- end
                elseif v.key == "StrengthRank" then
                    -- if self.m_KaifuRankRewardData and (g_TimeCtrl:GetTimeS() - self.m_KaifuRankRewardData.playerscore.endtime) > 0 then
                    --     bOpen = false
                    -- end
                elseif v.key == "TitleRank" then
                    -- if self.m_KaifuRankRewardData and (g_TimeCtrl:GetTimeS() - self.m_KaifuRankRewardData.txendtime) > 0 then
                    --     bOpen = false
                    -- end
                elseif v.key == "SummonRank" then
                    -- if self.m_KaifuRankRewardData and (g_TimeCtrl:GetTimeS() - self.m_KaifuRankRewardData.sumendtime) > 0 then
                    --     bOpen = false
                    -- end
                end
                if bOpen then
                    local info = {idx = v.idx, key = v.key}
                    table.insert(openHuodongList, info)
                end
     		end
        else
            dOpenData = self:GetUnLockViewData(v.key)
            if dOpenData then
                local info = {idx = v.idx, key = v.key}
                table.insert(openHuodongList, info)
            end
        end
 	end 

 	return openHuodongList

end


return CCelebrationCtrl