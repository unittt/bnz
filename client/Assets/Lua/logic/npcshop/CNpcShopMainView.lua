local CNpcShopMainView = class("CNpcShopMainView", CViewBase)

function CNpcShopMainView.ctor(self, cb)
	local name = "UI/NpcShop/NpcShopView.prefab"
	-- if g_SdkCtrl:IsIOSNativePay() then
	-- 	name = "UI/NpcShop/NpcShopViewIOS.prefab"
	-- end
	CViewBase.ctor(self, name, cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CNpcShopMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleSpr = self:NewUI(2, CSprite)
	self.m_TabBtnGrid = self:NewUI(3, CTabGrid)
	self.m_NpcShopPart = self:NewPage(4, CGoldCoinShopPart)
	self.m_ScoreShopPart = self:NewPage(6, CScoreShopPart)
	self.m_RechargePart = self:NewPage(5, CRechargePart)

	self:InitContent()

	self:ShowSubPageByIndex(1)

	g_ShopCtrl:RemoveLimitRedDot()
	-- if not CTaskHelp.GetClickTaskShopSelect() then
	-- 	self:ShowSubPageByIndex(1)
	-- else
	-- 	self:OnServerOpenViewSelect()
	-- end
end

function CNpcShopMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))

	-- 分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)

	self.m_PartInfoList = {
		{title = "h7_shangdian_3", part = self.m_NpcShopPart},
		{title = "h7_jifenduihuan_1", part = self.m_ScoreShopPart},
		{title = "h7_chongzhi_1", part = self.m_RechargePart},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "OnClickPage", i))
	end

	self:UpdateRebateRedPoint()
end

function CNpcShopMainView.OnWelfareCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
    	self:UpdateRebateRedPoint()
	end
end

function CNpcShopMainView.UpdateRebateRedPoint(self)
	local oBtn = self.m_TabBtnGrid:GetChild(3)
	oBtn.m_IgnoreCheckEffect = true
	local redState = g_WelfareCtrl:IsHadRebateRedPoint()
	if redState then
		oBtn:AddEffect("RedDot", 20, Vector2.New(-16, -16))
	else
		oBtn:DelEffect("RedDot")
	end
end

-- function CNpcShopMainView.ShowSpecificPart(self, tabIndex)
-- 	if not tabIndex then
-- 		g_ShopCtrl.m_ShopRecord.View.TabIndex = 0
-- 		tabIndex = 1
-- 	end
-- 	tabIndex = tabIndex or 1
-- 	self:ShowSubPageByIndex(tabIndex, self.m_PartInfoList[tabIndex])
-- end

function CNpcShopMainView.JumpToTargetItem(self, iItemid)
	self.m_NpcShopPart:JumpToTargetItem(iItemid)
end

function CNpcShopMainView.OnClickPage(self, tabIndex)
	self:ShowSubPageByIndex(tabIndex)
	if tabIndex == 2 then
		self.m_ScoreShopPart:SelectShop(1)
	end
end

function CNpcShopMainView.ShowSubPageByIndex(self, tabIndex)
	local args = self.m_PartInfoList[tabIndex]
	-- g_ShopCtrl.m_ShopRecord.View.TabIndex = tabIndex
	self.m_TitleSpr:SetSpriteName(args.title)
	self.m_TitleSpr:MakePixelPerfect()
	self.m_TabBtnGrid:SetTabSelect(args.btn)
	CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
	self.m_TabIndex = tabIndex
	-- local view = CSmallKeyboardView:GetView()
	-- if view then 
	-- 	view:OnClose()
	-- end
end

-- 服务器协议返回设置选中某个商品
-- function CNpcShopMainView.OnServerOpenViewSelect(self)
-- 	if CTaskHelp.GetClickTaskShopSelect() then
-- 		printc("GetClickTaskShopSelect 数据存在")
-- 		local oTask = CTaskHelp.GetClickTaskShopSelect()
-- 		local isItemFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM)
-- 		local isSummonFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON)
-- 		if isItemFind then
-- 			self:ShowSubPageByIndex(1)
-- 		elseif isSummonFind then
-- 			self:ShowSubPageByIndex(3)
-- 		end
-- 	else
-- 		printc("GetClickTaskShopSelect 数据不存在")
-- 	end	
-- end

function CNpcShopMainView.OnClose(self)
	-- local view = CSmallKeyboardView:GetView()
	-- if view then 
	-- 	view:OnClose()
	-- end
	self:CloseView()
end

return CNpcShopMainView