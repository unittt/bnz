local COrgMatchCtrl = class("COrgMatchCtrl", CCtrlBase)

function COrgMatchCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_MyRank = 0
	self.m_MyScore = 0
	self.m_ActionPoint = 0
	self.m_OrgDetailInfoList = {}
	self.m_TeamList = {}
	self.m_SingleList = {}
	self.m_StartTime = 0
	self.m_PreMapId = 504000 --准备厅地图
	self.m_MatchMapId = 505000 --战斗地图
end

--------------------------Set Data-----------------------------------
function COrgMatchCtrl.SetActionPoint(self, iActionPoint)
	self.m_ActionPoint = iActionPoint
	self:OnEvent(define.OrgMatch.Event.RefreshActionPoint)
end

function COrgMatchCtrl.SetStartTime(self, iStartTime)
	self.m_StartTime = iStartTime
	self:OnEvent(define.OrgMatch.Event.RefreshPreTime)
end

function COrgMatchCtrl.SetOrgDetailInfo(self, lOrgInfo)
	self.m_OrgDetailInfoList = lOrgInfo
	self:OnEvent(define.OrgMatch.Event.RefreshOrgDetailInfo)
end

function COrgMatchCtrl.SetMapTeamInfo(self, lSingle, lTeam)
	self.m_SingleList = {}
	self.m_TeamList = {}
	for i,player in ipairs(lSingle) do
		if player.pid ~= g_AttrCtrl.pid then
			table.insert(self.m_SingleList, player)
		end
	end
	for i,team in ipairs(lTeam) do
		if team.team_id ~= g_TeamCtrl.m_TeamID then
			table.insert(self.m_TeamList, team)
		end
	end
	self:OnEvent(define.OrgMatch.Event.RefreshTeamInfo)
end

function COrgMatchCtrl.SetOrgMatchList(self, lOrgMatch)
	self.m_OrgMatchList = lOrgMatch 
	self:OnEvent(define.OrgMatch.Event.RefreshOrgMatchList)
end

-------------------------Get Data-------------------------------------
function COrgMatchCtrl.GetActionPoint(self)
	return self.m_ActionPoint
end

function COrgMatchCtrl.GetMyRank(self)
	return self.m_MyRank
end

function COrgMatchCtrl.GetMyScore(self)
	return self.m_MyScore
end

function COrgMatchCtrl.GetTeamList(self)
	return self.m_TeamList
end

function COrgMatchCtrl.GetSingleList(self)
	return self.m_SingleList
end

function COrgMatchCtrl.GetTeamCount(self)
	return #self.m_TeamList
end

function COrgMatchCtrl.GetSingleCount(self)
	return #self.m_SingleList
end

function COrgMatchCtrl.GetOrgMatchList(self)
	return self.m_OrgMatchList
end

function COrgMatchCtrl.GetOrgDetailInfo(self)
	return self.m_OrgDetailInfoList
end

function COrgMatchCtrl.GetMatchStartTime(self)
	return self.m_StartTime
end

function COrgMatchCtrl.GetHuodongNpcInfo(self, isPrepare)

    local config = data.huodongdata.ORGWARNPC
    local infoList = {}
    for k, v in pairs(config) do 
        if isPrepare then 
        	if v.mapid == self.m_PreMapId then  
	            local info = {}
	            info.id = v.id
	            info.name = v.name
	            info.x = v.x
	            info.y = v.y
	            info.z = v.z
	            table.insert(infoList, info)
        	end 
        else
        	if v.mapid == self.m_MatchMapId and v.id >= 5004 then  
	            local info = {}
	            info.id = v.id
	            info.name = v.name
	            info.x = v.x
	            info.y = v.y
	            info.z = v.z
	            table.insert(infoList, info)
        	end 
        end 
    end 
    return infoList

end 

---------------------------------------------------------------------
return COrgMatchCtrl