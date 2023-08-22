local CBonfireCtrl = class("CBonfireCtrl", CCtrlBase)

function CBonfireCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Reset()
end

function CBonfireCtrl.Reset(self)
    self.m_BonfireEffect = nil
    self.m_CurRemainTime = 0
    self.m_CurTopicInfo = {}
    self.m_CurAnswerRound = 0
    self.m_CurQuestionState = 0
    self.m_CurActiveState = 0
    self.m_DrinkBuffAdds = nil
    self.m_GetGiftList = {}
    self.m_AddFriendList = {}
    self.m_IsBonfireScene = false

    self.m_CampfireInfo = nil
end

function CBonfireCtrl.C2GSCampfireDrink(self, amount)
    nethuodong.C2GSCampfireDrink(amount)
end 

function CBonfireCtrl.C2GSCampfireAnswer(self, id, answer, fill_answer)
    nethuodong.C2GSCampfireAnswer(id, answer, fill_answer)
end 

function CBonfireCtrl.C2GSCampfireToGift(self, pid)
    nethuodong.C2GSCampfireGiftOut(pid, 0)
end 

function CBonfireCtrl.C2GSCampfireQueryGiftables(self)
    nethuodong.C2GSCampfireQueryGiftables()
end  

function CBonfireCtrl.C2GSCampfireThankGift(self, pid)
    nethuodong.C2GSCampfireThankGift(pid)
end

function CBonfireCtrl.GS2CCampfirePreOpen(self, time)
    if self.m_IsBonfireScene  then
        return
    end
    self.Time = time
    -- if self.m_UpdateTimer then
    --     Utils.DelTimer(self.m_UpdateTimer)
    -- end
    -- self.m_CurRemainTime = time
    -- local view = CScheduleNotifyView:GetView()
    -- if view then
    --     view:GetData(time)
    -- else
    --     CScheduleNotifyView:ShowView(function (oView)
    --         oView:SetInfo(time)
    --     end)
    -- end
    -- local function update()
    --     if self.m_CurRemainTime <= 0 then
    --         return false
    --     end
    --     self.m_CurRemainTime = self.m_CurRemainTime - 1
    --     return true
    -- end 
    -- self.m_UpdateTimer = Utils.AddTimer(update, 1, 0)
    self:LocaFunc()
end

function  CBonfireCtrl.LocaFunc(self)
    --printc("玩家有帮派,可以参加")

    local function onsure()
        if g_AttrCtrl.org_id == 0 then
            --printc("玩家没有参加帮派")
            g_ScheduleCtrl:GS2COpenScheduleUI(1018)
            return
        end
        -- body
        -- printc("======调用了这个方法====")
        
        -- if g_AttrCtrl.org_id == 0 then
        --     g_NotifyCtrl:FloatMsg("您当前没有帮派，快去加入一个帮派吧！")
        --     CScheduleNotifyView:OnClose()
        --     CJoinOrgView:ShowView()
        --     return
        -- end
        local dSchedule = data.scheduledata.SCHEDULE[1018]
        nethuodong.C2GSEnterOrgHuodong(dSchedule.flag)


        if g_LimitCtrl:CheckIsLimit(true) then
            CScheduleNotifyView:OnClose()
            return
        end

        if g_LimitCtrl:CheckIsCannotMove() then
            CScheduleNotifyView:OnClose()
            return
        end
    
        local view = CMainMenuView:GetView()
        if view and self.m_IsBonfireScene then
            view:JoinBonfire()
        end
    end

    local notifyinfo ={
                namespr = data.scheduledata.SCHEDULE[1018].title,
                id = 1018,
                time = self.Time,
                joinbtncb = onsure,
                    }
    if g_AttrCtrl.grade < data.scheduledata.SCHEDULE[1018].level then
        return
    end 
    g_ScheduleCtrl:SetNotifyViewInfo(notifyinfo)

end
--GS2CCampfireInfo
function CBonfireCtrl.GS2CCampfireInfo(self, info)
    self.m_CampfireInfo = info
    local dDecode = g_NetCtrl:DecodeMaskData(info,"bonfire")
    if dDecode.drink_buff_adds then
        self.m_DrinkBuffAdds = info.drink_buff_adds
        self:OnEvent(define.Bonfire.Event.UpdateBonfireExp, info.drink_buff_adds)
    end
    -- if g_WarCtrl:IsWar() then
    --     printc("战斗中")
    --     return
    -- end
    if dDecode.state then
        self.m_CurActiveState = info.state
    end
    local mainView = CMainMenuView:GetView()
    if info.state == 1 then
        self.m_IsInBonfire = true
        printc("准备")
        --local view = CBonfireHintView:GetView()
        if self.m_IsInBonfire and self.m_IsInBonfireScene then
            self:ShowBonfireView()
            if info.lefttime < 0 then return end
            self:OnEvent(define.Bonfire.Event.UpdateLeftTime, info)
        else
            if g_OpenSysCtrl:GetOpenSysState("ORG_SYS") then --------------帮派系统是否解锁
               -- if view then
                  --  view.m_HintBox:SetActive(true)
                
                    -- CBonfireHintView:ShowView(function (oView)
                    --     oView.m_HintBox:SetActive(true) 
                    -- end)
                self:LocaFunc()
               -- end
            end
        end


    elseif info.state == 2 then

        printc("开始")
        self.m_IsInBonfire = true
        if self.m_IsBonfireScene and self.m_IsInBonfireScene then
            self:ShowBonfireView() 
            if info.lefttime < 0 then return end
            self:OnEvent(define.Bonfire.Event.UpdateLeftTime, info)
        end 
        if self.m_UpdateTimer then
            Utils.DelTimer(self.m_UpdateTimer)
        end

    elseif info.state == 3 then
        printc("结束")
        self.m_IsBonfireScene = false
        self.m_IsInBonfire = false
        if self.m_UpdateTimer then
            Utils.DelTimer(self.m_UpdateTimer)
        end
        if mainView then
            mainView:EndBonfire()
        end
        self.m_CurRemainTime = -1
        self:OnEvent(define.Bonfire.Event.EndBonfireActive)
    end
   -- end
end 

function CBonfireCtrl.GS2CCampfireQuestion(self, info)
    self.m_CurTopicInfo = info
    self.m_CurQuestionState = 1
    self.m_CurTopicTime = self.m_CurTopicInfo.time
    local function update()
        if self.m_CurTopicTime <= 0 then
            return false
        end
        self.m_CurTopicTime = self.m_CurTopicTime - 1
        return true
    end
    if self.m_DoneTimer then
        Utils.DelTimer(self.m_DoneTimer)
    end
    self.m_DoneTimer = Utils.AddTimer(update, 1, 0)
    self:OnEvent(define.Bonfire.Event.UpdateQuestion, info)
end 


function CBonfireCtrl.GS2CCampfireCorrectAnswer(self, info)
    self:OnEvent(define.Bonfire.Event.UpdateBonfireAnswer, info)
end 

function CBonfireCtrl.GS2CCampfireGotGift(self, info)
    local view = CBonfireGetItemView:GetView()
    if view then
        table.insert(self.m_GetGiftList, info) 
    else
        CBonfireGetItemView:ShowView(function (oView)
            oView:SetInfo(info)
        end)
    end
end 

function CBonfireCtrl.GS2CCampfireShowGiftables(self, info)
    -- if info == nil or next(info) == nil then
    --     g_NotifyCtrl:FloatMsg("暂无符合条件的玩家！")
    --     return
    -- end
    
    local view = CBonfireGiveView:GetView()
    if view then
        view:InitGrid(info.players)
    else
        CBonfireGiveView:ShowView(function (oView)
            oView:InitGrid(info.players)
        end)
    end
end 

function CBonfireCtrl.PlayEffect(self, pos)
    -- printc("播放特效")
    if self.m_BonfireEffect == nil then
        local path = "Effect/Scene/scene_eff_0023/Prefabs/scene_eff_0023.prefab"
        self.m_BonfireEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
        self.m_BonfireEffect:SetPos(Vector3.New(15, 7, 0))
    end
end

function CBonfireCtrl.GS2CCampfireInHuodongScene(self, info)
    local mainView = CMainMenuView:GetView()
    if info == 1 then
        self.m_IsBonfireScene = true
        self.m_IsInBonfireScene = true
        self.m_CurRemainTime = -1
        -- printc("在帮派场景中")
        if self.m_CurActiveState == 1 or self.m_CurActiveState == 2 then
            self:ShowBonfireView()
        end
    else
        if self.m_UpdateTimer then
            Utils.DelTimer(self.m_UpdateTimer)
        end
        if mainView then
            mainView:EndBonfire()
        end
        self.m_IsBonfireScene = false
        self.m_IsInBonfireScene = false
        --self.m_CurQuestionState = 3 --退出帮派场景
    end
    self:OnEvent(define.Bonfire.Event.SwitchScene, info)
end

function CBonfireCtrl.GS2CCampfireQuestionState(self, info)
    local cur_round = info.cur_round --当前轮次（0=未开始，正整数=当前轮次）
    local total_round = info.total_round --总轮次
    local answered = info.answered --是否答过
    local state = info.state
    local correct_cnt = info.correct_cnt
    self.m_CurQuestionInfo = info
    self.m_CurAnswerRound = cur_round
    if state == 3 then
        self.m_CurQuestionState = 2 --答题结束
        return    
    end
    if cur_round == 0 then 
        self.m_CurQuestionState = 0 --未开始
    elseif answered == 1 then
        if total_round ~= cur_round then
            self.m_CurQuestionState = 1 --答题未结束等待下一题
        else
            self.m_CurQuestionState = 2 --答题结束
        end
    else 
        self.m_CurQuestionState = 3 --服务器推送题目
    end    
end

function CBonfireCtrl.GS2CCampfireThankGift(self, id, playerName)
    if not g_FriendCtrl:IsMyFriend(id) then
        local view = CBonfireAddFriendView:GetView()
        local info = {pid = id, name = playerName}
        if view then
            table.insert(g_BonfireCtrl.m_AddFriendList, info)
        else
            CBonfireAddFriendView:ShowView(function (oView)
                -- printc("添加好友")
                oView:SetInfo(info)
            end)
        end
     end
end

function CBonfireCtrl.GS2CCampfireGiftTimes(self, info)
    self.m_GivenTimes = info
    self:OnEvent(define.Bonfire.Event.GiftTimes, info)
end

function CBonfireCtrl.ShowBonfireView(self)
    local view = CBonfireHintView:GetView()
    local mainView = CMainMenuView:GetView()
    if view then
        view.m_HintBox:SetActive(false)
    else
        CBonfireHintView:ShowView(function (oView)
            oView.m_HintBox:SetActive(false) 
        end)
    end
    if mainView then
        mainView:JoinBonfire()
    end
end

function CBonfireCtrl.IsShowAnswerView(self)
    if next(self.m_CurTopicInfo) and self.m_IsBonfireScene and 
    self.m_CurActiveState == 2 then
        return true
    else
        return false
    end
end

return CBonfireCtrl