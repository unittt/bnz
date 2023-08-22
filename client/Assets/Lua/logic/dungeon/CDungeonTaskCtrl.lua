local CDungeonTaskCtrl = class("CDungeonTaskCtrl", CCtrlBase)

function CDungeonTaskCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:InitData()
    self:Clear()
end

function CDungeonTaskCtrl.InitData(self)
    self.m_FubenTaskIds = {}
    self.m_FubenRewardDict = {
        [10001] = "FUMO",
        [10002] = "JINGSAN",
        [20001] = "FUMO_HARD",
        [20002] = "JINGSAN_HARD",
    }
    self:InitFubenTaskIds()
end

function CDungeonTaskCtrl.Clear(self)
    self.m_CurFubenTask = nil
    self.m_CurJyFubenTask = nil
    self.m_JyFubenFloor = nil
    if self.m_DelTimer then
        Utils.DelTimer(self.m_DelTimer)
        self.m_DelTimer = nil
    end
end

------------------ 侠影副本 --------------------
function CDungeonTaskCtrl.InitFubenTaskIds(self)
    local dTask = data.taskdata.TASK.FUBEN.TASK
    local sElite = "精英"
    for k, v in pairs(data.fubendata.DATA) do
        local sName = v.name
        local sHard = nil
        local sStrs = string.split(sName, "-")
        if sStrs and #sStrs > 0 then
            sName = sStrs[1]
            sHard = sStrs[2]
        end
        for id, t in pairs(dTask) do
            local sTaskName = t.name
            local taskIds = self.m_FubenTaskIds[k]
            if not taskIds then
                taskIds = {}
                self.m_FubenTaskIds[k] = taskIds
            end
            local sTaskHard = string.match(sTaskName,sElite)
            if string.match(sTaskName,sName) and sHard == sTaskHard then
                table.insert(taskIds, id)
            end
            table.sort(taskIds, function(a,b)
                return a < b
            end)
        end
    end
end

function CDungeonTaskCtrl.GetFubenTaskIds(self, iFubenId)
    return self.m_FubenTaskIds[iFubenId]
end

function CDungeonTaskCtrl.GetFubenProcess(self)
    if self:IsInCommonFuben() then
        local iFubenId = self:GetFubenId()
        local taskIds = self:GetFubenTaskIds(iFubenId)
        if not taskIds then return end
        for i, id in ipairs(taskIds) do
            if id == self.m_CurFubenTask:GetSValueByKey("taskid") then
                return i, #taskIds
            end
        end
    end
end

function CDungeonTaskCtrl.GetFubenRewards(self)
    if self:IsInCommonFuben() then
        -- local rewardStrs = self.m_CurFubenTask:GetCValueByKey("submitRewardStr")
        local sReward = self.m_CurFubenTask:GetCValueByKey("prereward")
        -- rewardStrs and rewardStrs[1]
        if sReward and string.len(sReward)>0 then
            local iFubenId = self:GetFubenId()
            local sKey = self.m_FubenRewardDict[iFubenId]
            if not sKey then
                return
            end
            -- sReward = sReward:match("R(%d+)")
            if sReward then
                return DataTools.GetRewardItems(sKey, sReward)
            end
        end
    end
end

function CDungeonTaskCtrl.GetFubenGoalDesc(self)
    if self.m_CurFubenTask then
        local sDesc = self.m_CurFubenTask:GetSValueByKey("targetdesc")
        local idx, iCnt = self:GetFubenProcess()
        if idx and iCnt then
            sDesc = string.format("%s(%d/%d)", sDesc, idx, iCnt)
        end
        return sDesc
    end
end

function CDungeonTaskCtrl.GetFubenDesc(self)
    if self.m_CurFubenTask then
        local sDesc = string.format("  #B%s#n",self.m_CurFubenTask:GetCValueByKey("description"))
        if self:IsFightTask(self.m_CurFubenTask) then
            sDesc = string.format("%s#R(准备战斗)#n", sDesc)
        end
        return sDesc
    end
end

function CDungeonTaskCtrl.GetFubenName(self)
    if self.m_CurFubenTask then
        local sName = self.m_CurFubenTask:GetCValueByKey("name")
        sName = string.gsub(sName, "#%a+", "")
        local strs = string.split(sName, "-")
        if strs and #strs > 1 then
            sName = string.format("#O%s#n#Y(%s)#n", strs[1], strs[2])
        else
            sName = string.format("#O%s#n", sName)
        end
        return sName
    end
end

function CDungeonTaskCtrl.GetFubenBossFigureId(self)
    if self.m_CurFubenTask then
        local iTarget = self.m_CurFubenTask:GetSValueByKey("target")
        if iTarget then
            local dTollgate = data.fubendata.FUBEN_TOLLGATE[iTarget]
            if not dTollgate then return end
            for i, v in ipairs(dTollgate.monster) do
                local dMon = data.fubendata.FUBEN_MONSTER[v.monsterid]
                if dMon and dMon.is_boss == 1 then
                    if dMon.name == "$npc" then
                        return self:GetTaskNpcShape(self.m_CurFubenTask)
                    end
                    return dMon.figureid
                end
                return self:GetTaskNpcShape(self.m_CurFubenTask)
            end
        end
    end
end

function CDungeonTaskCtrl.GetFubenBossDesc(self)
    if self.m_CurFubenTask then
        return self.m_CurFubenTask:GetCValueByKey("bossDesc")
    end
end

function CDungeonTaskCtrl.IsInCommonFuben(self)
    return self.m_CurFubenTask and true or false
end

function CDungeonTaskCtrl.GetFubenId(self)
    if not self.m_CurFubenTask then return end
    local iTask = self.m_CurFubenTask:GetSValueByKey("taskid")
    for k, v in pairs(self.m_FubenTaskIds) do
        for _, i in ipairs(v) do
            if i == iTask then
                return k
            end
        end
    end
end

function CDungeonTaskCtrl.ReceiveFubenTask(self, oTask)
    self.m_CurFubenTask = oTask
    self.m_CurJyFubenTask = nil
    self.m_JyFubenFloor = nil
    self:OnEvent(define.Dungeon.Event.ReceiveFubenTask)
end

function CDungeonTaskCtrl.DelFunbenTask(self)
    self.m_CurFubenTask = nil
    self.m_DelTimer = Utils.AddTimer(function()
        if not self.m_CurFubenTask then
            self:OnEvent(define.Dungeon.Event.DelFubenTask)
        end
    end, 0.2, 0)
end

function CDungeonTaskCtrl.FubenOver(self)
    self.m_CurFubenTask = nil
    self:OnEvent(define.Dungeon.Event.FubenOver)
end

----------------------- 六道传说 ------------------------
function CDungeonTaskCtrl.GetJyFubenTaskIds(self)
    if self:IsInJyFuben() then
        local iTask = self.m_CurJyFubenTask:GetSValueByKey("taskid")
        for _, dGroup in pairs(data.fubendata.JY_GROUPTASK) do
            local taskIds = dGroup.tasklist
            for _, id in ipairs(taskIds) do
                if id == iTask then
                    return taskIds
                end
            end
        end
    end
end

function CDungeonTaskCtrl.GetJyFubenProcess(self)
    local taskIds = self:GetJyFubenTaskIds()
    if taskIds then
        local iTask = self.m_CurJyFubenTask:GetSValueByKey("taskid") 
        for i, id in ipairs(taskIds) do
            if id == iTask then
                return i, #taskIds
            end
        end
    end
end

function CDungeonTaskCtrl.GetJyFubenRewards(self)
    if self:IsInJyFuben() then
        -- local iFloor = self:GetJyFubenLayer()
        -- if not iFloor then return end
        -- local iReward = data.fubendata.JY_FLOORREWARD[iFloor].reward
        local sReward = self.m_CurJyFubenTask:GetCValueByKey("prereward")
        if sReward and string.len(sReward) > 0 then
            return DataTools.GetRewardItems("JYFUBEN", sReward)
        end
    end
end

function CDungeonTaskCtrl.GetJyFubenGoalDesc(self)
    if self.m_CurJyFubenTask then
        local sDesc = self.m_CurJyFubenTask:GetSValueByKey("targetdesc")
        local idx, iCnt = self:GetJyFubenProcess()
        if idx and iCnt then
            sDesc = string.format("%s(%d/%d)", sDesc, idx, iCnt)
        end
        return sDesc
    end
end

function CDungeonTaskCtrl.GetJyFubenDesc(self)
    if self.m_CurJyFubenTask then
        local sDesc = string.format("  #B%s#n",self.m_CurJyFubenTask:GetCValueByKey("description"))
        if self:IsFightTask(self.m_CurJyFubenTask) then
            sDesc = string.format("%s#R(准备战斗)#n", sDesc)
        end
        return sDesc
    end
end

function CDungeonTaskCtrl.GetJyFubenFloorName(self)
    if self:IsInJyFuben() then
        local sFloor = string.printInChinese(self.m_JyFubenFloor)
        return string.format("#Y第%s层 %s#n", sFloor, self.m_CurJyFubenTask:GetCValueByKey("name"))
    end
end

function CDungeonTaskCtrl.GetJyFubenBossFigureId(self)
    if self.m_CurJyFubenTask then
        local iTarget = self.m_CurJyFubenTask:GetSValueByKey("target")
        if iTarget then
            local iFight = 0
            local dEvent = data.fubendata.JY_TASKEVENT[iTarget]
            local answers = dEvent and dEvent.answer
            iFight = answers and answers[1]
            iFight = iFight and string.match(iFight, "%d+")
            local dTollgate = iFight and data.fubendata.JYFUBEN_TOLLGATE[tonumber(iFight)]
            if not dTollgate then return end
            for i, v in ipairs(dTollgate.monster) do
                local dMon = data.fubendata.JYFUBEN_MONSTER[v.monsterid]
                if dMon and dMon.is_boss == 1 then
                   if dMon.name == "$npc" then
                        return self:GetTaskNpcShape(self.m_CurJyFubenTask)
                    end
                    return dMon.figureid
                end
                return self:GetTaskNpcShape(self.m_CurJyFubenTask)
            end
        end
    end
end

function CDungeonTaskCtrl.GetJyFubenBossDesc(self)
    if self.m_CurJyFubenTask then
        return self.m_CurJyFubenTask:GetCValueByKey("bossDesc")
    end
end

function CDungeonTaskCtrl.IsInJyFuben(self)
    local dMap = DataTools.GetMapInfo(g_MapCtrl.m_MapID)
    local bInJyFubenScene = dMap and dMap.virtual_game == "jyfuben"
    return bInJyFubenScene and self.m_CurJyFubenTask and self:GetJyFubenLayer() > 0
end

function CDungeonTaskCtrl.GetJyFubenLayer(self)
    if not self.m_JyFubenFloor and self.m_CurJyFubenTask then
        local extInfo = self.m_CurJyFubenTask:GetSValueByKey("ext_apply_info")
        if extInfo and next(extInfo) then
            for _, v in ipairs(extInfo) do
                if v.key == "floor" then
                    self.m_JyFubenFloor = v.value
                    break
                end
            end
        end
    end
    return self.m_JyFubenFloor or -1
end

function CDungeonTaskCtrl.ReceiveJyFubenTask(self, oTask)
    self.m_CurJyFubenTask = oTask
    self.m_CurFubenTask = nil
    if self:IsInJyFuben() then
        self:OnEvent(define.Dungeon.Event.ReceiveJyFubenTask)
    end
end

function CDungeonTaskCtrl.DelJyFunbenTask(self)
    self.m_CurJyFubenTask = nil
    self.m_DelTimer = Utils.AddTimer(function()
        if not self.m_CurJyFubenTask then
            self:OnEvent(define.Dungeon.Event.DelFubenTask)
        end
    end, 0.2, 0)
end

function CDungeonTaskCtrl.UpdateJyFubenFloor(self, name, floor)
    self.m_JyFubenFloor = floor
    self:OnEvent(define.Dungeon.Event.ReceiveJyFubenTask)
end

function CDungeonTaskCtrl.JyFubenOver(self)
    self.m_CurJyFubenTask = nil
    self.m_JyFubenFloor = nil
    self:OnEvent(define.Dungeon.Event.JyFubenOver)
end

---------------------- task ------------------------
function CDungeonTaskCtrl.IsFightTask(self, oTask)
    if oTask and oTask:GetSValueByKey("tasktype")==define.Task.TaskType.TASK_NPC_FIGHT then
        return true
    end
    return false
end

function CDungeonTaskCtrl.GetTaskNpcShape(self, oTask)
    if oTask then
        local npcs = oTask:GetSValueByKey("clientnpc")
        if npcs and #npcs > 0 then
            return npcs[1].model_info.figure
        end
    end
end

function CDungeonTaskCtrl.IsInFuben(self)
    return self:IsInCommonFuben() or self:IsInJyFuben()
end

return CDungeonTaskCtrl