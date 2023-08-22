local CViewBase = class("CViewBase", CPanel, CGameObjContainer)

function CViewBase.ctor(self, path, cb)
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnViewLoad"), true)
	self.m_Path = path
	self.m_LoadDoneFunc = cb
	self.m_StrikeResult = false --是否处理了点穿事件,处理了点穿事件则不自动关闭界面
	self.m_BehidLayer = nil
	self.m_HideCB = nil
	self.m_ShowID = Utils.GetUniqueID() --id越大，越晚调用ShowView
	self.m_IsActive = nil
	--界面设置，以下为默认值，继承类自己设置需要的属性
	self.m_DepthType = "Dialog"  --层次
	self.m_GroupName = nil --界面组(只有一个界面会被显示)
	-- ClickOut, Black, Shelter, Pierce
	-- ClickOut:点击有效，不带黑边 | Black:点击有效，带黑边 | Shelter:点击无效，带黑边 | Pierce:点击无效，不带黑边
	self.m_ExtendClose = nil
	self.m_BehindStrike = false --BehindView点击穿透
	self.m_OpenEffect = nil --打开界面动画 Scale
	self.m_ShowCB = nil
	self.m_ChildViewRef = nil
end

function CViewBase.GetShowID(self)
	return self.m_ShowID
end

function CViewBase.SetShowID(self, id)
	self.m_ShowID = id
end

function CViewBase.SetShowCB(self, cb)
	self.m_ShowCB = cb
end

function CViewBase.ClearShowCB(self)
	self.m_ShowCB = nil
end

function CViewBase.SetLoadDoneCB(self, cb)
	self.m_LoadDoneFunc = cb
end

function CViewBase.SetHideCB(self, cb)
	self.m_HideCB = cb
end

function CViewBase.ShowView(cls, cb)
	return g_ViewCtrl:ShowView(cls, cb)
end

function CViewBase.GetView(cls)
	return g_ViewCtrl:GetView(cls)
end

function CViewBase.CloseView(cls)
	g_ViewCtrl:CloseView(cls)
	-- 画舫灯谜 
	g_GuessRiddleCtrl:InHFDMMapHideTopUI(cls.classname)
end

function CViewBase.SetStrikeResult(self, b)
	self.m_StrikeResult = b
end

function CViewBase.GetStrikeResult(self)
	return self.m_StrikeResult
end

function CViewBase.SetActive(self, bActive)
	if self.m_IsActive == bActive then
		return
	end
	self.m_IsActive = bActive

	CPanel.SetActive(self, bActive)
	if bActive then
		local isWarRoot = self.classname == "CWarBg" or self.classname == "CWarBgSky"
		local oRoot = isWarRoot and UITools.GetWarUIRoot() or UITools.GetUIRoot()
		if self:GetParent() ~= oRoot.transform then
			self:SetParent(oRoot.transform, false)
		end
		self:StartOpenEffect()
		self:ExtendClose()
		g_ViewCtrl:TopView(self)
		if self.classname ~= "CMainMenuView" then
			g_ViewCtrl:HideOther(self)
		end
		g_ViewCtrl:RemoveGroupHide(self)
		self:OnShowView()
		if self.m_ShowCB then
			self.m_ShowCB()
			self.m_ShowCB = nil
		end
	else
		self:DestroyBeindLayer()
		g_ViewCtrl:AddGroupHide(self)
		self:OnHideView()
	end

end

function CViewBase.OnViewLoad(self, oClone, path)
	if oClone then
		--不需要清理的界面
		if table.index({}, self.classtype.classname) then
			local oAssetInfo = g_ResCtrl:GetAssetInfo(oClone, true)
			if oAssetInfo then
				oAssetInfo:SetDontRelease(true)
			end			
		end

		if g_ViewCtrl:GetLoadingView(self.classtype) then
			g_ResCtrl:ManagedTextures(oClone)
			if not oClone.activeSelf then
				printerror(string.format("警告：当前%s.Prefab的Active为false，请检查预制的Active是否设置正确", oClone.name))
				oClone:SetActive(true)
			end

			local isWarRoot = path == "UI/War/WarBg.prefab" or path == "UI/War/WarBgSky.prefab"
			local oRoot = isWarRoot and UITools.GetWarUIRoot() or UITools.GetUIRoot()
			oClone.transform:SetParent(oRoot.transform, false)
			CPanel.ctor(self, oClone)
			CGameObjContainer.ctor(self, oClone)
			self:OnCreateView()--获取控件
			if not self.m_IsNotCheckOnLoadShow then
				self:OnShowView()
			end
			if self.m_ShowCB then
				self.m_ShowCB()
				self.m_ShowCB = nil
			end
			if g_ViewCtrl:IsNeedShow(self) then
				self:SetActive(true)
			elseif g_ViewCtrl.m_MaskViewName == self.classtype.classname then
				--主界面为常驻界面，必须加入view缓存
				if g_MainMenuCtrl:IsExpand() then
					g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.SystemUI)
					g_ViewCtrl:AddGroupHide(self)
				end
			else
				self:SetActive(false)
				-- g_ResCtrl:PutObjectInCache(self.classtype.classname, self)
			end
			g_ViewCtrl:AddView(self.classtype, self)
			if self.m_LoadDoneFunc then
				self.m_LoadDoneFunc(self)
			end
			print(string.format("%s LoadDone!", self.classname))
		else
			oClone:Destroy()
			print(string.format("%s LoadDone, not in loadingview!", self.classname))
		end
		self:LoadDone() --画面结束加载时调用
		if g_GmCtrl.m_GMRecord.Logic.printNetTime then
			local curMS = g_TimeCtrl:GetTimeMS()
			local invalMS = curMS - g_GmCtrl.m_GMRecord.Logic.recordNetTime
			print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "Send", " UI绘制结束 MS | 间隔"), curMS, invalMS)
		end
	else
		g_NotifyCtrl:FloatMsg("界面加载出错了")
		g_ViewCtrl:SetLoadingView(self.classtype, nil)
		printerror(string.format("%s LoadError", self.classname))
	end
end

function CViewBase.ExtendClose(self)
	if not self.m_ExtendClose then
		return
	end
	
	if not self.m_BehidLayer then
		self.m_BehidLayer = CBehindLayer.New()
	end
	if self.m_ExtendClose == "Shelter" then
		self.m_BehidLayer:SetTextrueShow(true)
		self.m_BehidLayer:SetShelter(true)
	elseif self.m_ExtendClose == "Pierce" then
		self.m_BehidLayer:SetTextrueShow(false)
		self.m_BehidLayer:SetShelter(true)
	else
		self.m_BehidLayer:SetTextrueShow(self.m_ExtendClose == "Black")
	end
	self.m_BehidLayer:SetOwner(self)
	self.m_BehidLayer:SetLocalPos(Vector3.zero)
end

function CViewBase.StartOpenEffect(self)
	if self.m_OpenEffect == "Scale" then
		self:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
		local tween = DOTween.DOScale(self.m_Transform, Vector3.New(1, 1, 1), 0.35)
		DOTween.SetEase(tween, enum.DOTween.Ease.InOutFlash)
	end
end

function CViewBase.DestroyBeindLayer(self)
	if self.m_BehidLayer then
		self.m_BehidLayer:Destroy()
		self.m_BehidLayer = nil
	end
end

--请调用CloseView()关闭界面
function CViewBase.Destroy(self)
	self:DestroyBeindLayer()
	self:CloseChildView()
	if self.m_PageList and #self.m_PageList > 0 then
		for _, page in ipairs(self.m_PageList) do
			if page:IsInit() then
				page:Destroy()
			end
		end
	end
	CPanel.Destroy(self)
	CGameObjContainer.Destroy(self)
	g_ResCtrl:CheckManagedAssetsLater()
end

function CViewBase.SetDepthDeep(self, depth)
	local iRelative = depth - self:GetDepth()
	self:RelativeSubPanelDepth(iRelative)
	self:SetDepth(depth)
	-- UITools.SetSubPanelDepthDeep(self)
	if self.m_BehidLayer then
		self.m_BehidLayer:SetDepth(depth-1)
	end
end

function CViewBase.RelativeSubPanelDepth(self, iRelative)
	local panels = self:GetComponentsInChildren(classtype.UIPanel, true)
	for i=0, panels.Length-1 do
		local panel = panels[i]
		panel.depth = panel.depth + iRelative
	end
end

--关闭按钮的回调，比较通用放到ViewBase
function CViewBase.OnClose(self, o)
	self:CloseView()
end

--override function

--界面加载完成后调用,获取控件
function CViewBase.OnCreateView(self)
	--body
end

--界面SetActive True时调用
function CViewBase.OnShowView(self)
	--body
end

--界面SetActive False时调用
function CViewBase.OnHideView(self)
	--body
	if self.m_HideCB then
		self.m_HideCB()
	end
end

--界面加载完成时调用
function CViewBase.LoadDone(self)
	--body
	if self.m_GroupName == "main" and define.Res.CallGcViews[self.classname] then
		g_ResCtrl:CheckAutoGc()
	end
end

function CViewBase.SetChildView(self, oView)
	self.m_ChildViewRef = weakref(oView)
end

function CViewBase.CloseChildView(self)
	local oView = getrefobj(self.m_ChildViewRef)
	if oView then
		oView:CloseView()
	end
	self.m_ChildViewRef = nil
end

return CViewBase
