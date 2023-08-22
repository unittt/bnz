local CGMShopMainView = class("CGMShopMainView", CViewBase)

function CGMShopMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/GM/GMShopMainViwe.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CGMShopMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_TabBtnGrid = self:NewUI(3, CTabGrid)
	self.m_GMShopPart = self:NewPage(4, CGMShopPart)

	self:InitContent()
	self:ShowSpecificPart()
end

function CGMShopMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- 分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)

	self.m_PartInfoList = {
		{title = "GMShop", part = self.m_GMShopPart},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "OnTabBtn", i, v))
	end
end

function CGMShopMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex then
		g_GmCtrl.m_GMRecord.View.TabIndex = 0
		tabIndex = 1
	end
	tabIndex = tabIndex or 1
	self:OnTabBtn(tabIndex, self.m_PartInfoList[tabIndex])
end

function CGMShopMainView.OnTabBtn(self, tabIndex, args)
	if g_GmCtrl.m_GMRecord.View.TabIndex == tabIndex then
		return
	end

	g_GmCtrl.m_GMRecord.View.TabIndex = tabIndex
	self.m_TitleLabel:SetText(args.title)
	self.m_TabBtnGrid:SetTabSelect(args.btn)
	self:ShowSubPage(args.part)
end

function CGMShopMainView.OnClose(self)
	self:CloseView()
end

return CGMShopMainView