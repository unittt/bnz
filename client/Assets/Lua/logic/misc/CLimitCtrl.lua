local CLimitCtrl = class("CLimitCtrl", CCtrlBase)

function CLimitCtrl.ctor(self)
	CCtrlBase.ctor(self)
end

function CLimitCtrl.CheckIsLimit(self, bIsFloat, bIsTeamFloat)
	--跳舞允许操作
	-- if g_DancingCtrl.m_StateInfo then
	--     -- printc("舞会禁止移动")
	--     if bIsFloat then
	--      	g_NotifyCtrl:FloatMsg("你正在舞会中，不可以操作哦")
	--     end
	--     return true
 --    end
    if g_PlotCtrl:IsPlaying() then
    	return true
    end
    if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
    	if bIsTeamFloat then
			g_NotifyCtrl:FloatMsg("组队状态下只有队长可操作")
		end
		return true
	end
end

function CLimitCtrl.CheckDance(self, bIsFloat)
	--跳舞允许操作
	-- if g_DancingCtrl.m_StateInfo then
	--     -- printc("舞会禁止移动")
	--     if bIsFloat then
	--      	g_NotifyCtrl:FloatMsg("你正在舞会中，不可以操作哦")
	--     end
	--     return true
 --    end
    return false
end

function CLimitCtrl.CheckTeam(self, bIsFloat)
	if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
    	if bIsFloat then
			g_NotifyCtrl:FloatMsg("组队状态下只有队长可操作")
		end
		return true
	end
	return false
end

function CLimitCtrl.CheckPlot(self, bIsFloat)
	if self:CheckWedding() then
		return true
	elseif g_PlotCtrl:IsPlaying() then
		if bIsFloat then
			g_NotifyCtrl:FloatMsg("剧情中不可操作")
		end
    	return true
    end
    return false
end

function CLimitCtrl.CheckIsCannotMove(self)
	if self:CheckWedding() then
		return true
	elseif g_MapCtrl.m_IsFlyWaterProgress then
		g_NotifyCtrl:FloatMsg("踏浪中不可进行操作！")
		return true
	end
end

function CLimitCtrl.CheckWedding(self)
	if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
		if g_MarryCtrl:IsInMyWedding() then
			g_NotifyCtrl:FloatMsg("你正在和伴侣拜堂成亲，要专心一点哟")
		else
			g_NotifyCtrl:FloatMsg("婚礼进行中不可操作")
		end
		return true
	end
	return false
end

function CLimitCtrl.CheckIsCannotFly(self)
	if g_MapCtrl.m_MapID == g_OrgMatchCtrl.m_MatchMapId then
		g_NotifyCtrl:FloatMsg("此地有飞行管制，禁止飞行")
		return true
	end
end

function CLimitCtrl.CheckIsInFight(self, oFloatMsg)
	if g_WarCtrl:IsWar() then
		if oFloatMsg then
			g_NotifyCtrl:FloatMsg(oFloatMsg)
		end
		return true
	end
end

return CLimitCtrl