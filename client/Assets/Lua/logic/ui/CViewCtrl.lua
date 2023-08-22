local CViewCtrl = class("CViewCtrl", CCtrlBase)
define.Depth = {
	View = {
		Increase = 500, --同一pannel中view间隔500
	},
	Panel = {
		Increase = 50000, --pannel间隔50000
		Base = 50000 * 1,
		Login = 50000 * 2,
		Middle = 50000 * 2.5,
		Dialog = 50000 * 3,
		Fourth = 50000 * 4,
		Notify = 50000 * 5,
		Barrage = 50000 * 8,
		Story = 50000 * 9, --剧情
		BeyondTop = 50000 * 10,
		Guide = 50000 * 11,
		BeyondGuide = 50000 * 12,

		DemiSdk = 50000 * 95,

		Top = 50000 * 100, --最高层级
	}
}
define.View = {
	Event = {
		OnShowView = 1,
	},
	AtlasCount = 15
}

function CViewCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Views = {}
	self.m_GroupHideViews = {}
	self.m_NotGroupHideViews = {}
	self.m_LoadingViews = {}
	self.m_DontDestroyOnCloseeAll = {}
	self.m_UnloadAtlasCounter = define.View.AtlasCount
	self.m_MaskViewName = "CMainMenuView" --各种UI操作需过滤掉主界面
	self.m_LoginCloseAllNeedList = {"CNotifyView"} --, "CGuideView"
	self.m_SumSpecialFollowCloseAllNeedList = {"CNotifyView", "CMainMenuView", "CGuideView"}
	self.m_NpcShowViewName = {"CNpcShowView", "CInteractionView"}
end

function CViewCtrl.ShowView(self, cls, cb)

	if g_LingxiCtrl.m_IsInLingxiPoetry and not table.index(self.m_NpcShowViewName, cls.classname) then 
		g_LingxiCtrl:AddPoetryCbList(function ()
			g_ViewCtrl:ShowView(cls, cb)
		end)
		return
	end
	if g_MapCtrl.m_IsNpcCloseUp and not table.index(self.m_NpcShowViewName, cls.classname) then 
		g_MapCtrl:AddNpcShowCbList(function ()
			g_ViewCtrl:ShowView(cls, cb)
		end)
		return
	end
	local sOpenSys = DataTools.GetOpenSystemByCls(cls.classname)
	if sOpenSys and sOpenSys ~= "" then
		if not g_OpenSysCtrl:GetOpenSysState(sOpenSys, true) then
			return nil
		end
	end
	local oView = self:GetView(cls)
	if not oView then
		oView = g_ResCtrl:GetObjectFromCache(cls.classname)
		if oView then
			local oRoot = UITools.GetUIRoot()
			oView:SetParent(oRoot.transform, false)
		end
	end
	if oView then
		oView:SetActive(true)
		g_ViewCtrl:AddView(oView.classtype, oView)
		if cb then
			cb(oView)
		end
		oView:ExtendClose()
	else
		local oLodingView = self:GetLoadingView(cls)
		if oLodingView then
			oLodingView:SetLoadDoneCB(cb)
		else
			local tips = string.format("%s ShowView", cls.classname)
			if cls.classname == "CGuessRiddleView" then
				local oView = CMainMenuView:GetView()
				if oView then
					oView:InHFDMMapHideTopUI(false)
				end
			end
			if g_GmCtrl.m_GMRecord.Logic.printNetTime then
				g_GmCtrl.m_GMRecord.Logic.recordNetTime = g_TimeCtrl:GetTimeMS()
				tips = tips .. "当前MS：" .. g_GmCtrl.m_GMRecord.Logic.recordNetTime
			end
			print("打开界面UI:" .. tips)
			oLodingView = cls.New(cb)
		end
		self:SetLoadingView(cls, oLodingView)
	end
	self:OnEvent(define.View.Event.OnShowView, cls.classname)
	return oView
end

function CViewCtrl.ShowViewByClsName(self, classname, cb)
	return self:ShowView(_G[classname], cb)
end

--显示指定系统名的UI
--@param sSysName 系统中文名
--@param sTabName 右侧标签页
--@example g_ViewCtrl:ShowViewBySysName("打造", 洗炼, callback（func）)
function CViewCtrl.ShowViewBySysName(self, sSysName, sTabName, cb)
	local dData = DataTools.GetViewDetailDefine(sSysName)
	if not dData then
		return nil
	end
	local function func(oView)
		if sTabName then
			local iTab = dData.tab[sTabName]
			if iTab then
				oView:ShowSubPageByIndex(iTab)
			end
		end
		if cb then
		   cb(oView)
		end
	end
	self:ShowViewByClsName(dData.cls_name, func)
end

function CViewCtrl.CloseView(self, cls)
	print(cls.classname.." CloseView")
	local oLoadingView = self:GetLoadingView(cls)
	if oLoadingView then
		self:SetLoadingView(cls, nil)
	else
		local oView = self:GetView(cls)
		if oView then
			self:DelView(oView.classtype)
			self:ShowOne(oView)
			oView:OnHideView()
			self:DontDestroyOnCloseAll(cls.classname, false)
			--每当有画面关闭的时候，判断当前是否要显示快捷使用
			--g_ItemCtrl:LocalShowQuickUse()
			--每当有画面关闭的时候，判断是否有要显示的成就完成提示
			--g_AchieveCtrl:CheckShowAchieveTips()
			if datauser.resdata.Config[cls.classname] then
				oView:SetActive(false)
				g_ResCtrl:PutObjectInCache(cls.classname, oView)
			else
				oView:Destroy()
				if oView.m_ExtendClose == "Black" then
					g_ResCtrl:CheckUnloadAtlas()
				end
			end
		end
	end
end

function CViewCtrl.AddView(self, cls, oView)
	self:SetLoadingView(cls, nil)
	self.m_Views[cls.classname] = oView
	self:ViewChangeProcess()
end

function CViewCtrl.DelView(self, cls)
	self.m_Views[cls.classname] = nil
	self:ViewChangeProcess()
end

function CViewCtrl.GetView(self, cls)
	return self.m_Views[cls.classname]
end

function CViewCtrl.GetViewByName(self, classname)
	return self.m_Views[classname]
end

function CViewCtrl.GetViews(self)
	return self.m_Views
end

function CViewCtrl.GetViewCount(self)
	return table.count(self.m_Views)
end

function CViewCtrl.SetLoadingView(self, cls, oInstance)
	if oInstance then
		oInstance:SetShowID(Utils.GetUniqueID())
	end
	self.m_LoadingViews[cls.classname] = oInstance
end

function CViewCtrl.GetLoadingView(self, cls)
	return self.m_LoadingViews[cls.classname]
end

function CViewCtrl.TopView(self, oView)
	local sDepthType = oView.m_DepthType
	local iPanelBase = define.Depth.Panel[sDepthType]
	local iTop = iPanelBase
	local list = {}
	for _, v in pairs(self.m_Views) do
		if v.m_DepthType == sDepthType then
			table.insert(list, v)
			local d = v:GetDepth()
			if d > iTop then
				iTop = d
			end
		end
	end
	iTop = iTop + define.Depth.View.Increase
	oView:SetDepthDeep(iTop)
	if iTop > iPanelBase + define.Depth.Panel.Increase - define.Depth.View.Increase then --重置pannel中所有
		local iCur = iPanelBase
		table.sort(list, function(a,b) return a:GetDepth() < b:GetDepth() end)
		for i, v in ipairs(list) do
			iCur = iCur + define.Depth.View.Increase
			v:SetDepthDeep(iCur)
		end
	end
end

function CViewCtrl.HideOther(self, oView)
	local group = oView.m_GroupName
	if group then
		local lst = {}
		for k, v in pairs(self.m_Views) do
			if v.m_GroupName == group and v ~= oView and v:GetActive() then
				if v:GetActive() and k ~= self.m_MaskViewName then
					v:SetActive(false)
					self:AddGroupHide(v)
				elseif k == self.m_MaskViewName and g_MainMenuCtrl:IsExpand() then
					g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.SystemUI)
					-- printc("隐藏主界面")
					self:AddGroupHide(v)
				end
			end
		end
	end
end

function CViewCtrl.AddGroupHide(self, oView)
	self.m_GroupHideViews[oView:GetInstanceID()] = true
end

function CViewCtrl.RemoveGroupHide(self, oView)
	if Utils.IsExist(oView) then
		self.m_GroupHideViews[oView:GetInstanceID()] = nil
	end
end

--主动隐藏不是同一group的view，隐藏后代码里面要主动设置回来 ShowNotGroupOther()
function CViewCtrl.HideNotGroupOther(self, oView, notHideViewList)
	for k, v in pairs(self.m_Views) do
		if v ~= oView and v:GetActive() then
			if v:GetActive() and not table.index(notHideViewList or {}, k) then
				v:SetActive(false)				
				table.insert(self.m_NotGroupHideViews, v)
			end
		end
	end
end

function CViewCtrl.ShowNotGroupOther(self)
	for k,v in pairs(self.m_NotGroupHideViews) do
		if Utils.IsExist(v) then
			v:SetActive(true)
		end
	end
	self.m_NotGroupHideViews = {}
end

------------------- todo -----------------
function CViewCtrl.ShowByGroup(self, group)
	if not group then
		return
	end
	--local lst = {}
	local oShowView = nil  --记录 showid 最大的 oView
	local sViewName = nil
	for k, v in pairs(self.m_Views) do
		if v.m_GroupName == group then
			if oShowView then
				if v:GetShowID() > oShowView:GetShowID() then
					oShowView = v
					sViewName = k
				end
			else
				oShowView = v
				sViewName = k
			end
		end
	end
	if oShowView then
		oShowView:SetActive(true)
		self:HideOther(oShowView)
	end
end

function CViewCtrl.ShowOne(self, oView)
	local group = oView.m_GroupName
	if not group then
		return
	end
	local lst = {}
	local oShowView = nil
	local sViewName = nil
	for k, v in pairs(self.m_Views) do
		if v.m_GroupName == group and v ~= oView and self.m_GroupHideViews[v:GetInstanceID()] then
			if oShowView then
				if v:GetShowID() > oShowView:GetShowID() then
					oShowView = v
					sViewName = k
				end
			else
				oShowView = v
				sViewName = k
			end
		end
	end
	if oShowView then
		oShowView:SetActive(true)
		-- printc("ShowOne", sViewName)
		if sViewName == self.m_MaskViewName then
			g_MainMenuCtrl:ShowAllArea()
			-- printc("恢复主界面")
			return
		end
	end
end

function CViewCtrl.IsNeedShow(self, oView)
	local group = oView.m_GroupName
	if not group then
		return true
	end
	for _, v in pairs(self.m_Views) do
		if v.m_GroupName == group and v ~= oView then
			if v:GetShowID() > oView:GetShowID()  then
				return false
			end
		end
	end
	return true
end

function CViewCtrl.CloseGroup(self, group)
	for k, oView in pairs(self.m_Views) do
		if oView.m_GroupName == group then
			self:DelView(oView.classtype)
			oView:Destroy()
		end
	end
end

function CViewCtrl.CloseAll(self, lExcept, bCheckDontDestory)
	local list = {"CLoginView", "CGmConsoleView", "CNotifyView", "CGmView", "CEditorTableView", "CBottomView", "CLoadingView", "CLockScreenView", "CTestWarView"}
	if lExcept then
		lExcept = table.extend(lExcept, list)
	else
		lExcept = list
	end
	if bCheckDontDestory then
		lExcept = table.extend(lExcept, self.m_DontDestroyOnCloseeAll)
		self.m_DontDestroyOnCloseeAll = {}
	end
	for k, v in pairs(self.m_Views) do
		if table.index(lExcept, k) == nil then
			--printc("CloseAll-->CloseView: ", k)
			if v.CloseView then
				v:CloseView(v)
			else
				self:CloseView(v)
			end
		end
	end
	for k, v in pairs(self.m_LoadingViews) do
		if table.index(lExcept, k) == nil then
			self.m_LoadingViews[k] = nil
		end
	end
end

function CViewCtrl.SwitchScene(self)
	for k, v in pairs(self.m_Views) do
		if v.m_SwitchSceneClose then
			--printc("SwitchScene-->CloseView: ", k)
			if v.CloseView then
				v:CloseView(v)
			else
				self:CloseView(v)
			end
		end
	end
	for k, v in pairs(self.m_LoadingViews) do
		if v.m_SwitchSceneClose then
			self.m_LoadingViews[k] = nil
		end
	end
end

function CViewCtrl.DontDestroyOnCloseAll(self, clsname, bDont)
	if bDont then
		if table.index(self.m_DontDestroyOnCloseeAll, clsname) == nil then
			table.insert(self.m_DontDestroyOnCloseeAll, clsname)
		end
	else
		local index = table.index(self.m_DontDestroyOnCloseeAll, clsname)
		if index ~= nil then
			table.remove(self.m_DontDestroyOnCloseeAll, index)
		end
	end
end

function CViewCtrl.ViewChangeProcess(self)
	--[=[
	local oView = CNotifyView:GetView()
	if oView then
		oView:UpdateExpbarVisible()
	end
	]=]
	g_GuideCtrl:OnTriggerAll()
end

return CViewCtrl