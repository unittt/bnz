local CPlot = class("CPlot")

CPlot.TriggerType = {
	Unknown = 0,				--未知
	FirstEnter = 1,				--首次进入
	AcceptMission = 2,			--接受任务
	SubmitMission = 3,			--提交任务
	TalkToMissionSubmitNpc = 4, --点击提交NPC
	TollgateWin = 5,			--关卡胜利
	PlotPlayerOver = 6,			--剧情播放完
}

CPlot.EntEventType = {
	 -- 0 未知
    Unknown = 0;
    -- 1 战斗
    Battle = 1;
    -- 2 接受任务
    AcceptMission = 2;
    -- 3 进场景
    EnterScene = 3;
    -- 4 进入门派场景的默认点
    EnterFactionScene = 4;
    -- 5 剧情
    Plot = 5;
}

function CPlot.ctor(self, dInfo)
    -- 编号 int
    self.m_Id = dInfo.id or -1
    
    -- 名称 string
    self.m_Name = dInfo.name or "无"
    
    -- 能否跳过 bool
    self.m_Skipable = dInfo.skipable or true
    
    -- 触发类型 enum
    self.m_TriggerType = dInfo.triggerType or 0
    
    -- 触发参数 list
    self.m_TriggerParam = dInfo.triggerParam or {}
    
    -- 剧情结束事件 event?callback
    -- public PlotEndEvent plotEndEvent;
    self.m_PlotEndEvent = dInfo.plotEndEvent or 0
    
    -- 剧情是否播放 bool
    self.m_Show = dInfo.show or false
end

function CPlot.IsShow(self)
	return self.m_Show
end

return CPlot