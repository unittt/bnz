local CPlotMaskView = class("CPlotMaskView", CViewBase)

function CPlotMaskView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Plot/PlotMaskView.prefab", cb)
	--界面设置
	self.m_DepthType = "Story"
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CPlotMaskView.OnCreateView(self)
	self.m_MaskL = self:NewUI(1, CLabel)
	self.m_MaskSpr = self:NewUI(2, CSprite)
	
	self.m_OriginColor = self.m_MaskSpr:GetColor()
	self:InitContent()
end

function CPlotMaskView.InitContent(self)
	self.m_TweenColor = self.m_MaskSpr:GetComponent(classtype.TweenColor)
	self.m_TweenAlpha = self.m_MaskSpr:GetComponent(classtype.TweenAlpha)

	UITools.ResizeToRootSize(self.m_MaskSpr, 10, 10)
end

function CPlotMaskView.ExcuteMaskAction(self, dAction, cb)
	self.m_MaskAction = dAction
	self.m_Callback = cb
	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	oSequence:AppendInterval(dAction.duration)
	DOTween.OnComplete(oSequence, callback(self, "Hide"))

	self:SetMaskDesc(dAction.content, dAction.fontSize)
	self:SetMaskColor(dAction.startColor)
	self.m_MaskSpr:SetActive(true)

	if dAction.msgEndTime > 0 then
		if dAction.msgStartTime > 0 then
			DOTween.InsertCallback(self.m_Sequence, dAction.msgStartTime, callback(self, "ShowMaskDesc", true))
		else
			self:ShowMaskDesc(true)
		end
		DOTween.InsertCallback(self.m_Sequence, dAction.msgEndTime, callback(self, "ShowMaskDesc", false))
	end

	if dAction.fade then
		local bIsFadeIn = true
		local function Toggle()
			local oOldColor = self.m_MaskSpr:GetColor()
			local oNewColor = nil
			if bIsFadeIn then
				oNewColor = Color.New(dAction.endColor.r, dAction.endColor.g, dAction.endColor.b, dAction.endColor.a)
				bIsFadeIn = false
			else
 				oNewColor = Color.New(dAction.startColor.r, dAction.startColor.g, dAction.startColor.b, dAction.startColor.a)
 			end
			self.m_TweenColor.from = oOldColor
			self.m_TweenColor.to = oNewColor
			self.m_TweenColor.duration = math.max(dAction.fadeTweenTime,0)
			self.m_TweenColor:Play(true)
		end
		if dAction.fadeOutTime > 0 then
			DOTween.InsertCallback(oSequence, dAction.fadeOutTime, Toggle);
			if dAction.fadeInTime > 0 then
				DOTween.InsertCallback(oSequence, dAction.fadeInTime, Toggle);
			else
				Toggle()
			end
		else
			bIsFadeIn = false
			Toggle()
		end
	else
		if dAction.fadeInTime > 0 then
			DOTween.InsertCallback(self.m_Sequence, dAction.fadeInTime, callback(self, "SetMaskColor", dAction.endColor))
		else
			self:SetMaskColor(dAction.endColor)
		end
		if dAction.fadeOutTime > 0 then
			DOTween.InsertCallback(self.m_Sequence, dAction.fadeOutTime, callback(self, "SetMaskColor", dAction.startColor))
		else
			self:SetMaskColor(dAction.startColor)
		end
	end
end

function CPlotMaskView.FadeIn(self, iDuration)
	self.m_MaskL:SetActive(false)
	self.m_MaskSpr:SetColor(self.m_OriginColor)
	self.m_TweenAlpha.from = 1
	self.m_TweenAlpha.to = 0
	self.m_TweenAlpha.duration = iDuration or 0.5
	self.m_TweenAlpha:Play(true)
end

function CPlotMaskView.FadeOut(self, iDuration)
	self.m_MaskL:SetActive(false)
	self.m_MaskSpr:SetColor(self.m_OriginColor)
	self.m_TweenAlpha.from = 0
	self.m_TweenAlpha.to = 1
	self.m_TweenAlpha.duration = iDuration or 0.5
	self.m_TweenAlpha:Play(true)
end

function CPlotMaskView.Hide(self)
	self.m_MaskL:SetActive(false)
	self.m_MaskSpr:SetActive(false)
	if self.m_Callback then
		self.m_Callback()
	end
end

function CPlotMaskView.SetMaskColor(self, dColor)
	dColor = self:AdjustColor(dColor)
	local oColor = Color.New(dColor.r, dColor.g, dColor.b, dColor.a)
	self.m_MaskSpr:SetColor(oColor)
end

function CPlotMaskView.ShowMaskDesc(self, bIsShow)
	self.m_MaskL:SetActive(bIsShow)
end

function CPlotMaskView.SetMaskDesc(self, sDesc, iFontSize)
	self.m_MaskL:SetText(sDesc)
	-- self.m_MaskL.m_GameObject.font_size = iFontSize
	self.m_MaskL:SetActive(false)
end

function CPlotMaskView.Destroy(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	end
	CObject.Destroy(self)
end

function CPlotMaskView.AdjustColor(self, dColor)
	local iMin = 1/255
	dColor.r = math.max(iMin, dColor.r)
	dColor.g = math.max(iMin, dColor.g)
	dColor.b = math.max(iMin, dColor.b)
	return dColor
end

function CPlotMaskView.Pause(self)
	if self.m_Sequence then 
		self.m_Sequence:Pause()
	end
end

function CPlotMaskView.Resume(self)
	if self.m_Sequence then
		self.m_Sequence:Play()
	end
end

return CPlotMaskView