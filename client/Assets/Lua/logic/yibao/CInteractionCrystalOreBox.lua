local CInteractionCrystalOreBox = class("CInteractionCrystalOreBox", CBox)

function CInteractionCrystalOreBox.ctor(self, obj)
	CBox.ctor(self, obj)
end

function CInteractionCrystalOreBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CInteractionCrystalOreBox.SetCrystalOreUIInfo(self)
	if next(self.m_ParentView.m_CrystalOreBoxList) then
		for k,v in pairs(self.m_ParentView.m_CrystalOreBoxList) do
			self.m_ParentView.m_CrystalOreBoxList.m_GameObject:Destroy()
		end
		self.m_ParentView.m_CrystalOreBoxList = {}
	end
	local oData = self.m_ParentView:GetCrystalOrePos()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self.m_ParentView:AddCrystalOreUIBox(k, Vector3.New(v[1], v[2], 0))
		end
	end
end

function CInteractionCrystalOreBox.AddCrystalOreUIBox(self, oCrystalOre, oScreenPos)
	local oCrystalOreBox = self.m_ParentView.m_CrystalOreClone:Clone()

	table.insert(self.m_ParentView.m_CrystalOreBoxList, oCrystalOreBox)

	oCrystalOreBox:SetParent(self.m_ParentView.m_Widget.m_Transform)
	oCrystalOreBox:SetActive(true)
	
	local crystaloreSp = oCrystalOreBox:NewUI(1, CSprite)
	local effectSp = oCrystalOreBox:NewUI(2, CSprite)
	crystaloreSp:SetActive(true)
	effectSp:SetActive(false)
	local pos = g_CameraCtrl:GetUICamera():ScreenToWorldPoint(oScreenPos)
	oCrystalOreBox:SetPos(pos)
end

function CInteractionCrystalOreBox.InitCrystalOreLineList(self)
	self.m_ParentView.m_CrystalOreLineList = {}
	for i=1, #self.m_ParentView:GetCrystalOrePos() do
		local list = {}
		list.point = i
		list.hasbeendrag = false
		table.insert(self.m_ParentView.m_CrystalOreLineList, list)
	end
end

function CInteractionCrystalOreBox.SetCrystalOreLineList(self, dragwidth, dragheight)	
	if self.m_ParentView:CheckCrystalOreInDragArea(dragwidth, dragheight) then
		-- g_NotifyCtrl:FloatMsg("CheckCrystalOreInDragArea".. self.m_ParentView:CheckCrystalOreInDragArea(dragwidth, dragheight))
		for k,v in ipairs(self.m_ParentView.m_CrystalOreLineList) do
			if (v.point == self.m_ParentView:CheckCrystalOreInDragArea(dragwidth, dragheight)) and v.hasbeendrag == false then
				self.m_ParentView.m_CrystalOreBoxList[v.point]:NewUI(1, CSprite):SetActive(false)
				self.m_ParentView.m_CrystalOreBoxList[v.point]:NewUI(2, CSprite):SetActive(true)
				local tween = self.m_ParentView.m_CrystalOreBoxList[v.point]:NewUI(2, CSprite):GetComponent(classtype.TweenAlpha)
				tween:ResetToBeginning()
				tween.from = 1
				tween.to = 0
				tween.delay = 0.5
				tween.duration = 1
				tween:Play(true)

			   	v.hasbeendrag = true
			   	break
			end
		end

		self.m_ParentView:CheckCrystalOreDone()
	end
end

function CInteractionCrystalOreBox.CheckCrystalOreInDragArea(self, dragwidth, dragheight)
	for k,v in ipairs(self.m_ParentView:GetCrystalOrePos()) do
		if math.abs(v[1] - dragwidth) <= self.m_ParentView.m_CrystalOrePixelOffsetX
		and math.abs(v[2] - dragheight) <= self.m_ParentView.m_CrystalOrePixelOffsetY then
			return k
		end
	end
end

function CInteractionCrystalOreBox.CheckCrystalOreDone(self)
	if g_InteractionCtrl.m_InteractionQteConfig.type ~= define.Yibao.InteractionType.LinkCrystalOre then
		return
	end
	local isCrystalOreLineFinish = true
	-- table.print(self.m_ParentView.m_CrystalOreLineList, "self.m_ParentView.m_CrystalOreLineList")
	for k,v in pairs(self.m_ParentView.m_CrystalOreLineList) do
		if v.hasbeendrag == false then
			isCrystalOreLineFinish = false
			break
		end
	end

	if isCrystalOreLineFinish and not self.m_ParentView.m_CrystalOreInteractionDone then
		self.m_ParentView.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false
		g_InteractionCtrl.m_YibaoInteractionResult = 1

		g_NotifyCtrl:FloatMsg("收集成功啦")
		--开始互动任务成功后的亮光特效计时
		g_InteractionCtrl:SetInteractionLightCountTime()
		--互动任务的总计时停止
		g_InteractionCtrl:ResetInteractionTimer()
		self.m_ParentView.m_LeftTimeLbl:SetText("")
		self.m_ParentView.m_TimeSlider:SetActive(false)
		self.m_ParentView.m_InstructionLbl:SetActive(false)

		self.m_ParentView.m_CrystalOreInteractionDone = true
	end
end

function CInteractionCrystalOreBox.GetIsCrystalOreDoneById(self, id)
	for k,v in pairs(self.m_ParentView.m_CrystalOreLineList) do
		if v.point == id and v.hasbeendrag == true then
			return true
		end
	end
end

return CInteractionCrystalOreBox