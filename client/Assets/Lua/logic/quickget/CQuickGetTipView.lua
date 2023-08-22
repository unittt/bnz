local CQuickGetTipView = class("CQuickGetTipView", CViewBase)

function CQuickGetTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/QuickGet/QuickGetTipView.prefab", cb)
	self.m_DepthType = "Notify"
	self.m_ItemData = nil
end

function CQuickGetTipView.OnCreateView(self)
	self.m_Item     = self:NewUI(1, CBox)
	self.m_Icon     = self.m_Item:NewUI(1, CSprite)
	self.m_QuaSpr   = self.m_Item:NewUI(2, CSprite) 
	-- self.m_NumLab   = self.m_Item:NewUI(3, CLabel)
	self.m_NameLab  = self.m_Item:NewUI(4, CLabel)
	self.m_EffLab   = self.m_Item:NewUI(5, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_Grid     = self:NewUI(3, CGrid)
	self.m_SysBox  = self:NewUI(4, CBox)
	self.m_BG       = self:NewUI(5, CSprite)
	self.m_SelectFunc = {
		["商城"] = function(oView, iItemid, iSetItemId) self:JumpToShopItem(oView, iItemid, iSetItemId) end,
		["日程"] = function(oView, iItemid, iScheduleId) self:JumpToSchedule(oView, iItemid, iScheduleId) end,
		["交易所"] = function(oView, iItemid) self:JumpToEcononmyItem(oView, iItemid) end,
		["技能"] = function(oView, iItemid) self:JumpToOrgSkill(oView, iItemid) end,
		["合成"] = function(oView, iItemid, iTab) self:JumpToCompose(oView, iItemid, iTab) end,
		["帮派"] = function(oView, iItemid, iBuildId) self:JumpToOrgBuilding(oView, iBuildId) end,
		["福利"] = function(oView) self:JumpToFirstPay(oView) end
	}
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))	
end

function CQuickGetTipView.InitItemInfo(self, sid)
	if sid then
		local itemdata = DataTools.GetItemData(sid)
		self.m_ItemData = itemdata
		self.m_Icon:SpriteItemShape(itemdata.icon)
		self.m_QuaSpr:SetItemQuality(g_ItemCtrl:GetQualityVal( itemdata.id, itemdata.quality or 0 ) )
		self.m_NameLab:SetText(itemdata.name)
		self.m_EffLab:SetText(itemdata.introduction)
		self.m_DesLabel:SetText(g_ItemCtrl:GetItemDesc(sid))
		self.m_Grid:Clear()
		local x,y = self.m_BG:GetSize()
		local detla = 100*math.ceil(#itemdata.gainWayIdStr/3)-80
		self.m_BG:SetSize(x, y+detla)
		
		for i,configId in ipairs(itemdata.gainWayIdStr) do
			local spr = self:CreateSysSpr(configId)
			if spr then
				self.m_Grid:AddChild(spr)
			end
		end
		self.m_Grid:Reposition()
	end
end

function CQuickGetTipView.CreateSysSpr(self, configId)
	local dConfig = data.itemgaindata.CONFIG[configId]
	if not dConfig then
		return
	end
	local bIsUnlock = g_OpenSysCtrl:GetOpenSysState(dConfig.open_sys)
	local box = self.m_SysBox:Clone()
	box.spr = box:NewUI(1, CSprite)
	box.lab = box:NewUI(2, CLabel)
	box.m_IsUnloc = bIsUnlock
	box:SetActive(true)
	box.spr:SetSpriteName(dConfig.icon)
	box.lab:SetText(dConfig.gaindesc)
	box.spr:SetGrey(not bIsUnlock)
	box.spr:AddUIEvent("click", callback(self, "JumpToTargetSystem", dConfig, bIsUnlock))
	return box
end

function CQuickGetTipView.JumpToTargetSystem(self, dConfig, bIsUnlock)
	-- body
	if bIsUnlock then
		if g_WarCtrl:IsWar() and (dConfig.opentype ~= define.Item.GainType.UI or dConfig.go.sysname == "竞技场") then
			g_NotifyCtrl:FloatMsg("你在和敌人战斗中，哪里也去不了！")
			return
		end
		local iOpentype = dConfig.opentype
   		if iOpentype == define.Item.GainType.NPC then
   			g_MapTouchCtrl:WalkToGlobalNpc(dConfig.openid)
   		elseif iOpentype == define.Item.GainType.TASK then
   			local iNpcId = dConfig.openid
          	if iNpcId > 0 then
            	if iNpcId < 100 then
             	 	-- 当npcid小于100，判定为虚拟npcid（门派npcid）
              		iNpcId = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
            	end
            	g_MapTouchCtrl:WalkToGlobalNpc(iNpcId)
          	end
		elseif iOpentype == define.Item.GainType.UI then
			if dConfig.go.sysname == "帮派" and g_AttrCtrl.org_id == 0 then
				g_NotifyCtrl:FloatMsg("请先加入帮派")
				return
			end
			g_ViewCtrl:ShowViewBySysName(dConfig.go.sysname, dConfig.go.tabname, function(oView)
				-- oView:JumpToTargetItem(self.m_ItemData.id) -- 商城跳转 done
				local func = self.m_SelectFunc[dConfig.go.sysname]
				if func then
					func(oView, self.m_ItemData.id, dConfig.openid)
				end
			end)
		elseif iOpentype == define.Item.GainType.SCHEDULE then
			self:JumpToTargetSchedule(dConfig.openid)
		end
	else
		g_NotifyCtrl:FloatMsg(dConfig.tip)
		return
	end
	local oView = CQuickGetTipView:GetView()
	if oView then
		oView:CloseView()
	end
	self:CloseView()
	local oView = CQuickGetItemView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CQuickGetTipView.JumpToShopItem(self, oView, iItemid, iSetItemId)
	if oView.m_TabIndex == oView:GetPageIndex("Recharge") then
		if iSetItemId == 1 then
			oView.m_CurPage:BuyGoldCallBack()
		else
			oView.m_CurPage:RebateCallBack()
		end
		return
	end
	--目标物品不存在，尝试物品礼包
	local bIsSuccess = oView:JumpToTargetItem(iItemid)
	if not bIsSuccess and iSetItemId then
		oView:JumpToTargetItem(iSetItemId)
	end 
end

function CQuickGetTipView.JumpToSchedule(self, oView, iItemid, iScheduleId)
	oView:JumpToSchedule(iScheduleId)
end

function CQuickGetTipView.JumpToEcononmyItem(self, oView, iItemid)
	oView:JumpToTargetItem(iItemid)
end

function CQuickGetTipView.JumpToOrgSkill(self, oView, iItemid)
	oView:JumpToOrgSkillByItem(iItemid)
end

function CQuickGetTipView.JumpToCompose(self, oView, iItemid, iTab)
	if iTab == 2 then
		oView:ChangeTab(iTab)
	else
		oView:JumpToCompose(iItemid)
	end
end

function CQuickGetTipView.JumpToTargetSchedule(self, iScheduleId)
	local dSchedule = data.scheduledata.SCHEDULE[iScheduleId]
	g_ScheduleCtrl:ExcuteSchedule(dSchedule)
end

function CQuickGetTipView.JumpToOrgBuilding(self, oView, iBuildId)
	local oPage = oView.m_CurPage
	oPage:JumpToTargetBuilding(iBuildId)
end

function CQuickGetTipView.JumpToFirstPay(self, oView)
	oView:OnClickBtn(define.WelFare.Tab.FirstPay)
end
return CQuickGetTipView