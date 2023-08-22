local CInteractionFlowerBox = class("CInteractionFlowerBox", CBox)

function CInteractionFlowerBox.ctor(self, obj)
	CBox.ctor(self, obj)

	-- self.m_FlowerClone = self:NewUI(1, CBox)
	-- self.m_FlowerEffectWidget = self:NewUI(2, CWidget)
	-- self.m_FlowerModel = self:NewUI(3, CObject)
	-- self.m_FlowerWidgetBox = self:NewUI(4, CBox)
	-- self.m_FlowerBrokenPointList = {}
	-- for i = 1, 4 do
	-- 	local brokenObj = self:NewUI(i+4, CObject)
	-- 	brokenObj:SetLocalPos(Vector3.New(0, 0, 0))
	-- 	brokenObj:SetActive(true)
	-- 	table.insert(self.m_FlowerBrokenPointList, brokenObj)
	-- end
end

function CInteractionFlowerBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CInteractionFlowerBox.SetFlowerUIInfo(self)
	self.m_ParentView.m_InstructionLbl:SetLocalPos(Vector3.New(0, 30, 0))
	self.m_ParentView.m_TimeSlider:SetLocalPos(Vector3.New(0, 0, 0))
	self.m_ParentView.m_FuModel:SetActive(false)
	self.m_ParentView.m_FlowerModel:SetActive(true)
	self.m_ParentView.m_FlowerWidgetBox:SetActive(true)

	self.m_ParentView.m_FlowerEffectWidget:AddEffect("Screen", "ui_eff_0055")
	local tween = DOTween.DOLocalMoveX(self.m_ParentView.m_FlowerEffectWidget.m_Transform, 285, 2)
	DOTween.SetEase(tween, 1)
	DOTween.SetLoops(tween, -1, 1)

	-- if next(self.m_ParentView.m_FlowerBoxList) then
	-- 	for k,v in pairs(self.m_ParentView.m_FlowerBoxList) do
	-- 		self.m_ParentView.m_FlowerBoxList.m_GameObject:Destroy()
	-- 	end
	-- 	self.m_ParentView.m_FlowerBoxList = {}
	-- end
	-- local oData = self.m_ParentView:GetFlowersPos()
	-- if oData and next(oData) then
	-- 	for k,v in ipairs(oData) do
	-- 		self.m_ParentView:AddFlowerUIBox(k, Vector3.New(v[1], v[2], 0))
	-- 	end
	-- end
end

function CInteractionFlowerBox.AddFlowerUIBox(self, oFlower, oScreenPos)
	local oFlowerBox = self.m_ParentView.m_FlowerClone:Clone()

	table.insert(self.m_ParentView.m_FlowerBoxList, oFlowerBox)

	oFlowerBox:SetParent(self.m_ParentView.m_Widget.m_Transform)
	oFlowerBox:SetActive(true)
	
	local flowerSp = oFlowerBox:NewUI(1, CSprite)
	local effectSp = oFlowerBox:NewUI(2, CSprite)
	flowerSp:SetActive(true)
	effectSp:SetActive(false)
	local pos = g_CameraCtrl:GetUICamera():ScreenToWorldPoint(oScreenPos)
	oFlowerBox:SetPos(pos)
end

function CInteractionFlowerBox.InitFlowersLineList(self)
	self.m_ParentView.m_FlowersLineList = {}
	for i=1, #self.m_ParentView:GetFlowersPos() do
		local list = {}
		list.point = i
		list.hasbeendrag = false
		table.insert(self.m_ParentView.m_FlowersLineList, list)
	end
end

function CInteractionFlowerBox.SetFolwersLineList(self, dragwidth, dragheight)	
	if self.m_ParentView:CheckFlowersInDragArea(dragwidth, dragheight) then
		-- g_NotifyCtrl:FloatMsg("CheckFlowersInDragArea".. self.m_ParentView:CheckFlowersInDragArea(dragwidth, dragheight))
		for k,v in ipairs(self.m_ParentView.m_FlowersLineList) do
			if (v.point == self.m_ParentView:CheckFlowersInDragArea(dragwidth, dragheight)) and v.hasbeendrag == false then
				-- self.m_ParentView.m_FlowerBoxList[v.point]:NewUI(1, CSprite):SetActive(false)
				-- self.m_ParentView.m_FlowerBoxList[v.point]:NewUI(2, CSprite):SetActive(true)
				-- local tween = self.m_ParentView.m_FlowerBoxList[v.point]:NewUI(2, CSprite):GetComponent(classtype.TweenAlpha)
				-- tween:ResetToBeginning()
				-- tween.from = 1
				-- tween.to = 0
				-- tween.delay = 0.5
				-- tween.duration = 1
				-- tween:Play(true)

				self.m_ParentView.m_FlowerBrokenPointList[v.point]:SetActive(true)
				-- local tween = DOTween.DOLocalMoveY(self.m_ParentView.m_FlowerBrokenPointList[v.point].m_Transform, 2.1, 0.5)
				local vet = {self.m_ParentView.m_FlowerBrokenPointList[v.point].m_Transform.localPosition, Vector3.New(-1.7, -0.9, 0)}
				local tween = DOTween.DOLocalPath(self.m_ParentView.m_FlowerBrokenPointList[v.point].m_Transform, vet, 0.5, 0, 0, 10, nil)
				DOTween.SetEase(tween, 1)
				local function finish()
					self.m_ParentView.m_FlowerBrokenPointList[v.point]:SetActive(false)
				end
				DOTween.OnComplete(tween, finish)

			   	v.hasbeendrag = true
			   	break
			end
		end

		self.m_ParentView:CheckFlowerDone()
	end
end

function CInteractionFlowerBox.CheckFlowersInDragArea(self, dragwidth, dragheight)
	for k,v in ipairs(self.m_ParentView:GetFlowersPos()) do
		if math.abs(v[1] - dragwidth) <= self.m_ParentView.m_FlowerPixelOffsetX
		and math.abs(v[2] - dragheight) <= self.m_ParentView.m_FlowerPixelOffsetY then
			return k
		end
	end
end

function CInteractionFlowerBox.CheckFlowerDone(self)
	if g_InteractionCtrl.m_InteractionQteConfig.type ~= define.Yibao.InteractionType.LinkFlower then
		return
	end
	local isFlowerLineFinish = true
	-- table.print(self.m_ParentView.m_FlowersLineList, "self.m_ParentView.m_FlowersLineList")
	for k,v in pairs(self.m_ParentView.m_FlowersLineList) do
		if v.hasbeendrag == false then
			isFlowerLineFinish = false
			break
		end
	end

	if isFlowerLineFinish and not self.m_ParentView.m_FlowerInteractionDone then
		self.m_ParentView.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		self.m_ParentView.m_FlowerEffectWidget:DelEffect("Screen")
		g_NotifyCtrl:FloatMsg("收割成功啦")
		-- g_NotifyCtrl:FloatItemBox(10136)
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_ParentView.m_LeftTimeLbl:SetText("")
		self.m_ParentView.m_TimeSlider:SetActive(false)
		self.m_ParentView.m_InstructionLbl:SetActive(false)

		self.m_ParentView.m_FlowerInteractionDone = true
	end
end

function CInteractionFlowerBox.GetIsFlowerDoneById(self, id)
	for k,v in pairs(self.m_ParentView.m_FlowersLineList) do
		if v.point == id and v.hasbeendrag == true then
			return true
		end
	end
end

return CInteractionFlowerBox