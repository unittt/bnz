local CPlotDialogueView = class("CPlotDialogueView", CViewBase)

function CPlotDialogueView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Plot/PlotDialogueView.prefab", cb)
	--界面设置
	self.m_DepthType = "Story"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CPlotDialogueView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_NormalBox = self:NewUI(2, CBox)
	self.m_MaskSp = self:NewUI(4, CSprite)
	self.m_BottomSpr = self.m_NormalBox:NewUI(1, CTexture)
	self.m_NpcNameSpr = self.m_NormalBox:NewUI(2, CSprite)
	self.m_NpcNameLabel = self.m_NormalBox:NewUI(3, CLabel)
	self.m_LeftDialogueMsg = self.m_NormalBox:NewUI(5, CLabel)
	self.m_RightDialogueMsg = self.m_NormalBox:NewUI(6, CLabel)
	self.m_ActorTexture = self.m_NormalBox:NewUI(7, CActorTexture)
	-- self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_DialogueL = self:NewUI(3, CLabel)
	self.m_LeftDialogueMark = self.m_NormalBox:NewUI(8, CSprite)
	self.m_RightDialogueMark = self.m_NormalBox:NewUI(9, CSprite)

	self:InitContent()
end

function CPlotDialogueView.InitContent(self)
	self.m_NpcNameSpr:SetActive(false)
	UITools.ResizeToRootSize(self.m_Container)
	UITools.ResizeToRootSize(self.m_MaskSp)
end

function CPlotDialogueView.ExcuteDialogueAction(self, dAction)
	self.m_Container:SetActive(true)
	local sText = dAction.content
	sText = string.gsub(sText, "#N", string.format("#G%s#n", g_AttrCtrl.name))
	if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
	    local sBridegroom = g_MarryPlotCtrl:GetProtagonistName(1)
	    local sBride = g_MarryPlotCtrl:GetProtagonistName(2)
	    sText = string.gsub(sText, "#BridegroomName", string.format("#G%s#n", sBridegroom))
	    sText = string.gsub(sText, "#BrideName", string.format("#G%s#n", sBride))
	end
	if not dAction.isHero and dAction.modelId <= 0 then
		self.m_ActorTexture:SetActive(false)

		self.m_LeftDialogueMsg:SetActive(false)
		self.m_RightDialogueMsg:SetActive(false)
		self.m_LeftDialogueMark:SetActive(false)
		self.m_RightDialogueMark:SetActive(false)
		self.m_DialogueL:SetActive(true)
		self.m_DialogueL:SetRichText(sText, nil, nil, true)
	else
		self.m_ActorTexture:SetActive(true)		
		local function loadFinish()
			if self.m_IsSpecial then
				self.m_ActorTexture.m_ActorCamera:SetOrthographicSize(1.2)
				self.m_ActorTexture:SetLocalScale(Vector3.New(1.5, 1.5, 1))
			else
				self.m_ActorTexture.m_ActorCamera:SetOrthographicSize(0.8)
				self.m_ActorTexture:SetLocalScale(Vector3.New(1, 1, 1))
			end
			local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
			local oEulerAngle = oActor:GetLocalEulerAngles()
			oActor:SetLocalEulerAngles(Vector3.New(oEulerAngle.x, oEulerAngle.y, oEulerAngle.z-5))
		end
		if not dAction.isRight then
			if dAction.isHero or (not dAction.isHero and dAction.sName and dAction.sName ~= "") then
				-- self.m_NpcNameSpr:SetActive(true)
				self.m_IsShowNpcNameSpr = true
				-- self.m_NpcNameLabel:SetLocalPos(Vector3.New(186, 32, 0))
				self.m_BottomSpr:SetFlip(enum.UISprite.Flip.Nothing)
				self.m_NpcNameSpr:SetFlip(enum.UISprite.Flip.Nothing)
				-- self.m_NpcNameSpr:SetPivot(enum.UIWidget.Pivot.BottomLeft)
				-- UITools.NearTarget(self.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomLeft, Vector2.New(200, 0))
				local sName
				if dAction.isHero then
					sName = g_AttrCtrl.name
				else
					sName = dAction.sName
				end
				self.m_NpcNameLabel:SetText(sName)
			else
				-- self.m_NpcNameSpr:SetActive(false)
				self.m_IsShowNpcNameSpr = false
			end

			local modelId
			if dAction.isHero then
				modelId = g_AttrCtrl.model_info.shape
			else
				modelId = dAction.modelId
			end
			self.m_IsSpecial = define.Dialogue.SpecialShape[modelId]
			local iPosY = -0.9
			if self.m_IsSpecial then
				iPosY = -1.14
			end

			local modelCofig = ModelTools.GetModelConfig(modelId)
			local model_info = {}
			model_info.figure = modelId
			model_info.scale = modelCofig.scale
    		model_info.rendertexSize = 1.2
    		model_info.pos = Vector3.New(0,iPosY,3)
    		model_info.rotate = Vector3.New(0, -30, 0)
    		model_info.cb = loadFinish
    		local function onActorTexLoadDone()
    			if self.m_IsShowNpcNameSpr then
    				self.m_NpcNameSpr:SetActive(true)
    			else
    				self.m_NpcNameSpr:SetActive(false)
    			end
    			self.m_BottomSpr:SetActive(true)
    			loadFinish()
    			self.m_ActorTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)
				UITools.NearTarget(self.m_Container, self.m_ActorTexture, enum.UIAnchor.Side.BottomLeft)
				if self.m_IsSpecial then
					local width = self.m_ActorTexture:GetWidth()*0.75 - 200
					self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(-width, 0, 0))
				else
					local width = self.m_ActorTexture:GetWidth()*0.5 - 200
					self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(-width, 35, 0))
				end
				UITools.NearTarget(self.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomLeft, Vector2.New(320, 0))
    		end
			self.m_ActorTexture:ChangeShape(model_info, onActorTexLoadDone)

			self.m_LeftDialogueMsg:SetActive(false)
			self.m_RightDialogueMsg:SetActive(true)
			self.m_DialogueL:SetActive(false)
			self.m_NpcNameSpr:SetActive(false)
			self.m_BottomSpr:SetActive(false)
			self.m_RightDialogueMsg:SetRichText(sText, nil, nil, true)
			self.m_LeftDialogueMark:SetActive(false)
			self.m_RightDialogueMark:SetActive(true)
		else
			if dAction.isHero or (not dAction.isHero and dAction.sName and dAction.sName ~= "") then
				-- self.m_NpcNameSpr:SetActive(true)
				self.m_IsShowNpcNameSpr = true
				-- self.m_NpcNameLabel:SetLocalPos(Vector3.New(-186, 32, 0))
				self.m_BottomSpr:SetFlip(enum.UISprite.Flip.Horizontally)
				self.m_NpcNameSpr:SetFlip(enum.UISprite.Flip.Nothing)
				-- self.m_NpcNameSpr:SetPivot(enum.UIWidget.Pivot.BottomRight)
				-- UITools.NearTarget(self.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomRight)
				local sName
				if dAction.isHero then
					sName = g_AttrCtrl.name
				else
					sName = dAction.sName
				end
				self.m_NpcNameLabel:SetText(sName)
			else
				-- self.m_NpcNameSpr:SetActive(false)
				self.m_IsShowNpcNameSpr = false
			end

			local modelId
			if dAction.isHero then
				modelId = g_AttrCtrl.model_info.shape
			else
				modelId = dAction.modelId
			end
			self.m_IsSpecial = define.Dialogue.SpecialShape[modelId]
			local iPosY = -0.9
			if self.m_IsSpecial then
				iPosY = -1.14
			end

			local modelCofig = ModelTools.GetModelConfig(modelId)
			local model_info = {}
			model_info.figure = modelId
			model_info.scale = modelCofig.scale
    		model_info.rendertexSize = 1.2
    		model_info.pos = Vector3.New(0,iPosY,3)
    		model_info.rotate = Vector3.New(0, 30, 0)
    		model_info.cb = loadFinish
    		local function onActorTexLoadDone()
    			if self.m_IsShowNpcNameSpr then
    				self.m_NpcNameSpr:SetActive(true)
    			else
    				self.m_NpcNameSpr:SetActive(false)
    			end
    			self.m_BottomSpr:SetActive(true)
    			loadFinish()
    			self.m_ActorTexture:SetPivot(enum.UIWidget.Pivot.BottomRight)
				UITools.NearTarget(self.m_Container, self.m_ActorTexture, enum.UIAnchor.Side.BottomRight)
				if self.m_IsSpecial then
					local width = self.m_ActorTexture:GetWidth()*0.75 - 200
					self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(width, 0, 0))
				else
					local width = self.m_ActorTexture:GetWidth()*0.5 - 200
					self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(width, 35, 0))
				end
				UITools.NearTarget(self.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomRight, Vector2.New(-300, 0))
    		end
			self.m_ActorTexture:ChangeShape(model_info, onActorTexLoadDone)			

			self.m_LeftDialogueMsg:SetActive(true)
			self.m_RightDialogueMsg:SetActive(false)
			self.m_DialogueL:SetActive(false)
			self.m_NpcNameSpr:SetActive(false)
			self.m_BottomSpr:SetActive(false)
			self.m_LeftDialogueMsg:SetRichText(sText, nil, nil, true)
			self.m_LeftDialogueMark:SetActive(true)
			self.m_RightDialogueMark:SetActive(false)
		end
	end
end

function CPlotDialogueView.Hide(self)
	self.m_Container:SetActive(false)
end



return CPlotDialogueView