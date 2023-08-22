local CFlyRideAniCtrl = class("CFlyRideAniCtrl", CCtrlBase)


function CFlyRideAniCtrl.ctor(self)

    CCtrlBase.ctor(self)
    self.m_AnimCb = nil
    self.m_IsFlying = false

    self.m_SkyCloudEffect = nil
    self.m_SkyCloudRender = nil

end

--请求飞行
function CFlyRideAniCtrl.RequestFly(self, cb)

    if not g_HorseCtrl.use_ride then 
        return
    end 

    if self.m_IsFlying then 
        return
    end 

    self.m_AnimCb = cb

    if  g_AttrCtrl:GetHeroFlyState() == define.FlyRide.FlyState.Ground then 

        netride.C2GSSetRideFly(g_HorseCtrl.use_ride, 1)

    elseif  g_AttrCtrl:GetHeroFlyState() == define.FlyRide.FlyState.Fly then 

        netride.C2GSSetRideFly(g_HorseCtrl.use_ride, 0)

    end 

    self.m_IsFlying = true
 
end

function CFlyRideAniCtrl.CheckInTeam(self, walker)
    
    if walker.m_TeamID then 
        self:TeamHandle(walker.m_TeamID)
    end 

end

function CFlyRideAniCtrl.TeamHandle(self, teamId, doAni, cb)

    --找出队长
    local pList =  g_MapCtrl.m_Teams[teamId]
    local leader = g_MapCtrl.m_Players[pList[1]]

    if not leader then 
        return
    end 

    self:TryFly(leader)

end


function CFlyRideAniCtrl.RespondFly(self, walker, doAni, cb)
    
    local fun = function ( ... )
        
        if cb then 
            cb()
        end 

        if self.m_AnimCb then
            self.m_IsFlying = false
            self.m_AnimCb()
            self.m_AnimCb = nil
        end 

    end

    self:TryFly(walker, doAni, fun)

end

--飞行
function CFlyRideAniCtrl.TryFly(self, walker, doAni, cb)
    if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
        return
    end
    --data
    if walker.m_TeamID then 
        --找出队长
        local leader = g_MapCtrl:GetTeamLeader(walker.m_Pid)
        if leader then 
            if leader == walker then 
                --同步状态
                local pList = g_MapCtrl.m_Teams[walker.m_TeamID]
                for k, id in ipairs(pList) do 
                    local member = g_MapCtrl:GetPlayer(id)
                    if member then 
                        member.m_TeamFlyState = leader:IsInFlyState()
                        member.m_Leader = leader
                    end 
                end
            else
                walker.m_TeamFlyState = leader:IsInFlyState()
                walker.m_Leader = leader
            end    
        end 
    else
        walker.m_TeamFlyState = nil
        walker.m_Leader = nil
    end  

    --performance
    if walker.m_TeamID then 
        local pList = g_MapCtrl.m_Teams[walker.m_TeamID]
        for k, id in ipairs(pList) do 
            local member = g_MapCtrl:GetPlayer(id)
            if member then 
                if member.m_TeamFlyState then 
                    self:WalkerFly(member, doAni, cb)
                else
                    self:WalkerLand(member, doAni, cb)
                end  
                self:UpdateFollowDis(member)
            end   
        end
    else
        if walker:IsInFlyState() then 
            self:WalkerFly(walker, doAni, cb)
        else
            self:WalkerLand(walker, doAni, cb)
        end  
        self:UpdateFollowDis(walker)
    end 

end

function CFlyRideAniCtrl.WalkerFly(self, walker, doAni, cb)

    --飞行高度
    local flyHeight = 1
    local camSize = walker:GetFlyCamSize()
    if walker:IsOnFlyRide() then 
        flyHeight = walker:GetFlyHeight()
    else
        if walker.m_Leader then 
            flyHeight = walker.m_Leader:GetFlyHeight()
            camSize = walker.m_Leader:GetFlyCamSize()
        end 
    end 
    
    walker:FlyAni(flyHeight, camSize, doAni, cb)

    --模型
    if walker:IsOnGroundRide() then 
        local modelInfo = table.copy(walker.m_ModelInfo)
        modelInfo.horse = nil
        walker.m_Actor:ChangeShape(modelInfo)
        walker:AddFootCloudEffect()
    end

    if not walker:IsOnRide() then 
        walker:AddFootCloudEffect()
    end 

    --摄像机
    if walker.classname == "CHero" then 
        local size = walker:GetFlyCamSize()
        if walker.m_Leader then
            size = walker.m_Leader:GetFlyCamSize()             
        end 
        self:HandleCamScale(true, size, doAni)
        self:ShowCloudEffect(true)
        self:HandleCamFollowOffset(walker, true, flyHeight, nil, doAni)
    end

    --速度
    if walker.m_Leader then
        if walker.m_Leader == walker then 
            local speed = walker:GetRideSpeed(true)
            walker:SetMoveSpeed(speed)
        else
            local leaderSpeed = walker.m_Leader.m_Walker.moveSpeed
             walker:SetMoveSpeed(leaderSpeed)

        end 
    else
        local speed = walker:GetRideSpeed(true)
        walker:SetMoveSpeed(speed)
    end 

    --处理跟随宠物的状态
    local summon = walker:GetFollowSummon()
    if summon then 
        summon:ShowWalker(false)
    end 

    --处理跟随npc的状态
    local fNpc = walker:GetFollowNpc()
    if fNpc then
        if walker.m_TeamID then 
            if walker.m_Leader == walker then  
                fNpc:FlyAni(flyHeight, camSize, doAni)
                fNpc:SetMoveSpeed(walker.m_Walker.moveSpeed)
                local lastMem = g_MapCtrl:FindLastMember(walker.m_Pid)
                if lastMem then
                    local dis = lastMem:GetFollowDis()
                    fNpc:Follow(lastMem, dis)
                    fNpc:ShowWalker(true)
                    fNpc:AddFootCloudEffect() 
                end 
            else
                fNpc:ShowWalker(false)
            end
        else
             local walkerSpeed = walker.m_Walker.moveSpeed
             fNpc:SetMoveSpeed(walkerSpeed)
             fNpc:AddFootCloudEffect() 
             fNpc:FlyAni(flyHeight, camSize, doAni)
             local dis = walker:GetFollowDis()
             fNpc:Follow(walker, dis)
             fNpc:ShowWalker(true)
        end 
    end 

end

--降落
function CFlyRideAniCtrl.WalkerLand(self, walker, doAni, cb)

    local finish = function ()
        if walker:IsOnGroundRide() then 
            if walker.m_ModelInfo then 
                walker:HandleChangeShape()
            end 
        end
        
        if cb then 
            cb()
        end 
    end

    walker:LandAni(doAni, finish)
    walker:DelFootCloudEffect()

    if walker.classname == "CHero" then  
        self:HandleCamScale(false, nil, doAni)
        self:ShowCloudEffect(false)
        self:HandleCamFollowOffset(walker, false, 0, nil, doAni)
    end

    if walker.m_Leader then
        if walker.m_Leader.m_Pid == walker.m_Pid then 
            local speed = walker:GetRideSpeed(false)
            walker:SetMoveSpeed(speed)
        else
            --同步速度
            local leaderSpeed = walker.m_Leader.m_Walker.moveSpeed
             walker:SetMoveSpeed(leaderSpeed)
        end 
    else
        local speed = walker:GetRideSpeed(false)
        walker:SetMoveSpeed(speed)
    end 

    local summon = walker:GetFollowSummon()
    if summon then
        local dis = walker:GetFollowDis()
        if walker.m_TeamID then 
            if walker.m_Leader and (walker.m_Leader.m_Pid == walker.m_Pid) then 
                summon:ShowWalker(true)
                summon:SetMoveSpeed(walker.m_Walker.moveSpeed)
                summon:SetFollowDis(dis)
            else
                summon:ShowWalker(false)
            end  
        else
            summon:ShowWalker(true)
            summon:SetMoveSpeed(walker.m_Walker.moveSpeed)
            summon:SetFollowDis(dis)
        end 

    end

    local fNpc = walker:GetFollowNpc()
    if fNpc then
        if walker.m_TeamID then 
            if walker.m_Leader == walker then 
                fNpc:LandAni(doAni)
                fNpc:SetMoveSpeed(walker.m_Walker.moveSpeed)
                local lastMem = g_MapCtrl:FindLastMember(walker.m_Pid)
                if lastMem then 
                    local dis = lastMem:GetFollowDis()
                    fNpc:Follow(lastMem, dis)
                end 
                fNpc:ShowWalker(true)
                fNpc:DelFootCloudEffect() 
            else
                fNpc:ShowWalker(false)
                fNpc:DelFootCloudEffect() 
            end 
        else
            fNpc:LandAni(doAni)
            local walkerSpeed = walker.m_Walker.moveSpeed
            fNpc:SetMoveSpeed(walkerSpeed)
            local dis = walker:GetFollowDis()
            fNpc:Follow(walker, dis)
            fNpc:DelFootCloudEffect() 
            fNpc:ShowWalker(true)    
        end 
    end 

end 


--更新跟随距离
function CFlyRideAniCtrl.UpdateFollowDis(self, walker)

    local factor = define.Fly.Data.FlyScaleFactor
    
    if walker.m_TeamID then 
        local leader = g_MapCtrl:GetTeamLeader(walker.m_Pid)
        if leader and (leader == walker) then 
            local nextFollower = g_MapCtrl:FindNextFollower(walker.m_Pid)
            if nextFollower then 
                local followDis = walker:GetFollowDis()
                local summon = walker:GetFollowSummon()
                if summon then
                    if walker.m_TeamFlyState then 
                        summon:SetFollowDis(followDis * factor)
                    else
                        summon:SetFollowDis(followDis)
                    end 
                   
                end

                if not walker.m_TeamFlyState then
                    if summon then 
                        followDis = followDis + define.Walker.Follow_Distance
                    end 
                end  
                if walker.m_TeamFlyState then 
                    nextFollower:SetFollowDis(followDis * factor)
                else
                    nextFollower:SetFollowDis(followDis)
                end
            end

            local fNpc = walker:GetFollowNpc()
            if fNpc then 
                local lastMem = g_MapCtrl:FindLastMember(walker.m_Pid)
                if lastMem then    
                    local followDis = lastMem:GetFollowDis()
                    if lastMem.m_TeamFlyState then 
                        fNpc:SetFollowDis(followDis * factor)
                    else
                        fNpc:SetFollowDis(followDis)
                    end 
                end       
            end
        else
            local nextFollower = g_MapCtrl:FindNextFollower(walker.m_Pid)
            if nextFollower then 
                local followDis = walker:GetFollowDis()
                if walker.m_TeamFlyState and not walker:IsOnFlyRide() then
                    followDis = define.Walker.Follow_Distance
                end  
                if walker.m_TeamFlyState then 
                    nextFollower:SetFollowDis(followDis * factor)
                else
                    nextFollower:SetFollowDis(followDis)
                end 
                
            else
                if leader then 
                    local fNpc = leader:GetFollowNpc()
                    if fNpc then 
                        local lastMem = g_MapCtrl:FindLastMember(leader.m_Pid)
                        if lastMem then    
                            local followDis = lastMem:GetFollowDis()
                            if lastMem.m_TeamFlyState then 
                                fNpc:SetFollowDis(followDis * factor)
                            else
                                fNpc:SetFollowDis(followDis)
                            end 
                        end       
                    end
                end 
            end  
        end 
  
    else
        --处理宠物和npc的跟随距离
        local followDis = walker:GetFollowDis()
        local summon = walker:GetFollowSummon()
        if summon then
            if walker:IsInFlyState() then 
                summon:SetFollowDis(followDis * factor)
            else
                summon:SetFollowDis(followDis)
            end        
        end

        local fNpc = walker:GetFollowNpc()
        if fNpc then 
            if walker:IsInFlyState() then 
                fNpc:SetFollowDis(followDis * factor)
            else
                fNpc:SetFollowDis(followDis)
            end       
        end 
    end 

end

function CFlyRideAniCtrl.ShowSummon(self, follower)
    
    if follower.m_Type ~= "s" then 
        return
    end 

    if follower.hideByMarry then
        return
    end

    local followTarget = follower.m_FollowTarget

    if not followTarget then 
        return
    end 
    
    local pid = followTarget.m_Pid

    local isInTeam = g_MapCtrl:IsWalkerInTeam(pid)
    local isLeaderSelf = g_MapCtrl:IsLeaderSelf(pid)

    if isInTeam then 
        if isLeaderSelf then 
            if followTarget:IsInFlyState() then 
                follower:ShowWalker(false)
            else
                follower:ShowWalker(true)
            end

        else
            follower:ShowWalker(false)
        end 
    else
        if followTarget:IsInFlyState() then 
            follower:ShowWalker(false)
        else
            follower:ShowWalker(true)
        end  
    end

end

--跟随宠物处理
function CFlyRideAniCtrl.HandleSummon(self, follower)

    if follower.m_Type ~= "s" then 
        return
    end 
  
    local followTarget = follower.m_FollowTarget

    if not followTarget then 
        return
    end 

    if followTarget:IsShow() then 
         self:ShowSummon(follower)
    end 
    
    local dis = followTarget:GetFollowDis()

    follower:Follow(followTarget, dis)
    follower:SetMoveSpeed(followTarget.m_Walker.moveSpeed)

end

function CFlyRideAniCtrl.ShowFollowNpc(self, followNpc)
   
    if followNpc.m_Type ~= "n" then 
        return
    end 

    local belongTarget = followNpc.m_BelongTo

    if not belongTarget then 
        return
    end 

    local pid = belongTarget.m_Pid
    local isInTeam = g_MapCtrl:IsWalkerInTeam(pid)
    
    if isInTeam then 
        local isLeaderSelf = g_MapCtrl:IsLeaderSelf(pid)
        if isLeaderSelf then 
            if belongTarget:IsShow() then 
                followNpc:ShowWalker(true)
            end   
        else
            followNpc:ShowWalker(false)
        end 
    else
        if belongTarget:IsShow() then 
            followNpc:ShowWalker(true)
        end
    end 

end

--跟随npc处理
function CFlyRideAniCtrl.HandleFollowNpc(self, followNpc)

    if followNpc.m_Type ~= "n" then 
        return
    end 

    local belongTarget = followNpc.m_BelongTo

    if not belongTarget then 
        return
    end 
    
    local pid = belongTarget.m_Pid
    local isInTeam = g_MapCtrl:IsWalkerInTeam(pid)
 
    local factor = define.Fly.Data.FlyScaleFactor
    if isInTeam then 
        local isLeaderSelf = g_MapCtrl:IsLeaderSelf(pid)
        if isLeaderSelf then 
            local lastMem = g_MapCtrl:FindLastMember(pid)
            if lastMem then 
                local dis = lastMem:GetFollowDis()
                if belongTarget:IsInFlyState() then 
                     followNpc:Follow(lastMem, dis * factor)
                else
                     followNpc:Follow(lastMem, dis)
                end 
            else
                local dis = belongTarget:GetFollowDis()
                if belongTarget:IsInFlyState() then 
                     followNpc:Follow(belongTarget, dis * factor)
                else
                     followNpc:Follow(belongTarget, dis)
                end 
            end  
 
            if belongTarget:IsInFlyState() then 
                local flyHeight = belongTarget:GetFlyHeight()
                local camSize = belongTarget:GetFlyCamSize() 
                followNpc:FlyAni(flyHeight, camSize)
                followNpc:AddFootCloudEffect() 
            else
                followNpc:LandAni()
                followNpc:DelFootCloudEffect() 
            end
            followNpc:ShowWalker(true)
            followNpc:SetMoveSpeed(belongTarget.m_Walker.moveSpeed) 
        else
            followNpc:ShowWalker(false)
        end 
    else
        local dis = belongTarget:GetFollowDis()
        followNpc:ShowWalker(true)
        if belongTarget:IsInFlyState() then
            followNpc:Follow(belongTarget, dis * factor) 
            local flyHeight = belongTarget:GetFlyHeight()
            local camSize = belongTarget:GetFlyCamSize() 
            followNpc:FlyAni(flyHeight, camSize)
            followNpc:AddFootCloudEffect()
              
        else
            followNpc:Follow(belongTarget, dis) 
            followNpc:LandAni()
            followNpc:DelFootCloudEffect() 
                  
        end 
         followNpc:SetMoveSpeed(belongTarget.m_Walker.moveSpeed)

    end 
end

--处理镜头缩放
function CFlyRideAniCtrl.HandleCamScale(self, fly, camSize, doAni)
    
    if fly then 
        if doAni then
            g_CameraCtrl:DoFlyCamAnimation(camSize, 0.6)
        else
            local oMainCam = g_CameraCtrl:GetMainCamera()
            oMainCam:SetOrthographicSize(camSize)
            g_MapCtrl:ResetMapCamera() 
        end
    else
        if doAni then
            g_CameraCtrl:DoFlyCamAnimation(3.5, 0.6)
        else
            local oMainCam = g_CameraCtrl:GetMainCamera()
            oMainCam:SetOrthographicSize(3.5)
            g_MapCtrl:ResetMapCamera() 
        end
    end 

end

--处理镜头跟随
function CFlyRideAniCtrl.HandleCamFollowOffset(self, walker, fly, offset, time, doAni)

    time = time or 0.7
    local mapCam = g_CameraCtrl:GetMapCamera()
    if fly then 
        if doAni then 
            mapCam:SetCameraOffsetY(offset, true, time)
        else
            mapCam:SetCameraOffsetY(offset, false, 0)
        end
    else
        if doAni then 
            mapCam:SetCameraOffsetY(0, true, time)
        else
            mapCam:SetCameraOffsetY(0, false, 0)
        end 
    end 

end

function CFlyRideAniCtrl.ShowCloudEffect(self, isShow)

    local show = function ()
        if g_MarryPlotCtrl:IsPlayingWeddingPlot() then return end
        if self.m_SkyCloudEffect then 
            if not self.m_SkyCloudRender then 
                self.m_SkyCloudRender = self.m_SkyCloudEffect:GetComponentInChildren(classtype.Renderer)
            end     
        
            if self.m_SkyCloudRender then 
                self.m_SkyCloudEffect:SetActive(true)
                local mat = self.m_SkyCloudRender.material
                if mat:GetFloat("_Alpha") == 1 then 
                    return
                end
                local fun = function (arg)
                    mat:SetFloat("_Alpha",  arg)
                end
                DOTween.DoFloat(0, 1, 0.8, fun)
            end 
        end 
    end

    local effectDone = function ()
        if self.m_SkyCloudEffect then 
             self.m_SkyCloudEffect:SetPos(Vector3.New(30,0,-1))
             if isShow then 
                  show()
              else
                  self.m_SkyCloudEffect:SetActive(false)
              end
        else
             self.m_SkyCloudEffect:SetActive(false)
        end 
    end
    local coludPath = "Effect/Scene/scene_eff_0021/Prefabs/scene_eff_0021.prefab"
    if not self.m_SkyCloudEffect then 
         self.m_SkyCloudEffect = CEffect.New(coludPath, UnityEngine.LayerMask.NameToLayer("Default"), true, effectDone)
    else  

        if isShow then 
            show()
        else
            if self.m_SkyCloudRender then         
                local render = self.m_SkyCloudRender
                local mat =  render.material
                if mat:GetFloat("_Alpha") == 0 then 
                    return
                end
                local fun = function (arg)
                    mat:SetFloat("_Alpha",  arg)
                end
                DOTween.DoFloat(1, 0, 0.8, fun)
            end
        end
    end

end


--更新队长后面成员的跟随距离
function CFlyRideAniCtrl.UpdateLeaderFollowerDis(self, pid)

    local isLeaderSelf = g_MapCtrl:IsLeaderSelf(pid)
    if not isLeaderSelf then 
        return
    end 

    local nextFollower = g_MapCtrl:FindNextFollower(pid)

    if not nextFollower then 
        return
    end 
    
    --获取lead的跟随距离
    local leader = g_MapCtrl:GetTeamLeader(pid)
    local dis = leader:GetFollowDis()

    if leader then 
        if leader:IsInFlyState() then 
            nextFollower:Follow(leader, dis)
        else
            local followSummon = leader:GetFollowSummon()
            if followSummon then 
                nextFollower:Follow(leader, dis + define.Walker.Follow_Distance)
            else
                nextFollower:Follow(leader, dis)
            end 
        end 
    end 
    
end

--更新离队成员的状态,并返回离队成员的id
function CFlyRideAniCtrl.UpdateMissTeamMember(self, oList, nList)

    local IsInLpid = function (id, list)
            
        for j, i in ipairs(list) do 
            if id == i then 
                return true
            end 
        end

        return false

    end

    local pid = nil
    for k, v in ipairs(oList) do 
        local isInList = IsInLpid(v, nList)
        if not isInList then 
            pid = v
        end 
    end 

    if pid then 
        local walker = g_MapCtrl.m_Players[pid]
        if walker then 
            self:TryFly(walker, true)
        end 

        return pid
    end

end

function CFlyRideAniCtrl.ResetAll(self)
    
    local oMainCam = g_CameraCtrl:GetMainCamera()
    oMainCam:SetOrthographicSize(3.5)
    self.m_IsFlying = false
    self.m_AnimCb = nil
    g_HudCtrl:ScaleHudLayer()

    if self.m_SkyCloudEffect then         
        self.m_SkyCloudEffect:SetActive(false)
    end 

end

return CFlyRideAniCtrl