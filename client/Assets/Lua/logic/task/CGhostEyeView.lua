local CGhostEyeView = class("CGhostEyeView", CViewBase)

function CGhostEyeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/GhostEyeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CGhostEyeView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_EyeBtn = self:NewUI(2, CButton)
	self.m_TimeSp = self:NewUI(3, CSprite)
	self.m_MaskBg = self:NewUI(4, CTexture)
	self.m_EyeCloseBtn = self:NewUI(5, CButton)
	self.m_AnotherBg = self:NewUI(6, CSprite)
	self.m_DescLbl = self:NewUI(7, CLabel)
	self.m_EffectWidget = self:NewUI(8, CWidget)
	--暂时屏蔽特效
	self.m_EffectWidget:SetActive(false)
	
	self:InitContent()
end

function CGhostEyeView.InitContent(self)
	UITools.ResizeToRootSize(self.m_MaskBg, 10, 10)
	self.m_MaskBg:SetColor(Color.New(1, 1, 1, 1))
	self.m_TimeSp.m_UIWidget.fillAmount = 0

	for i=1,5 do
		if i <= define.Task.Time.GhostEyeBoxNum then
			self["m_BoxEffect"..i]:SetActive(true)
		else
			self["m_BoxEffect"..i]:SetActive(false)
		end
	end
	self.m_EyeBtn:SetActive(true)
	self.m_Widget:GetComponent(classtype.BoxCollider).enabled = true
	self.m_TimeSp:SetActive(true)
	self.m_MaskBg:SetActive(false)
	self.m_EyeCloseBtn:SetActive(false)
	self.m_AnotherBg:SetActive(true)
	self.m_DescLbl:SetActive(true)
	self.m_DescLbl:SetText("开启天眼通，可入鬼界！")
	self.m_EffectWidget:AddEffect("GhostEye")

	self.m_EyeBtn:AddUIEvent("click", callback(self, "OnClickEye"))
	self.m_EyeCloseBtn:AddUIEvent("click", callback(self, "OnClickEyeClose"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
end

function CGhostEyeView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.EyeCountTime then
		if g_TaskCtrl.m_EyeLeftTime > -0.1 then
			self.m_TimeSp.m_UIWidget.fillAmount = (define.Task.Time.GhostEyeCircleDurationTime - g_TaskCtrl.m_EyeLeftTime)/define.Task.Time.GhostEyeCircleDurationTime
		else
			self:ExecuteEvent()
			g_TaskCtrl:ResetGhostEyeEffectForwardTimer()
			g_TaskCtrl:ResetGhostEyeEffectReverseTimer()
			-- self:CloseView()
			self:ResetUI()
		end
	elseif oCtrl.m_EventID == define.Task.Event.GhostEyeEffectForward then
		for i=1,define.Task.Time.GhostEyeBoxNum do
			local tween = self["m_BoxEffect"..i]:GetComponent(classtype.TweenHeight)
			self["m_BoxEffect"..i]:SetWidth(110)
			tween.from = 110
			tween.to = 200
			tween.duration = define.Task.Time.GhostEyeDurationTime
			tween:ResetToBeginning()
			if i == 1 then
				tween.delay = 0
			else
				tween.delay = 0 + (define.Task.Time.GhostEyeDurationTime/(define.Task.Time.GhostEyeBoxNum-1))*(i-1)
			end
			tween:PlayForward()
		end
	elseif oCtrl.m_EventID == define.Task.Event.GhostEyeEffectReverse then
		for i=1,define.Task.Time.GhostEyeBoxNum do
			local tween = self["m_BoxEffect"..i]:GetComponent(classtype.TweenHeight)
			self["m_BoxEffect"..i]:SetWidth(200)
			tween.from = 200
			tween.to = 110
			tween.duration = define.Task.Time.GhostEyeDurationTime
			tween:ResetToBeginning()
			if i == 1 then
				tween.delay = 0
			else
				tween.delay = 0 + (define.Task.Time.GhostEyeDurationTime/(define.Task.Time.GhostEyeBoxNum-1))*(i-1)
			end
			tween:PlayForward()
		end
	elseif oCtrl.m_EventID == define.Task.Event.EyeCloseCountTime then
		if g_TaskCtrl.m_EyeCloseLeftTime > -0.1 then
			self.m_TimeSp.m_UIWidget.fillAmount = (define.Task.Time.GhostEyeCircleDurationTime - g_TaskCtrl.m_EyeCloseLeftTime)/define.Task.Time.GhostEyeCircleDurationTime
		else
			g_TaskCtrl:ResetGhostEyeEffectForwardTimer()
			g_TaskCtrl:ResetGhostEyeEffectReverseTimer()
			self:CloseView()
		end
	end
end

function CGhostEyeView.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.SetGhostEye then
		self:ShowGhostContent()
	end
end

function CGhostEyeView.ShowGhostContent(self, isLogin)
	local oView = CNotifyView:GetView()
	if oView then
		-- oView.m_FloatTable:Clear()
		oView:ClearFloatMsg()
	end
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StopWalk()
	end
	self.m_EyeBtn:SetActive(true)
	self.m_Widget:GetComponent(classtype.BoxCollider).enabled = true
	self.m_TimeSp:SetActive(true)
	self.m_MaskBg:SetActive(false)
	self.m_EyeCloseBtn:SetActive(false)
	self.m_AnotherBg:SetActive(true)
	self.m_DescLbl:SetActive(true)
	self.m_DescLbl:SetText("开启天眼通，可入鬼界！")
	self.m_EffectWidget:AddEffect("GhostEye")

	if isLogin then
		self:ResetUI()
	else
		self.m_TimeSp.m_UIWidget.fillAmount = 0
		g_TaskCtrl:SetEyeCountTime()
		g_TaskCtrl:SetGhostEyeEffectForward()
		g_TaskCtrl:SetGhostEyeEffectReverse()
	end
end

function CGhostEyeView.SetCloseEffect(self)
	local oView = CNotifyView:GetView()
	if oView then
		-- oView.m_FloatTable:Clear()
		oView:ClearFloatMsg()
	end
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StopWalk()
	end
	for i=1,5 do
		if i <= define.Task.Time.GhostEyeBoxNum then
			self["m_BoxEffect"..i]:SetActive(true)
		else
			self["m_BoxEffect"..i]:SetActive(false)
		end
	end
	self.m_EyeBtn:SetActive(false)
	self.m_Widget:GetComponent(classtype.BoxCollider).enabled = true
	self.m_TimeSp:SetActive(true)
	-- self.m_MaskBg:SetActive(false)
	self.m_EyeCloseBtn:SetActive(true)
	self.m_AnotherBg:SetActive(true)
	self.m_DescLbl:SetActive(true)
	self.m_DescLbl:SetText("关闭天眼通，返回现实！")
	self.m_EffectWidget:AddEffect("GhostEye")

	local function delay()
		local oView = CNotifyView:GetView()
		if oView then
			-- oView.m_FloatTable:Clear()
			oView:ClearFloatMsg()
		end
		return false
	end
	Utils.AddTimer(delay, 0, 0.2)	

	self.m_TimeSp.m_UIWidget.fillAmount = 0
	g_TaskCtrl:SetEyeCloseCountTime()
	g_TaskCtrl:SetGhostEyeEffectForward()
	g_TaskCtrl:SetGhostEyeEffectReverse()
end

function CGhostEyeView.OnClickEye(self)
	self:ExecuteEvent()
	g_TaskCtrl:ResetEyeTimer()
	g_TaskCtrl:ResetGhostEyeEffectForwardTimer()
	g_TaskCtrl:ResetGhostEyeEffectReverseTimer()
	-- self:CloseView()
	self:ResetUI()
end

function CGhostEyeView.ExecuteEvent(self)
	--处理了全局npc和临时npc
	g_MapCtrl:SetGlobalNpcActive()
	g_MapCtrl:SetClientNpcActive()
end

function CGhostEyeView.ResetUI(self)
	for i=1,5 do
		self["m_BoxEffect"..i]:SetActive(false)
	end
	self.m_EyeBtn:SetActive(false)
	self.m_Widget:GetComponent(classtype.BoxCollider).enabled = false
	self.m_TimeSp:SetActive(false)
	self.m_MaskBg:SetActive(true)
	self.m_EyeCloseBtn:SetActive(false)
	self.m_AnotherBg:SetActive(false)
	self.m_DescLbl:SetActive(false)
	self.m_EffectWidget:DelEffect("GhostEye")
end

function CGhostEyeView.OnClickEyeClose(self)
	g_TaskCtrl:ResetEyeCloseTimer()
	g_TaskCtrl:ResetGhostEyeEffectForwardTimer()
	g_TaskCtrl:ResetGhostEyeEffectReverseTimer()
	self:CloseView()
end

return CGhostEyeView