local CDancingCtrl = class("CDancingCtrl", CCtrlBase)

function CDancingCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self.m_StateInfo = nil
    self.m_AttendNum = nil
    self.m_dancingStateId = 1002
    self.m_RideId = nil
    self.m_dancingId = 1016
    self.m_DanceLeftTime = 0

    self.danceTimer = {}
end

function CDancingCtrl.Clear(self)
    self.m_StateInfo = nil
    self.m_DanceLeftTime = 0
    for k,v in pairs(self.danceTimer) do
        Utils.DelTimer(v)
    end
    self.danceTimer = {}
end

function CDancingCtrl.GS2CDanceStart(self, time)
    -- local hero = g_MapCtrl:GetHero()
    -- hero:StopWalk()
    -- CDancingActivityView:ShowView(function(oView)
    --     oView:RefreshDancing(self.m_AttendNum,time)
    -- end)
end

------------------协议返回------------------

function CDancingCtrl.LoginDancingState(self, stateInfo)
    self.m_StateInfo = nil
    for i,v in pairs(stateInfo) do
        if v.state_id == self.m_dancingStateId then
            --printc("denglu舞会状态---")
            self.m_StateInfo = v
        end
    end 
    if self.m_StateInfo then
        self:SetDanceCountTime(self.m_StateInfo.time)
        --暂时屏蔽
        -- CDancingActivityView:ShowView()
        g_DancingCtrl:AddTip()
    else
        g_DancingCtrl:DelTip()
    end
    self:OnEvent(define.Dancing.Event.DanceStateUpdate)
end

function CDancingCtrl.AddDancingState(self, stateInfo)
    if stateInfo.state_id ~= self.m_dancingStateId then
        return
    end
    if stateInfo.state_id == self.m_dancingStateId then
        --printc("zengjia舞会状态---")
        self.m_StateInfo = stateInfo
    end
    if self.m_StateInfo then
        self:SetDanceCountTime(self.m_StateInfo.time)
        --暂时屏蔽
        -- CDancingActivityView:ShowView()
        g_DancingCtrl:AddTip()
    end
    self:OnEvent(define.Dancing.Event.DanceStateUpdate)
end

function CDancingCtrl.RemoveDancingState(self, stateID)
    if stateID ~= self.m_dancingStateId then
        return
    end
    if stateID == self.m_dancingStateId then
        self.m_StateInfo = nil
    end
    self:ResetDanceTimer()
    self.m_DanceLeftTime = 0
    self:OnEvent(define.Dancing.Event.DanceCount)
    self:OnEvent(define.Dancing.Event.DanceStateUpdate)
    --暂时屏蔽
    -- CDancingActivityView:CloseView()
    g_DancingCtrl:DelTip()
    --询问下一次
    self:StartNext()
end

function CDancingCtrl.GS2CDanceLeftCnt(self, num)
    self.m_AttendNum = num
    --printc("剩余参与次数：",self.m_AttendNum)
end

function CDancingCtrl.GS2CDanceDoubleReward(self, pbdata)
    -- local oHero = g_MapCtrl:GetHero()
    if not g_WarCtrl:IsWar() then
        if pbdata.double == 1 then
            -- oHero:ShowDamage(pbdata.exp, true, true)
            g_NotifyCtrl:FloatMsg("参与舞动全城幸运暴击获得#G"..pbdata.exp.."#n#cur_6")
        else
            -- oHero:ShowDamage(pbdata.exp, false, true)
            g_NotifyCtrl:FloatMsg("参与舞动全城获得#G"..pbdata.exp.."#n#cur_6")
        end
    end
end

---------------------------------------------

--开始跳舞状态
function CDancingCtrl.AddDanceTip(self, oPlayer, shapid)
    if not oPlayer.m_IsWalking and g_MapCtrl:CheckInDanceArea(oPlayer) and not oPlayer.m_DanceTimer and oPlayer.m_IsInDanceState then
        oPlayer.m_DanceDelayTime = 0
        oPlayer:TurnInDanceState()
    end
end

--移除跳舞状态
function CDancingCtrl.DelDanceTip(self, oPlayer)
    if oPlayer then       
        if oPlayer.m_Actor then
            oPlayer.m_Actor:Play("idleCity")
            oPlayer:ResetShadowPos()
        end
        oPlayer:DelBindObj("dancer")
        if oPlayer.m_DanceTimer then
            Utils.DelTimer(oPlayer.m_DanceTimer)
            oPlayer.m_DanceTimer = nil
        end
    end
    --角色正常状态
    -- if self.danceTimer[oPlayer.m_Pid] then
    --    Utils.DelTimer(self.danceTimer[oPlayer.m_Pid])
    --    self.danceTimer[oPlayer.m_Pid] = nil
    -- end
end

--点击确定界面的确定按钮
function CDancingCtrl.AttendDancing()
    local dancingData = data.dancedata.CONDITION[1]
    local itemNum = g_ItemCtrl:GetBagItemAmountBySid(dancingData.cost.itemid)
    local num = g_DancingCtrl.m_AttendNum or 5
    if num <= 0 then
        local windowConfirmInfo = {msg ="今日参与次数已满，少侠请改日再来",title = "提示"}
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
        return
    elseif (g_ScheduleCtrl.m_SvrActivePoint or 0) < data.dancedata.CONDITION[1].active_point then
        g_NotifyCtrl:FloatMsg("您当前活跃度未达到#G"..data.dancedata.CONDITION[1].active_point.."#n，无法参加舞动全城活动")
        return
    end
    -- local rideId = g_AttrCtrl.model_info.horse
    -- if rideId and  rideId ~= 0 then
    --    g_NotifyCtrl:FloatMsg("骑乘坐骑时不可跳舞，请先下坐骑")
    -- end

    --暂时屏蔽
    -- if g_HorseCtrl.m_isUseRide then
    --     g_HorseCtrl:C2GSUseRide(g_HorseCtrl.use_ride, 0)
    -- end
    --local activityData = data.scheduledata.SCHEDULE[1016]
    if itemNum < dancingData.cost.amount  then
        -- local windowConfirmInfo = {msg ="缺少道具舞会邀请函，请确认包裹中是否拥有参与道具",title = "提示"}
        -- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
        local itemlist = {{sid = dancingData.cost.itemid, count = itemNum, amount = 1}}
        g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
            nethuodong.C2GSDanceStart(1)
        end)
        return
    end
    nethuodong.C2GSDanceStart()
end

--判断是否显示舞会图标
function CDancingCtrl.IsShowDanceIcon(self, bInArea, bFloat)
    --printc("----判断是否显示舞会图标--",bInArea)
    if bInArea == false then
        return false
    end
    local dancingData = data.dancedata.CONDITION[1]
    local itemNum = g_ItemCtrl:GetBagItemAmountBySid(dancingData.cost.itemid)
    --local activityData = data.scheduledata.SCHEDULE[1016]
    if g_AttrCtrl.grade < dancingData.grade then
        if not self.m_StateInfo and bFloat then
            g_NotifyCtrl:FloatMsg("人物当前等级未达到"..data.scheduledata.SCHEDULE[self.m_dancingId].level.."级，无法参与舞动全城活动")
        end
        return false
    end
    --暂时屏蔽
    -- if itemNum < dancingData.cost.amount  then
    --    if not self.m_StateInfo and bFloat then
    --       g_NotifyCtrl:FloatMsg("你身上缺少舞会邀请函，无法参与舞动全城活动")
    --    end
    --    return false
    -- end
    local num = g_DancingCtrl.m_AttendNum  or 5
    if num <= 0 then
        if not self.m_StateInfo and bFloat then
            g_NotifyCtrl:FloatMsg("今天已经跳到脚软了，明天再来吧")
        end
        return false
    end
    return true
end

------------跳舞逻辑----------

--继续下一次
function CDancingCtrl.StartNext(self)
    local oHero = g_MapCtrl:GetHero()
    if not (oHero and g_MapCtrl:CheckInDanceArea(oHero)) then
        return
    end
    --暂时屏蔽
    -- CDancingActivityView:CloseView()  --关闭ui
    local countTime = 10
    local timer = nil
    local closeUI = function ()
        CDialogueOptionView:CloseView()
        CItemQuickUseView:CloseView()
        CTaskItemQuickUseView:CloseView()
        if timer then
            Utils.DelTimer(timer)
            timer = nil
        end
        local oHero = g_MapCtrl:GetHero()
        if oHero then

            if g_MapCtrl:CheckInDanceArea(oHero) then
                g_DancingCtrl:AttendDancing()
            else
                local function onCallback()
                    CDanceWindowView:ShowView()
                end
                g_MapTouchCtrl:CrossMapPos(101000, Vector3.New(32, 30, 0), nil, define.Walker.Npc_Talk_Distance, onCallback)
            end
        end
        end
        local cancel = function () 
        if timer then
            Utils.DelTimer(timer)
            timer = nil
        end
        return false
    end

    local start = function() 
        --printc("倒计时：",countTime)
        local windowConfirmInfo = {
        msg = "舞会欢庆结束，是否继续参与？",
        okCallback = closeUI,
        pivot = enum.UIWidget.Pivot.Center ,
        okStr = "确定".."("..countTime..")",
        cancelCallback = cancel
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
        if countTime <= 0 then
            local view = CWindowComfirmView:GetView()
            if view then
                view:CloseView()
            end 
            g_DancingCtrl:AttendDancing()   --倒计时为0，判断还可以参与吗
            if timer then
                Utils.DelTimer(timer)
                timer = nil
            end
        end
        countTime = countTime - 1
        return true
    end

    timer = Utils.AddTimer(start,1,0)
end

--开始跳舞状态
function CDancingCtrl.AddTip(self)
    if not self.m_StateInfo then
        return
    end
    local role = g_MapCtrl:GetHero()
    if not role then
        return
    end
    if not role.m_IsWalking and g_MapCtrl:CheckInDanceArea(role) and not role.m_DanceTimer then
        role.m_DanceDelayTime = 0
        role:TurnInDanceState()
    end 
end

function CDancingCtrl.ResetDancingAnimTime(self)
    if not self.m_StateInfo then
        return
    end
    local role = g_MapCtrl:GetHero()
    if not role then
        return
    end
    role:DelBindObj("dancer")
    if role.m_DanceTimer then 
        Utils.DelTimer(role.m_DanceTimer)
        role.m_DanceTimer = nil
    end
    if g_MapCtrl:CheckInDanceArea(role) and not role.m_DanceTimer then --not role.m_IsWalking and
        role.m_DanceDelayTime = data.dancedata.CONDITION[1].ridetime
        role:TurnInDanceState()
    end
end

--移除跳舞状态
function CDancingCtrl.DelTip(self)
    local hero = g_MapCtrl:GetHero()
    if hero then       
        if hero.m_Actor then
            hero.m_Actor:Play("idleCity")
            hero:ResetShadowPos()
        end
        hero:DelBindObj("dancer")
        if hero.m_DanceTimer then
            Utils.DelTimer(hero.m_DanceTimer)
            hero.m_DanceTimer = nil
        end
    end
    -- if g_DancingCtrl.m_RideId then
    --    g_HorseCtrl:C2GSUseRide(g_DancingCtrl.m_RideId, 1)
    -- end
    --角色正常状态
    -- if self.dance_timer then
    --    Utils.DelTimer(self.dance_timer)
    --    self.dance_timer = nil
    -- end
end

-- 舞会结束
-- function CDancingCtrl.DancingOver(self)
--     if self.dance_timer then
--        Utils.DelTimer(self.dance_timer)
--        self.dance_timer = nil
--     end
--     self:DelTip()
--     self:StartNext()
-- end

-- 跳舞的倒计时
function CDancingCtrl.SetDanceCountTime(self, setTime)  
    self:ResetDanceTimer()
    local function progress()
        self.m_DanceLeftTime = self.m_DanceLeftTime - 1

        self:OnEvent(define.Dancing.Event.DanceCount)

        if self.m_DanceLeftTime <= 0 then
            self.m_DanceLeftTime = 0

            self:OnEvent(define.Dancing.Event.DanceCount)

            return false
        end
        return true
    end
    self.m_DanceLeftTime = setTime + 1
    self.m_DanceCountTimer = Utils.AddTimer(progress, 1, 0)
end

function CDancingCtrl.ResetDanceTimer(self)
    if self.m_DanceCountTimer then
        Utils.DelTimer(self.m_DanceCountTimer)
        self.m_DanceCountTimer = nil      
    end
end

return CDancingCtrl