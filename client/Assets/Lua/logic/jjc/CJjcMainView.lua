local CJjcMainView = class("CJjcMainView", CViewBase)

function CJjcMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Jjc/JjcMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CJjcMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_SinglePart = self:NewPage(3, CJjcSinglePart)
	self.m_GroupPart = self:NewPage(4, CJjcGroupPart)

	g_GuideCtrl:AddGuideUI("jjcview_close_btn", self.m_CloseBtn)

	self:InitContent()
end

function CJjcMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
			local oBtn = CButton.New(obj)
			oBtn:SetGroup(self:GetInstanceID())
			return oBtn
		end)
	for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
		if i==1 then
			oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, nil))
		else
			oTab:SetActive(false)
		end
	end
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
  
	-- self:ShowSinglePart()
	self:RefreshSysEff()
end

function CJjcMainView.ShowSubPageByIndex(self, iIndex, ...)
	if iIndex == self:GetPageIndex("Single") then
		netjjc.C2GSOpenJJCMainUI()
	elseif iIndex == self:GetPageIndex("Group") then
		netjjc.C2GSOpenChallengeUI()
	end
	local oTab = self.m_BtnGrid:GetChild(iIndex)
	oTab:SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
end

function CJjcMainView.RefreshSysEff(self)
	g_SysUIEffCtrl:DelSysEff("JJC_SYS")
	g_SysUIEffCtrl:DelSysEff("JJC_SYS",2)
end

return CJjcMainView