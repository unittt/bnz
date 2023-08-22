local CItemComposeView = class("CItemComposeView", CViewBase)

function CItemComposeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemComposeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CItemComposeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ComposeTab = self:NewUI(2, CButton)
	self.m_DecomposeTab = self:NewUI(3, CButton)
	self.m_ComposeBox = self:NewUI(4, CItemComposeBox)
	self.m_DecomposeBox = self:NewUI(5, CItemDecomposeBox)
	self.m_Boxs = {
		[1] = self.m_ComposeBox,
		[2] = self.m_DecomposeBox,
	}
	self.m_Tabs = {
		[1] = self.m_ComposeTab,
		[2] = self.m_DecomposeTab,
	}

	-- TouchOutDetect(匿名function用callback代替)
	-- g_UITouchCtrl:TouchOutDetect(self, function (gameObj)
		-- if CSmallKeyboardView:GetView() == nil then
        -- 	self:CloseView()
        -- end
    -- end)

	self.m_CurrentBox = nil
	self.m_CurrentTab = -1
	self:InitContent()
end

function CItemComposeView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ComposeTab:AddUIEvent("click", callback(self, "ChangeTab", 1))
	self.m_DecomposeTab:AddUIEvent("click", callback(self, "ChangeTab", 2))
	self:ChangeTab(1)
	self.m_ComposeTab:SetSelected(true)
end

function CItemComposeView.ChangeTab(self, iTab)
	if iTab == self.m_CurrentTab then
		return
	end
	if self.m_CurrentBox then
		self.m_CurrentBox:SetActive(false)
	end
	self.m_Tabs[iTab]:SetSelected(true)
	local oBox = self.m_Boxs[iTab]
	if oBox then
		oBox:SetActive(true)
		self.m_CurrentBox = oBox
		self.m_CurrentTab = iTab
	end
end

function CItemComposeView.JumpToGemStoneCompose(self, oItem)
	-- printc(oItem:GetCValueByKey("name"))
	self:ChangeTab(1)
	self.m_CurrentBox:JumpToTargetCatalog(4, 0)
	self.m_CurrentBox:SetSelectedItem(oItem)
end

function CItemComposeView.JumpToGemStoneMix(self, oItem)
	self:ChangeTab(1)
	self.m_CurrentBox:JumpToTargetCatalog(5, 0)
	self.m_CurrentBox:SetSelectedItem(oItem)
end

function CItemComposeView.JumpToCompose(self, iItemId)
	self:ChangeTab(1)
	local dCatalogInfo = data.itemcomposedata.ITEM2CAT[iItemId][1]
	self.m_CurrentBox:JumpToTargetCatalog(dCatalogInfo.cat_id, dCatalogInfo.subcat_id)
end

function CItemComposeView.JumpToDeCompose(self, iItemId)
	self.m_ComposeBox:JumpToTargetCatalog(1,1)
	self:ChangeTab(2)
	self.m_CurrentBox:ChangeSelectId(iItemId)
end
return CItemComposeView