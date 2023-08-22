local CItemGainBox = class("CItemGainBox", CBox)

function CItemGainBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_TitleLb = self:NewUI(1, CLabel)
	self.m_ItemScrollView = self:NewUI(2, CScrollView)
	self.m_GainWayGrid = self:NewUI(3, CGrid)
	self.m_SysPrefab = self:NewUI(4, CBox)
	self.m_ContentBg = self:NewUI(5, CSprite)
	self.m_SysPrefab:SetActive(false)
	-- self.m_SelectFunc = {
	-- 	["商城"] = function(oView, iItemid, iSetItemId) self:JumpToShopItem(oView, iItemid, iSetItemId) end,
	-- 	["日程"] = function(oView, iItemid, iScheduleId) self:JumpToSchedule(oView, iItemid, iScheduleId) end,
	-- 	["交易所"] = function(oView, iItemid) self:JumpToEcononmyItem(oView, iItemid) end,
	-- 	["技能"] = function(oView, iItemid) self:JumpToOrgSkill(oView, iItemid) end,
	-- 	["合成"] = function(oView, iItemid, iTab) self:JumpToCompose(oView, iItemid, iTab) end,
	-- 	["帮派"] = function(oView, iItemid, iBuildId) self:JumpToOrgBuilding(oView, iBuildId) end,
	-- 	["福利"] = function(oView) self:JumpToFirstPay(oView) end,
	-- 	["充值"] = function(oView) self:JumpToRechargeRebate(oView, iItemid, iSubTab) end,
	-- }
end

function CItemGainBox.SetInitBox(self, citem)
	self.m_ItemData = citem.m_CItemInfoGetter()
	self:RefreshGrid(self.m_ItemData.gainWayIdStr)
end

function CItemGainBox.RefreshGrid(self, datalist)
	self.m_GainWayGrid:Clear()
	for i,configId in ipairs(datalist) do
		local oBox = self:CreateSysBox(configId)
		if oBox then
			self.m_GainWayGrid:AddChild(oBox)
		end
	end
	self.m_GainWayGrid:Reposition()
end

function CItemGainBox.CreateSysBox(self, configId)
	local dConfig = data.itemgaindata.CONFIG[configId]
	if not dConfig then
		return
	end
	local bIsUnlock = g_OpenSysCtrl:GetOpenSysState(dConfig.open_sys)
	local oBox = self.m_SysPrefab:Clone()
	oBox.m_IsUnloc = bIsUnlock
	oBox:SetActive(true)
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_TabNameL = oBox:NewUI(2, CLabel)

	oBox.m_IconSpr:SetSpriteName(dConfig.icon)
	oBox.m_TabNameL:SetText(dConfig.gaindesc)
	oBox.m_IconSpr:SetGrey(not bIsUnlock)
	oBox.m_IconSpr:AddUIEvent("click", callback(self, "JumpToTargetSystem", dConfig, bIsUnlock))
	return oBox
end

function CItemGainBox.JumpToTargetSystem(self, dConfig, bIsUnlock)
	g_ItemGainWayCtrl:JumpToTargetSystem(dConfig, bIsUnlock, self.m_ItemData.id)
	-- if bIsUnlock then
	-- 	if g_WarCtrl:IsWar() and (dConfig.opentype ~= define.Item.GainType.UI or dConfig.go.sysname == "竞技场") then
	-- 		g_NotifyCtrl:FloatMsg("你在和敌人战斗中，哪里也去不了！")
	-- 		return
	-- 	end
	-- 	local iOpentype = dConfig.opentype
 --   		if iOpentype == define.Item.GainType.NPC then
 --   			g_MapTouchCtrl:WalkToGlobalNpc(dConfig.openid)
 --   			g_ViewCtrl:CloseAll({"CMainMenuView"})
 --   		elseif iOpentype == define.Item.GainType.TASK then
 --   			local iNpcId = dConfig.openid
 --          	if iNpcId > 0 then
 --            	if iNpcId < 100 then
 --             	 	-- 当npcid小于100，判定为虚拟npcid（门派npcid）
 --              		iNpcId = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
 --            	end
 --            	g_MapTouchCtrl:WalkToGlobalNpc(iNpcId)
 --          	end
 --          	g_ViewCtrl:CloseAll({"CMainMenuView"})
 --          	return
	-- 	elseif iOpentype == define.Item.GainType.UI then
	-- 		if dConfig.go.sysname == "帮派" and g_AttrCtrl.org_id == 0 then
	-- 			g_NotifyCtrl:FloatMsg("请先加入帮派")
	-- 			return
	-- 		end
	-- 		g_ViewCtrl:ShowViewBySysName(dConfig.go.sysname, dConfig.go.tabname, function(oView)
	-- 			-- oView:JumpToTargetItem(self.m_ItemData.id) -- 商城跳转 done
	-- 			local func = self.m_SelectFunc[dConfig.go.sysname]
	-- 			if func then
	-- 				func(oView, self.m_ItemData.id, dConfig.openid)
	-- 			end
	-- 		end)
	-- 	elseif iOpentype == define.Item.GainType.SCHEDULE then
	-- 		self:JumpToTargetSchedule(dConfig.openid)
	-- 	end
	-- else
	-- 	g_NotifyCtrl:FloatMsg(dConfig.tip)
	-- 	return
	-- end
	-- local oView = CItemTipsView:GetView()
	-- if oView then
	-- 	oView:CloseView()
	-- end
	-- oView = CItemMainView:GetView()
	-- if oView then
	-- 	oView:CloseView()
	-- end
	-- oView = CQuickGetItemView:GetView()
	-- if oView then
	-- 	oView:CloseView()
	-- end
	-- oView = COrgTaskView:GetView()
	-- if oView then
	-- 	oView:CloseView()
	-- end
end

-- function CItemGainBox.JumpToShopItem(self, oView, iItemid, iSetItemId)
-- 	if oView.m_TabIndex == oView:GetPageIndex("Recharge") then
-- 		if iSetItemId == 1 then
-- 			oView.m_CurPage:BuyGoldCallBack()
-- 		else
-- 			oView.m_CurPage:RebateCallBack()
-- 		end
-- 		return
-- 	end
-- 	--目标物品不存在，尝试物品礼包
-- 	local bIsSuccess = oView:JumpToTargetItem(iItemid)
-- 	if not bIsSuccess and iSetItemId then
-- 		oView:JumpToTargetItem(iSetItemId)
-- 	end 
-- end

-- function CItemGainBox.JumpToSchedule(self, oView, iItemid, iScheduleId)
-- 	if iScheduleId and iScheduleId ~= 0 then
-- 		oView:JumpToSchedule(iScheduleId)
-- 	end
-- end

-- function CItemGainBox.JumpToEcononmyItem(self, oView, iItemid)
-- 	oView:JumpToTargetItem(iItemid)
-- end

-- function CItemGainBox.JumpToOrgSkill(self, oView, iItemid)
-- 	oView:JumpToOrgSkillByItem(iItemid)
-- end

-- function CItemGainBox.JumpToCompose(self, oView, iItemid, iTab)
-- 	if iTab == 2 then
-- 		oView:ChangeTab(iTab)
-- 	else
-- 		oView:JumpToCompose(iItemid)
-- 	end
-- end

-- function CItemGainBox.JumpToTargetSchedule(self, iScheduleId)
-- 	local dSchedule = data.scheduledata.SCHEDULE[iScheduleId]
-- 	g_ScheduleCtrl:ExcuteSchedule(dSchedule)
-- end

-- function CItemGainBox.JumpToOrgBuilding(self, oView, iBuildId)
-- 	local oPage = oView.m_CurPage
-- 	oPage:JumpToTargetBuilding(iBuildId)
-- end

-- function CItemGainBox.JumpToFirstPay(self, oView)
-- 	oView:OnClickBtn(define.WelFare.Tab.FirstPay)
-- end
return CItemGainBox