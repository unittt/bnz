local CRankCtrl = class("CRankCtrl", CCtrlBase)

function CRankCtrl.ctor(self)	
	CCtrlBase.ctor(self)
    self.m_CurRankTypeId = nil
    self.m_CurSubTypeId = nil
    self.m_CurPage = 1
    self.m_MyRank = nil
    self.m_RankList = {}

    --开业庆典使用
    --角色等级 综合实力 宠物 帮派威望
    self.m_CelebrationRankType = {201, 202, 203, 204}
    self.m_CelebrationRankName = {[201] = "GradeRank", [202] = "StrengthRank", [203] = "SummonRank", [204] = "OrgRank"}
    self.m_NoRankShiftList = {109, 116, 222, 223, 225}
    self.m_SummonRankList = {108, 203}
    self.m_HideMyRankCid = {205, 206, 207, 208, 209, 210}
    self.m_TimeLimitList = {211} -- 限时运营活动 
    self.m_RankTotalPage = 5

    --世界杯竞猜begin
    self.m_MySuccessCount = 0
    self.m_MySuccessRate = 0
    --世界杯竞猜end
end

function CRankCtrl.GetCurRankData(self)
    if self.m_CurSubTypeId then
        return self.m_RankList[self.m_CurSubTypeId]
    end
end

function CRankCtrl.C2GSGetRankInfo(self, id, page)
    self.m_CurSubTypeId = id
    netrank.C2GSGetRankInfo(id, page)
end

function CRankCtrl.C2GSGetRankTop3(self, idx)
    self.m_CurSubTypeId = idx
    netrank.C2GSGetRankTop3(idx)
end

function CRankCtrl.C2GSGetUpvoteAmount(self, pid)
    netrank.C2GSGetUpvoteAmount(pid)    
end
                                                               
function CRankCtrl.GS2CGetRankInfo(self, info)
    -- if next(info.grade_rank) ~= nil then 
    self.m_CurPage = info.page
    -- end
    self.m_MyRank = info.my_rank
    self.m_MyRankValue = self.m_MyRankValue == -1 and info.my_rank_value --排名依据的积分或点赞数之类
    local sInfoKey = define.Rank.InfoKey[info.idx]
    -- 部分榜没rank_shift，添加0
    if table.index(self.m_NoRankShiftList, info.idx) then
        for _, v in ipairs(info[sInfoKey]) do
            v.rank_shift = 0
        end
    end

    self.m_RankList[info.idx] = info[sInfoKey]

    --worldcup begin
    if info ~= nil and info.idx == 225 then
        nethuodong.C2GSWorldCupHistory()
        self:RefreshWorldcupGuessMyRankData(info)
    end
    --worldcup end

    self:OnEvent(define.Rank.Event.UpdateRankInfo, info)
end

function CRankCtrl.RefreshWorldcupGuessMyRankData(self, info)
    printc("info.my_rank:", info.my_rank)
    self.m_MySuccessCount = 0
    self.m_MySuccessRate = 0
    if info.my_rank == nil or info.my_rank == 0 then
        --榜外
        g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn = false
    else
        --榜内
        g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn = true
        local isFind = false
        for k, v in pairs(info.worldcup_rank) do
            if k == info.my_rank then 
                isFind = true
                if v.suc_count == nil then
                    self.m_MySuccessCount = 0
                else
                    self.m_MySuccessCount = v.suc_count          
                end

                if v.suc_rate == nil then
                    self.m_MySuccessRate = 0
                else
                    self.m_MySuccessRate = v.suc_rate          
                end
            end
        end

        if isFind == false then
            --printerror("info.my_rank:", info.my_rank)
        end
    end

    printc("RefreshWorldcupGuessMyRankData g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn:", g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn)
    printc("1 g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate:", g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate, " g_RankCtrl.m_MySuccessRate:", g_RankCtrl.m_MySuccessRate)
end

function CRankCtrl.GS2CGetRankTop3(self, idx, info)
    -- if next(info) == nil then 
    --     return
    -- end 
    self:OnEvent(define.Rank.Event.UpdateMeinInfo, info)
end

function CRankCtrl.GS2CGetUpvoteAmount(self, pid, upvote)
    local info = {pid = pid, upvote = upvote}
    self:OnEvent(define.Rank.Event.UpdateMeinUpvote, info)
end

function CRankCtrl.GS2CSumBasciInfo(self, summonData)
    --table.print(summonData,"宠物基本信息：")
    g_LinkInfoCtrl:ShowSummonInfo(summonData)
    --self:OnEvent(define.Rank.Event.ShowSummonInfo, summonData)
end

function CRankCtrl.IsHideMyInfo(self, cid)
    -- body
   local bIsHideCid = false

   for i,v in ipairs(self.m_HideMyRankCid) do
        if cid == v then
            bIsHideCid = true
        end
   end
   if bIsHideCid then
        if data.schooldata.DATA[g_AttrCtrl.school].name == data.rankdata.INFO[cid].name then
            bIsHideCid = false
        end
   end
   return bIsHideCid

end

return CRankCtrl