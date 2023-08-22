local CMapFadeView = class("CMapFadeView", CViewBase)

function CMapFadeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Map/MapFadeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Increase"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CMapFadeView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_MapBg = self:NewUI(2, CTexture)
	self.m_shot = self:GetMissingComponent(classtype.ShotHelper)
	self.m_AlphaTween = self.m_MapBg:GetComponent(classtype.TweenAlpha)
	self.m_MapFadeCb = nil	
	self:InitContent()
end

function CMapFadeView.InitContent(self)
	self.m_AlphaTween.enabled = false
	self.m_MapBg:SetAlpha(0)
	UITools.ResizeToRootSize(self.m_MapBg)
	self:RefreshUI()
end

function CMapFadeView.RefreshUI(self)

	local mainCam = g_CameraCtrl:GetMainCamera()
	self.m_shot:Capture(mainCam.m_Camera, callback(self, "LoadDone"))
	
end

function CMapFadeView.LoadDone(self, tex)

	self:SetTexture(tex)

end

function CMapFadeView.SetTexture(self, tex)
	if tex then
		self.m_MapBg:SetMainTexture(tex)
		self.m_MapBg:SetAlpha(0.8)
		self.m_AlphaTween.from = 0.8
		self.m_AlphaTween.to = 0
		self.m_AlphaTween.duration = 1.2
		self.m_AlphaTween.enabled = true
		self.m_AlphaTween:ResetToBeginning()
		self.m_AlphaTween:PlayForward()
		self.m_AlphaTween.onFinished = function ()
			tex:Destroy()
		end
	end
end

return CMapFadeView