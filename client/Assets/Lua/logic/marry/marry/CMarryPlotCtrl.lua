local CMarryPlotCtrl = class("CMarryPlotCtrl", CCtrlBase)

function CMarryPlotCtrl.ctor(self, obj)
    CCtrlBase.ctor(self)
    self.m_MaxPlotTime = 40
    self:Reset()
end

function CMarryPlotCtrl.Reset(self)
    if self:IsPlayingWeddingPlot() then
        self.m_CurPlotPlayer:Finish(true)
        g_NotifyCtrl:SetEffectMsgActive(true)
        CMarrySharedView:CloseView()
    end
    self.m_CurPlotPlayer = nil
    self.m_IsCheckWedding = false
    self:DelCheckPlayTimer()
    self.m_DelayPlayElapsedTime = 0
    self.m_CurPlotId = nil
    self.m_IsPlaying = false
end

function CMarryPlotCtrl.PlayWeddingPlot(self, iPlotId, elapsedTime)
    if self:IsPlayingWeddingPlot() then
        printc("playing wedding plot ------------- ")
        return
    end
    self.m_CurPlotId = iPlotId
    printc("is in my wedding --------- ", g_MarryCtrl:IsInMyWedding(), elapsedTime)
    if not g_MarryCtrl:IsInMyWedding() and elapsedTime >= 0 then
        local bLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
        local bJoinTeam = g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeave()
        if not self:IsHeroInMarryArea() or (not bLeader and bJoinTeam) then
            self:DelayPlayWeddingPlot(iPlotId, elapsedTime)
            return
        end
        if bLeader then
            netmarry.C2GSTeamShowWedding()
        end
    end
    self:LoadConfig(iPlotId, elapsedTime)
end

function CMarryPlotCtrl.LoadConfig(self, iPlotId, elapsedTime)
    if not iPlotId then return end
    local sPath = string.format("Config/GamePlotConfig/GamePlot_%d.bytes", iPlotId)
    if not g_ResCtrl:IsExist(sPath) then
        printc("not plot config ---------------- ", sPath)
        g_MarryCtrl:EndWedding()
        return
    end
    local bytes = g_ResCtrl:Load(sPath)
    if not bytes then
        printc("not plot config ---------------- ", sPath)
        g_MarryCtrl:EndWedding()
        return
    end
    local str = tostring(bytes)
    local dPlot = decodejson(str)
    self.m_IsPlaying = true
    self:OnLoadWeddingPlotData(dPlot, elapsedTime)
end

function CMarryPlotCtrl.OnLoadWeddingPlotData(self, dPlot, elapsedTime)
    if not dPlot then
        g_MarryCtrl:EndWedding()
        printerror("CPlotCtrl.OnLoadPlotDataFinish n", self.m_CurPlotId)
        return
    elseif elapsedTime then
        if elapsedTime < 0 then
            elapsedTime = dPlot.plotTime - 2
        elseif elapsedTime > dPlot.plotTime then
            -- printc("elaspedTime大于剧情时间 ---------- ", elapsedTime, dPlot.plotTime)
            g_MarryCtrl:EndWedding()
            return
        end
    end
    printc("Begin play wedding plot")
    -- 婚礼场景为当前场景时，不跳转至新场景(统一跳场景)
    if false then--dPlot.sceneId == g_MapCtrl.m_MapID then
        self:OnStartWeddingPlot()
        self.m_CurPlotPlayer = CWeddingPlotPlayer.New(dPlot, elapsedTime)
    else
        self:LoadPlotScene(dPlot, elapsedTime)
    end
end

function CMarryPlotCtrl.LoadPlotScene(self, dPlot, elapsedTime)
    local dCamera = dPlot.cameraList[1]
    local dPosInfo = {
        face_x = 0,
        face_y = 0,
        x = dCamera and dCamera.originPos.x*1000 or 0,
        y = dCamera and dCamera.originPos.y*1000 or 0,
    }
    local function OnMapLoadDone()
        self:OnStartWeddingPlot()
        self.m_CurPlotPlayer = CWeddingPlotPlayer.New(dPlot, elapsedTime)
    end
    g_MapCtrl:AddLoadDoneCb(OnMapLoadDone)
    g_MapCtrl:ShowScene(0, dPlot.sceneId, "婚礼", dPosInfo, true)
    g_MapCtrl:EnterScene(nil, dPosInfo)
end

function CMarryPlotCtrl.DelayPlayWeddingPlot(self, iPlotId, elapsedTime)
    self:DelCheckPlayTimer()
    if elapsedTime >= self.m_MaxPlotTime then
        self.m_CurPlotId = nil
        g_MarryCtrl:EndWedding()
        return
    end
    self.m_DelayPlayElapsedTime = elapsedTime
    self.m_IsCheckWedding = true
    self.m_DelayPlayTimer = Utils.AddTimer(callback(self, "UpdateDelayTimer"), 1, 0)
end

function CMarryPlotCtrl.DelCheckPlayTimer(self)
    if self.m_DelayPlayTimer then
        Utils.DelTimer(self.m_DelayPlayTimer)
        self.m_DelayPlayTimer = nil
    end
    self.m_IsCheckWedding = false
end

function CMarryPlotCtrl.PlayWeddingCachePlot(self)
    if self.m_CurPlotId then
        if g_TeamCtrl:IsLeader(g_AttrCtrl.pid) then
            netmarry.C2GSTeamShowWedding()
        elseif g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeave() then -- 队员以队长为主
            return
        end
        self:DelCheckPlayTimer()
        self:LoadConfig(self.m_CurPlotId, self.m_DelayPlayElapsedTime)
    end
end

function CMarryPlotCtrl.TeamShowWedding(self)
    self:DelCheckPlayTimer()
    if not self:IsPlayingWeddingPlot() then
        self:LoadConfig(self.m_CurPlotId, self.m_DelayPlayElapsedTime)
    end
end

function CMarryPlotCtrl.OnStartWeddingPlot(self)
    CMarryComfirmView:CloseView()
    CMarryAcceptView:CloseView()
    CMarrySharedView:CloseView()
    CWelfareView:CloseView()
    CHotTopicView:CloseView()
    CWindowComfirmView:CloseView()
    g_ViewCtrl:HideNotGroupOther(CNotifyView:GetView(), {"CMainMenuView", "CNotifyView"})
    -- g_ViewCtrl:CloseAll({"CMainMenuView"})
    g_MainMenuCtrl:ShowMainMenu(false)
    g_MapCtrl:SetAllMapEffectActive(false, true)
    g_MapCtrl:SetMarryWalkersShow(false)
    g_NotifyCtrl:SetEffectMsgActive(false)
    if g_FlyRideAniCtrl.m_SkyCloudEffect then
        g_FlyRideAniCtrl.m_SkyCloudEffect:SetActive(false)
    end
    g_OpenSysCtrl:PauseShowSysOpen()
    self:SetCameraFollow(false)
end

function CMarryPlotCtrl.FinishWeddingPlot(self)
    if self:IsPlayingWeddingPlot() then
        self.m_IsPlaying = false
        if self.m_CurPlotPlayer then
            self.m_CurPlotPlayer:Finish()
            self.m_CurPlotPlayer = nil
        else
            return
        end
    end
    self.m_CurPlotId = nil

    local oView = CMarrySharedView:GetView()
    if oView and g_GuideCtrl:CheckCurGuide() then
        oView:CloseView()
        oView = nil
    end
    -- 截图界面打开时不显示主界面
    if not oView then
        g_MainMenuCtrl:ShowMainMenu(true)
    end
    
    g_MapCtrl:SetAllMapEffectActive(true, true)
    g_MapCtrl:SetMarryWalkersShow(true)
    g_ViewCtrl:ShowNotGroupOther()
    g_NotifyCtrl:SetEffectMsgActive(true)
    if next(g_OpenSysCtrl.m_ShowSys) then
        g_OpenSysCtrl:StartShow()
    end
    local oView = CPlotMaskView:GetView()
    if oView then
        oView:CloseView()
        oView = nil
    end
    if g_MapCtrl.m_IsInPlot then
        netmarry.C2GSMarryReScene()
    else
        self:SetCameraFollow(true)
        local oHero = g_MapCtrl:GetHero()
        g_FlyRideAniCtrl:TryFly(oHero)
    end
end

function CMarryPlotCtrl.UpdateDelayTimer(self)
    self.m_DelayPlayElapsedTime = self.m_DelayPlayElapsedTime + 1
    if self.m_DelayPlayElapsedTime < self.m_MaxPlotTime then
        return true
    else
        self.m_IsCheckWedding = false
        self.m_DelayPlayElapsedTime = 0
        self.m_DelayPlayTimer = nil
        self.m_CurPlotId = nil
        g_MarryCtrl:EndWedding()
        return false
    end
end

function CMarryPlotCtrl.SetCameraFollow(self, bFollow)
    if bFollow then
        g_MapCtrl:ResetCameraFollow()
    else
        local oCam = g_CameraCtrl:GetMapCamera()
        if oCam then
            oCam:Follow(nil)
        end
    end
end

function CMarryPlotCtrl.IsPlayingWeddingPlot(self)
    return self.m_IsPlaying -- self.m_CurPlotPlayer ~= nil
end

function CMarryPlotCtrl.IsHeroInMarryArea(self)
    local oHero = g_MapCtrl:GetHero()
    if oHero then
        return oHero:IsInMarryArea()
    end
    return false
end

function CMarryPlotCtrl.IsCheckWedding(self)
    return self.m_IsCheckWedding
end

function CMarryPlotCtrl.GetProtagonistShapeData(self, iNpcId)
    local dModel, dPlayer
    if iNpcId == 1 then
        dPlayer = g_MarryCtrl.m_Groom
    else
        dPlayer = g_MarryCtrl.m_Bride
    end
    if dPlayer then
        dModel = dPlayer.model_info
        if dModel then
            dModel.horse = nil
            dModel.show_wing = nil
            dModel.weapon = nil
        end
    end
    return dModel
end

function CMarryPlotCtrl.GetProtagonistName(self, iNpcId)
    local dPlayer = iNpcId == 1 and g_MarryCtrl.m_Groom or g_MarryCtrl.m_Bride
    return dPlayer and dPlayer.name or ""
end

function CMarryPlotCtrl.GetProtagonistTitle(self, iNpcId)
    return iNpcId == 1 and "新郎" or "新娘"
end

return CMarryPlotCtrl