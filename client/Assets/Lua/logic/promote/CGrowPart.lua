local CGrowPart = class("CGrowPart", CPageBase)

function CGrowPart.ctor(self, obj)
	-- body
	CPageBase.ctor(self, obj)

	self.m_SelLevel = 0
end

function CGrowPart.OnInitPage(self)
	self.m_LevelGrid = self:NewUI(1, CGrid)
	self.m_LevelBox = self:NewUI(2, CBox)
	self.m_EventGrid = self:NewUI(3, CGrid)
	self.m_EventBox = self:NewUI(4, CBox)
	self.m_EventScrollView = self:NewUI(5, CScrollView)
	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshEventBox"))
	self:InitContent()
end

function CGrowPart.InitContent(self)
	-- local list = data.promotedata.GROW
	local maxlevel = 7 --= list[#list].level
	-- 当前所处阶段
	local section
	if g_AttrCtrl.grade%10 ~= 0 then
		section =  math.ceil (g_AttrCtrl.grade/10)
	else
		section =  math.ceil (g_AttrCtrl.grade/10) + 1
	end
	if section > maxlevel then
		section = maxlevel 
	end

	local levellist = self.m_LevelGrid:GetChildList()
	---------当前等级分段向后显示一个等级

	local len = math.clamp(section+1, 1, maxlevel)
	for i=1, len do
		local levelbtn = nil 
		if i>#levellist then
			levelbtn = self.m_LevelBox:Clone()
			levelbtn:SetActive(true)
			self.m_LevelGrid:AddChild(levelbtn)
			levelbtn:SetGroup(self.m_LevelGrid:GetInstanceID())
			levelbtn.title = levelbtn:NewUI(1, CLabel)
			levelbtn.redpoint = levelbtn:NewUI(2, CSprite)
			levelbtn.stitle = levelbtn:NewUI(3, CLabel)
			levelbtn.title:SetText(tonumber(i*10-10).."级～"..tonumber(i*10-1).."级")
			levelbtn.stitle:SetText(tonumber(i*10-10).."级～"..tonumber(i*10-1).."级")
			levelbtn:AddUIEvent("click", callback(self, "OnGradeSelectd", i))

			local bRed = g_PromoteCtrl:JudgeRewardByLevel(i)
			levelbtn.redpoint:SetActive(bRed)

			-- local dSection = data.promotedata.GROW
			-- local list = {}
			-- for x,y in pairs(dSection) do
			-- 	if i == y.level then
			-- 		table.insert(list, {id = y.id})
			-- 	end
			-- end
			-- if g_PromoteCtrl:JudgeCanGetRewardByList(list) then
			-- 	levelbtn.redpoint:SetActive(true)
			-- else
			-- 	levelbtn.redpoint:SetActive(false)
			-- end
			-- printc("======tostring===========",tostring( g_PromoteCtrl:JudgeCanGetRewardByList(list)))

		else
			levelbtn = levellist[i]
		end
	end
	-- if section +1 >= maxlevel then
	-- 	self.m_LevelGrid:GetChild(section +1):SetActive(false)
	-- end
	if g_PromoteCtrl.m_GrowMinLevelIdx < 10000  then
		for i,v in pairs(data.promotedata.GROW) do
			if g_PromoteCtrl.m_GrowMinLevelIdx == v.id then 
				-- self.m_LevelGrid:GetChild(v.level).redpoint:SetActive(false)
				self:OnGradeSelectd(v.level)
				break
			end
		end
	else
		self:OnGradeSelectd(section)
	end
end

function CGrowPart.OnGradeSelectd(self, section)
	if self.m_SelLevel == section then
		return
	end
	self.m_SelLevel = section

	self.m_LevelGrid:GetChild(section):SetSelected(true)
	--self.m_LevelGrid:GetChild(section).redpoint:SetActive(false)
	
	local wholeinfo = data.promotedata.GROW
	local coinreward = data.rewarddata.GROWREWARD
	local itemreward = data.rewarddata.GROW_ITEMREWARD
	local partinfo = {}
	for i,v in pairs(wholeinfo) do
		if section == v.level then
			table.insert(partinfo, v)
		end
	end
	--g_PromoteCtrl:ClickHideRedDot(partinfo)

	--初始化的排序
	--完成奖励的排序
	for i=1,#partinfo do
		local info = g_PromoteCtrl:JudgeGrowDataTypeByID(partinfo[i].id)
		if info == define.Promote.Type.Reward then -- 1
			partinfo[i].sort = 1
		elseif info == define.Promote.Type.Finish then -- 2
			partinfo[i].sort = 3
		elseif info == define.Promote.Type.ToDoTask then -- 3
			partinfo[i].sort = 2
		end
	end
	table.sort(partinfo , function (a,b)
		-- body
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.level_index < b.level_index 
		end
	end)

	local eventlist = self.m_EventGrid:GetChildList()
	for i=1,#partinfo do
		local event = nil
		if i>#eventlist  then
			event = self.m_EventBox:Clone()
			self.m_EventGrid:AddChild(event)
			--event:SetGroup(self.m_EventGrid:GetInstanceID())
			event.icon = event:NewUI(1, CSprite)
			event.task = event:NewUI(2, CLabel)
			event.reward = event:NewUI(3, CLabel)
			event.gobtn = event:NewUI(4, CButton)
			event.finish =  event:NewUI(5, CSprite)
			event.redpoint = event:NewUI(6, CSprite)
			event.getreward = event:NewUI(7, CButton)
			event.bg = event:NewUI(8, CSprite)
		else
			event = eventlist[i]
		end
		event:SetActive(true)
		local singleinfo = partinfo[i]
		event.data = singleinfo

		local icon = singleinfo.icon  --特殊图标处理
		if string.len(icon) > 6 then
			event.icon:SetStaticSprite("MainMenuAtlas", icon)
		else
			event.icon:SpriteItemShape(singleinfo.icon)
		end
		event.task:SetText(singleinfo.name)
		event.gobtn:AddUIEvent("click", callback(self, "OnGohead", singleinfo))
		event.getreward:AddUIEvent("click", callback(self, "OnReward", singleinfo.id))
		local des = ""
		for i,v in pairs(coinreward[singleinfo.reward]) do
			if i == "exp" and v and tonumber(v) then
				des = des .. "人物经验×"..v.." "
			elseif i == "gold" and v and tonumber(v)  then
				des = des .."金币×"..v.." "
			elseif i == "partnerexp" and v and  tonumber(v) then
				des = des.."伙伴经验×"..v.." "
			elseif i == "silver"  and tonumber(v) then
				des = des.."银币×"..v.." "
			elseif i == "summexp" and v and tonumber(v) then
				des = des.."宠物经验×"..v
			elseif i == "item" and next(v) then
				for n,j in ipairs(itemreward) do
					if v[1]	== j.idx then
						local oItemData = DataTools.GetItemData(tonumber(j.sid)) 
						des = des..oItemData.name.."×"..j.amount
					end
				end
			end
		end
		event.reward:SetText(des)

		local info = g_PromoteCtrl:JudgeGrowDataTypeByID(singleinfo.id)
		if info == define.Promote.Type.ToDoTask then
			event.gobtn:SetActive(true)
			event.getreward:SetActive(false)
			event.finish:SetActive(false)
			event.bg:SetSpriteName("h7_di_2")
		elseif  info == define.Promote.Type.Reward then
			event.gobtn:SetActive(false)
			event.getreward:SetActive(true)
			event.getreward:AddEffect("RedDot", 22)
			event.finish:SetActive(false)
			event.bg:SetSpriteName("h7_di_2")
		elseif info == define.Promote.Type.Finish then
			event.gobtn:SetActive(false)
			event.getreward:SetActive(false)
			event.finish:SetActive(true)
			event.bg:SetSpriteName("h7_di_12")
		end
		if event.data.id == 41 then
			event.gobtn:SetActive(false) --挖宝不显示前往按钮
 		end
		
		self.m_EventGrid:Reposition()
	end
	eventlist = self.m_EventGrid:GetChildList() 
	for i=1,#eventlist do
		if i>#partinfo then
			eventlist[i]:SetActive(false)
		end
	end

	self.m_EventScrollView:ResetPosition()
end

function CGrowPart.OnReward(self, id)
	g_PromoteCtrl:C2GSGrowReward(id)
end

function CGrowPart.OnGohead(self, info)
	-- body
	-- if g_LimitCtrl:CheckIsLimit(true, true) then
 --    	return
 --    end
	if g_BonfireCtrl.m_IsBonfireScene and (g_BonfireCtrl.m_CurActiveState == 2 or g_BonfireCtrl.m_CurActiveState == 1) then
        g_NotifyCtrl:FloatMsg("你正在帮派篝火活动中，不可挑战")
        return
    end
    if g_WarCtrl:IsWar() then
        g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
       return
    end

    --系统开启判断
    local bOpen = self:IsSysOpen(info)
    if not bOpen then
    	return
    end

	local oView = nil
	if info.id == 1 then  --获得第一个宠物
		oView = CSummonStoreView:ShowView()
	elseif info.id == 2  then -- 添加第一个好友
		CFindFrdView:ShowView()
	elseif info.id == 3 then -- 升级一次心法技能
		oView = CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(2)
		end)
	elseif info.id == 4  then --完成序章命运

		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)

	elseif info.id == 5 then --拥有四个伙伴
		CPartnerMainView:ShowView()
	elseif info.id == 6  then -- 加入一个帮派并在帮派频道发言一次
		if g_AttrCtrl.org_id == 0 then
			g_OrgCtrl:OpenOrgView()
		else
		 	oView = CChatMainView:ShowView(function(oView)
		 		oView:SwitchChannel(define.Channel.Org)
		 	end)
		end
	elseif info.id == 7  then  -- 完成十次师门任务
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.SHIMEN.ID)
	elseif info.id == 41 then --挖宝一次
	 
	elseif info.id == 9 then -- 初始技能升级到2
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(1)
		end)
	elseif info.id == 10  then -- 完成第一章 西湖美人
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)

	elseif info.id == 11  then -- 抓鬼十次
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.GHOST.ID)
	elseif info.id == 12  then --  升级帮派技能一次
		oView = CSkillMainView:ShowView(function (oView)
			-- body
			oView:ShowSubPageByIndex(4)
		end)
	elseif info.id == 13  then -- 封妖一次
		nethuodong.C2GSFengYaoAutoFindNPC()
		-- local mapID = 101000
		-- local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
		-- if sealNpcMapInfo then
		-- 	mapID = sealNpcMapInfo.mapid
		-- end	
		-- g_MapCtrl:C2GSClickWorldMap(mapID)
	elseif info.id == 14  then -- 参加六道百科一次		
		-- if g_ScheduleCtrl:TodayExistIDScheudle(1021) then
		--  	CScheduleMainView:ShowView(function ( oView )
		--  		-- body
		--  		oView:ShowMainViewTabBtn(2)
		--  	end)
		-- else
		-- 	oView = CScheduleMainView:ShowView(function (oView)
		-- 		-- body
		-- 		oView:OnSetHintInfo()
		-- 	end)
		-- end
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1021)
	 	end)
	elseif info.id == 15  then -- 强化一次装备
		oView = CForgeMainView:ShowView( function (oView)
			-- body
			oView:ShowSubPageByIndex(2)
		end)

	elseif info.id == 16 then -- 参与帮派封魔一次
		if g_AttrCtrl.org_id == 0 then
			g_OrgCtrl:OpenOrgView()
		else
		 	-- if g_ScheduleCtrl:TodayExistIDScheudle(1019) then
		 	-- 	oView =  CScheduleMainView:ShowView(function ( oView )
		 	-- 		-- body
		 	-- 		oView:ShowMainViewTabBtn(2)
		 	-- 	end)
		 	-- else
		 	-- 	oView = CScheduleMainView:ShowView(function (oView)
				-- -- body
				-- 	oView:OnSetHintInfo()
				-- end)
		 	-- end
			CScheduleMainView:ShowView(function(oView)
		 		oView:ShowMainViewTabBtn(2)
		 		oView:OnShowScheduleTips(1019)
		 	end)
		end
	elseif info.id == 17 then -- 参与英雄试炼一次

		nethuodong.C2GSTrialOpenUI()

	elseif info.id == 18  then -- 进行一次宠物合宠
		oView = CSummonMainView:ShowView(function(oView)
			-- body
			oView:ShowSubPageByIndex(2)
			oView.m_AdjustPart:OnCompoundShow()
		end)
	elseif info.id == 19  then --获得冰凌马坐骑
		oView = CHorseMainView:ShowView(function(oView)
			-- body
			oView:ShowSubPageByIndex(3)
		end)
	elseif info.id == 20  then --参加一次竞技场

		g_JjcCtrl:OpenJjcMainView()
	
	elseif info.id == 21  then -- 参加一次火眼金睛

		g_MapTouchCtrl:WalkToGlobalNpc(5284)

	elseif info.id == 22  then --完成第二章情结难解
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)

	elseif info.id == 23  then --完成第三章相爱相杀
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)
	elseif info.id == 24  then -- 完成灵犀任务一次
		g_MapTouchCtrl:WalkToGlobalNpc(5279)
	elseif info.id == 25  then -- 完成一次装备打造
		CForgeMainView:ShowView()
	elseif info.id == 26  then  -- 完成一次异宝收集
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.YIBAO.ID)
	elseif info.id == 27  then -- 参加一次三界斗法
		-- if g_ScheduleCtrl:TodayExistIDScheudle(1012) then
		--  	oView =  CScheduleMainView:ShowView(function ( oView )
		--  		-- body
		--  		oView:ShowMainViewTabBtn(2)
		--  	end)
		-- else
		--  	oView = CScheduleMainView:ShowView(function (oView)
		-- 		-- body
		-- 		oView:OnSetHintInfo()
		-- 	end)
		-- end	
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1012)
	 	end)
	elseif info.id == 28  then --通关一次附魔金山寺副本
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif info.id == 29  then --升级一次头衔
		CBadgeView:ShowView()
	elseif info.id == 30  then --完成第四章师从紫薇
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)
	elseif info.id == 31  then -- 完成第五章 姐妹情深
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)


	elseif info.id == 32  then  --洗练一次装备
		oView = CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(3)
		end)
	elseif info.id == 33  then -- 参加一次六脉会武
		-- if g_ScheduleCtrl:TodayExistIDScheudle(1023) then
		--  	oView =  CScheduleMainView:ShowView(function ( oView )
		--  		-- body
		--  		oView:ShowMainViewTabBtn(2)
		--  	end)
		-- else
		--  	oView = CScheduleMainView:ShowView(function (oView)
		-- 		-- body
		-- 		oView:OnSetHintInfo()
		-- 	end)
		-- end
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1023)
	 	end)
	elseif info.id == 34  then  -- 地煞星 ，直接传送地图

		-- local mapID = 201000
		-- g_MapCtrl:C2GSClickWorldMap(mapID)

		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1009)
	 	end)
	elseif info.id == 35  then  --武器附魂一次
		oView = CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(4)
		end)
	elseif info.id == 36  then --完成第六章相逢断桥
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)
	elseif info.id == 37  then --完成六道传说副本通关一次
		g_MapTouchCtrl:WalkToGlobalNpc(5254)
	elseif info.id == 38  then --通关一次水漫金山寺副本
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif info.id == 39 then --完成第七章智取王府
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)
	elseif info.id == 40  then --完成第八章三生缘续
		local storyID = next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID])
		nettask.C2GSClickTask(storyID)
	elseif info.id == 42 then --二十八星宿
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1029)
	 	end)
	elseif info.id == 43 then --建立1次师徒关系
		g_MapTouchCtrl:WalkToGlobalNpc(5294)
	elseif info.id == 44 then --参加1次科举答题
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
			oView:OnShowScheduleTips(1041)
	 	end)
	elseif info.id == 45 then --挑战1次金玉满堂
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1020)
	 	end)
	elseif info.id == 46 then --完成1次舞动全城
		nethuodong.C2GSDanceAuto()
	elseif info.id == 47 then --完成1次门派试练
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1013)
	 	end)
	elseif info.id == 48 then --完成1次订婚
		g_MapTouchCtrl:WalkToGlobalNpc(5229)
	elseif info.id == 49 then --参加1次蜀山论道
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1039)
	 	end)
	elseif info.id == 50 then --参加1次九州争霸
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1034)
	 	end)
	elseif info.id == 51 then --激活1件羽翼
		CWingMainView:ShowView()
	elseif info.id == 52 then --完成1次结拜
		g_MapTouchCtrl:WalkToGlobalNpc(5295)
	elseif info.id == 53 then --通关1次镇魔塔
		g_MapTouchCtrl:WalkToGlobalNpc(5296)
	elseif info.id == 54 then --完成1次任务链
		g_MapTouchCtrl:WalkToGlobalNpc(5278)
	elseif info.id == 55 then --挑战1次乱世魔影
		CScheduleMainView:ShowView(function(oView)
	 		oView:ShowMainViewTabBtn(2)
	 		oView:OnShowScheduleTips(1038)
	 	end)
	elseif info.id == 56 then --升级1次神器
		CArtifactMainView:ShowView(function (oView)		
			oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
		end)
	elseif info.id == 57 then --佩戴1件法宝
		CFaBaoView:ShowView(function(oView)
			oView:ShowSubPageByIdx(1)
		end)
	end
	CGaideMainView:GetView():CloseView()
end

-- 未达活动开启条件时的飘字
function CGrowPart.IsSysOpen(self, info)
	--未添加系统的不需要判断开启条件
	if string.len(info.stype) == 0 then
		return true
	end

	local opendata = DataTools.GetViewOpenData(info.stype)
	local blevel = g_AttrCtrl.grade >= opendata.p_level
	local bOpen = g_OpenSysCtrl:GetOpenSysState(info.stype)
	if (not bOpen) or (not blevel) then
		g_NotifyCtrl:FloatMsg(string.format("等级达到#G%d#n级时开放#G%s#n", opendata.p_level, opendata.name))
	end
	return (blevel and bOpen)
end

function CGrowPart.RefreshEventBox(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.Promote.Event.RefreshGrow  then
		if Utils.IsNil(self) then
			return
		end
		local list = self.m_EventGrid:GetChildList()
		local box = nil
		for i,event in ipairs(list) do
			if event.data.id == oCtrl.m_EventData.index then
				box = event
				break
			end
		end
		if not box then 
		  -- local oView =  CGaideMainView:GetView()
		  -- if oView then
		  -- 	oView:CloseView()
		  -- end
		  return
		end
		if oCtrl.m_EventData.finish == 1 and oCtrl.m_EventData.reward == 1  then
			box.gobtn:SetActive(false)
			box.getreward:SetActive(true)
			box.finish:SetActive(false)
		elseif oCtrl.m_EventData.finish == 1 and oCtrl.m_EventData.reward == 2 then 
			box.gobtn:SetActive(false)
			box.getreward:SetActive(false)
			box.finish:SetActive(true)
			box.bg:SetSpriteName("h7_di_12")
		end
	elseif oCtrl.m_EventID == define.Promote.Event.RefreshGrowRedPoint then
		local level = self.m_SelLevel
		local levelbtn = self.m_LevelGrid:GetChild(level)
		if levelbtn then
			local bRed = g_PromoteCtrl:JudgeRewardByLevel(level)
			levelbtn.redpoint:SetActive(bRed)
			--levelbtn.redpoint:SetActive(g_PromoteCtrl:JudgeCanGetRewardByList({id = oCtrl.m_EventData.index}))
		end
	end
	
end

return CGrowPart