local CSummonMainView = class("CSummonMainView", CViewBase)

function CSummonMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_ViewName = {"属性界面","炼妖界面","图鉴界面"}
end

function CSummonMainView.OnCreateView(self)
	self.m_TitleSprite = self:NewUI(1, CSprite)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_BtnGrid = self:NewUI(3, CTabGrid)
	self.m_PropertyPart = self:NewPage(4, CSummonPropertyPage) -- 属性
	self.m_AdjustPart = self:NewPage(5, CSummonAdjustPage)	--炼妖
	self.m_DetailPart = self:NewPage(6, CSummonBookPage) --图鉴

	self.m_SummonGuideWidget1 = self:NewUI(7, CWidget)
	self.m_SummonGuideWidget2 = self:NewUI(8, CWidget)
	self.m_SummonGuideWidget3 = self:NewUI(9, CWidget)

	g_GuideCtrl:AddGuideUI("summon_guide_widget1", self.m_SummonGuideWidget1)
	g_GuideCtrl:AddGuideUI("summon_guide_widget2", self.m_SummonGuideWidget2)
	g_GuideCtrl:AddGuideUI("summon_guide_widget3", self.m_SummonGuideWidget3)

	self.m_CurTabIndex = 0

	self:InitContent()
	if next(g_SummonCtrl.m_SummonsDic) == nil then
		self:ShowSubPageByIndex(3)
		return
	else
		local defaultIndex = g_SummonCtrl:GetDefaultTabIndex()
		if defaultIndex then
			self:ShowSubPageByIndex(defaultIndex)
		end
		-- self:ShowSubPageByIndex(1)
	end
end

function CSummonMainView.OnActive(self, bActive)
    if not bActive then
        CSummonWashPointView:OnClose()
    end
end

function CSummonMainView.InitContent(self)
	g_GuideCtrl:AddGuideUI("petview_close_btn", self.m_CloseBtn)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	--分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn:SetGroup(self.m_BtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_BtnGrid:InitChild(init)
	self.partInfoList = {
		{titleName = "属 性", btn = self.m_BtnGrid:GetChild(1), part = self.m_PropertyPart,titleSpriteName = "h7_chongwushuxing"},
		{titleName = "洗 宠", btn = self.m_BtnGrid:GetChild(2), part = self.m_AdjustPart,titleSpriteName = "h7_chongwupeiyang"},
		{titleName = "图 鉴", btn = self.m_BtnGrid:GetChild(3), part = self.m_DetailPart,titleSpriteName = "h7_chongwutujian"},
	}
	for i,v in ipairs(self.partInfoList) do
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
		local openState = g_SummonCtrl:IsSpecityTabOpen(i)
		v.btn:SetActive(openState)
	end

	g_GuideCtrl:AddGuideUI("petview_adjust_btn", self.m_BtnGrid:GetChild(2))
end

function CSummonMainView.ShowSubPageByIndex(self, tabIndex)
	if next(g_SummonCtrl.m_SummonsDic) == nil and tabIndex < 3 then
	   g_NotifyCtrl:FloatMsg("你当前没有宠物，无法打开"..self.m_ViewName[tabIndex])
	   self.m_BtnGrid:GetChild(3):SetSelected(true)
	   return
	end

	if self.m_CurTabIndex == tabIndex then
		return
	end
	if not g_SummonCtrl:IsSpecityTabOpen(tabIndex) then
		return
	end

	local oTab = self.m_BtnGrid:GetChild(tabIndex)
	oTab:SetSelected(true)
	local args = self.partInfoList[tabIndex]
	self.m_TitleSprite:SetSpriteName(args.titleSpriteName)
	CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
	self.m_CurTabIndex = tabIndex
end

function CSummonMainView.HandleItemTip(self, iItemId)
	self.m_PropertyPart:HandleItemTip(iItemId)
end

function CSummonMainView.CloseView(self)
	g_SummonCtrl:SaveSummonEffRecord(nil, true)
	g_SummonCtrl:ClearCompoundSelRecord()
	g_SummonCtrl:SetStudyGuildItem(nil)
	CViewBase.CloseView(self)
end

return CSummonMainView