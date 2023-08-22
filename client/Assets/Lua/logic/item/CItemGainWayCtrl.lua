local CItemGainWayCtrl = class("CItemGainWayCtrl", CCtrlBase)

function CItemGainWayCtrl.ctor(self)
	CCtrlBase.ctor(self)
		self.m_SelectFunc = {
		["商城"] = function(oView, iItemid, iSetItemId) self:JumpToShopItem(oView, iItemid, iSetItemId) end,
		["日程"] = function(oView, iItemid, iScheduleId) self:JumpToSchedule(oView, iItemid, iScheduleId) end,
		["交易所"] = function(oView, iItemid) self:JumpToEcononmyItem(oView, iItemid) end,
		["技能"] = function(oView, iItemid,  openid) self:JumpToOrgSkill(oView, iItemid,  openid) end,
		["合成"] = function(oView, iItemid, iTab) self:JumpToCompose(oView, iItemid, iTab) end,
		["帮派"] = function(oView, iItemid, iBuildId) self:JumpToOrgBuilding(oView, iBuildId) end,
		["福利"] = function(oView, iItemid, openid, dConfig) self:JumpToWelfare(oView, iItemid, openid, dConfig) end,
		["充值"] = function(oView) self:JumpToRechargeRebate(oView, iItemid, iSubTab) end,
		["防具商店"] = function (oView, iItemid) self:JumpToNpcShop(oView, iItemid) end,
		["武器商店"] = function (oView, iItemid) self:JumpToNpcShop(oView, iItemid) end,
		["药店"] = function (oView, iItemid) self:JumpToNpcShop(oView, iItemid) end,
		["神秘宝箱"] = function () self:JumpToMysticalBox() end,
		["聚宝盆"] = function() self:JumpToAssembleTreasure() end,
	}
	self.m_ItemData = nil
end

function CItemGainWayCtrl.JumpToTargetSystem(self, dConfig, bIsOpen, sid)
	if not bIsOpen then
		g_OpenSysCtrl:FloatTipUnOpenMsg(dConfig.open_sys)
		return
	end

	if g_WarCtrl:IsWar() and (dConfig.opentype ~= define.Item.GainType.UI or dConfig.go.sysname == "竞技场") then
		g_NotifyCtrl:FloatMsg("你在和敌人战斗中，哪里也去不了！")
		return
	end
	local iOpentype = dConfig.opentype
		if iOpentype == define.Item.GainType.NPC then
			g_MapTouchCtrl:WalkToGlobalNpc(dConfig.openid)
			g_ViewCtrl:CloseAll({"CMainMenuView"})
		elseif iOpentype == define.Item.GainType.TASK then
			local iNpcId = dConfig.openid
      	if iNpcId > 0 then
        	if iNpcId < 100 then
         	 	-- 当npcid小于100，判定为虚拟npcid（门派npcid）
          		iNpcId = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
        	end
        	g_MapTouchCtrl:WalkToGlobalNpc(iNpcId)
      	end
      	g_ViewCtrl:CloseAll({"CMainMenuView"})
      	return
	elseif iOpentype == define.Item.GainType.UI then
		if dConfig.go.sysname == "帮派" and g_AttrCtrl.org_id == 0 then
			g_NotifyCtrl:FloatMsg("请先加入帮派")
			return
		end
		if dConfig.open_sys == "MYSTICALBOX" then
			local func = self.m_SelectFunc[dConfig.go.sysname]
			if func then
				func()
			end
		elseif dConfig.open_sys == "JUBAOPEN" then
			local func = self.m_SelectFunc[dConfig.go.sysname]
			if func then
				local bSuccess = func()
				if not bSuccess then
					return
				end
			end
		else
			g_ViewCtrl:ShowViewBySysName(dConfig.go.sysname, dConfig.go.tabname, function(oView)
				-- oView:JumpToTargetItem(self.m_ItemData.id) -- 商城跳转 done
				local func = self.m_SelectFunc[dConfig.go.sysname]
				if func then
					func(oView, sid, dConfig.openid, dConfig)
				end
			end)
		end
	elseif iOpentype == define.Item.GainType.SCHEDULE then
		self:JumpToTargetSchedule(dConfig.openid)
	end


	local oView = CItemTipsView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = CItemMainView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = CQuickGetItemView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = COrgTaskView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CItemGainWayCtrl.JumpToShopItem(self, oView, iItemid, iSetItemId)
	if oView.m_TabIndex == oView:GetPageIndex("Recharge") then
		if iSetItemId == 1 then
			oView.m_CurPage:BuyGoldCallBack()
		else
			oView.m_CurPage:RebateCallBack()
		end
		return
	elseif oView.m_TabIndex == oView:GetPageIndex("Score") then
		iItemid = DataTools.GetPartnerCellItem(iItemid) or iItemid
		local iShopId = DataTools.GetScoreShopByItem(iItemid)
		oView.m_ScoreShopPart:SelectShopById(iShopId)
		oView.m_ScoreShopPart:JumpToTargetItem(iItemid)
	end
	--目标物品不存在，尝试物品礼包
	--如果配置的礼包id为负数，直接取正数跳转，不跳转物品
	if iSetItemId and iSetItemId < 0 then
		oView:JumpToTargetItem(-iSetItemId)
		return
	end
	local bIsSuccess = oView:JumpToTargetItem(iItemid)
	if not bIsSuccess and iSetItemId then
		oView:JumpToTargetItem(iSetItemId)
	end 
end

function CItemGainWayCtrl.JumpToSchedule(self, oView, iItemid, iScheduleId)
	if iScheduleId and iScheduleId ~= 0 then
		oView:JumpToSchedule(iScheduleId)
	end
end

function CItemGainWayCtrl.JumpToEcononmyItem(self, oView, iItemid)
	oView:JumpToTargetItem(iItemid)
end

function CItemGainWayCtrl.JumpToOrgSkill(self, oView, iItemid, openid)
	oView:JumpToOrgSkillByItem(iItemid, openid)
end

function CItemGainWayCtrl.JumpToCompose(self, oView, iItemid, iTab)
	if iTab == 2 then
		oView:ChangeTab(iTab)
	else
		oView:JumpToCompose(iItemid)
	end
end

function CItemGainWayCtrl.JumpToTargetSchedule(self, iScheduleId)
	local dSchedule = data.scheduledata.SCHEDULE[iScheduleId]
	g_ScheduleCtrl:ExcuteSchedule(dSchedule)
end

function CItemGainWayCtrl.JumpToOrgBuilding(self, oView, iBuildId)
	local oPage = oView.m_CurPage
	oPage:JumpToTargetBuilding(iBuildId)
end

function CItemGainWayCtrl.JumpToWelfare(self, oView, iItemid, openid, dConfig)
	-- if iItemid == 10012 then
	-- 	oView:OnClickBtn(define.WelFare.Tab.GiftDay)
	-- 	return
	-- end
	if dConfig then
		local sys = DataTools.GetSysName(dConfig.open_sys)
		local iTab = sys and define.WelFare.Tab[sys]
		if iTab then
			if iTab == define.WelFare.Tab.FirstPay then
				if openid > 0 then
					g_FirstPayCtrl.selIdx = openid
				end
			end
			oView:OnClickBtn(iTab)
		end
	end
end

function CItemGainWayCtrl.JumpToNpcShop(self, oView, itemid)
	oView:JumpToTargetItem(itemid)
end

function CItemGainWayCtrl.JumpToMysticalBox(self)
	if g_MysticalBoxCtrl.m_open_state == 1 then
		nethuodong.C2GSMysticalboxOperateBox(1)
		g_MysticalBoxCtrl:OnShowMysticalBoxView()
	elseif g_MysticalBoxCtrl.m_open_state == 2 then
		g_MysticalBoxCtrl:OnShowMysticalBoxView()
	end
end

-- 聚宝盆
function CItemGainWayCtrl.JumpToAssembleTreasure(self)
	local bSuccess = false
	if g_AssembleTreasureCtrl.m_IsOpenActivity then
		netrank.C2GSGetRankInfo(211, 1)
		CAssembleTreasureView:ShowView()
		bSuccess = true
	else
		g_NotifyCtrl:FloatTimelimitHuodongMsg("聚宝盆")
	end
	return bSuccess
end

return CItemGainWayCtrl