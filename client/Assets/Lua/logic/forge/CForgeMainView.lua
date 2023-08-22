local CForgeMainView = class("CForgeMainView", CViewBase)

function CForgeMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CForgeMainView.ShowView(cls, cb)
	g_ForgeCtrl:ShowView(cls, cb)
end

function CForgeMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CTabGrid)
	self.m_ForgeMainPart = self:NewPage(3, CForgeMainPart)
	self.m_StrengthenPart = self:NewPage(4, CForgeStrengthenPart)
	self.m_WashPart = self:NewPage(5, CForgeWashPart)
	self.m_AttachSoulPart = self:NewPage(6, CForgeAttachSoulPart)
	self.m_InlayPart = self:NewPage(7, CForgeInlayPart)
	self.m_ForgeGuideWidget = self:NewUI(8, CWidget)

	g_GuideCtrl:AddGuideUI("forge_guide_widget", self.m_ForgeGuideWidget)

	self:InitContent()
end

function CForgeMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
		oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, nil))

		if i == 2 then
			g_GuideCtrl:AddGuideUI("equip_qh_tab_btn", oTab)
		elseif i == 3 then
			g_GuideCtrl:AddGuideUI("equip_xl_tab_btn", oTab)
		end

		local openState = g_ForgeCtrl:IsSpecityTabOpen(i)
		oTab:SetActive(openState)
	end
	g_GuideCtrl:AddGuideUI("forgeview_close_btn", self.m_CloseBtn)

	local defaultIndex = g_ForgeCtrl:GetDefaultTabIndex()
	if defaultIndex then
		self:ShowSubPageByIndex(defaultIndex)
	end
	self:RegisterSysEffs()
end

function CForgeMainView.ShowSubPageByIndex(self, iIndex, iItemId)
	local oTab = self.m_BtnGrid:GetChild(iIndex)
	if not oTab or not oTab:GetActive() then
		g_NotifyCtrl:FloatMsg("功能未解锁")
		self:ShowSubPageByIndex(1)
		return
	end
	oTab:SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, iItemId)
	g_ForgeCtrl:RecordLastTab(iIndex)
	if iIndex > 1 then
		self:GetCurrentPage():ChangeSelectId(iItemId)
	end
end

function CForgeMainView.Destroy(self)
	for _,oPart in ipairs(self.m_PageList) do
		if oPart.SaveSelectedId then
			oPart:SaveSelectedId()
		end
	end
	CViewBase.Destroy(self)
end

function CForgeMainView.RegisterSysEffs(self)
	local oGrid = self.m_BtnGrid
	g_SysUIEffCtrl:TryAddEff("EQUIP_DZ", oGrid:GetChild(2))
	g_SysUIEffCtrl:TryAddEff("EQUIP_XL", oGrid:GetChild(3))
	g_SysUIEffCtrl:TryAddEff("EQUIP_FH", oGrid:GetChild(4))
	g_SysUIEffCtrl:DelSysEff("EQUIP_SYS")
end

return CForgeMainView