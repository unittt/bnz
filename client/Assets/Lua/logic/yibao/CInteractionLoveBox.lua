local CInteractionLoveBox = class("CInteractionLoveBox", CBox)

function CInteractionLoveBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_LoveStartBg = self:NewUI(1, CTexture)
	self.m_LoveEndBg = self:NewUI(2, CTexture)
	self.m_LoveTagList = {}
	for i = 1, 6 do
		table.insert(self.m_LoveTagList, self:NewUI(i+2, CBox))
	end
	self.m_LoveEffWidget = self:NewUI(9, CWidget)
	self.m_LovePassLineSp = self:NewUI(10, CSprite)
end

function CInteractionLoveBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CInteractionLoveBox.InitLovePointsLineList(self)
	self.m_LovePassLineSp:SetActive(false)
	for k,v in pairs(self.m_ParentView.m_LoveTagList) do
		v:NewUI(1, CSprite):SetActive(false)
		v:NewUI(2, CSprite):SetActive(false)
		v:NewUI(3, CSprite):SetActive(false)
		v:NewUI(4, CSprite):SetActive(false)
	end

	self.m_LoveShowIndex = 1
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
		self.m_EffectTimer = nil
	end
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		if self.m_LoveShowIndex == 1 then
			for k,v in pairs(self.m_ParentView.m_LoveTagList) do
				v:NewUI(3, CSprite):SetActive(false)
				v:NewUI(4, CSprite):SetActive(false)
			end
		end
		self.m_ParentView.m_LoveTagList[self.m_LoveShowIndex]:NewUI(3, CSprite):SetActive(true)
		self.m_ParentView.m_LoveTagList[self.m_LoveShowIndex]:NewUI(4, CSprite):SetActive(true)
		local nextIndex = self.m_LoveShowIndex + 1
		if nextIndex > #self.m_ParentView.m_LoveTagList then
			nextIndex = 1
		end
		self.m_ParentView.m_LoveTagList[nextIndex]:NewUI(4, CSprite):SetActive(true)
		self.m_LoveShowIndex = self.m_LoveShowIndex + 1
		if self.m_LoveShowIndex > #self.m_ParentView.m_LoveTagList then
			self.m_LoveShowIndex = 1
		end
		return true
	end	
	self.m_EffectTimer = Utils.AddTimer(progress, 1, 0)

	self.m_ParentView.m_LovePointsLineList = {}
	if #self.m_ParentView:GetLovePointsPos() <= 2 then
		for i=1,#self.m_ParentView:GetLovePointsPos() - 1 do
			local list = {}
			list.point1 = i
			list.point2 = i + 1
			list.hasbeendrag = false
			table.insert(self.m_ParentView.m_LovePointsLineList, list)
		end
	else
		for i=1,#self.m_ParentView:GetLovePointsPos() - 1 do
			local list = {}
			list.point1 = i
			list.point2 = i + 1
			list.hasbeendrag = false
			table.insert(self.m_ParentView.m_LovePointsLineList, list)
		end
		local list = {}
		list.point1 = #self.m_ParentView:GetLovePointsPos()
		list.point2 = 1
		list.hasbeendrag = false
		table.insert(self.m_ParentView.m_LovePointsLineList, list)
	end
end

function CInteractionLoveBox.SetLovePointsLineList(self, dragwidth, dragheight)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end
	
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
		self.m_EffectTimer = nil
	end
	for k,v in pairs(self.m_ParentView.m_LoveTagList) do
		v:NewUI(3, CSprite):SetActive(false)
		v:NewUI(4, CSprite):SetActive(false)
	end
	if self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight) then
		-- g_NotifyCtrl:FloatMsg("CheckLovePointsInDragArea".. self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight))
		if not self.m_ParentView.m_CheckStartPoint then
			self.m_ParentView.m_CheckStartPoint = self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight)
			self.m_ParentView.m_LoveTagList[self.m_ParentView.m_CheckStartPoint]:NewUI(1, CSprite):SetActive(true)			
		else
			for k,v in ipairs(self.m_ParentView.m_LovePointsLineList) do
				if (v.point1 == self.m_ParentView.m_CheckStartPoint and v.point2 == self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight)) or
				   (v.point2 == self.m_ParentView.m_CheckStartPoint and v.point1 == self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight)) then
				   self.m_ParentView.m_LoveTagList[v.point1]:NewUI(2, CSprite):SetActive(true)
				   v.hasbeendrag = true
				   break
				end
			end
			self.m_ParentView.m_CheckStartPoint = self.m_ParentView:CheckLovePointsInDragArea(dragwidth, dragheight)
			self.m_ParentView.m_LoveTagList[self.m_ParentView.m_CheckStartPoint]:NewUI(1, CSprite):SetActive(true)
		end
		self.m_LovePassLineSp:SetActive(true)
		self.m_LovePassLineSp:SetPos(self.m_ParentView.m_LoveTagList[self.m_ParentView.m_CheckStartPoint]:NewUI(1, CSprite):GetPos())
	end
	if self.m_ParentView.m_CheckStartPoint then
		local oUICamera = g_CameraCtrl:GetUICamera()
		local vScreenPos = oUICamera:WorldToScreenPoint(self.m_ParentView.m_LoveTagList[self.m_ParentView.m_CheckStartPoint]:GetPos())
		local oStartPoint = Vector3.New(vScreenPos.x, vScreenPos.y, 0)
		local oEndPoint = Vector3.New(dragwidth, dragheight, 0)
		local distance = Vector3.Distance(oStartPoint, oEndPoint)*1.4
		self.m_LovePassLineSp:SetWidth(distance)

		local oFromVet = Vector3.New(-1, 0, 0)
		local oToVet = Vector3.New(dragwidth - vScreenPos.x, dragheight - vScreenPos.y, 0)
		local oDot = Vector3.Dot(oFromVet, oToVet)
		local oCross = Vector3.Cross(oFromVet, oToVet)
		local oAngle = Vector3.Angle(oFromVet, oToVet)
		self.m_LovePassLineSp:SetLocalEulerAngles(Vector3.New(0, 0, oCross.z > 0 and oAngle or -oAngle))
		-- printc("我的角度oDot", oDot, " oAngle", oAngle, " oCross", oCross.z)
	end
end

function CInteractionLoveBox.CheckLovePointsInDragArea(self, dragwidth, dragheight)
	for k,v in ipairs(self.m_ParentView:GetLovePointsPos()) do
		-- local width = v[1]*self.m_ParentView.m_ScaleRatio
		-- width = self.m_ParentView:SetPointPixelLimitValue(width, self.m_ParentView.m_ActualTexWidth, true)
		-- local height = v[2]*self.m_ParentView.m_ScaleRatio		
		-- height = self.m_ParentView:SetPointPixelLimitValue(height, self.m_ParentView.m_ActualTexHeight)

		if math.abs(v[1] - dragwidth) <= self.m_ParentView.m_LovePointPixelOffsetX
		and math.abs(v[2] - dragheight) <= self.m_ParentView.m_LovePointPixelOffsetY then
			return k
		end
	end
end

function CInteractionLoveBox.CheckLoveDone(self)
	if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
		return
	end
	if g_InteractionCtrl.m_YibaoInteractionResult == 1 then
		return
	end
	local isLovePointLineFinish = true
	for k,v in pairs(self.m_ParentView.m_LovePointsLineList) do
		if v.hasbeendrag == false then
			isLovePointLineFinish = false
			break
		end
	end

	if isLovePointLineFinish then
		self.m_ParentView.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		self.m_LovePassLineSp:SetActive(false)
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		g_NotifyCtrl:FloatMsg("爱心绘制成功啦")
		g_InteractionCtrl.m_YibaoInteractionLightSetTime = 4
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		g_InteractionCtrl.m_YibaoInteractionLightSetTime = nil
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_ParentView.m_LeftTimeLbl:SetText("")
		self.m_ParentView.m_TimeSlider:SetActive(false)
		self.m_ParentView.m_InstructionLbl:SetActive(false)
		for k,v in pairs(self.m_ParentView.m_LoveTagList) do
			v:SetActive(false)
		end
		self.m_ParentView.m_LoveEndBg:SetActive(true)
		self.m_ParentView.m_LoveEffWidget:AddEffect("Screen", "ui_eff_0048")
	end
	return isLovePointLineFinish
end

return CInteractionLoveBox