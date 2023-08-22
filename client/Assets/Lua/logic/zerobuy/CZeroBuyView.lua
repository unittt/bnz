local CZeroBuyView = class("CZeroBuyView", CViewBase)

function CZeroBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/ZeroBuy/ZeroBuyView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CZeroBuyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ChenBtn = self:NewUI(2, CButton)
	self.m_WaiguanBtn = self:NewUI(3, CButton)
	self.m_FlyBtn = self:NewUI(4, CButton)
	self.m_ChenPart = self:NewPage(5, CZeroBuyChenPart)
	self.m_WaiguanPart = self:NewPage(6, CZeroBuyWaiguanPart)
	self.m_FlyPart = self:NewPage(7, CZeroBuyFlyPart)

	self.m_SelectIndex = 1--self:GetPageIndex("main")
	
	self:InitContent()
end

function CZeroBuyView.InitContent(self)
	g_ZeroBuyCtrl.m_IsHasClickMainMenu = true
	g_ZeroBuyCtrl:OnEvent(define.ZeroBuy.Event.UpdateInfo)

	self.m_ChenBtn.m_IgnoreCheckEffect = true
	self.m_WaiguanBtn.m_IgnoreCheckEffect = true
	self.m_FlyBtn.m_IgnoreCheckEffect = true
	self.m_ChenBtn:SetGroup(self:GetInstanceID())
	self.m_WaiguanBtn:SetGroup(self:GetInstanceID())
	self.m_FlyBtn:SetGroup(self:GetInstanceID())
	self.m_BtnList = {self.m_ChenBtn, self.m_WaiguanBtn, self.m_FlyBtn}

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ChenBtn:AddUIEvent("click", callback(self, "OnClickChenBtn"))
	self.m_WaiguanBtn:AddUIEvent("click", callback(self, "OnClickWaiguanBtn"))
	self.m_FlyBtn:AddUIEvent("click", callback(self, "OnClickFlyBtn"))
end

function CZeroBuyView.OnClickChenBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Chen"))
end

function CZeroBuyView.OnClickWaiguanBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Waiguan"))
end

function CZeroBuyView.OnClickFlyBtn(self)
	self:ShowSubPageByIndex(self:GetPageIndex("Fly"))
end

function CZeroBuyView.ShowSubPageByIndex(self, iIndex, ...)
	self.m_SelectIndex = iIndex
	local oTab = self.m_BtnList[iIndex]
	oTab:SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
end

return CZeroBuyView