local CWeddingPlotPlayer = class("CWeddingPlotPlayer", CGamePlotPlayer)

function CWeddingPlotPlayer.ctor(self, dPlotInfo, elapsedTime)
    self.m_ScreenShotTime = 1.2
    self.m_BeforeEndTime = 0.3
    self.m_IsFinish = false
    self.m_IsShotting = false
    self.m_ScreenShotTimer = nil
    CGamePlotPlayer.ctor(self, dPlotInfo, elapsedTime)
end

function CWeddingPlotPlayer.Init(self, dPlot)
    self.m_CharacterList = {}
    self.m_EffectList = {}
    self.m_CameraList = {}
    self.m_DialogueList = {}
    self.m_UIEffectList = {}
    local oSequence = DOTween.Sequence()
    self.m_Sequence = oSequence

    local plotTime = dPlot.plotTime
    if self.m_ElapsedTime then
        plotTime = plotTime - self.m_ElapsedTime
    end
    DOTween.AppendInterval(oSequence, plotTime)
    DOTween.OnComplete(oSequence, callback(g_MarryCtrl, "EndWedding", true))

    self:InitAllCamera(dPlot.cameraList)
    self:InitAllCharacter(dPlot.characterList)
    self:InitAllSceneEffect(dPlot.sceneEffectList)
    self:InitAllDialogue(dPlot.dialogueList)
    self:InitAllAudio(dPlot.audioActionList)
    self:InitAllSceneMask(dPlot.screenMaskActionList)
    self:InitAllUIEffect(dPlot.uiEffectList)

    self:InitScreenShot(plotTime)
end

function CWeddingPlotPlayer.InitScreenShot(self, plotTime)
    if not g_MarryCtrl:IsInMyWedding() then return end
    self.m_ScreenShotTimer = nil
    local shotTime = plotTime - self.m_BeforeEndTime
    if shotTime > 0 then
        local oShotSequence = DOTween.Sequence()
        self.m_ShotSequence = oShotSequence
        DOTween.AppendInterval(oShotSequence, shotTime)
        DOTween.OnComplete(oShotSequence, callback(self, "ScreenShot"))
    else
        self:ScreenShot()
    end
end

function CWeddingPlotPlayer.GetNewPlotCharCtrl(self, dCharInfo, oWalker)
    local elapsedTime = self:GetPlotEntityElapsedTime(dCharInfo)
    return CWeddingPlotCharacterCtrl.New(dCharInfo, oWalker, elapsedTime)
end

function CWeddingPlotPlayer.OnChangeShape(self, oWalker, dCharInfo, bIsDie)
    if type(dCharInfo.defaultAnim) ~= "userdata" then
        if bIsDie then
            local function callback()
                if Utils.IsNil(oWalker) then
                    return
                end
                oWalker:SetLocalPos(Vector3.New(dCharInfo.originPos.x, dCharInfo.originPos.y, 0))
            end
            Utils.AddTimer(callback, 0, 0.5)
            local dInfo = ModelTools.GetAnimClipInfo(dCharInfo.modelId , dCharInfo.defaultAnim)
            oWalker.m_Actor:PlayInFrame(dCharInfo.defaultAnim, dInfo.frame, dInfo.frame)
        else
            oWalker:CrossFade(dCharInfo.defaultAnim)
        end
    end
end

function CWeddingPlotPlayer.ScreenShot(self)
    self:Pause()
    self.m_IsShotting = true
    -- 未加载完资源处理
    if self:IsLoadingChars() then
        self.m_ScreenShotTimer = Utils.AddTimer(callback(self, "CheckCharsLoad"), 0.1, 0)
    else
        self:BeginScreenShot()
    end
end

function CWeddingPlotPlayer.BeginScreenShot(self)
    self.m_ScreenShotTimer = Utils.AddTimer(callback(self, "Resume"), 0, self.m_ScreenShotTime)
    self:ClearAllChatMsg()
    self:HideAllHud()
    self:SetUIEffectsLayer("TransparentFX")
    g_MarryCtrl:ShowShareMarriedView(true, callback(self, "SetUIEffectsLayer", "UI"))
end

function CWeddingPlotPlayer.ClearAllChatMsg(self)
    for i, v in ipairs(self.m_CharacterList) do
        v:ClearChatMsg()
    end
end

function CWeddingPlotPlayer.HideAllHud(self)
    for i, v in ipairs(self.m_CharacterList) do
        v.m_Walker.m_HudNode:SetPosHide(true)
    end
end

function CWeddingPlotPlayer.IsLoadingChars(self)
    for i, v in ipairs(self.m_CharacterList) do
        if v.m_Walker.m_Actor.m_IsLoading then
            return true
        end
    end
    return false
end

function CWeddingPlotPlayer.CheckCharsLoad(self)
    if self:IsLoadingChars() then
        return true
    else
        self:BeginScreenShot()
        return false
    end
end

function CWeddingPlotPlayer.Resume(self)
    self.m_IsShotting = false
    CGamePlotPlayer.Resume(self)
end

function CWeddingPlotPlayer.Finish(self, bInterrupt)
    if self.m_IsFinish then return end
    if self.m_ShotSequence then
        self.m_ShotSequence:Kill(not bInterrupt)
        self.m_ShotSequence = nil
    end
    if self.m_Sequence then
        self.m_Sequence:Kill(not bInterrupt)
        self.m_Sequence = nil
    end
    if self.m_ScreenShotTimer then
        Utils.DelTimer(self.m_ScreenShotTimer)
    end
    if g_MarryCtrl:IsInMyWedding() and not g_MarryCtrl:IsScreenShotPlot() then
        netmarry.C2GSMarryWeddingEnd()
    end
    self.m_IsFinish = true
    self.m_IsShotting = false
    CGamePlotPlayer.Finish(self)
end

return CWeddingPlotPlayer