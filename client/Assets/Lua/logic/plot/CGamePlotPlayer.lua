local CGamePlotPlayer = class("CGamePlotPlayer", CObject)

CGamePlotPlayer.ModelOrient = {
	[0] = Vector3.north,
	[1] = Vector3.northEast,
	[2] = Vector3.east,
	[3] = Vector3.southEast,
	[4] = Vector3.south,
	[5] = Vector3.southWest,
	[6] = Vector3.west,
	[7] = Vector3.northWest
}

function CGamePlotPlayer.ctor(self, dPlotInfo, elapsedTime)
	self.m_PlotInfo = dPlotInfo
	self.m_ElapsedTime = elapsedTime
	self:Init(dPlotInfo)
end

function CGamePlotPlayer.Init(self, dPlot)
	self.m_CharacterList = {}
	self.m_EffectList = {}
	self.m_CameraList = {}
	self.m_DialogueList = {}
	self.m_UIEffectList = {}
	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	self.m_AudioSequence = nil
	self.m_UIEffectRoot = nil

	--添加剧情结束回调
	local plotTime = dPlot.plotTime
	if self.m_ElapsedTime then
		plotTime = plotTime - self.m_ElapsedTime
	end
	DOTween.AppendInterval(oSequence, plotTime)
	local function endf()
		printc("Finish")
		g_PlotCtrl:FinishPlot()
	end 
	DOTween.OnComplete(oSequence, endf)

	self:InitAllCharacter(dPlot.characterList)
	self:InitAllSceneEffect(dPlot.sceneEffectList)
	self:InitAllCamera(dPlot.cameraList)
	self:InitAllDialogue(dPlot.dialogueList)
	self:InitAllAudio(dPlot.audioActionList)
	self:InitAllSceneMask(dPlot.screenMaskActionList)
	self:InitAllScenePresure(dPlot.screenPresureActionList)
	self:InitAllMinGame(dPlot.minGameActionList)
	self:InitAllUIEffect(dPlot.uiEffectList)
end
                 
function CGamePlotPlayer.InitAllCharacter(self, tCharacterList)
	for i,dChar in ipairs(tCharacterList) do
		if dChar.active then
			local startTime = self:GetPlotEntityWaitTime(dChar)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "CreateCharacter", dChar))
			elseif startTime == 0 then
				self:CreateCharacter(dChar)
			end
		end
	end
end

function CGamePlotPlayer.InitAllSceneEffect(self, tEffectList)
	self.m_SceneEffectNode = CObject.New(UnityEngine.GameObject.New())
	self.m_SceneEffectNode:SetName("PlotScenenNode")
	self.m_EffMask = CPlotEffectMask.New()
	local time = self.m_ElapsedTime
	for i,dEffect in ipairs(tEffectList) do
		if dEffect.active then
			local startTime = self:GetPlotEntityWaitTime(dEffect)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "CreateSceneEffect", dEffect))
			elseif startTime == 0 then
				self:CreateSceneEffect(dEffect)
			end
		end
	end
end

function CGamePlotPlayer.InitAllCamera(self, tCameraList)
	for i,dCamera in ipairs(tCameraList) do
		if dCamera.active then
			local startTime = self:GetPlotEntityWaitTime(dCamera)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, dCamera.startTime, callback(self, "CreateCamera", dCamera))
			elseif startTime == 0 then
				self:CreateCamera(dCamera)
			end
		end
	end
end

function CGamePlotPlayer.InitAllDialogue(self, tDialogueList)
	for i,dDialogue in ipairs(tDialogueList) do
		if dDialogue.active then
			local startTime = self:GetPlotEntityWaitTime(dDialogue)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "CreateDialogue", dDialogue))
			elseif startTime == 0 then
				self:CreateDialogue(dDialogue)
			end
		end
	end
end

function CGamePlotPlayer.InitAllAudio(self, tAudioList)
	for i,dAudio in ipairs(tAudioList) do
		if dAudio.active then
			local startTime = self:GetPlotEntityWaitTime(dAudio)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "PlayAudio", dAudio))
			elseif startTime == 0 then
				self:PlayAudio(dAudio)
			end
		end
	end
end

function CGamePlotPlayer.InitAllSceneMask(self, tMaskList)
	for i,dMask in ipairs(tMaskList) do
		if dMask.active then
			local startTime = self:GetPlotEntityWaitTime(dMask)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "ShowScreenMask", dMask))
			elseif startTime == 0 then
				self:ShowScreenMask(dMask)
			end
		end
	end
end

function CGamePlotPlayer.InitAllScenePresure(self, tPresureList)
	for i,dPresure in ipairs(tPresureList) do
		if dPresure.active then
			DOTween.InsertCallback(self.m_Sequence, dPresure.startTime, callback(self, "ShowScreenPresure", dPresure))
		end
	end
end

function CGamePlotPlayer.InitAllMinGame(self, tMinGameList)
	for i,dMinGame in ipairs(tMinGameList) do
		if dMinGame.active then
			DOTween.InsertCallback(self.m_Sequence, dMinGame.startTime, callback(self, "ShowMinGame", dMinGame))
		end
	end
end

function CGamePlotPlayer.InitAllUIEffect(self, uiEffectList)
	if not uiEffectList then return end
	self:CreateUIEffectRoot()
	for i, dUIEff in ipairs(uiEffectList) do
		if dUIEff.active then
			local startTime = self:GetPlotEntityWaitTime(dUIEff)
			if startTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, startTime, callback(self, "CreateUIEffect", dUIEff))
			elseif startTime == 0 then
				self:CreateUIEffect(dUIEff)
			end
		end
	end
end

function CGamePlotPlayer.CreateCharacter(self, dCharInfo)
	local name = dCharInfo.name
	local oWalker = CPlayer.New()
	oWalker:SetName(name)
	oWalker:SetMapID(g_MapCtrl:GetResID())
	--屏蔽一个加载模型是0的报错
	--默认动作特殊处理死亡
	local bIsDie = type(dCharInfo.defaultAnim) ~= "userdata" and dCharInfo.defaultAnim == "die"
	if bIsDie then
		oWalker:SetLocalPos(Vector3.New(10000, 10000, 0))
	else
		oWalker:SetLocalPos(Vector3.New(dCharInfo.originPos.x, dCharInfo.originPos.y, 0))
	end
	oWalker:SetCheckInScreen(false)
	oWalker:ShowWalker(true)
	oWalker.m_Actor:SetLocalEulerAngles(CGamePlotPlayer.ModelOrient[dCharInfo.orient])
	local oCtrl = self:GetNewPlotCharCtrl(dCharInfo, oWalker)
	table.insert(self.m_CharacterList, oCtrl)
end

function CGamePlotPlayer.GetNewPlotCharCtrl(self, dCharInfo, oWalker)
	local elapsedTime = self:GetPlotEntityElapsedTime(dCharInfo)
	return CPlotCharacterCtrl.New(dCharInfo, oWalker, elapsedTime)
end

function CGamePlotPlayer.CreateSceneEffect(self, dEffectInfo)
	--TODO:细节未处理
	dEffectInfo.effMask = self.m_EffMask
	local oCtrl = CPlotSceneEffectCtrl.New(dEffectInfo, self.m_SceneEffectNode, self:GetPlotEntityElapsedTime(dEffectInfo))
	table.insert(self.m_EffectList, oCtrl)
end

function CGamePlotPlayer.CreateCamera(self, dCameraInfo)
	local oCtrl = CPlotCameraCtrl.New(dCameraInfo, self:GetPlotEntityElapsedTime(dCameraInfo))
	table.insert(self.m_CameraList, oCtrl)
end

function CGamePlotPlayer.CreateDialogue(self, dDialogueInfo)
	local oCtrl = CPlotDialogueCtrl.New(dDialogueInfo, self:GetPlotEntityElapsedTime(dDialogueInfo))
	table.insert(self.m_DialogueList, oCtrl)
end

function CGamePlotPlayer.PlayAudio(self, oAudioAction)
	--TODO:音乐or音效播放，未实现
	if oAudioAction.audioType == define.Plot.AudioType.Music then
		g_AudioCtrl:PlayMusic(oAudioAction.audioPath)
		if self.m_AudioSequence then
			self.m_AudioSequence:Kill()
			self.m_AudioSequence = nil
		end
		local leftTime = oAudioAction.duration
		local elapsedTime = self:GetPlotEntityElapsedTime(oAudioAction)
		if elapsedTime and elapsedTime > 0 then
			leftTime = leftTime - elapsedTime
		end
		local oAudioSequence = DOTween.Sequence()
		self.m_AudioSequence = oAudioSequence
		DOTween.AppendInterval(oAudioSequence, leftTime)
		DOTween.OnComplete(oAudioSequence, function()
			g_MapCtrl:PlayBgMusic()
		end)
	elseif oAudioAction.audioType == define.Plot.AudioType.Sound then
		g_AudioCtrl:PlaySound(oAudioAction.audioPath)
	end
end

function CGamePlotPlayer.ShowScreenMask(self, oMaskAction)
	local elapsedTime = self:GetPlotEntityElapsedTime(oMaskAction)
	if elapsedTime and elapsedTime > 0 then
		local leftTime = oMaskAction.duration - elapsedTime
		if leftTime <= 0 then
			return
		else
			oMaskAction.duration = leftTime
			oMaskAction.msgStartTime = oMaskAction.msgStartTime - elapsedTime
			oMaskAction.msgEndTime = oMaskAction.msgEndTime - elapsedTime
			oMaskAction.fadeInTime = oMaskAction.fadeInTime - elapsedTime
			oMaskAction.fadeOutTime = oMaskAction.fadeOutTime - elapsedTime
			oMaskAction.fadeTweenTime = oMaskAction.fadeTweenTime - elapsedTime
		end
	end
	CPlotMaskView:ShowView(function(oView)
		oView:ExcuteMaskAction(oMaskAction)
	end)
end

function CGamePlotPlayer.ShowScreenPresure(self, oPresureAction)
	CPlotSkipView:ShowView(function(oView)
		oView:SetSkipCallback(callback(g_PlotCtrl, "FinishPlot"))
	end)
end

function CGamePlotPlayer.ShowMinGame(self, oMinGameAction)
	if oMinGameAction.pause then
		self:Pause()
	end
	--小游戏(qte)根据人物位置的坐标列表
	local list = {}
	for k,v in pairs(self.m_PlotInfo.characterList) do
		if v.qteOpen then
			table.insert(list, v.originPos)
		end
	end
	CTaskAnimeQteView:ShowView(function (oView)
		oView:SetPlotCharacterPos(list)
		g_TaskCtrl:SetAnimeQteInfo(oMinGameAction.gameId, oMinGameAction.duration)
		oView:RefreshUI()
	end)
end

function CGamePlotPlayer.CreateUIEffect(self, dInfo)
	local elapsedTime = self:GetPlotEntityElapsedTime(dInfo)
	local oCtrl = CPlotUIEffectCtrl.New(self.m_UIEffectRoot, dInfo, elapsedTime)
	table.insert(self.m_UIEffectList, oCtrl)
end

function CGamePlotPlayer.CreateUIEffectRoot(self)
	if self.m_UIEffectRoot then return end
    local obj = CObject.New(UnityEngine.GameObject.New("PlotUIEffectRoot"))
    local oUIRoot = UITools.GetUIRoot()
    obj:SetParent(oUIRoot.transform, false)
    self.m_UIEffectRoot = obj
end

function CGamePlotPlayer.SetUIEffectsLayer(self, sLayer)
	local iLayer = UnityEngine.LayerMask.NameToLayer(sLayer)
	for i, v in ipairs(self.m_UIEffectList) do
    	v:SetEffectLayer(iLayer)
	end
end

function CGamePlotPlayer.Pause(self)
	self.m_Sequence:Pause()

	local oView = CPlotMaskView:GetView()
	if oView then
		oView:Pause()
	end
	for i,oCtrl in ipairs(self.m_CharacterList) do
		oCtrl:Pause()
	end
	for i,oCtrl in ipairs(self.m_EffectList) do
		oCtrl:Pause()
	end
	for i,oCtrl in ipairs(self.m_CameraList) do
		oCtrl:Pause()
	end
	for i,oCtrl in ipairs(self.m_DialogueList) do
		oCtrl:Pause()
	end
	for i,oCtrl in ipairs(self.m_UIEffectList) do
		oCtrl:Pause()
	end
end

function CGamePlotPlayer.Resume(self)
	if self.m_Sequence:IsPlaying() then
		return
	end
	self.m_Sequence:Play()

	local oView = CPlotMaskView:GetView()
	if oView then
		oView:Resume()
	end
	for i,oCtrl in ipairs(self.m_CharacterList) do
		oCtrl:Resume()
	end
	for i,oCtrl in ipairs(self.m_EffectList) do
		oCtrl:Resume()
	end
	for i,oCtrl in ipairs(self.m_CameraList) do
		oCtrl:Resume()
	end
	for i,oCtrl in ipairs(self.m_DialogueList) do
		oCtrl:Resume()
	end
	for i,oCtrl in ipairs(self.m_UIEffectList) do
		oCtrl:Resume()
	end
end

function CGamePlotPlayer.Finish(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	else
		return
	end
	if self.m_SceneEffectNode then
		self.m_SceneEffectNode:Destroy()
		self.m_SceneEffectNode = nil
	end
	local oView = CPlotSkipView:GetView()
	if oView then
		oView:CloseView()
		oView = nil
	end
	-- oView = CPlotMaskView:GetView()
	-- if oView then
	-- 	oView:CloseView()
	-- 	oView = nil
	-- end
	oView = CPlotDialogueView:GetView()
	if oView then
		oView:CloseView()
		oView = nil
	end
	for i,oCtrl in ipairs(self.m_CharacterList) do
		oCtrl:Dispose()
	end
	for i,oCtrl in ipairs(self.m_EffectList) do
		oCtrl:Dispose()
	end
	for i,oCtrl in ipairs(self.m_CameraList) do
		oCtrl:Dispose()
	end
	for i,oCtrl in ipairs(self.m_DialogueList) do
		oCtrl:Dispose()
	end
	for i,oCtrl in ipairs(self.m_UIEffectList) do
		oCtrl:Dispose()
	end
	if self.m_AudioSequence then
		self.m_AudioSequence:Kill(true)
		self.m_AudioSequence = nil
	end
	if self.m_EffMask then
		self.m_EffMask:Destroy()
		self.m_EffMask = nil
	end
	if self.m_UIEffectRoot then
		self.m_UIEffectRoot:Destroy()
		self.m_UIEffectRoot = nil
	end
	self:Destroy()
end

-- 获取等待时间，用于从中间开始播放
function CGamePlotPlayer.GetPlotEntityWaitTime(self, dEntity)
	if self.m_ElapsedTime then
		local startTime, endTime = dEntity.startTime, dEntity.endTime
		if not endTime and startTime then
			endTime = dEntity.duration and startTime + dEntity.duration
		end
		if startTime and endTime then
			if self.m_ElapsedTime < startTime then
				return startTime - self.m_ElapsedTime
			elseif self.m_ElapsedTime < endTime then
				return 0
			end
		end
		return -1
	else
		return dEntity.startTime
	end
end

function CGamePlotPlayer.GetPlotEntityElapsedTime(self, dEntity)
	if self.m_ElapsedTime and dEntity.startTime then
		local elapsedTime = self.m_ElapsedTime - dEntity.startTime
		return elapsedTime > 0 and elapsedTime
	end
end

return CGamePlotPlayer