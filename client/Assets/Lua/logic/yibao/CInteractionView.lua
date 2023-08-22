local CInteractionView = class("CInteractionView", CViewBase)

function CInteractionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/YiBao/InteractionView.prefab", cb)
	--界面设置
	self.m_DepthType = "Guide"
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Shelter"
	self.m_ScaleRatio = 0.3
	self.m_ScreenWidth = 1280
	self.m_ScreenHeight = 768
	self.m_ActualTexWidth = nil
	self.m_ActualTexHeight = nil
	self.m_ShowColor = Color.New(0.8, 0.8, 0.8, 0)

	self.m_PixelNumx = 6
	self.m_PixelNumy = 6
	self.m_PointPixelNumx = 12
	self.m_PointPixelNumy = 12
	self.m_PixelOffsetX = 0
	self.m_PixelOffsetY = 0
	
	self.m_PixelShowColor = {}
	self.m_PointPixelShowColor = {}	

	self.m_TagBoxList = {}

	self.m_TimeTag = 0
	self.m_AutoOffsetPointX = 0
	self.m_AutoOffsetPointY = 0

	--涂擦图片相关
	self.m_PicPixelNumx = 9
	self.m_PicPixelNumy = 9
	self.m_PicPixelOffsetX = 0
	self.m_PicPixelOffsetY = 0
	self.m_PicPixelShowColor = {}

	--连线相关
	self.m_PointsLineList = {}
	self.m_PointPixelOffsetX = 35
	self.m_PointPixelOffsetY = 35

	--鲜花相关
	self.m_FlowerBoxList = {}
	self.m_FlowerPixelOffsetX = 50
	self.m_FlowerPixelOffsetY = 135
	self.m_FlowersLineList = {}
	self.m_FlowerInteractionDone = false
	
	--晶石相关
	self.m_CrystalOreBoxList = {}
	self.m_CrystalOrePixelOffsetX = 70
	self.m_CrystalOrePixelOffsetY = 70
	self.m_CrystalOreLineList = {}
	self.m_CrystalOreInteractionDone = false

	--绘制爱心相关
	self.m_LovePointsLineList = {}
	self.m_LovePointPixelOffsetX = 30
	self.m_LovePointPixelOffsetY = 30

	--救狗相关
	self.m_DogBoxList = {}
	self.m_DogPixelOffsetX = 300
	self.m_DogPixelOffsetY = 150
	-- self.m_DogsLineList = {}
	self.m_DogInteractionDone = false

	--灵魂球相关
	self.m_TotalNeedBall = 2
	self.m_CurHasBall = 0
	self.m_CurNeedType = 1

	--摇铃相关
	self.m_BellDoneList = {left = false, right = false}
	self.m_BellPixelOffsetX = 125
	self.m_BellPixelOffsetY = 135

	--药草相关
	self.m_HerbDoneList = {left = false, right = false}
	self.m_HerbPixelOffsetX = 300
	self.m_HerbPixelOffsetY = 157

	self.m_Texture2D = nil
	self.m_PicTexture2D = nil

	self.m_Test = false
end

function CInteractionView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Texture = self:NewUI(2, CTexture)
	self.m_DragWidget = self:NewUI(3, CWidget)
	self.m_LeftTimeLbl = self:NewUI(4, CLabel)
	self.m_TagClone = self:NewUI(7, CLabel)
	self.m_InstructionLbl = self:NewUI(8, CLabel)
	self.m_FlowerModel = self:NewUI(11, CObject)
	self.m_FlowerBrokenPointList = {}
	for i = 1, 4 do
		local brokenObj = self:NewUI(i+11, CObject)
		-- local oOldPos = brokenObj:GetLocalPos()
		-- brokenObj:SetLocalPos(Vector3.New(oOldPos.x, 0.12, oOldPos.y))
		brokenObj:SetActive(true)
		table.insert(self.m_FlowerBrokenPointList, brokenObj)
	end
	self.m_FlowerWidgetBox = self:NewUI(16, CBox)
	self.m_MaskTexture = self:NewUI(17, CTexture)
	-- self.m_FuBg = self:NewUI(18, CTexture)
	self.m_FlowerEffectWidget = self:NewUI(19, CWidget)

	self.m_FlowerBox = self:NewUI(20, CInteractionFlowerBox)
	self.m_FlowerBox:SetParentView(self)
	self.m_CrystalOreBox = self:NewUI(21, CInteractionCrystalOreBox)
	self.m_CrystalOreBox:SetParentView(self)
	self.m_LoveBox = self:NewUI(22, CInteractionLoveBox)
	self.m_LoveBox:SetParentView(self)

	self.m_LoveStartBg = self.m_LoveBox.m_LoveStartBg
	self.m_LoveEndBg = self.m_LoveBox.m_LoveEndBg
	self.m_LoveTagList = self.m_LoveBox.m_LoveTagList
	self.m_LoveEffWidget = self.m_LoveBox.m_LoveEffWidget
	self.m_LovePassLineSp = self.m_LoveBox.m_LovePassLineSp

	self.m_TimeSlider = self:NewUI(23, CSlider)
	self.m_KnifeWidget = self:NewUI(24, CWidget)

	self.m_DogBox = self:NewUI(25, CInteractionDogBox)
	self.m_DogEffectWidget = self.m_DogBox.m_DogEffectWidget
	self.m_DogEffectWidget2 = self.m_DogBox.m_DogEffectWidget2
	self.m_DogWidgetBox = self.m_DogBox.m_DogWidgetBox
	self.m_DogModel = self.m_DogBox.m_DogModel
	self.m_CageModel = self.m_DogBox.m_CageModel
	self.m_MainCageModel = CMainModel.New(self.m_CageModel.m_GameObject)
	self.m_DogBox:SetParentView(self)
	-- self.m_DogBrokenPointList = self.m_DogBox.m_DogBrokenPointList

	self.m_BallBox = self:NewUI(26, CInteractionBallBox)
	self.m_BallTitleLbl = self.m_BallBox.m_BallTitleLbl
	self.m_BallIcon = self.m_BallBox.m_BallIcon
	self.m_BallCountLbl = self.m_BallBox.m_BallCountLbl
	self.m_BallClone = self.m_BallBox.m_BallClone
	self.m_SkyWidget = self.m_BallBox.m_SkyWidget
	self.m_RiverWidget = self.m_BallBox.m_RiverWidget
	self.m_BallBg = self.m_BallBox.m_BallBg
	self.m_BallClone:SetActive(false)

	self.m_PictureBox = self:NewUI(27, CBox)
	self.m_PictureIcon = self.m_PictureBox:NewUI(1, CTexture)
	self.m_PictureMask = self.m_PictureBox:NewUI(2, CTexture)
	-- self.m_PictureBg = self.m_PictureBox:NewUI(3, CSprite)
	self.m_PictureDirtyTex = self.m_PictureBox:NewUI(3, CTexture)
	self.m_PicPlane = self.m_PictureBox:NewUI(4, CObject)
	self.m_PicFingerEffect = self.m_PictureBox:NewUI(5, CWidget)

	self.m_PictureBox:SetLocalPos(Vector3.New(0, 0, -700))

	self.m_BellBox = self:NewUI(28, CBox)
	self.m_BellModel = self.m_BellBox:NewUI(1, CObject)
	self.m_BellEffectWidget = self.m_BellBox:NewUI(2, CWidget)
	self.m_BellPosWidget = self.m_BellBox:NewUI(3, CWidget)
	self.m_MainBellModel = CMainModel.New(self.m_BellModel.m_GameObject)

	self.m_FuModel = self:NewUI(29, CObject)
	self.m_MainFuModel = CMainModel.New(self.m_FuModel.m_GameObject)

	self.m_ScreenEffWidget = self:NewUI(30, CWidget)

	self.m_HerbBox = self:NewUI(31, CBox)
	self.m_HerbModel = self.m_HerbBox:NewUI(1, CObject)
	self.m_HerbEffectWidget = self.m_HerbBox:NewUI(2, CWidget)
	self.m_HerbPosWidget = self.m_HerbBox:NewUI(3, CWidget)
	self.m_MainHerbModel = CMainModel.New(self.m_HerbModel.m_GameObject)

	self.m_ScreenWidth = UnityEngine.Screen.width
	self.m_ScreenHeight = UnityEngine.Screen.height

	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_LB:SetActive(false)
	end
	
	self:InitContent()
end

function CInteractionView.InitContent(self)
	UITools.ResizeToRootSize(self.m_MaskTexture, 10, 10)
	self.m_FlowerModel:SetActive(false)
	self.m_FlowerWidgetBox:SetActive(false)
	self.m_FuModel:SetActive(true)
	self.m_FlowerEffectWidget:DelEffect("Screen")
	self.m_DogBox:SetActive(false)
	self.m_BallBox:SetActive(false)
	self.m_PictureBox:SetActive(false)

	self.m_DragWidget:AddUIEvent("dragstart", callback(self, "OnDragInteractionStart"))
	self.m_DragWidget:AddUIEvent("drag", callback(self, "OnDragInteraction"))
	self.m_DragWidget:AddUIEvent("dragend", callback(self, "OnDragInteractionEnd"))

	g_InteractionCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_ActualTexWidth = math.ceil(self.m_ScreenWidth*self.m_ScaleRatio)
	self.m_ActualTexHeight = math.ceil(self.m_ScreenHeight*self.m_ScaleRatio)

	self.m_PixelShowColor = {}
	for i=1, self.m_PixelNumx do
		for j=1, self.m_PixelNumy do
			table.insert(self.m_PixelShowColor, Color.New(1, 1, 175/255, 1))
		end
	end
	for i=1, self.m_PointPixelNumx do
		for j=1, self.m_PointPixelNumy do
			table.insert(self.m_PointPixelShowColor, Color.New(1, 1, 0, 1))
		end
	end
	self.m_PixelOffsetX = math.ceil((self.m_PixelNumx + self.m_PixelNumy)/2)
	self.m_PixelOffsetY = math.ceil((self.m_PixelNumx + self.m_PixelNumy)/2)
	-- self.m_PointPixelOffsetX = math.ceil((self.m_PointPixelNumx + self.m_PointPixelNumy)/2)
	-- self.m_PointPixelOffsetY = math.ceil((self.m_PointPixelNumx + self.m_PointPixelNumy)/2)

	self.m_PicPixelShowColor = {}
	for i=1, self.m_PicPixelNumx do
		for j=1, self.m_PicPixelNumy do
			table.insert(self.m_PicPixelShowColor, Color.New(1, 1, 1, 0))
		end
	end
	self.m_PicPixelOffsetX = math.ceil((self.m_PicPixelNumx + self.m_PicPixelNumy)/2)
	self.m_PicPixelOffsetY = math.ceil((self.m_PicPixelNumx + self.m_PicPixelNumy)/2)
end

function CInteractionView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Yibao.Event.InteractionTime then
		if g_InteractionCtrl.m_YibaoInteractionTime > 0 then
			self.m_LeftTimeLbl:SetActive(false)
			self.m_LeftTimeLbl:SetText("剩余时间:"..os.date("%M:%S", g_InteractionCtrl.m_YibaoInteractionTime))
			self.m_TimeSlider:SetActive(true)
			self.m_TimeSlider:SetValue((g_InteractionCtrl.m_YibaoInteractionSetTime - g_InteractionCtrl.m_YibaoInteractionTime) / g_InteractionCtrl.m_YibaoInteractionSetTime)
		else
			self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
			self.m_LeftTimeLbl:SetText("")
			self.m_TimeSlider:SetActive(true)
			self.m_TimeSlider:SetValue(1)

			if g_InteractionCtrl.m_ForthDone then
				if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					self.m_FlowerEffectWidget:DelEffect("Screen")
					for k,v in ipairs(self.m_FlowersLineList) do
						if v.hasbeendrag == false then
							self.m_FlowerBrokenPointList[v.point]:SetActive(true)
							-- local tween = DOTween.DOLocalMoveY(self.m_FlowerBrokenPointList[v.point].m_Transform, 2.1, 0.5)
							local vet = {self.m_FlowerBrokenPointList[v.point].m_Transform.localPosition, Vector3.New(-1.7, -0.9, 0)}
							local tween = DOTween.DOLocalPath(self.m_FlowerBrokenPointList[v.point].m_Transform, vet, 0.5, 0, 0, 10, nil)
							DOTween.SetEase(tween, 1)
							local function finish()
								self.m_FlowerBrokenPointList[v.point]:SetActive(false)
							end
							DOTween.OnComplete(tween, finish)
						end
					end
					-- g_NotifyCtrl:FloatItemBox(10136)
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkAnyPattern then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					local tween = self.m_Texture:GetComponent(classtype.TweenScale)
					self.m_Texture:SetLocalScale(Vector3.New(1, 1, 1))
					tween.enabled = true
					tween.from = Vector3.New(1, 1, 1)
					tween.to = Vector3.New(0.22, 0.22, 1)
					tween.duration = 0.3
					tween:ResetToBeginning()
					tween.delay = 0
					tween:PlayForward()
					tween.onFinished = function ()
						local function onAnimEnd()
							if Utils.IsNil(self) then
								return false
							end
							self.m_ScreenEffWidget:AddEffect("Screen", "ui_eff_0046")
							return false
						end
						self.m_MainFuModel:CrossFade("show", 1.533)

						if self.m_WaterTimer then
							Utils.DelTimer(self.m_WaterTimer)
							self.m_WaterTimer = nil
						end
						self.m_WaterTimer = Utils.AddTimer(onAnimEnd, 0, 1.533)
					end
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPicture then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					self.m_PicPlane:SetActive(false)
					self.m_ScreenEffWidget:AddEffect("Screen", "ui_eff_0049")

					if self.m_PicTimer then
						Utils.DelTimer(self.m_PicTimer)
						self.m_PicTimer = nil			
					end
					local function progress()
						if Utils.IsNil(self) then
							return false
						end
						self.m_PictureIcon:SetActive(false)
						return false
					end	
					self.m_PicTimer = Utils.AddTimer(progress, 0, 0.8)
					self.m_PictureDirtyTex:SetActive(false)
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkDog then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					self.m_DogEffectWidget:DelEffect("Screen")
					self.m_DogEffectWidget2:DelEffect("Screen")
					self.m_MainCageModel:CrossFade("idleRide")
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBall then
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBell then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					self.m_BellEffectWidget:DelEffect("Screen")
					self.m_MainBellModel:CrossFade("show")
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkHerb then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					self.m_HerbEffectWidget:DelEffect("Screen")
					-- g_NotifyCtrl:FloatItemBox(10136)
					self.m_MainHerbModel:CrossFade("show")
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
					self.m_TimeSlider:SetActive(false)
					self.m_InstructionLbl:SetActive(false)
					for k,v in pairs(self.m_LoveTagList) do
						v:SetActive(false)
					end
					self.m_LoveEndBg:SetActive(true)
					self.m_LoveEffWidget:AddEffect("Screen", "ui_eff_0048")
				end
			end
		end
	elseif oCtrl.m_EventID == define.Yibao.Event.InteractionLightTime then
		if g_InteractionCtrl.m_YibaoInteractionLightTime > 0 then
			self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		else
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LB:SetActive(true)
			end
			local oNotifyView = CNotifyView:GetView()
			if oNotifyView then
				oNotifyView.m_UIPanel.sortingOrder = 0
				local oPos = oNotifyView.m_FloatTable:GetLocalPos()
				oNotifyView.m_FloatTable:SetLocalPos(Vector3.New(oPos.x, oPos.y, 0))
			end
			g_NetCtrl:SetCacheProto("interaction", false)
			g_NetCtrl:ClearCacheProto("interaction", true)
			self:CloseView()
		end
	elseif oCtrl.m_EventID == define.Yibao.Event.InteractionFailTime then
		if g_InteractionCtrl.m_YibaoInteractionFailTime > 0 then
			self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
			--暂时屏蔽自动画线
			-- self:SetAutoDrawLine(oCtrl.m_EventData)

			if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then
				self.m_FlowerEffectWidget:DelEffect("Screen")
			end
		else
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LB:SetActive(true)
			end
			local oNotifyView = CNotifyView:GetView()
			if oNotifyView then
				oNotifyView.m_UIPanel.sortingOrder = 0
				local oPos = oNotifyView.m_FloatTable:GetLocalPos()
				oNotifyView.m_FloatTable:SetLocalPos(Vector3.New(oPos.x, oPos.y, 0))
			end
			g_NetCtrl:SetCacheProto("interaction", false)
			g_NetCtrl:ClearCacheProto("interaction", true)
			self:CloseView()
		end
	elseif oCtrl.m_EventID == define.Yibao.Event.InteractionCrystalOreFailTime then
		if g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime > 0 then
			self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false

			for k,v in ipairs(self.m_CrystalOreBoxList) do
				if not self:GetIsCrystalOreDoneById(k) then
					v:NewUI(1, CSprite):SetActive(false)
					v:NewUI(2, CSprite):SetActive(true)
					local tween = v:NewUI(2, CSprite):GetComponent(classtype.TweenAlpha)
					tween:ResetToBeginning()
					tween.from = 1
					tween.to = 0
					tween.delay = 0.5
					tween.duration = 1
					tween:Play(true)
				end
			end			
		else
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LB:SetActive(true)
			end
			g_NetCtrl:SetCacheProto("interaction", false)
			g_NetCtrl:ClearCacheProto("interaction", true)
			self:CloseView()
		end
	end
end

function CInteractionView.SetContent(self)
	g_InteractionCtrl.IsShowing = true
	if self.m_Test then
		g_NetCtrl:SetCacheProto("interaction", true)
		g_InteractionCtrl.m_ForthDone = true
		g_InteractionCtrl.m_InteractionQteConfig = {}
		g_InteractionCtrl.m_InteractionQteConfig.type = 5
		g_InteractionCtrl.m_InteractionQteConfig.desc = "操作描述操作描述"
	end

	--判断是否成功的变量
	g_InteractionCtrl.m_YibaoInteractionResult = 2

	local oView = CNotifyView:GetView()
	if oView then
		-- oView.m_FloatTable:Clear()
		oView:ClearFloatMsg()
	end

	local bIsNeedTex2D = false
	if table.index({define.Yibao.InteractionType.LinkPoint, define.Yibao.InteractionType.LinkCrystalOre, define.Yibao.InteractionType.LinkAnyPattern, 
	}, g_InteractionCtrl.m_InteractionQteConfig.type)  then
		bIsNeedTex2D = true
	end
	
	if bIsNeedTex2D then
		self.m_Texture2D = UnityEngine.Texture2D.New(self.m_ActualTexWidth, self.m_ActualTexHeight, 4, false)
		self.m_Texture:SetMainTexture(self.m_Texture2D)	
		local offsetW = -150
		local offsetH = offsetW*(self.m_ScreenHeight/self.m_ScreenWidth)
		UITools.ResizeToRootSize(self.m_Texture, offsetW, offsetH)

		local list = {}
		for i=1, self.m_ActualTexWidth do
			for j=1, self.m_ActualTexHeight do
				table.insert(list, self.m_ShowColor)
			end
		end
		self.m_Texture2D:SetPixels(0, 0, self.m_ActualTexWidth, self.m_ActualTexHeight, list)
	end

	self.m_LoveBox:SetActive(false)
	self.m_LoveStartBg:SetActive(true)
	self.m_LoveEndBg:SetActive(false)
	for k,v in pairs(self.m_LoveTagList) do
		v:SetActive(true)
	end

	self.m_InstructionLbl:SetText(g_InteractionCtrl.m_InteractionQteConfig.desc)

	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then

		-- self:SetInitPoints()
		self:InitPointsLineList()
		table.print(self.m_PointsLineList, "self.m_PointsLineList")
		self:SetTagUIInfo()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
				printc("开始互动任务的总计时1 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
				printc("开始互动任务的总计时2 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then

		self:InitFlowersLineList()
		self:SetFlowerUIInfo()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
				printc("开始互动任务的总计时1 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
				printc("开始互动任务的总计时2 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then

		self:InitCrystalOreLineList()
		self:SetCrystalOreUIInfo()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
				printc("开始互动任务的总计时1 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
				printc("开始互动任务的总计时2 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkAnyPattern then
		self.m_IsLinkAnyPatternDone = false
		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			printc("连线的时间",g_InteractionCtrl.m_YibaoInteractionSetTime)
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
		self.m_FuModel:SetActive(false)
		self.m_LoveBox:SetActive(true)
		-- self.m_InstructionLbl:SetActive(false)
		self:InitLovePointsLineList()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 360
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
				printc("开始互动任务的总计时1 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
				printc("开始互动任务的总计时2 "..g_InteractionCtrl.m_YibaoInteractionSetTime)
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPicture then
		local markWidth = 250
		local markHeight = 150
		-- self.m_PicFingerEffect:SetPos(self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5-markWidth*0.5, self.m_ScreenHeight*0.5+markHeight*0.5)))
		self.m_PicFingerEffect:SetLocalPos(Vector3.New(-120, 100, 0))
		self.m_PicFingerEffect:AddEffect("Screen", "ui_eff_0055")
		-- local vetList = {
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5-markWidth*0.5, self.m_ScreenHeight*0.5+markHeight*0.5)), 
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5+markWidth*0.5, self.m_ScreenHeight*0.5+markHeight*0.5)),
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5-markWidth*0.5, self.m_ScreenHeight*0.5)),
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5+markWidth*0.5, self.m_ScreenHeight*0.5)),
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5-markWidth*0.5, self.m_ScreenHeight*0.5-markHeight*0.5)),
		-- self:GetWorldPos(Vector2.New(self.m_ScreenWidth*0.5+markWidth*0.5, self.m_ScreenHeight*0.5-markHeight*0.5)),
		-- }
		local vetList = {
			Vector3.New(-120, 100, 0),
			Vector3.New(120, 100, 0),
			Vector3.New(-120, 0, 0),
			Vector3.New(120, 0, 0),
			Vector3.New(-120, -100, 0),
			Vector3.New(120, -100, 0),
		}
		local tweenPath = DOTween.DOLocalPath(self.m_PicFingerEffect.m_Transform, vetList, 3, 0, 0, 10, nil)
		DOTween.SetDelay(tweenPath, 0)
		DOTween.SetLoops(tweenPath, -1, 0)

		local oNotifyView = CNotifyView:GetView()
		if oNotifyView then
			oNotifyView.m_UIPanel.sortingOrder = 7
			local oPos = oNotifyView.m_FloatTable:GetLocalPos()
			oNotifyView.m_FloatTable:SetLocalPos(Vector3.New(oPos.x, oPos.y, -90))
		end
		-- self.m_PicTexture2D =  UnityEngine.Texture.ConvertToTex2D(self.m_PictureDirtyTex.m_UIWidget.mainTexture:Instantiate())
		-- self.m_PictureDirtyTex:SetMainTexture(self.m_PicTexture2D)

		-- self.m_PicPlaneTex2D = self.m_PicPlane:GetComponent(classtype.HolePaint).mTexture

		local oUICamera = g_CameraCtrl:GetUICamera()
		local oTargetScreenPos = oUICamera:WorldToScreenPoint(self.m_PictureDirtyTex.m_UIWidget.worldCorners[1])
		self.m_LeftBottomPointX = oTargetScreenPos.x
		self.m_LeftBottomPointY = oTargetScreenPos.y

		self.m_PictureBox:SetActive(true)
		self.m_FuModel:SetActive(false)
		self.m_Texture:SetActive(false)

		self.m_PictureMaskCount = 30
		-- local texPixels = self.m_PicTexture2D:GetPixels()
		-- for i=1, table.count(texPixels) do
		-- 	if texPixels[i].a ~= 0 then
		-- 		self.m_PictureMaskCount = self.m_PictureMaskCount + 1
		-- 	end
		-- end
		-- local texPixels = self.m_PicPlaneTex2D:GetPixels()
		-- for i=1, table.count(texPixels) do
		-- 	if texPixels[i].r == 1 then
		-- 		self.m_PictureMaskCount = self.m_PictureMaskCount + 1
		-- 	end
		-- end
		printc("污渍的数量:", self.m_PictureMaskCount)

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 14
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkDog then
		local oNotifyView = CNotifyView:GetView()
		if oNotifyView then
			oNotifyView.m_UIPanel.sortingOrder = 7
			local oPos = oNotifyView.m_FloatTable:GetLocalPos()
			oNotifyView.m_FloatTable:SetLocalPos(Vector3.New(oPos.x, oPos.y, -90))
		end

		self.m_DogInteractionDone = false
		self:SetDogUIInfo()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBall then

		self.m_CurHasBall = 0
		self.m_CurNeedType = table.randomvalue({1, 2, 3})

		UITools.NearTarget(self.m_BallBg, self.m_TimeSlider, enum.UIAnchor.Side.Bottom)
		UITools.NearTarget(self.m_TimeSlider, self.m_InstructionLbl, enum.UIAnchor.Side.Bottom)

		self:RefreshBallBox()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 14
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBell then

		self.m_MainBellModel:SetLocalScale(Vector3.New(1, 1, 1))
		local tweenScale = DOTween.DOScale(self.m_MainBellModel.m_Transform, Vector3.New(250, 250, 250), 1)
		DOTween.SetDelay(tweenScale, 0)

		self.m_BellDoneList = {left = false, right = false}
		self:RefreshBellBox()

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkHerb then

		self.m_HerbDoneList = {left = false, right = false}
		self:RefreshHerbBox()
		self.m_InstructionLbl:SetLocalPos(Vector3.New(0, 30, 0))
		self.m_TimeSlider:SetLocalPos(Vector3.New(0, 0, 0))

		if self.m_Test then
			g_InteractionCtrl.m_YibaoInteractionSetTime = 10
			g_InteractionCtrl:SetInteractionCountTime()
		else
			--开始互动任务的总计时
			if g_InteractionCtrl.m_InteractionTotalTime then
				g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionTotalTime
			else
				if g_InteractionCtrl.m_InteractionQteConfig then
					g_InteractionCtrl.m_YibaoInteractionSetTime = g_InteractionCtrl.m_InteractionQteConfig.lasts
				else
					g_InteractionCtrl.m_YibaoInteractionSetTime = 10
				end
			end
			g_InteractionCtrl:SetInteractionCountTime()
		end
	end

	if bIsNeedTex2D then
		self.m_Texture2D:Apply(false)
	end
end

--------------------以下是拖动事件----------------------

function CInteractionView.OnDragInteractionStart(self, obj)
	if table.index({define.Yibao.InteractionType.LinkFlower, define.Yibao.InteractionType.LinkDog, define.Yibao.InteractionType.LinkBell, define.Yibao.InteractionType.LinkHerb}, g_InteractionCtrl.m_InteractionQteConfig.type)  then
		self:ShowKnifeEffect(true)
	end
	--开始互动任务拖动的计时
	g_InteractionCtrl:SetInteractionTouchTime()

	printc("OnDragInteractionStart")
end

function CInteractionView.OnDragInteraction(self, obj, moveDelta)
	local mousePosX = UnityEngine.Input.mousePosition.x
	if mousePosX > self.m_ScreenWidth then
		mousePosX = self.m_ScreenWidth
	elseif mousePosX < 0 then
		mousePosX = 0
	end
	local mousePosY = UnityEngine.Input.mousePosition.y
	if mousePosY > self.m_ScreenHeight then
		mousePosY = self.m_ScreenHeight
	elseif mousePosY < 0 then
		mousePosY = 0
	end

	self.m_KnifeWidget:SetPos(self:GetWorldPos(Vector2.New(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)))

	--鲜花不要画线了
	if table.index({define.Yibao.InteractionType.LinkPoint, define.Yibao.InteractionType.LinkCrystalOre, define.Yibao.InteractionType.LinkAnyPattern,}
	, g_InteractionCtrl.m_InteractionQteConfig.type) then
		self:CalculateTex2DDragColor(mousePosX, mousePosY, moveDelta)	
		self.m_Texture2D:Apply(false)
	end

	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
		self:SetPointsLineList(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then
		self:SetFolwersLineList(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then
		self:SetCrystalOreLineList(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
		self:SetLovePointsLineList(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)
		self:CheckLoveDone()
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkDog then
		if moveDelta.x < 0 then
			self:CheckDogDone(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y)
		end
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPicture then
		self.m_PicFingerEffect:DelEffect("Screen")
		-- self:PictureCalculateTex2DDragColor(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, moveDelta, 256, 256)	
		self:CheckPictureDone()
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBell then
		self:CheckBellDone(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, moveDelta)
	end
	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkHerb then
		self:CheckHerbDone(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, moveDelta)
	end
	-- printc("UnityEngine.Input.mousePosition.x", mousePosX, mousePosY)
	-- printc("OnDragInteraction", moveDelta.x, moveDelta.y)
end

function CInteractionView.OnDragInteractionEnd(self, obj)
	self:ShowKnifeEffect(false)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	--互动任务拖动的计时停止
	g_InteractionCtrl:ResetInteractionTouchTimer()

	if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
		local isPointLineFinish = true
		table.print(self.m_PointsLineList, "self.m_PointsLineList")
		for k,v in pairs(self.m_PointsLineList) do
			if v.hasbeendrag == false then
				isPointLineFinish = false
				break
			end
		end

		--isFinish暂时屏蔽
		if isPointLineFinish then --isFinish and 
			self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
			g_InteractionCtrl.m_YibaoInteractionResult = 1

			g_NotifyCtrl:FloatMsg("连线成功啦")
			--开始互动任务成功后的亮光特效计时
			g_InteractionCtrl:SetInteractionLightCountTime()
			--互动任务的总计时停止
			g_InteractionCtrl:ResetInteractionTimer()
			self.m_LeftTimeLbl:SetText("")
			self.m_TimeSlider:SetActive(false)
			self.m_InstructionLbl:SetActive(false)
		else
			g_NotifyCtrl:FloatMsg(data.interactiondata.TEXT[define.Yibao.InteractionText.Again].content)
			if g_InteractionCtrl.m_YibaoInteractionResult == 2 then
				self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = true
			end

			local list = {}
			for i=1, self.m_ActualTexWidth do
				for j=1, self.m_ActualTexHeight do
					table.insert(list, self.m_ShowColor)
				end
			end
			self.m_Texture2D:SetPixels(0, 0, self.m_ActualTexWidth, self.m_ActualTexHeight, list)
			self.m_Texture2D:Apply(false)

			self:InitPointsLineList()
			--很有必要
			self.m_CheckStartPoint = nil
			table.print(self.m_PointsLineList, "Reset self.m_PointsLineList")
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then
		self:CheckFlowerDone()
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then
		local list = {}
		for i=1, self.m_ActualTexWidth do
			for j=1, self.m_ActualTexHeight do
				table.insert(list, self.m_ShowColor)
			end
		end
		self.m_Texture2D:SetPixels(0, 0, self.m_ActualTexWidth, self.m_ActualTexHeight, list)
		self.m_Texture2D:Apply(false)

		self:CheckCrystalOreDone()
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkAnyPattern then
		g_InteractionCtrl.m_YibaoInteractionResult = 1
		self.m_IsLinkAnyPatternDone = true
	
		self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_LeftTimeLbl:SetText("")
		self.m_TimeSlider:SetActive(false)
		self.m_InstructionLbl:SetActive(false)

		--绘制成功后的表现
		local tween = self.m_Texture:GetComponent(classtype.TweenScale)
		self.m_Texture:SetLocalScale(Vector3.New(1, 1, 1))
		tween.enabled = true
		tween.from = Vector3.New(1, 1, 1)
		tween.to = Vector3.New(0.1, 0.1, 1)
		tween.duration = 0.3
		tween:ResetToBeginning()
		tween.delay = 0
		tween:PlayForward()
		tween.onFinished = function ()
			local function onAnimEnd()
				if Utils.IsNil(self) then
					return false
				end
				self.m_ScreenEffWidget:AddEffect("Screen", "ui_eff_0046")
				g_NotifyCtrl:FloatMsg("绘制咒文成功啦")
				g_InteractionCtrl:SetInteractionLightCountTime()
				return false
			end
			self.m_MainFuModel:CrossFade("show", 1.533)

			if self.m_WaterTimer then
				Utils.DelTimer(self.m_WaterTimer)
				self.m_WaterTimer = nil
			end
			self.m_WaterTimer = Utils.AddTimer(onAnimEnd, 0, 1.533)
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
		if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
			return
		end
		if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
			return
		end
		local isLovePointLineFinish = self:CheckLoveDone()

		if isLovePointLineFinish then
			
		else
			g_NotifyCtrl:FloatMsg("请完整连线哦") --"请按照数字首尾顺序连接哦"
			if g_InteractionCtrl.m_YibaoInteractionResult == 2 then
				self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = true
			end

			-- self:InitLovePointsLineList()
			self.m_LovePassLineSp:SetActive(false)
			for k,v in pairs(self.m_LoveTagList) do
				v:NewUI(1, CSprite):SetActive(false)
			end
			for k,v in ipairs(self.m_LovePointsLineList) do
				if v.hasbeendrag then
					self.m_LoveTagList[v.point1]:NewUI(1, CSprite):SetActive(true)
					self.m_LoveTagList[v.point2]:NewUI(1, CSprite):SetActive(true)
				end
			end
			--很有必要
			self.m_CheckStartPoint = nil
			table.print(self.m_LovePointsLineList, "Reset self.m_LovePointsLineList")
		end
	elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPicture then
		self:CheckPictureDone()
	end

	printc("OnDragInteractionEnd", g_InteractionCtrl.m_YibaoInteractionTouchTime)
end

---------------------以下是画线接口-------------------

--清空tex2d的画线
function CInteractionView.ResetTex2D(self)
	local list = {}
	for i=1, self.m_ActualTexWidth do
		for j=1, self.m_ActualTexHeight do
			table.insert(list, self.m_ShowColor)
		end
	end
	self.m_Texture2D:SetPixels(0, 0, self.m_ActualTexWidth, self.m_ActualTexHeight, list)
end

function CInteractionView.SetPixelLimitValue(self, value, maxVal, isValueX)
	local offset
	if isValueX then
		offset = self.m_PixelOffsetX
	else
		offset = self.m_PixelOffsetY
	end
	if value <= offset then
		value = 1 + offset
	elseif value >= maxVal - offset then
		value = maxVal - 1 - offset
	end
	return value
end

--起始点的设置
function CInteractionView.SetPointPixelLimitValue(self, value, maxVal, isValueX)
	local offset
	if isValueX then
		offset = self.m_PointPixelOffsetX
	else
		offset = self.m_PointPixelOffsetY
	end
	if value <= offset then
		value = 1 + offset
	elseif value >= maxVal - offset then
		value = maxVal - 1 - offset
	end
	return value
end

function CInteractionView.CalculateTex2DDragColor(self, mousePosX, mousePosY, moveDelta)
	if moveDelta.x > self.m_ScreenWidth then
		moveDelta.x = self.m_ScreenWidth
	elseif moveDelta.x < -self.m_ScreenWidth then
		moveDelta.x = -self.m_ScreenWidth
	end
	if moveDelta.y > self.m_ScreenHeight then
		moveDelta.y = self.m_ScreenHeight
	elseif moveDelta.y < -self.m_ScreenHeight then
		moveDelta.y = -self.m_ScreenHeight
	end

	local originPosX = mousePosX - moveDelta.x
	local originPosY = mousePosY - moveDelta.y

	if moveDelta.x == 0 then
		-- if math.abs(moveDelta.y) == 0 then
		-- 	return
		-- end
		local width = mousePosX*self.m_ScaleRatio
		width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)
		if moveDelta.y ~= 0 then
			if moveDelta.y > 0 then	
				for i=1, math.abs(moveDelta.y) do			
					local height = (mousePosY - moveDelta.y + i)*self.m_ScaleRatio
					height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)
					self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)

					if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
						-- self:SetPointsLineList(width, height)
					elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
						-- self:SetLovePointsLineList(width, height)
					end
				end
			elseif moveDelta.y < 0 then	
				for i=1, math.abs(moveDelta.y) do
					local height = (mousePosY - moveDelta.y - i)*self.m_ScaleRatio
					height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)
					self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
					if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
						-- self:SetPointsLineList(width, height)
					elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
						-- self:SetLovePointsLineList(width, height)
					end
				end
			end
		elseif moveDelta.y == 0 then
			local height = (mousePosY - moveDelta.y)*self.m_ScaleRatio
			height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)
			self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
			if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
				-- self:SetPointsLineList(width, height)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
				-- self:SetLovePointsLineList(width, height)
			end
		end
	elseif moveDelta.x < 0 then
		if math.abs(moveDelta.x) >=  math.abs(moveDelta.y) then
			for i=1, math.abs(moveDelta.x) do
				local width = (mousePosX - (moveDelta.x + i))*self.m_ScaleRatio
				width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)

				-- local ratio = moveDelta.y/moveDelta.x
				-- local yDelta = (moveDelta.x + i)*ratio

				local height = (mousePosY - (moveDelta.y*(moveDelta.x + i)/moveDelta.x))*self.m_ScaleRatio
				height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)
				self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
				if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
					-- self:SetPointsLineList(width, height)
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
					-- self:SetLovePointsLineList(width, height)
				end
			end
		else
			self:SetTex2DYValue(mousePosX, mousePosY, moveDelta)
		end
	elseif moveDelta.x > 0 then
		if math.abs(moveDelta.x) >=  math.abs(moveDelta.y) then
			for i=1, math.abs(moveDelta.x) do
				local width = (mousePosX - (moveDelta.x - i))*self.m_ScaleRatio
				width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)
				local height = (mousePosY - (moveDelta.y*(moveDelta.x - i)/moveDelta.x))*self.m_ScaleRatio
				height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)
				self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
				if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
					-- self:SetPointsLineList(width, height)
				elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
					-- self:SetLovePointsLineList(width, height)
				end
			end
		else
			self:SetTex2DYValue(mousePosX, mousePosY, moveDelta)
		end
	end
end

function CInteractionView.SetTex2DYValue(self, mousePosX, mousePosY, moveDelta)
	if moveDelta.y < 0 then
		for i=1, math.abs(moveDelta.y) do
			local height = (mousePosY - (moveDelta.y + i))*self.m_ScaleRatio
			height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)

			local width = (mousePosX - (moveDelta.x*(moveDelta.y + i)/moveDelta.y))*self.m_ScaleRatio
			width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)
			
			self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
			if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
				-- self:SetPointsLineList(width, height)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
				-- self:SetLovePointsLineList(width, height)
			end
		end
	elseif moveDelta.y > 0 then
		for i=1, math.abs(moveDelta.y) do
			local height = (mousePosY - (moveDelta.y - i))*self.m_ScaleRatio
			height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)

			local width = (mousePosX - (moveDelta.x*(moveDelta.y - i)/moveDelta.y))*self.m_ScaleRatio
			width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)
			
			self.m_Texture2D:SetPixels(width, height, self.m_PixelNumx, self.m_PixelNumy, self.m_PixelShowColor)
			if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
				-- self:SetPointsLineList(width, height)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
				-- self:SetLovePointsLineList(width, height)
			end
		end
	end
end

function CInteractionView.SetInitPoints(self)
	for k,v in ipairs(self:GetPointsPos()) do
		local width = v[1]*self.m_ScaleRatio
		width = self:SetPixelLimitValue(width, self.m_ActualTexWidth, true)

		local height = v[2]*self.m_ScaleRatio
		height = self:SetPixelLimitValue(height, self.m_ActualTexHeight)

		self.m_Texture2D:SetPixels(width, height, self.m_PointPixelNumx, self.m_PointPixelNumy, self.m_PointPixelShowColor)
	end
end

function CInteractionView.SetTagUIInfo(self)
	if next(self.m_TagBoxList) then
		for k,v in pairs(self.m_TagBoxList) do
			self.m_TagBoxList.m_GameObject:Destroy()
		end
		self.m_TagBoxList = {}
	end
	local oData = self:GetPointsPos()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddTagUIBox(k, Vector3.New(v[1] - 10, v[2] + 20, 0))
		end
	end
end

function CInteractionView.AddTagUIBox(self, oTag, oScreenPos)
	local oTagBox = self.m_TagClone:Clone()

	table.insert(self.m_TagBoxList, oTagBox)

	oTagBox:SetParent(self.m_Widget.m_Transform)
	
	oTagBox:SetActive(true)
	oTagBox:SetText("#gold_"..oTag)
	local pos = g_CameraCtrl:GetUICamera():ScreenToWorldPoint(oScreenPos)
	oTagBox:SetPos(pos)
end

function CInteractionView.InitPointsLineList(self)
	self.m_PointsLineList = {}
	if #self:GetPointsPos() <= 2 then
		for i=1,#self:GetPointsPos() - 1 do
			local list = {}
			list.point1 = i
			list.point2 = i + 1
			list.hasbeendrag = false
			table.insert(self.m_PointsLineList, list)
		end
	else
		for i=1,#self:GetPointsPos() - 1 do
			local list = {}
			list.point1 = i
			list.point2 = i + 1
			list.hasbeendrag = false
			table.insert(self.m_PointsLineList, list)
		end
		local list = {}
		list.point1 = #self:GetPointsPos()
		list.point2 = 1
		list.hasbeendrag = false
		table.insert(self.m_PointsLineList, list)
	end
end

function CInteractionView.SetPointsLineList(self, dragwidth, dragheight)	
	if self:CheckPointsInDragArea(dragwidth, dragheight) then
		-- g_NotifyCtrl:FloatMsg("CheckPointsInDragArea".. self:CheckPointsInDragArea(dragwidth, dragheight))
		if not self.m_CheckStartPoint then
			self.m_CheckStartPoint = self:CheckPointsInDragArea(dragwidth, dragheight)
			return
		else
			for k,v in ipairs(self.m_PointsLineList) do
				if (v.point1 == self.m_CheckStartPoint and v.point2 == self:CheckPointsInDragArea(dragwidth, dragheight)) or
				   (v.point2 == self.m_CheckStartPoint and v.point1 == self:CheckPointsInDragArea(dragwidth, dragheight)) then
				   v.hasbeendrag = true
				   break
				end
			end
			self.m_CheckStartPoint = self:CheckPointsInDragArea(dragwidth, dragheight)
		end
	end
end

function CInteractionView.IsColorEqual(self, col1, col2)
	if col1.r == col2.r and col1.g == col2.g and col1.b == col2.b and col1.a == col2.a then
		return true
	end
	return false
end

function CInteractionView.CheckPointsInDragArea(self, dragwidth, dragheight)
	for k,v in ipairs(self:GetPointsPos()) do
		-- local width = v[1]*self.m_ScaleRatio
		-- width = self:SetPointPixelLimitValue(width, self.m_ActualTexWidth, true)
		-- local height = v[2]*self.m_ScaleRatio		
		-- height = self:SetPointPixelLimitValue(height, self.m_ActualTexHeight)

		if math.abs(v[1] - dragwidth) <= self.m_PointPixelOffsetX
		and math.abs(v[2] - dragheight) <= self.m_PointPixelOffsetY then
			return k
		end
	end
end

function CInteractionView.SetAutoDrawLine(self, time)
	if time > 0 and time <= #self:GetPointsPos() then
		-- printc("CInteractionView.SetAutoDrawLine", self.m_PointsLineList[math.ceil(time == 0 and 0.1 or time)].point1, ",", math.ceil(time))
		local point1 = self:GetPointsPos()[self.m_PointsLineList[math.ceil((time == 0 and {0.1} or {time})[1])].point1]
		local point2 = self:GetPointsPos()[self.m_PointsLineList[math.ceil((time == 0 and {0.1} or {time})[1])].point2]

		if self.m_TimeTag ~= math.ceil(time) then
			self.m_AutoOffsetPointX = point1[1] + math.ceil((point2[1] - point1[1])/8)
			self.m_AutoOffsetPointY = point1[2] + math.ceil((point2[2] - point1[2])/8)
			self.m_TimeTag = math.ceil(time)
		end

		if math.ceil(time) == 2 then
			if time - math.floor(time) < 0.9 then
				local delta = Vector2.New(math.ceil((point2[1] - point1[1])/8), math.ceil((point2[2] - point1[2])/8))
				-- printc("哈哈哈哈哈哈", delta.x, " ,", delta.y)
				self:CalculateTex2DDragColor(self.m_AutoOffsetPointX, self.m_AutoOffsetPointY, delta)
				self.m_AutoOffsetPointX = self.m_AutoOffsetPointX + math.ceil((point2[1] - point1[1])/8)
				self.m_AutoOffsetPointY = self.m_AutoOffsetPointY + math.ceil((point2[2] - point1[2])/8)
			end
		elseif math.ceil(time) == 5 then
			if time - math.floor(time) < 0.7 then
				local delta = Vector2.New(math.ceil((point2[1] - point1[1])/8), math.ceil((point2[2] - point1[2])/8))
				-- printc("哈哈哈哈哈哈", delta.x, " ,", delta.y)
				self:CalculateTex2DDragColor(self.m_AutoOffsetPointX, self.m_AutoOffsetPointY, delta)
				self.m_AutoOffsetPointX = self.m_AutoOffsetPointX + math.ceil((point2[1] - point1[1])/8)
				self.m_AutoOffsetPointY = self.m_AutoOffsetPointY + math.ceil((point2[2] - point1[2])/8)
			end
		else
			if time - math.floor(time) < 0.8 then
				local delta = Vector2.New(math.ceil((point2[1] - point1[1])/8), math.ceil((point2[2] - point1[2])/8))
				-- printc("吼吼吼吼吼吼吼吼吼", delta.x, " ,", delta.y)
				self:CalculateTex2DDragColor(self.m_AutoOffsetPointX, self.m_AutoOffsetPointY, delta)
				self.m_AutoOffsetPointX = self.m_AutoOffsetPointX + math.ceil((point2[1] - point1[1])/8)
				self.m_AutoOffsetPointY = self.m_AutoOffsetPointY + math.ceil((point2[2] - point1[2])/8)
			end
		end
		
		self.m_Texture2D:Apply(false)
	end
end

function CInteractionView.ShowKnifeEffect(self, bShow)
	if bShow then
		self.m_KnifeWidget:SetActive(true)
		-- self.m_KnifeWidget:DelEffect("Tailing")
		-- self.m_KnifeWidget:AddEffect("Tailing", 3)

		self.m_KnifeWidget:DelEffect("Screen")
		self.m_KnifeWidget:AddEffect("Screen", "ui_eff_0047", nil, nil, nil, 3)
	else
		self.m_KnifeWidget:SetActive(false)
	end
end

function CInteractionView.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

-------------绘画鲜花类型相关的接口--------------

function CInteractionView.SetFlowerUIInfo(self)
	self.m_FlowerBox:SetFlowerUIInfo()
end

function CInteractionView.AddFlowerUIBox(self, oFlower, oScreenPos)
	self.m_FlowerBox:AddFlowerUIBox(oFlower, oScreenPos)
end

function CInteractionView.InitFlowersLineList(self)
	self.m_FlowerBox:InitFlowersLineList()
end

function CInteractionView.SetFolwersLineList(self, dragwidth, dragheight)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	self.m_FlowerBox:SetFolwersLineList(dragwidth, dragheight)
end

function CInteractionView.CheckFlowersInDragArea(self, dragwidth, dragheight)
	return self.m_FlowerBox:CheckFlowersInDragArea(dragwidth, dragheight)
end

function CInteractionView.CheckFlowerDone(self)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	self.m_FlowerBox:CheckFlowerDone()
end

function CInteractionView.GetIsFlowerDoneById(self, id)
	return self.m_FlowerBox:GetIsFlowerDoneById(id)
end

-------------绘画晶矿类型相关的接口--------------

function CInteractionView.SetCrystalOreUIInfo(self)
	self.m_CrystalOreBox:SetCrystalOreUIInfo()
end

function CInteractionView.AddCrystalOreUIBox(self, oCrystalOre, oScreenPos)
	self.m_CrystalOreBox:AddCrystalOreUIBox(oCrystalOre, oScreenPos)
end

function CInteractionView.InitCrystalOreLineList(self)
	self.m_CrystalOreBox:InitCrystalOreLineList()
end

function CInteractionView.SetCrystalOreLineList(self, dragwidth, dragheight)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	self.m_CrystalOreBox:SetCrystalOreLineList(dragwidth, dragheight)
end

function CInteractionView.CheckCrystalOreInDragArea(self, dragwidth, dragheight)
	return self.m_CrystalOreBox:CheckCrystalOreInDragArea(dragwidth, dragheight)
end

function CInteractionView.CheckCrystalOreDone(self)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	self.m_CrystalOreBox:CheckCrystalOreDone()
end

function CInteractionView.GetIsCrystalOreDoneById(self, id)
	return self.m_CrystalOreBox:GetIsCrystalOreDoneById(id)
end

--------------绘制爱心相关接口-----------------

function CInteractionView.InitLovePointsLineList(self)
	self.m_LoveBox:InitLovePointsLineList()
end

function CInteractionView.SetLovePointsLineList(self, dragwidth, dragheight)	
	self.m_LoveBox:SetLovePointsLineList(dragwidth, dragheight)
end

function CInteractionView.CheckLovePointsInDragArea(self, dragwidth, dragheight)
	return self.m_LoveBox:CheckLovePointsInDragArea(dragwidth, dragheight)
end

function CInteractionView.CheckLoveDone(self)
	return self.m_LoveBox:CheckLoveDone()
end

-------------救狗类型相关的接口--------------

function CInteractionView.SetDogUIInfo(self)
	self.m_DogBox:SetDogUIInfo()
end

function CInteractionView.CheckDogDone(self, dragwidth, dragheight)
	self.m_DogBox:CheckDogDone(dragwidth, dragheight)
end

---------------灵魂球相关接口--------------

function CInteractionView.RefreshBallBox(self)
	self.m_SkyWidget:AddEffect("Circu", nil, 3)
	self.m_RiverWidget:AddEffect("Circu", nil, 3)
	self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
	self.m_BallBox:SetActive(true)
	self.m_FuModel:SetActive(false)
	self.m_BallCountLbl:SetText(self.m_CurHasBall.."/"..self.m_TotalNeedBall)
	self.m_BallIcon:SetSpriteName(self:GetBallTypeSprite(self.m_CurNeedType))
	self:SetBallCloneTime()
end

function CInteractionView.GetBallTypeSprite(self, type)
	if type == 1 then
		return "10001"
	elseif type == 2 then
		return "10002"
	elseif type == 3 then
		return "10003"
	end
end

--灵魂球生成
function CInteractionView.SetBallCloneTime(self)	
	self:ResetBallCloneTimer()
	local function progress()
		if Utils.IsNil(self) or self.m_CurHasBall >= self.m_TotalNeedBall then
			return false
		end
		local oBall = self.m_BallClone:Clone(false)
		oBall:SetParent(self.m_BallBox.m_Transform)
		oBall.m_Type = table.randomvalue({1, 2, 3})
		oBall:SetSpriteName(self:GetBallTypeSprite(oBall.m_Type))
		oBall:SetActive(true)
		oBall:SetPos(self:GetWorldPos(Vector2.New(0, UnityEngine.Screen.height*0.12)))
		oBall:AddUIEvent("click", callback(self, "OnClickBall", oBall))

		local tweenX = DOTween.DOLocalMoveX(oBall.m_Transform, UnityEngine.Screen.width + 100, 14)
		oBall.m_TweenX = tweenX
		DOTween.SetEase(tweenX, 1)
		local function finish()
			if not Utils.IsNil(oBall) then
				oBall:Destroy()
			end
		end
		DOTween.OnComplete(tweenX, finish)

		local tweenY = DOTween.DOLocalMoveY(oBall.m_Transform, -100, 3.5)
		oBall.m_TweenY = tweenY
		DOTween.SetEase(tweenY, 1)
		DOTween.SetLoops(tweenY, -1, 1)
		
		return true
	end
	self.m_BallCloneTimer = Utils.AddTimer(progress, 2, 0)
end

function CInteractionView.ResetBallCloneTimer(self)
	if self.m_BallCloneTimer then
		Utils.DelTimer(self.m_BallCloneTimer)
		self.m_BallCloneTimer = nil			
	end
end

function CInteractionView.OnClickBall(self, oBall)
	if self.m_CurHasBall >= self.m_TotalNeedBall then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if oBall.m_Type ~= self.m_CurNeedType then
		g_NotifyCtrl:FloatMsg("点错了哦！")
		return
	end
	if oBall.m_Type == self.m_CurNeedType then
		self.m_CurHasBall = self.m_CurHasBall + 1
	end
	self.m_BallCountLbl:SetText(self.m_CurHasBall.."/"..self.m_TotalNeedBall)
	oBall.m_TweenX:Kill(false)
	oBall.m_TweenY:Kill(false)

	local vet = {oBall:GetPos(), self:GetWorldPos(Vector2.New(UnityEngine.Screen.width*0.5, UnityEngine.Screen.height - 50))}
	local tweenPath = DOTween.DOPath(oBall.m_Transform, vet, 1, 0, 0, 10, nil)
	DOTween.SetEase(tweenPath, 1)
	local function finish()
		if not Utils.IsNil(oBall) then
			oBall:Destroy()
		end
	end
	DOTween.OnComplete(tweenPath, finish)

	if self.m_CurHasBall >= self.m_TotalNeedBall then
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		g_NotifyCtrl:FloatMsg("灵魂球收集成功啦")
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_LeftTimeLbl:SetText("")
		self.m_TimeSlider:SetActive(false)
		self.m_InstructionLbl:SetActive(false)
	end
end

------------------画卷擦除相关------------------

function CInteractionView.CheckPictureDone(self)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end
	local maskCount = 0
	-- local texPixels = self.m_PicTexture2D:GetPixels()
	-- for i=1, table.count(texPixels) do
	-- 	if texPixels[i].a ~= 0 then
	-- 		maskCount = maskCount + 1
	-- 	end
	-- end
	self.m_PicPlaneTex2D = self.m_PicPlane:GetComponent(classtype.HolePaint).mTexture
	local texPixels = self.m_PicPlaneTex2D:GetPixels()
	for i=1, table.count(texPixels) do
		if texPixels[i].r == 1 then
			maskCount = maskCount + 1
		end
	end
	printc("检查CheckPictureDone maskCount:", maskCount)

	if maskCount/self.m_PictureMaskCount <= 0.7 then
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		
		self.m_PicPlane:SetActive(false)
		-- g_NotifyCtrl:FloatMsg("寻找图案成功啦")
		self.m_ScreenEffWidget:AddEffect("Screen", "ui_eff_0049")

		if self.m_PicTimer then
			Utils.DelTimer(self.m_PicTimer)
			self.m_PicTimer = nil			
		end
		local function progress()
			if Utils.IsNil(self) then
				return false
			end
			self.m_PictureIcon:SetActive(false)
			
			--开始互动任务成功后的亮光特效计时
			-- g_InteractionCtrl.m_YibaoInteractionLightSetTime = 5
			g_InteractionCtrl:SetInteractionLightCountTime()
			-- g_InteractionCtrl.m_YibaoInteractionLightSetTime = nil
			return false
		end	
		self.m_PicTimer = Utils.AddTimer(progress, 0, 0.8)
		self.m_PictureDirtyTex:SetActive(false)
		
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_LeftTimeLbl:SetText("")
		self.m_TimeSlider:SetActive(false)
		self.m_InstructionLbl:SetActive(false)
		-- self.m_PictureBg:SetActive(false)
		self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false		

		-- local list = {}
		-- for i=1, self.m_ActualTexWidth do
		-- 	for j=1, self.m_ActualTexHeight do
		-- 		table.insert(list, self.m_ShowColor)
		-- 	end
		-- end
		-- self.m_Texture2D:SetPixels(0, 0, self.m_ActualTexWidth, self.m_ActualTexHeight, list)
		-- self.m_Texture2D:Apply(false)

		-- local function delay()
		-- 	if Utils.IsNil(self) then
		-- 		return false
		-- 	end
		-- 	local tween = self.m_PictureIcon:GetComponent(classtype.TweenScale)
		-- 	self.m_PictureIcon:SetLocalScale(Vector3.New(1, 1, 1))
		-- 	tween.enabled = true
		-- 	tween.from = Vector3.New(1, 1, 1)
		-- 	tween.to = Vector3.New(1.55, 1.55, 1)
		-- 	tween.duration = 0.5
		-- 	tween:ResetToBeginning()
		-- 	tween.delay = 0
		-- 	tween:PlayForward()
		-- 	return false
		-- end
		-- Utils.AddTimer(delay, 0, 1)
	end
end

function CInteractionView.PictureCalculateTex2DDragColor(self, mousePosX, mousePosY, moveDelta, picWidth, picHeight)
	if mousePosX <= self.m_LeftBottomPointX + picWidth and mousePosX >= self.m_LeftBottomPointX and
	mousePosY <= self.m_LeftBottomPointY + picHeight and mousePosY >= self.m_LeftBottomPointY then
		if moveDelta.x > self.m_ScreenWidth then
			moveDelta.x = self.m_ScreenWidth
		elseif moveDelta.x < -self.m_ScreenWidth then
			moveDelta.x = -self.m_ScreenWidth
		end
		if moveDelta.y > self.m_ScreenHeight then
			moveDelta.y = self.m_ScreenHeight
		elseif moveDelta.y < -self.m_ScreenHeight then
			moveDelta.y = -self.m_ScreenHeight
		end

		-- if moveDelta.x == 0 and moveDelta.y == 0 then
		-- 	return
		-- end
		-- local originX = math.floor(mousePosX - self.m_LeftBottomPointX)
		-- local offsetX = math.floor(mousePosX - self.m_LeftBottomPointX - moveDelta.x)
		-- local originY = math.floor(mousePosY - self.m_LeftBottomPointY)
		-- local offsetY = math.floor(mousePosY - self.m_LeftBottomPointY - moveDelta.y)
		-- for i=math.min(originX, offsetX), math.max(originX, offsetX) do
		-- 	for j=math.min(originY, offsetY), math.max(originY, offsetY) do
		-- 		local width = self:PictureSetPixelLimitValue(i, picWidth, true)
		-- 		local height = self:PictureSetPixelLimitValue(j, picHeight)
		-- 		self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
		-- 	end
		-- end
		-- self.m_PicTexture2D:Apply(false)
		-- if true then
		-- 	return
		-- end

		if moveDelta.x == 0 then
			-- if math.abs(moveDelta.y) == 0 then
			-- 	return
			-- end
			local width = math.floor(mousePosX - self.m_LeftBottomPointX)
			width = self:PictureSetPixelLimitValue(width, picWidth, true)
			if moveDelta.y ~= 0 then
				if moveDelta.y > 0 then	
					for i=1, math.abs(moveDelta.y) do			
						local height = math.floor((mousePosY - self.m_LeftBottomPointY - moveDelta.y + i))
						height = self:PictureSetPixelLimitValue(height, picHeight)
						self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
					end
				elseif moveDelta.y < 0 then	
					for i=1, math.abs(moveDelta.y) do
						local height = math.floor((mousePosY - self.m_LeftBottomPointY - moveDelta.y - i))
						height = self:PictureSetPixelLimitValue(height, picHeight)
						self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
					end
				end
			elseif moveDelta.y == 0 then
				local height = math.floor((mousePosY - self.m_LeftBottomPointY - moveDelta.y))
				height = self:PictureSetPixelLimitValue(height, picHeight)
				self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
			end
		elseif moveDelta.x < 0 then
			if math.abs(moveDelta.x) >=  math.abs(moveDelta.y) then
				for i=1, math.abs(moveDelta.x) do
					local width = math.floor((mousePosX - self.m_LeftBottomPointX - (moveDelta.x + i)))
					width = self:PictureSetPixelLimitValue(width, picWidth, true)

					local height = math.floor((mousePosY - self.m_LeftBottomPointY - (moveDelta.y*(moveDelta.x + i)/moveDelta.x)))
					height = self:PictureSetPixelLimitValue(height, picHeight)
					self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
				end
			else
				self:PictureSetTex2DYValue(mousePosX, mousePosY, moveDelta, picWidth, picHeight)
			end
		elseif moveDelta.x > 0 then
			if math.abs(moveDelta.x) >=  math.abs(moveDelta.y) then
				for i=1, math.abs(moveDelta.x) do
					local width = math.floor((mousePosX - self.m_LeftBottomPointX - (moveDelta.x - i)))
					width = self:PictureSetPixelLimitValue(width, picWidth, true)
					local height = math.floor((mousePosY - self.m_LeftBottomPointY - (moveDelta.y*(moveDelta.x - i)/moveDelta.x)))
					height = self:PictureSetPixelLimitValue(height, picHeight)
					self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
				end
			else
				self:PictureSetTex2DYValue(mousePosX, mousePosY, moveDelta, picWidth, picHeight)
			end
		end
		self.m_PicTexture2D:Apply(false)
	end
end

function CInteractionView.PictureSetTex2DYValue(self, mousePosX, mousePosY, moveDelta, picWidth, picHeight)
	if moveDelta.y < 0 then
		for i=1, math.abs(moveDelta.y) do
			local height = math.floor((mousePosY - self.m_LeftBottomPointY - (moveDelta.y + i)))
			height = self:PictureSetPixelLimitValue(height, picHeight)

			local width = math.floor((mousePosX - self.m_LeftBottomPointX - (moveDelta.x*(moveDelta.y + i)/moveDelta.y)))
			width = self:PictureSetPixelLimitValue(width, picWidth, true)
			
			self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
		end
	elseif moveDelta.y > 0 then
		for i=1, math.abs(moveDelta.y) do
			local height = math.floor((mousePosY - self.m_LeftBottomPointY - (moveDelta.y - i)))
			height = self:PictureSetPixelLimitValue(height, picHeight)

			local width = math.floor((mousePosX - self.m_LeftBottomPointX - (moveDelta.x*(moveDelta.y - i)/moveDelta.y)))
			width = self:PictureSetPixelLimitValue(width, picWidth, true)
			
			self.m_PicTexture2D:SetPixels(width, height, self.m_PicPixelNumx, self.m_PicPixelNumy, self.m_PicPixelShowColor)
		end
	end
end

function CInteractionView.PictureSetPixelLimitValue(self, value, maxVal, isValueX)
	local offset
	if isValueX then
		offset = self.m_PicPixelOffsetX
	else
		offset = self.m_PicPixelOffsetY
	end
	if value <= offset then
		value = 1 + offset
	elseif value >= 240 then
		value = 240 - 1 - offset
	end
	return value
end

------------------摇铃相关接口-------------------

function CInteractionView.RefreshBellBox(self)
	self.m_BellBox:SetActive(true)
	self.m_FuModel:SetActive(false)
	self.m_BellEffectWidget:AddEffect("Screen", "ui_eff_0055")
	local tween = DOTween.DOLocalMoveX(self.m_BellEffectWidget.m_Transform, 285, 2)
	DOTween.SetEase(tween, 1)
	DOTween.SetLoops(tween, -1, 1)
end

function CInteractionView.CheckBellDone(self, dragwidth, dragheight, moveDelta)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end

	local screenPos = self:GetBellPos()
	if math.abs(screenPos.x - dragwidth) <= self.m_BellPixelOffsetX
	and math.abs(screenPos.y - dragheight) <= self.m_BellPixelOffsetY then
		if moveDelta.x < 0 then
			self.m_BellDoneList.right = true
			self.m_MainBellModel:CrossFade("show")
		elseif moveDelta.x > 0 then
			self.m_BellDoneList.left = true
			self.m_MainBellModel:CrossFade("show")
		end
	end

	if self.m_BellDoneList.left and self.m_BellDoneList.right then
		self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		self.m_BellEffectWidget:DelEffect("Screen")
		g_NotifyCtrl:FloatMsg("摇动铃铛成功啦")
		
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_LeftTimeLbl:SetText("")
		self.m_TimeSlider:SetActive(false)
		self.m_InstructionLbl:SetActive(false)
	end
end

------------------药草相关接口-------------------

function CInteractionView.RefreshHerbBox(self)
	self.m_HerbBox:SetActive(true)
	self.m_FuModel:SetActive(false)
	self.m_HerbEffectWidget:AddEffect("Screen", "ui_eff_0055")
	local tween = DOTween.DOLocalMoveX(self.m_HerbEffectWidget.m_Transform, 285, 2)
	DOTween.SetEase(tween, 1)
	DOTween.SetLoops(tween, -1, 1)
end

function CInteractionView.CheckHerbDone(self, dragwidth, dragheight, moveDelta)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end

	local screenPos = self:GetHerbPos()
	if math.abs(screenPos.x - dragwidth) <= self.m_HerbPixelOffsetX
	and math.abs(screenPos.y - dragheight) <= self.m_HerbPixelOffsetY then
		if moveDelta.x < 0 then
			self.m_HerbDoneList.right = true
			self.m_MainHerbModel:CrossFade("show")
		elseif moveDelta.x > 0 then
			self.m_HerbDoneList.left = true
			self.m_MainHerbModel:CrossFade("show")
		end
	end

	if self.m_HerbDoneList.left and self.m_HerbDoneList.right then
		self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		self.m_HerbEffectWidget:DelEffect("Screen")
		g_NotifyCtrl:FloatMsg("鲜花采集成功啦")
		-- g_NotifyCtrl:FloatItemBox(10136)
		
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_LeftTimeLbl:SetText("")
		self.m_TimeSlider:SetActive(false)
		self.m_InstructionLbl:SetActive(false)
	end
end

-------------------其他的接口--------------------

--范围(20, 20) 到 (1000, 600)
--define.Yibao.InteractionType LinkPoint是连线
function CInteractionView.GetPointsPos(self)
	if self.m_Test then
		-- local list = {{20,20}, {430,200}, {830,200}, {1240,720}}
		local list = {{430,400}, {430, 200}, {830, 200}, {830, 400}, }
		-- local list = {{430,400}, {630,200}, {830,400}}
		-- local list = {{20,20}, {430,400}, {630,200}, {430, 200}, {830, 200}, {830, 400}, {1240,720}}
		-- local list = { {430, 200}, {630,200}, {20,20}, {1240,720}, {430,400}, {830, 400},{830, 200}, {576, 45}, {130, 600} }
		return list
	else
		local list = {}
		if g_InteractionCtrl.m_InteractionQteConfig and g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
			for k,v in ipairs(g_InteractionCtrl.m_InteractionQteConfig.pointlist) do
				local item = {}
				item[1] = self.m_ScreenWidth/2 + v.posx
				item[2] = self.m_ScreenHeight/2 + v.posy
				table.insert(list, item)
			end
		end
		return list
	end	
end

function CInteractionView.GetFlowersPos(self)
	local list = {}
	for i = 1, 4 do
		local item = {}
		local oUICamera = g_CameraCtrl:GetUICamera()
		local vScreenPos = oUICamera:WorldToScreenPoint(self.m_FlowerWidgetBox:NewUI(i, CWidget):GetPos())
		item[1] = vScreenPos.x
		item[2] = vScreenPos.y
		table.insert(list, item)
	end
	return list
end

function CInteractionView.GetCrystalOrePos(self)
	if self.m_Test then
		-- local list = {{20,20}, {430,200}, {830,200}, {1240,720}}
		local list = {{430,400}, {430, 200}, {830, 200}, {830, 400}, }
		-- local list = {{430,400}, {630,200}, {830,400}}
		-- local list = {{20,20}, {430,400}, {630,200}, {430, 200}, {830, 200}, {830, 400}, {1240,720}}
		-- local list = { {430, 200}, {630,200}, {20,20}, {1240,720}, {430,400}, {830, 400},{830, 200}, {576, 45}, {130, 600} }
		return list
	else
		local list = {}
		if g_InteractionCtrl.m_InteractionQteConfig and g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then
			for k,v in ipairs(g_InteractionCtrl.m_InteractionQteConfig.pointlist) do
				local item = {}
				item[1] = self.m_ScreenWidth/2 + v.posx
				item[2] = self.m_ScreenHeight/2 + v.posy
				table.insert(list, item)
			end
		end
		return list
	end
end

function CInteractionView.GetLovePointsPos(self)
	local list = {}
	for i = 1, #self.m_LoveTagList do
		local item = {}
		local oUICamera = g_CameraCtrl:GetUICamera()
		local vScreenPos = oUICamera:WorldToScreenPoint(self.m_LoveTagList[i]:GetPos())
		item[1] = vScreenPos.x
		item[2] = vScreenPos.y
		table.insert(list, item)
	end
	return list
end

function CInteractionView.GetDogsPos(self)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vScreenPos = oUICamera:WorldToScreenPoint(self.m_DogWidgetBox:GetPos())
	return vScreenPos
end

function CInteractionView.GetBellPos(self)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vScreenPos = oUICamera:WorldToScreenPoint(self.m_BellPosWidget:GetPos())
	return vScreenPos
end

function CInteractionView.GetHerbPos(self)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vScreenPos = oUICamera:WorldToScreenPoint(self.m_HerbPosWidget:GetPos())
	return vScreenPos
end

function CInteractionView.OnHideView(self)
	g_InteractionCtrl.IsShowing = false
	for k,v in pairs(g_InteractionCtrl.m_InteractionEndCbList) do
		if v then v() end
	end
	g_InteractionCtrl.m_InteractionEndCbList = {}
end

return CInteractionView