local CArtifactMainView = class("CArtifactMainView", CViewBase)

function CArtifactMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Artifact/ArtifactMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CArtifactMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_MainPart = self:NewPage(4, CArtifactMainPart)
	self.m_QhPart = self:NewPage(5, CArtifactQHPart)
	self.m_QilingPart = self:NewPage(6, CArtifactQiLingPart)	
	self.m_TujianPart = self:NewPage(7, CArtifactTujianPart)
	self.m_ArtifactGuideWidget = self:NewUI(8, CWidget)

	g_GuideCtrl:AddGuideUI("artifact_guide_widget", self.m_ArtifactGuideWidget)

	self.m_IsNotCheckOnLoadShow = true
	self.m_SelectIndex = self:GetPageIndex("main")

	self:InitContent()
end

function CArtifactMainView.OnShowView(self)
	netartifact.C2GSArtifactOpenUI()
end

function CArtifactMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)
	self.m_MainBtn = self.m_BtnGrid:GetChild(1)
	self.m_QHBtn = self.m_BtnGrid:GetChild(2)
	self.m_QiLingBtn = self.m_BtnGrid:GetChild(3)
	self.m_TujianBtn = self.m_BtnGrid:GetChild(4)
	self:InitTab()
	for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
		oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, nil))
	end
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_ArtifactCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlArtifactEvent"))

	self:RegisterSysEffs()
end

function CArtifactMainView.OnCtrlArtifactEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Artifact.Event.UpdateArtifactInfo then
		self:InitTab()
	end
end

function CArtifactMainView.InitTab(self)
	self.m_MainBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Artifact))
	self.m_QHBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Artifact)) --and g_ArtifactCtrl.m_ArtifactGrade >= data.artifactdata.CONFIG[1].strength_open_level)
	--暂时屏蔽
	self.m_QHBtn:SetActive(false)
	self.m_QiLingBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Artifact)) --and g_ArtifactCtrl.m_ArtifactGrade >= data.artifactdata.CONFIG[1].spirit_open_level)
	self.m_TujianBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Artifact))
	self.m_BtnGrid:Reposition()
end

function CArtifactMainView.ShowSubPageByIndex(self, iIndex, ...)
	if not g_OpenSysCtrl:GetOpenSysState(define.System.Artifact) then
		return
	end
	if iIndex == self:GetPageIndex("qh") and not (g_ArtifactCtrl.m_ArtifactGrade >= data.artifactdata.CONFIG[1].strength_open_level) then
		g_ArtifactCtrl:OnShowArtifactQHView()
		self:ShowSubPageByIndex(self.m_SelectIndex)
		return
	end
	if iIndex == self:GetPageIndex("Qiling") and not (g_ArtifactCtrl.m_ArtifactGrade >= data.artifactdata.CONFIG[1].spirit_open_level) then
		g_ArtifactCtrl:OnShowArtifactQiLingView()
		self:ShowSubPageByIndex(self.m_SelectIndex)
		return
	end
	self.m_SelectIndex = iIndex
	local oTab = self.m_BtnGrid:GetChild(iIndex)
	oTab:SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
end

function CArtifactMainView.RegisterSysEffs(self)
	g_SysUIEffCtrl:DelSysEff("ARTIFACT")
end

return CArtifactMainView