 local CGuideView = class("CGuideView", CViewBase)

function CGuideView.ctor(self, cb)
	--路径修改
	CViewBase.ctor(self, "UI/Guide/GuideView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondTop"
	self.m_DlgTextColor = "[AF302A]"
end

function CGuideView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	-- self.m_TipsLabel = self:NewUI(2, CLabel)
	self.m_SwipeGuide = self:NewUI(3, CWidget)
	self.m_ParentPanel = self:NewUI(4, CPanel)
	self.m_EventWidget = self:NewUI(5, CWidget)
	self.m_TextureBox = self:NewUI(6, CGuideTextureBox)
	self.m_FocusBox = self:NewUI(7, CGuideFocusBox)
	self.m_DlgBox = self:NewUI(8, CBox)
	self.m_OpenBox = self:NewUI(9, CGuideOpenBox)
	self.m_ContinueLabel = self:NewUI(10, CLabel)
	self.m_CircleScaleTexture = self:NewUI(11, CSprite)
	self.m_RightArrowSp = self:NewUI(12, CSprite)
	self.m_LeftArrowSp = self:NewUI(13, CSprite)
	self.m_RedNotifySp = self:NewUI(14, CSprite)

	self:InitContent()
end

function CGuideView.InitContent(self)
	self.m_CircleScaleTexture:SetActive(false)
	self.m_RightArrowSp:SetActive(false)
	self.m_LeftArrowSp:SetActive(true)
	self.m_RedNotifySp:SetActive(false)
	self.m_GuideUIInfo = nil
	self.m_GuideKey = nil
	self.m_ClickContinue = false
	self.m_RefreshTextFunc = nil
	UITools.ResizeToRootSize(self.m_Contanier)
	self.m_EventWidget:AddUIEvent("click", callback(self, "OnGuideUIClick"))
	self.m_DlgBox.m_Label = self.m_DlgBox:NewUI(1, CLabel)
	self.m_DlgBox.m_Sprite = self.m_DlgBox:NewUI(2, CSprite)
	self.m_DlgBox.m_NextSpr = self.m_DlgBox:NewUI(3, CSprite)
	-- self.m_TipsLabel:SetText("")
	self:HideAllGuide()
end

function CGuideView.HideAllGuide(self)
	self.m_SwipeGuide:SetActive(false)
	self.m_DlgBox:SetActive(false)
	self.m_TextureBox:SetActive(false)
	self.m_OpenBox:SetActive(false)
	self.m_ContinueLabel:SetActive(false)
end

function CGuideView.SetCenterText(self, sText)
	self:HideAllGuide()
	self.m_TipsLabel:SetText(sText)
end

function CGuideView.SwipeGuide(self, bActive)
	self:HideAllGuide()
	self.m_SwipeGuide:SetActive(bActive)
end

function CGuideView.ClickGuide(self, oUI)
	self:ResetGuideUI()
	if oUI.m_Delegate then
		for i, func in ipairs(self.m_EventWidget.m_Delegate:GetFunctions()) do
			oUI.m_Delegate:AddFunction(function(...) func(..., oUI) end)
		end
	end
	self.m_GuideUIInfo = {
		ui = oUI,
		parent = oUI:GetParent(),
	}
	oUI:SetParent(self.m_ParentPanel.m_Transform, true)
	UITools.SetSubPanelDepthDeep(self.m_ParentPanel)
	UITools.MarkParentAsChanged(oUI.m_GameObject)
	self.m_EventWidget:SetActive(true)
end

function CGuideView.CircleBeforeClickGuide(self, onCallback, oTargetPos)
	self.m_TextureBox:SetActive(false)
	self.m_DlgBox:SetActive(false)
	self.m_CircleScaleTexture:SetActive(true)
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	self.m_CircleScaleTexture:SetPos(g_NotifyCtrl:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.5)))
	self.m_CircleScaleTexture:SetLocalScale(Vector3.New(1, 1, 1))
	local tweenScale = DOTween.DOScale(self.m_CircleScaleTexture.m_Transform, Vector3.New(0.2, 0.2, 0.2), 1)
	local function onFinish()		
		-- callback(self, "CircleMoveEffect", onCallback, oTargetPos)
		self:CircleMoveEffect(onCallback, oTargetPos)
	end
	DOTween.OnComplete(tweenScale, onFinish)
end

function CGuideView.CircleMoveEffect(self, onCallback, oTargetPos)
	local oPathList = {self.m_CircleScaleTexture:GetPos(), oTargetPos}
	local tweenPath = DOTween.DOPath(self.m_CircleScaleTexture.m_Transform, oPathList, 0.35, 0, 0, 10, nil)
	DOTween.SetEase(tweenPath, enum.DOTween.Ease.Linear)
	local function onEnd()
		self.m_TextureBox:SetActive(true)
		self.m_DlgBox:SetActive(true)
		self.m_CircleScaleTexture:SetActive(false)
		if onCallback then
			onCallback()
		end
	end
	DOTween.OnComplete(tweenPath, onEnd)
end

function CGuideView.DlgGuide(self, lTexts, bPlayTween, sSpriteName, vPos, lAudios)
	self.m_DlgBox:SetActive(true)
	if sSpriteName then
		self.m_DlgBox.m_Sprite:SetSpriteName(sSpriteName)
	end
	if vPos then
		self.m_DlgBox:SetPos(vPos)
	end
	if bPlayTween then
		self.m_DlgBox:UITweenPlay()
	else
		self.m_DlgBox:UITweenStop()
	end
	self:NewTextFunc(lTexts, lAudios, self.m_DlgBox.m_Label, self.m_DlgBox.m_NextSpr)
end

function CGuideView.TextureGuide(self, sTxtureName, bPlayTween, bFlipY, vPos)
	self.m_TextureBox:SetActive(true)
	self.m_TextureBox.m_PlayTween = bPlayTween
	self.m_TextureBox.m_FlipY = bFlipY
	self.m_TextureBox:SetTextureName(sTxtureName)
	--暂时屏蔽
	-- if vPos then
	-- 	self.m_TextureBox:SetPos(vPos)
	-- else
	-- 	self.m_TextureBox:SetLocalPos(Vector3.zero)
	-- end
end

function CGuideView.SetTextureLeft(self)
	UITools.NearTarget(self.m_DlgBox.m_Sprite, self.m_TextureBox.m_Texture, enum.UIAnchor.Side.Left, Vector2.New(0, 0))
end

function CGuideView.SetTextureRight(self, offsetX, offsetY)
	UITools.NearTarget(self.m_DlgBox.m_Sprite, self.m_TextureBox.m_Texture, enum.UIAnchor.Side.Left, Vector2.New((offsetX or 0)+182, offsetY or 0))
end

function CGuideView.NotifyGuide(self)
	self.m_EventWidget:SetActive(false)
	self.m_FocusBox:SetFocusCommon(0, 1, 6, 1)
end

function CGuideView.SetFocus(self, x, y, w, h, sEffect, bClickContinue, isParticle, offsetpos, rotate)
	self.m_FocusBox:SetFocusCommon(x, y, w, h)
	self.m_FocusBox:SetEffect(sEffect, isParticle, offsetpos, rotate)
	self.m_EventWidget:SetActive(bClickContinue)
end

function CGuideView.OpenEffect(self, sSpriteName, sOpen, oUI)
	self:HideAllGuide()
	self.m_OpenBox:SetActive(true)
	self.m_OpenBox:SetOpen(sSpriteName, sOpen, oUI)
end

function CGuideView.ResetView(self)
	self.m_FocusBox:Black()
	self:HideAllGuide()
	self.m_EventWidget:SetActive(true)
end

function CGuideView.NewTextFunc(self, lTexts, lAudios, oLabel, oNextSpr)
	self.m_RestoreActive = self.m_EventWidget:GetActive()
	self.m_EventWidget:SetActive(true)
	lTexts = table.copy(lTexts)
	lAudios = table.copy(lAudios or {})
	self.m_RefreshTextFunc = function()
		local text = lTexts[1]
		if text then
			table.remove(lTexts, 1)
			oLabel:SetText(self.m_DlgTextColor..text)
			self.m_DlgBox.m_Sprite:SetAnchor("rightAnchor", oLabel.m_UIWidget.printedSize.x + 30, 0)
			-- printc("CGuideView.NewTextFunc", oLabel.m_UIWidget.printedSize.x)
			oLabel:SimulateOnEnable()
		end
		oNextSpr:SetActive(#lTexts > 1)
		if not next(lTexts) then
			self.m_EventWidget:SetActive(self.m_RestoreActive)
			self.m_RefreshTextFunc = nil
		end

		local oAudio = lAudios[1]
		if oAudio then
			table.remove(lAudios, 1)
			--暂时屏蔽语音
			-- if oAudio ~= "" then
			-- 	g_AudioCtrl:PlaySound(oAudio)
			-- end
		end
	end
	self.m_RefreshTextFunc()
end

function CGuideView.OnGuideUIClick(self, obj, oGuideUI)
	if self.m_RefreshTextFunc then
		self:m_RefreshTextFunc()
	else
		local dInfo = self.m_GuideUIInfo
		if dInfo then
			if oGuideUI == dInfo.ui then
				dInfo.ui:ClearEffect()
				g_GuideCtrl:Continue()
			else
				if self.m_ClickContinue then
					dInfo.ui:ClearEffect()
					g_GuideCtrl:Continue()
				else
					g_GuideCtrl:ShowWrongTips()
				end
			end
		else
			if self.m_ClickContinue then
				g_GuideCtrl:Continue()
			end
		end
	end
end

function CGuideView.StopDelayClose(self)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil
	end
	if self.m_DelayActiveTimer then
		Utils.DelTimer(self.m_DelayActiveTimer)
		self.m_DelayActiveTimer = nil
	end
end

function CGuideView.ResetGuideUI(self)
	local dInfo = self.m_GuideUIInfo
	if dInfo then
		if not Utils.IsNil(dInfo.ui) then
			dInfo.ui:DelEffect("Finger")
			if dInfo.ui.m_IsHasColliderResize then
				if not Utils.IsNil(dInfo.ui) then
					local oBoxCollider = dInfo.ui:GetComponent(classtype.BoxCollider)
					if oBoxCollider then
						oBoxCollider.size = oBoxCollider.size / define.Guide.Args.BoxColliderArgs
					end
				end
				dInfo.ui.m_IsHasColliderResize = false
			end
			if not Utils.IsNil(dInfo.parent) then
				dInfo.ui:SetParent(dInfo.parent, true)
			else
				dInfo.ui:SetActive(false)
			end
			-- dInfo.ui:ClearEffect()				
			UITools.MarkParentAsChanged(dInfo.ui.m_GameObject)
		end
		self.m_GuideUIInfo = nil
	end
end

function CGuideView.DelayClose(self)
	self:StopDelayClose()
	self:ResetGuideUI()
	self.m_DelayTimer = Utils.AddTimer(callback(self, "CloseView"), 0, 5)
	self.m_DelayActiveTimer = Utils.AddTimer(callback(self, "SetActive", false), 0, 0.3)
end

return CGuideView