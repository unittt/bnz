local CNpcCloseUpView = class("CNpcCloseUpView", CViewBase)

function CNpcCloseUpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/NpcCloseUpView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CNpcCloseUpView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	-- self.m_MaskTexture = self:NewUI(2, CTexture)
	self.m_BgTexture = self:NewUI(3, CTexture)
	self.m_ClickWidget = self:NewUI(4, CWidget)
	-- self.m_NameBg = self:NewUI(5, CSprite)
	self.m_NameLbl = self:NewUI(6, CLabel)
	self.m_DescLbl = self:NewUI(7, CLabel)
	self.m_ActorTexture = self:NewUI(8, CActorTexture)
	-- self.m_PenBgSp = self:NewUI(9, CTexture)
	self.m_NameSp = self:NewUI(10, CTexture)

	self.m_Test = false
	self.m_IsCouldClose = false
	self.m_IsShowName = false

	self.m_DownTime = 0.5
	
	self:InitContent()
end

function CNpcCloseUpView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Widget, 5, 5)
	-- UITools.ResizeToRootSize(self.m_BgTexture, 5, 5)
	-- self.m_ActorTexture:SetActive(false)
	-- self.m_NameBg:SetActive(false)
	self.m_NameLbl:SetActive(false)
	self.m_DescLbl:SetActive(false)
	-- self.m_PenBgSp:SetActive(true)
	self.m_NameSp:SetActive(false)
	self.m_ClickWidget:AddUIEvent("click", callback(self, "OnClickWidget"))
end

function CNpcCloseUpView.RefreshUI(self, pbdata)
	self:BeforeShow()
	
	self.m_NameSp:SetActive(false)
	self.m_IsShowName = false

	if self.m_Test then
		self.m_IsShowName = true
		self.m_NameStr = "公孙策"
		self.m_DescStr = "哈哈哈哈哈哈哈哈"
		self.m_Model = 2201--g_AttrCtrl.model_info.shape --2502
	else
		local nameTexStr -- = "h7_ming_1"
		if pbdata.npctype ~= 0 then
			local config = DataTools.GetGlobalNpc(pbdata.npctype)
			self.m_NameStr = config.name
			self.m_DescStr = config.desc
			self.m_Model = data.modeldata.CONFIG[config.figureid].model
			if config.closeupname ~= "" then
				self.m_IsShowName = true
				nameTexStr = config.closeupname
			end
		elseif pbdata.parnter ~= 0 then
			local config = DataTools.GetPartnerInfo(pbdata.parnter)
			self.m_NameStr = config.name
			self.m_DescStr = config.desc
			self.m_Model = data.modeldata.CONFIG[config.shape].model
			if config.closeupname ~= "" then
				self.m_IsShowName = true
				nameTexStr = config.closeupname
			end
		else
			self.m_NameStr = "未配置"
			self.m_DescStr = "未配置"
			self.m_Model = 1110
		end
		if nameTexStr then
			local sTextureName = "Texture/Task/"..nameTexStr..".png"
			g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetNameTexture"))
		end
	end

	self.m_IsCouldClose = false
	-- self.m_ActorTexture:SetActive(false)
	-- self.m_NameBg:SetActive(false)
	self.m_NameLbl:SetActive(false)
	self.m_DescLbl:SetActive(false)

	self.m_ActorTexture:SetActive(true)
	self.m_ActorTexture:ChangeShape( {shape = self.m_Model}, function ()
		-- self.m_ActorTexture:SetActive(true)
		-- self.m_ActorTexture.m_ActorCamera:SetOrthographicSize(0.95)

		local sShowName = "show"
		local clipInfo = ModelTools.GetAnimClipData(self.m_Model)
		if clipInfo and clipInfo.show2 then
			sShowName = "show2"
		end
		self.m_ActorTexture:CrossFade(sShowName)
		--[[

		local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
		if oActor then
			local sShowName = "show"
			if clipInfo and clipInfo.show2 then
				sShowName = "show2"
			end
			oActor:CrossFade(sShowName)
		end
		]]
	end)

	self:ShowNameBg()
end

function CNpcCloseUpView.SetNameTexture(self, prefab, errcode)
	if prefab then
		self.m_NameSp:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CNpcCloseUpView.ShowNameBg(self)
	local function finish()
		self.m_DescLbl:SetActive(true)
		self.m_DescLbl:SetText(self.m_DescStr)
		local typetween = self.m_DescLbl:GetComponent(classtype.TypewriterEffect)
		typetween.enabled = true
		typetween:ResetToBeginning()
		typetween.onFinished = function ()
			self.m_IsCouldClose = true

			--延迟3秒操作，自动关闭界面
			if self.m_DelayTimer4 then
				Utils.DelTimer(self.m_DelayTimer4)
				self.m_DelayTimer4 = nil			
			end
			local function delay4()
				if Utils.IsNil(self) then
					return false
				end
				self:AfterClose()
				self:CloseView()
				return false
			end
			self.m_DelayTimer4 = Utils.AddTimer(delay4, 0, define.Task.Time.NpcCloseUpCloseViewDelayTime)
		end
	end

	if self.m_IsShowName then
		local tween =self.m_NameSp:GetComponent(classtype.TweenScale)
		self.m_NameSp:SetActive(true)
		self.m_NameSp:SetLocalScale(Vector3.New(5, 5, 1))
		tween.enabled = true
		tween.from = Vector3.New(5, 5, 1)
		tween.to = Vector3.New(1, 1, 1)
		tween.duration = self.m_DownTime
		tween:ResetToBeginning()
		tween.delay = 0
		tween:PlayForward()
		tween.onFinished = function ()
			finish()
		end
	else
		self.m_NameSp:SetActive(false)
		finish()
	end
end

function CNpcCloseUpView.OnClickWidget(self)
	if self.m_IsCouldClose then
		self:AfterClose()
		self:CloseView()
	end
end

function CNpcCloseUpView.BeforeShow(self)
	local oGuideView = CGuideView:GetView()
	local oPartnerView = CPartnerMainView:GetView()
	local oNotifyView = CNotifyView:GetView()
	if oGuideView then
		oGuideView:SetActive(false)
	end
	if oPartnerView then
		oPartnerView:SetActive(false)
	end
	if oNotifyView then
		oNotifyView:SetActive(false)
	end
end

function CNpcCloseUpView.AfterClose(self)
	local oGuideView = CGuideView:GetView()
	local oPartnerView = CPartnerMainView:GetView()
	local oNotifyView = CNotifyView:GetView()
	if oGuideView then
		oGuideView:SetActive(true)
	end
	if oPartnerView then
		oPartnerView:SetActive(true)
	end
	if oNotifyView then
		oNotifyView:SetActive(true)
	end
end

function CNpcCloseUpView.OnHideView(self)
	g_MapCtrl.m_IsNpcCloseUp = false
	for k,v in pairs(g_MapCtrl.m_NpcShowEndCbList) do
		if v then
			v()
		end
	end
	g_MapCtrl.m_NpcShowEndCbList = {}
	g_NotifyCtrl:SetFloatTableActive(true)
end

return CNpcCloseUpView