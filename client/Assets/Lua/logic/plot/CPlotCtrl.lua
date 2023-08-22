local CPlotCtrl = class("CPlotCtrl", CCtrlBase)

function CPlotCtrl.ctor(self, obj)
	CCtrlBase.ctor(self)
	
	self.m_CurTriggerPlot = nil --当前触发的剧情
	self.m_CurPlotPlayer = nil  --剧情播放器
	self.m_FinishPlotCb = nil	--剧情结束回调
	self.m_NextPlotId = nil   --銜接劇情
	self.m_IsShowingDialogueView = false
	self.m_PlotEndCbList = {}
end

function CPlotCtrl.Clear(self)
	self.m_PlotEndCbList = {}
end

function CPlotCtrl.Init(self)
	self.m_PlotMgr:SetLoadDoneCallback()
end

function CPlotCtrl.SetFinishPlotCb(self, cb)
	self.m_FinishPlotCb = cb
end

function CPlotCtrl.AddPlotEndCbList(self, cb)
	table.insert(self.m_PlotEndCbList, cb)
end

-- function CPlotCtrl.PlayPlot(self, oPlot)
-- 	printc("CPlotCtrl.PlayPlot", oPlot.m_Name, oPlot.m_Id)
-- 	self.m_CurTriggerPlot = oPlot	
-- 	if self.m_CurTriggerPlot:IsShow() then
-- 		self:PlayPlotById(oPlot.m_Id)
-- 	else
-- 		self:FinishPlot()
-- 	end
-- end

function CPlotCtrl.PlayPlotById(self, iPlotId)
	if g_TaskCtrl.m_IsShowingPieceView then
		g_TaskCtrl:AddPieceShowingCbList(function ()
 			g_PlotCtrl:PlayPlotById(iPlotId)
 		end)
		return
	end
	if self:IsPlaying() then
		g_NotifyCtrl:FloatMsg("剧情播放中，无法重复播放")
		return
	end
	if g_NotifyCtrl.m_IsPieceShowing then
		g_NotifyCtrl.m_IsPieceEndCb = function ()
			g_PlotCtrl:PlayPlotById(iPlotId)
		end	
		return
	end
	CTaskMainView:CloseView()
	CTaskStoryPieceView:CloseView()
	g_ViewCtrl:HideNotGroupOther(CNotifyView:GetView(), {"CMainMenuView", "CNotifyView"})
	self.m_CurTriggerPlot = iPlotId
	printc("CPlotCtrl.PlayPlotById", iPlotId)

	self:PlotBarrageHandle(iPlotId)

	local sPlotResKey = string.format("GamePlot_%d", iPlotId)
	--TODO:加载剧情配置文件
	self:LoadConfig(sPlotResKey)
end

function CPlotCtrl.FinishPlot(self)
	printc("CPlotCtrl.FinishPlot")
	if self.m_CurPlotPlayer then
		self.m_CurPlotPlayer:Finish()
		self.m_CurPlotPlayer = nil
	end
	--Test
	self:RequestServer()
	if self.m_NextPlotId and self.m_NextPlotId > 0 then
		printc("播放衔接剧情",self.m_NextPlotId)
		self:PlayPlotById(self.m_NextPlotId)
		self.m_NextPlotId = 0
		g_BarrageCtrl:StopCheckPlotTime()
		return
	end
	g_BarrageCtrl:StopCheckPlotTime()
	CPlotSkipView:CloseView()
	CPlotDialogueView:CloseView()
	local oView = CPlotMaskView:GetView()
	if oView then
		oView:CloseView()
		oView = nil
	end

	local oPlotBarrageSendView = CPlotBarrageSendView:GetView()
	if oPlotBarrageSendView then
		oPlotBarrageSendView:CloseView()
		oPlotBarrageSendView = nil
	end
	g_ViewCtrl:ShowNotGroupOther()

	g_MapCtrl:SetAllMapEffectActive(true, true)
	g_MainMenuCtrl:ShowMainMenu(true)
	if self.m_FinishPlotCb then
		self.m_FinishPlotCb(self.m_CurTriggerPlot)
		self.m_FinishPlotCb = nil
	end
	for k,v in pairs(self.m_PlotEndCbList) do
		if v then v() end
	end
	self.m_PlotEndCbList = {}

	g_BarrageCtrl:CloseBarrageView()

	self.m_CurTriggerPlot = nil
end

function CPlotCtrl.IsPlaying(self)
	return self.m_CurPlotPlayer ~= nil
end

function CPlotCtrl.IsWaitingPlay(self)
	return self.m_CurTriggerPlot ~= nil
end

function CPlotCtrl.LoadConfig(self, sPlotRes)
	local sPath = "Config/GamePlotConfig/"..sPlotRes..".bytes"
	printc("Load ",sPath)
	local bytes = g_ResCtrl:Load(sPath)
	if not bytes then
		printc("警告：当前不存在的配置数据，请检查是否错误文件路径")
		return 
	end

	local sStr = tostring(bytes)
	local dPlot = decodejson(sStr)
	table.print(dPlot)
	self:OnLoadPlotDataFinish(dPlot)
end

function CPlotCtrl.OnLoadPlotDataFinish(self, dPlot)
	if not dPlot then
		printerror("CPlotCtrl.OnLoadPlotDataFinish n", self.m_CurTriggerPlot)
	end
	printc("CPlotCtrl.OnLoadPlotDataFinish")
	local dCamera = dPlot.cameraList[1]

	local oCameraEntiry = self:GetCameraConfigOfPlot(dPlot)
	local pos_info = {
	 	face_x = 0,
		face_y = 0,
		x = dCamera and dCamera.originPos.x*1000 or 0,
		y = dCamera and dCamera.originPos.y*1000 or 0,
	}

	self.m_NextPlotId = dPlot.nextPlot
	CPlotMaskView:ShowView(function(oView)
		oView:FadeIn(0.5)
	end)
	local function OnMapLoadDone()
		g_MainMenuCtrl:ShowMainMenu(false)
		g_MapCtrl:SetAllMapEffectActive(false, true)
		self.m_CurPlotPlayer = CGamePlotPlayer.New(dPlot)
	end
	printc("加载场景：",dPlot.sceneId)
	g_MapCtrl:AddLoadDoneCb(OnMapLoadDone)
	g_MapCtrl:ShowScene(0, dPlot.sceneId, "剧情", pos_info, true)
	g_MapCtrl:EnterScene(nil, pos_info)
end

function CPlotCtrl.ClosePresureView(self)
	-- TODO:未实现
end

function CPlotCtrl.RequestServer(self)
	-- TODO:未实现
	-- netscene.C2GSClickWorldMap(self.m_PreSceneId, self.m_PreEid, self.m_PreMapId)
end

function CPlotCtrl.GetCameraConfigOfPlot(self, dPlot)
 	if dPlot.cameraList ~= nil and #dPlot.cameraList > 0 then
 		return dPlot.cameraList[1]
 	else
		return nil
	end
end

function CPlotCtrl.Pause(self)
	if self.m_CurPlotPlayer then
		self.m_CurPlotPlayer:Pause()
	end
end

function CPlotCtrl.Resume(self)
	if self.m_CurPlotPlayer then
		self.m_CurPlotPlayer:Resume()
	end
end

function CPlotCtrl.SendSkipBgEvent(self, bActive)
	if bActive == 1 then
		self.m_IsShowingDialogueView = false
	else
		self.m_IsShowingDialogueView = true
	end
	self:OnEvent(define.Plot.Event.SkipBg, bActive)
end

--剧情弹幕相关处理
function CPlotCtrl.PlotBarrageHandle(self, iPlotId)
	
	self.m_StartTime = g_TimeCtrl:GetTimeS()

	--打开剧情弹幕UI
	CPlotBarrageSendView:ShowView()

	-- 请求剧情弹幕数据
	netbulletbarrage.C2GSGetStoryBulletBarrage(iPlotId)

	--检查剧情播放时刻
	g_BarrageCtrl:StartCheckPlotTime(self.m_StartTime)

end

return CPlotCtrl