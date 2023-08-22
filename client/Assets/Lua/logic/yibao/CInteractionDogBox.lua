local CInteractionDogBox = class("CInteractionDogBox", CBox)

function CInteractionDogBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_DogEffectWidget = self:NewUI(1, CWidget)
	self.m_DogWidgetBox = self:NewUI(2, CWidget)
	self.m_DogModel = self:NewUI(3, CObject)
	self.m_CageModel = self:NewUI(4, CObject)
	self.m_DogEffectWidget2 = self:NewUI(5, CWidget)

	self.m_MainCageModel = CMainModel.New(self.m_CageModel.m_GameObject)
	-- self.m_DogBrokenPointList = {}
	-- for i = 1, 4 do
	-- 	local brokenObj = self:NewUI(i+3, CObject)
	-- 	brokenObj:SetLocalPos(Vector3.New(0, 0, 0))
	-- 	brokenObj:SetActive(true)
	-- 	table.insert(self.m_DogBrokenPointList, brokenObj)
	-- end
end

function CInteractionDogBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CInteractionDogBox.SetDogUIInfo(self)
	self.m_ParentView.m_FuModel:SetActive(false)
	self.m_ParentView.m_DogBox:SetActive(true)
	self.m_ParentView.m_DogModel:SetActive(true)
	self.m_ParentView.m_DogWidgetBox:SetActive(true)

	self.m_ParentView.m_DogEffectWidget:AddEffect("Screen", "ui_eff_0051", nil, nil, nil, 1, true)

	self.m_ParentView.m_DogEffectWidget2:AddEffect("Screen", "ui_eff_0055")
	local tween = DOTween.DOLocalMoveX(self.m_ParentView.m_DogEffectWidget2.m_Transform, -285, 2)
	DOTween.SetEase(tween, 1)
	DOTween.SetLoops(tween, -1, 0)
end

function CInteractionDogBox.CheckDogDone(self, dragwidth, dragheight)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end
	local screenPos = self.m_ParentView:GetDogsPos()
	if math.abs(screenPos.x - dragwidth) <= self.m_ParentView.m_DogPixelOffsetX
	and math.abs(screenPos.y - dragheight) <= self.m_ParentView.m_DogPixelOffsetY then
		self.m_ParentView.m_DogInteractionDone = true
	end

	if self.m_ParentView.m_DogInteractionDone then
		self.m_ParentView.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		self.m_ParentView.m_DogEffectWidget:DelEffect("Screen")
		self.m_ParentView.m_DogEffectWidget2:DelEffect("Screen")
		-- g_NotifyCtrl:FloatMsg("笼门打开成功啦")
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl.m_YibaoInteractionLightSetTime = 2
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_ParentView.m_LeftTimeLbl:SetText("")
		self.m_ParentView.m_TimeSlider:SetActive(false)
		self.m_ParentView.m_InstructionLbl:SetActive(false)

		self.m_MainCageModel:CrossFade("idleRide")

		-- self.m_ParentView.m_DogBrokenPointList[1]:SetActive(true)
		-- local vet = {self.m_ParentView.m_DogBrokenPointList[4].m_Transform.localPosition, Vector3.New(-1.7, -0.9, 0)}
		-- local tween = DOTween.DOLocalPath(self.m_ParentView.m_DogBrokenPointList[1].m_Transform, vet, 0.5, 0, 0, 10, nil)
		-- DOTween.SetEase(tween, 1)
		-- local function finish()
		-- 	self.m_ParentView.m_DogBrokenPointList[1]:SetActive(false)
		-- end
		-- DOTween.OnComplete(tween, finish)
	end
end

return CInteractionDogBox