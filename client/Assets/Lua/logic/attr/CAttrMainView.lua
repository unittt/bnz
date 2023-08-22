local CAttrMainView = class("CAttrMainView", CViewBase)

function CAttrMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrMainView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CAttrMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleSprite = self:NewUI(2, CSprite)
	self.m_BtnGrid = self:NewUI(3, CTabGrid)
	self.m_AttrMainPart = self:NewPage(4, CAttrMainPart)
	self.m_AttrPointPart = self:NewPage(5, CAttrPointPart)
	self:InitContent()
end

function CAttrMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)
	self.m_AttrBtn = self.m_BtnGrid:GetChild(1)
	self.m_PointBtn = self.m_BtnGrid:GetChild(2)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self.m_TitleIcon = {
		[1] = "h7_renwushuxing",
		[2] = "h7_renwujiadian",
		--[3] = "h7_shizhuang",
 	}
	for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
		oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
	end
	self:ShowSubPageByIndex(1)
	local IsOpen = g_OpenSysCtrl:GetOpenSysState("ROLE_ADDPOINT")
	local showPoint = false
	if IsOpen and g_AttrCtrl.grade >= data.opendata.OPEN.ROLE_ADDPOINT.p_level then
		self.m_PointBtn:SetActive(true)
		showPoint = true
	else
		self.m_PointBtn:SetActive(false)
	end
	if not showPoint then
	   local pos = self.m_PointBtn:GetLocalPos()
	end
	local showSkill = g_AttrCtrl.grade >= 20
	self:RegisterSysEffs()
end

function CAttrMainView.ShowSubPageByIndex(self, iIndex)
	if iIndex == self:GetPageIndex("Waiguan") then
		self.m_AttrBtn:SetActive(false)
		self.m_PointBtn:SetActive(false)
		self.m_BtnGrid:Reposition()
	else
		self.m_AttrBtn:SetActive(true)
		self.m_PointBtn:SetActive(g_OpenSysCtrl:GetOpenSysState("ROLE_ADDPOINT"))
		self.m_BtnGrid:Reposition()
	end

	self.m_TitleSprite:SetSpriteName(self.m_TitleIcon[iIndex])
	self.m_TitleSprite:MakePixelPerfect()
	local oTab = self.m_BtnGrid:GetChild(iIndex)
	oTab:SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex)
end

function CAttrMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex then
		tabIndex = 1
	end
	self:ShowSubPageByIndex(tabIndex)
end

function CAttrMainView.RegisterSysEffs(self)
	g_SysUIEffCtrl:TryAddEff("ROLE_ADDPOINT", self.m_PointBtn)
	g_SysUIEffCtrl:DelSysEff("ROLE_S")
end

function CAttrMainView.CloseView(self)
	CViewBase.CloseView(self)
end

return CAttrMainView