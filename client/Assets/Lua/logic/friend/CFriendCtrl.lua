local CFriendCtrl = class("CFrienCtrl", CCtrlBase)

function CFriendCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_FriendDict = {}
	self.m_Friend = {all = {}, teamer = {}, recent = {}, black = {}}
	self.m_Online = {}
	self.m_Version = 1
	self:InitFriendRelationConfig()
	self.m_AddFriendConfirmList = {}
	-- self.m_DungeonAddFriendConfirmList = {}
	self.m_DungeonAddFriendConfirmHashList = {}
	self.m_DungeonPidList = {}
	self.m_IsInDungeonView = false
	self.m_NotifyRefuseStrangerData = {}
	self.m_IsFriendConfirmShowing = false

	self.m_RecentLimit = 100
	self.m_IsInitFriendData = false
	self.m_IsInitRecentData = false
end

function CFriendCtrl.Clear(self)
	self.m_AddFriendConfirmList = {}
	-- self.m_DungeonAddFriendConfirmList = {}
	self.m_DungeonAddFriendConfirmHashList = {}
	self.m_DungeonPidList = {}
	self.m_IsInDungeonView = false
	self.m_NotifyRefuseStrangerData = {}
	self.m_IsFriendConfirmShowing = false
	self.m_IsInitFriendData = false
	self.m_IsInitRecentData = false
end

------------下边的函数是根据协议返回设置数据---------------------

--GS2CLoginFriend返回的协议信息,下边三个函数都是

--设置好友all的数据
function CFriendCtrl.InitFriend(self, pidlist)
	local queryList = {}
	local queryRecentList = {}
	self:LoadFriendList()
	self:LoadRecentList()
	self.m_Friend["all"] = {}
	for k, obj in pairs(pidlist) do
		local pid = obj.pid
		table.insert(self.m_Friend["all"], pid)
		-- if not self.m_FriendDict[pid] then
		table.insert(queryList, pid)
		-- end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
	--查询最近联系人的玩家数据
	for k,v in pairs(self.m_Friend["recent"]) do
		local pid = tonumber(v)
		if not self.m_FriendDict[pid] then
			table.insert(queryRecentList, pid)
		end
	end
	if #queryRecentList > 0 then
		netfriend.C2GSQueryFriendProfile(queryRecentList)
	end
	self.m_IsInitFriendData = true
end

--设置pid对应的online状态的列表
function CFriendCtrl.InitOnlineState(self, onlinelist)
	for _, onlineinfo in pairs(onlinelist) do
		self.m_Online[onlineinfo.pid] = onlineinfo.onlinestatus
	end
end

--设置黑名单black的list
function CFriendCtrl.InitBlackList(self, pidlist)
	local queryList = {}
	for k, pid in pairs(pidlist) do
		self:RemoveRecent(pid)
		table.insert(self.m_Friend["black"], pid)
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
end

--添加好友all列表profile数据,更新self.m_FriendDict字典数据
function CFriendCtrl.AddFriendList(self, friendlist)
	local updateList = {}
	local addList = {}
	for k, frdobj in pairs(friendlist) do
		if self.m_FriendDict[frdobj.pid] then
			table.update(self.m_FriendDict[frdobj.pid], frdobj)
		else
			frdobj = self:CreateObj(frdobj)
			self.m_FriendDict[frdobj.pid] = frdobj
		end
		
		table.insert(updateList, frdobj.pid)
		if not self:IsMyFriend(frdobj.pid) then
			table.insert(self.m_Friend["all"], frdobj.pid)
			table.insert(addList, frdobj.pid)
		end
		g_MasterCtrl:CheckMasterRelation(self.m_FriendDict[frdobj.pid])
	end
	-- table.print(addList,"添加好友列表")
	self:OnEvent(define.Friend.Event.Add, addList)
	self:OnEvent(define.Friend.Event.Update, updateList)
	self:SaveFriendList()

	local sText = data.frienddata.FRIENDTEXT[define.Friend.Text.AddFriendHello].content
	for k,v in pairs(addList) do
		g_TalkCtrl:AddSelfMsg(v, sText)
		g_TalkCtrl:SendChat(v, sText)
	end	
end

--创建一个默认数据，pid对应的数据
function CFriendCtrl.CreateObj(self, frdobj)
	local frdlist = {
		grade = 0,
		shape = 1110,
		school = 1, 
		orgid = 0, 
		friend_degree = 0,
		relation = 0,
	}
	return table.update(frdlist, frdobj)	
end

function CFriendCtrl.AddStranger(self, friendlist)
	local pidList = {}
	local saveflag = false
	for k, frdobj in pairs(friendlist) do
		table.insert(pidList, frdobj.pid)
		frdobj = self:CreateObj(frdobj)
		self.m_FriendDict[frdobj.pid] = frdobj
		if self:IsRecentFriend(frdobj.pid) or self:IsBlackFriend(frdobj.pid) then
			saveflag = true
		end
		g_MasterCtrl:CheckMasterRelation(self.m_FriendDict[frdobj.pid])
	end
	self:OnEvent(define.Friend.Event.Update, pidList)
	if saveflag then
		self:SaveFriendList()
	end	
end

function CFriendCtrl.DelFriendList(self, pidlist)
	for k, pid in pairs(pidlist) do
		local index = table.index(self.m_Friend["all"], pid)
		if index then
			table.remove(self.m_Friend["all"], index)
		end
		g_TalkCtrl:UpdateNotifyData(pid)
	end
	self:OnEvent(define.Friend.Event.Del, pidlist)
end

function CFriendCtrl.AddBlackFriend(self, pidlist)
	local queryList = {}
	for k, pid in pairs(pidlist) do
		self:RemoveRecent(pid)
		if not table.index(self.m_Friend["black"], pid) then
			table.insert(self.m_Friend["black"], pid)
		end
		if not self.m_FriendDict[pid] then
			table.insert(queryList, pid)
		end
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
	self:OnEvent(define.Friend.Event.AddBlack, pidlist)
end

function CFriendCtrl.DelBlackFriend(self, pidlist)
	for k, pid in pairs(pidlist) do
		local index = table.index(self.m_Friend["black"], pid)
		if index then
			table.remove(self.m_Friend["black"], index)
		end
	end
	self:OnEvent(define.Friend.Event.DelBlack, pidlist)
end

--最近联系人不是根据协议数据返回设置，本地的
function CFriendCtrl.RefreshRecent(self, pid)
	local queryList = {}
	local iAmount = 30
	local t = self.m_Friend["recent"]
	local i = table.index(t, pid)
	if i then
		-- t[i] = t[1]
		-- t[1] = pid
		table.remove(t,i)
		table.insert(t,1,pid)
	else
		if #t > iAmount then
			table.remove(t, #t)
		end
		table.insert(t, 1, pid)
	end
	if not self.m_FriendDict[pid] then
		table.insert(queryList, pid)
	end
	if #queryList > 0 then
		netfriend.C2GSQueryFriendProfile(queryList)
	end
	self:OnEvent(define.Friend.Event.AddRecent, pid)
	self:SaveRecentList()
	g_TalkCtrl:CheckRecentNotifyMsg()
end

function CFriendCtrl.RemoveRecent(self, pid)
	local t = self.m_Friend["recent"]
	local index = table.index(t, pid)
	if index then
		table.remove(t, index)
	end
	self:OnEvent(define.Friend.Event.DelRecent, pid)
	self:SaveRecentList()
	g_TalkCtrl:CheckRecentNotifyMsg()
end

function CFriendCtrl.UpdateTeamerFriend(self)
	local list = g_TeamCtrl:GetMemberList()
	local teamlist = self.m_Friend["teamer"]
	for k, teamobj in pairs(list) do
		local pid = teamobj.pid
		if teamobj and pid ~= g_AttrCtrl.pid then
			if not table.index(teamlist, pid) then
				table.insert(teamlist, pid)
			end
			self.m_FriendDict[pid] = self:CreateTeamerFriend(teamobj)
		end	
	end
	self:OnEvent(define.Friend.Event.Update, list)
	self:OnEvent(define.Friend.Event.UpdateTeamer)
end

function CFriendCtrl.CreateTeamerFriend(self, info)
	local pid = info.pid
	local dict = {
		pid = info.pid,
		name = info.name,
		icon = info.icon,
		grade = info.grade,
		school = info.school,
	}
	local frdobj = self.m_FriendDict[pid]
	if frdobj and self:IsMyFriend(pid) then
		table.update(frdobj, dict)
	else
		frdobj = dict
	end
	return frdobj
end

-- 点击玩家时，检测是否需要更好友信息
function CFriendCtrl.CheckPlayerInfo(self, dPlayer)
	if self:IsMyFriend(dPlayer.pid) then
		local bUpdate = false
		local dFriend = self:GetFriend(dPlayer.pid)
		if dFriend then
			-- 等级是否变化
			if dFriend.grade ~= dPlayer.grade then
				bUpdate = true
			end
		else
			bUpdate = true
		end
		if bUpdate then
			self:QueryFriend({dPlayer.pid})
		end
	end
end

function CFriendCtrl.GS2COpenSendFlowerUI(self, pbdata)
	CFlowerGiveView:ShowView(function (oView)
		oView:RefreshUI(pbdata)
	end)
end

function CFriendCtrl.GS2CSendFlowerSuccess(self, pbdata)
	g_TalkCtrl:AddSelfMsg(pbdata.pid, pbdata.bless)
	g_TalkCtrl:SendChat(pbdata.pid, pbdata.bless)
	--CFlowerGiveView:CloseView()
end

function CFriendCtrl.GS2CSceneEffect(self, pbdata)
	g_NotifyCtrl:ShowFlowerEffect(pbdata.effect)
end

function CFriendCtrl.GS2CRefreshFriendProfile(self, profile)
	local oFrd = self.m_FriendDict[profile.pid]
	if not oFrd then
		return
	end
	for k , v in pairs(profile) do
		if oFrd[k] ~= v then
			oFrd[k] = v
		end		
	end
	g_MasterCtrl:CheckMasterRelation(oFrd)
	self:OnEvent(define.Friend.Event.Update)
end

function CFriendCtrl.GS2CVerifyFriend(self, pbdata)
	local windowInputInfo = {
		des = "[63432c]申请添加好友:"..pbdata.name,
		title = "输入验证信息",
		inputLimit = 20,
		cancelCallback = function () end,
		defaultText = data.frienddata.FRIENDTEXT[define.Friend.Text.AddVerifyFriendEmpty].content,
		okCallback = function (oInput)
			if not oInput then
				return
			end
			local inputStr = oInput:GetText()
			-- if not inputStr or inputStr == "" then
			-- 	g_NotifyCtrl:FloatMsg("请输入添加好友的验证信息")
			-- 	return true
			-- end
			if inputStr and inputStr ~= "" then
				if g_MaskWordCtrl:IsContainMaskWord(inputStr) then
					g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Friend.Text.AddFriendMaskWord].content)
					return true
				end			
			end
			
			if not inputStr or inputStr == "" then
				inputStr = data.frienddata.FRIENDTEXT[define.Friend.Text.AddVerifyFriendEmpty].content
			end
			netfriend.C2GSVerifyFriend(pbdata.pid, inputStr or "")
		end,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function CFriendCtrl.GS2CVerifyFriendConfirm(self, pbdata)
	if self.m_IsInDungeonView then
		local oPidList = {}
		for k,v in pairs(pbdata.verify_list) do
			if table.index(self.m_DungeonPidList, v.pid) then
				-- table.insert(self.m_DungeonAddFriendConfirmList, v)
				self.m_DungeonAddFriendConfirmHashList[v.pid] = v
				table.insert(oPidList, v.pid)
			end
		end

		if next(oPidList) then
			self:OnEvent(define.Friend.Event.UpdateFriendConfirm, oPidList)
		end
	end
	if self.m_IsInDungeonView then
		for k,v in pairs(pbdata.verify_list) do
			if not table.index(self.m_DungeonPidList, v.pid) then
				table.insert(self.m_AddFriendConfirmList, v)
			end
		end
	else
		for k,v in pairs(pbdata.verify_list) do
			table.insert(self.m_AddFriendConfirmList, v)
		end
	end
	self:ShowVerifyFriendConfirmView()
end

function CFriendCtrl.ShowVerifyFriendConfirmView(self)
	if not next(self.m_AddFriendConfirmList) then
		return
	end
	if self.m_IsFriendConfirmShowing then
		return
	end
	local oData = self.m_AddFriendConfirmList[1]

	local windowConfirmInfo = {
		msg = "申请添加好友:"..oData.name.."\n申请理由:"..oData.msg,
		title = "好友验证",
		-- pivot = enum.UIWidget.Pivot.Center,
		okCallback = function () 
			netfriend.C2GSVerifyFriendComfirm(oData.pid, 1)	
			table.remove(self.m_AddFriendConfirmList, 1)
			self.m_IsFriendConfirmShowing = false
			if next(self.m_AddFriendConfirmList) then
				g_FriendCtrl:ShowVerifyFriendConfirmView()
			end
		end,
		cancelCallback = function () 
			netfriend.C2GSVerifyFriendComfirm(oData.pid, 0)
			table.remove(self.m_AddFriendConfirmList, 1)
			self.m_IsFriendConfirmShowing = false
			if next(self.m_AddFriendConfirmList) then
				g_FriendCtrl:ShowVerifyFriendConfirmView()
			end
		end,
		okStr = "同意",
		cancelStr = "拒绝",
		closeType = 3,
		hideContentBg = true,
		close_btn = 1,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	-- self.m_IsFriendConfirmShowing = true
end

function CFriendCtrl.GS2CNotifyRefuseStrangerMsg(self, pbdata)
	self.m_NotifyRefuseStrangerData[pbdata.pid] = true
	self:OnEvent(define.Friend.Event.NotifyRefuseStrangerMsg)
end

function CFriendCtrl.GS2CAckChatTo(self, pbdata)
	self.m_NotifyRefuseStrangerData[pbdata.pid] = false
	self:OnEvent(define.Friend.Event.NotifyRefuseStrangerMsg)
end

--both标记是否互相加为好友， 1 是 0 不是
--别人加我，这里协议通知
function CFriendCtrl.GS2CRefreshFriendProfileBoth(self, pbdata)
	local frdobj = self.m_FriendDict[pbdata.pid]
	if frdobj then
		frdobj.both = pbdata.both
	end
	self:OnEvent(define.Friend.Event.RefreshFriendProfileBoth, pbdata)
end

------------------下边的函数是获取all，black，recent，team，recommendfriend，OnlineState数据的接口---------------------

function CFriendCtrl.SetRecommendFriends(self, recommendfrdlist)
	self.m_RecommendFrdList = recommendfrdlist or {}
	self.m_RecommendSortList = {}
	for i=1, 5 do
		self.m_RecommendSortList[i] = {}
	end
	for k,v in pairs(self.m_RecommendFrdList) do
		if tonumber(v.type) == 1 then
			table.insert(self.m_RecommendSortList[1], v)
		elseif tonumber(v.type) == 2 then
			table.insert(self.m_RecommendSortList[2], v)
		elseif tonumber(v.type) == 3 then
			table.insert(self.m_RecommendSortList[3], v)
		elseif tonumber(v.type) == 4 then
			table.insert(self.m_RecommendSortList[4], v)
		else
			table.insert(self.m_RecommendSortList[5], v)
		end
	end
end

function CFriendCtrl.GetRecommendFriends(self)
	local data = self.m_RecommendFrdList or {}
	local newfrdList = {}
	-- for k, frdobj in pairs(data) do
	-- 	if table.index(self.m_Friend["all"], frdobj.pid) then
	-- 		--continue
	-- 	elseif self.m_LastRecommend and table.index(self.m_LastRecommend, frdobj.pid) then			
	-- 		--continue
	-- 	else
	-- 		table.insert(newfrdList, frdobj)
	-- 	end
	-- end
	for i=1, 5 do
		table.shuffle(self.m_RecommendSortList[i])
	end
	local timeCountList = {0, 0, 0, 0}
	for i=1, 4 do
		for k, frdobj in pairs(self.m_RecommendSortList[i]) do
			if table.index(self.m_Friend["all"], frdobj.pid) then
				--continue
			elseif self.m_LastRecommend and table.index(self.m_LastRecommend[i], frdobj.pid) then			
				--continue
			else
				if i == 4 then
					if #newfrdList < 8 then
						table.insert(newfrdList, frdobj)
					end
				else
					timeCountList[i] = timeCountList[i] + 1
					if timeCountList[i] <= 2 then
						table.insert(newfrdList, frdobj)
					end
				end
			end
		end
	end
	
	self.m_LastRecommend = {}
	for i=1, 5 do
		self.m_LastRecommend[i] = {}
	end
	table.shuffle(newfrdList)
	-- newfrdList =table.slice(newfrdList, 1, 8)
	for k, frdobj in pairs(newfrdList) do
		if tonumber(frdobj.type) == 1 then
			table.insert(self.m_LastRecommend[1], frdobj.pid)
		elseif tonumber(frdobj.type) == 2 then
			table.insert(self.m_LastRecommend[2], frdobj.pid)
		elseif tonumber(frdobj.type) == 3 then
			table.insert(self.m_LastRecommend[3], frdobj.pid)
		elseif tonumber(frdobj.type) == 4 then
			table.insert(self.m_LastRecommend[4], frdobj.pid)
		else
			table.insert(self.m_LastRecommend[5], frdobj.pid)
		end
		-- table.insert(self.m_LastRecommend, frdobj.pid)
	end
	return newfrdList
end

function CFriendCtrl.GetMyFriend(self)
	return self.m_Friend["all"]
end

function CFriendCtrl.GetRecentFriend(self)
	return self.m_Friend["recent"]
end

--获取self.m_FriendDict数据，传一个pid
function CFriendCtrl.GetFriend(self, pid)
	return self.m_FriendDict[pid]
end

--self.m_Friend["all"],存储的是好友列表
function CFriendCtrl.IsMyFriend(self, pid)
	return table.index(self.m_Friend["all"], pid)
end

--self.m_Friend["black"],存储的是黑名单列表
function CFriendCtrl.GetBlackList(self)
	return self.m_Friend["black"]
end

function CFriendCtrl.IsBlackFriend(self, pid)
	return table.index(self.m_Friend["black"], pid)
end

--self.m_Friend["recent"],存储的是最近联系人列表
function CFriendCtrl.IsRecentFriend(self, pid)
	return table.index(self.m_Friend["recent"], pid)
end

--self.m_Friend["teamer"],存储的是最近队伍列表
function  CFriendCtrl.GetTeamerFriend(self, pid)
	return self.m_Friend["teamer"]
end

function CFriendCtrl.SetOnlineState(self, pid, state)
	self.m_Online[pid] = state
	self:OnEvent(define.Friend.Event.Update, {pid})
end

function CFriendCtrl.GetOnlineState(self, pid)
	if self:IsMyFriend(pid) then
		return self.m_Online[pid]
	else
		return 1
	end
end

function CFriendCtrl.GetOnlineFriendList(self)
	local list = {}
	for k,pid in pairs(self.m_Friend["all"]) do
		if self:GetOnlineState(pid) ~= 0 and self.m_FriendDict[pid] then
			table.insert(list, self.m_FriendDict[pid])
		end
	end
	local sort = function(d1, d2)
		if d1.grade ~= d2.grade then
			return d1.grade > d2.grade
		else
			return d1.school < d2.school 
		end
	end
	table.sort(list, sort)
	return list
end

--好友列表的排序函数
function CFriendCtrl.Sort(a, b)
	local frdobjA = g_FriendCtrl:GetFriend(a)
	local frdobjB = g_FriendCtrl:GetFriend(b)
	if not frdobjB then
		return false
	end
	if not frdobjA then
		return false
	end
	
	local onlineA = g_FriendCtrl:GetOnlineState(a)
	local onlineB = g_FriendCtrl:GetOnlineState(b)
	if onlineA ~= onlineB then
		if not onlineA then onlineA = 1 end
		if not onlineB then onlineB = 1 end
		return onlineA > onlineB
	end

	local sortlist = {"friend_degree"}
	for _, key in pairs(sortlist) do
		if not frdobjA[key] then
			return false
		end
		if not frdobjB[key] then
			return false
		end
		if frdobjA[key] ~= frdobjB[key] then
			return frdobjA[key] > frdobjB[key]
		end
	end

	if not frdobjA.pid then
		return false
	end
	if not frdobjB.pid then
		return false
	end
	local dExtra = {a = frdobjA.pid, b = frdobjB.pid}
	--预防空字符的名字
	if frdobjA.name == "" then
		return false
	elseif frdobjB.name == "" then
		return false
	end
	return CInitialCtrl.InitialSortStr(frdobjA.name, frdobjB.name, dExtra)
end

function CFriendCtrl.JJCSort(a, b)
	local frdobjA = g_FriendCtrl:GetFriend(a)
	local frdobjB = g_FriendCtrl:GetFriend(b)
	if not frdobjB then
		return false
	end
	if not frdobjA then
		return false
	end
	return frdobjA.pid < frdobjB.pid
end

-------------------------发送协议------------------------

--请求pid的列表对应的角色信息，发协议
function CFriendCtrl.QueryFriend(self, pidlist)
	netfriend.C2GSQueryFriendProfile(pidlist)
end

--请求添加好友，发协议
function CFriendCtrl.ApplyAddFriend(self, pid)
	netfriend.C2GSApplyAddFriend(pid)
end

-----------------------下边的函数是好友ui相关--------------------------------

function CFriendCtrl.GetRelationIcon(self, iDegree, relation)
	local name = nil
	if iDegree < self.m_FriendRelationConfigList[1].id then
		name = self.m_FriendRelationConfigList[1].color
	else
		for k,v in ipairs(self.m_FriendRelationConfigList) do
			if iDegree >= v.id then
				name = v.color
			end
		end
	end
	return name
end

function CFriendCtrl.InitFriendRelationConfig(self)
	self.m_FriendRelationConfigList = {}
	for k,v in pairs(data.frienddata.FRIENDSHIP) do
		table.insert(self.m_FriendRelationConfigList, v)
	end
	table.sort(self.m_FriendRelationConfigList, function(a, b) return a.id < b.id end)
end

function CFriendCtrl.ApplyAddBlackFriend(self, pid, name)
	local frdobj = table.index(self.m_Friend["all"], pid)
	if not name then
		name = frdobj.name
	end
	-- printc(type(pid))
	local sMsg = string.gsub(data.frienddata.FRIENDTEXT[define.Friend.Text.AddBlack1].content,"#role",name)
	if frdobj then
		if self:IsMyFriend(pid) then
			sMsg = string.gsub(data.frienddata.FRIENDTEXT[define.Friend.Text.AddBlack2].content,"#role",name)
		end	
	end
	self:ShowBlackTip(pid, sMsg)
end

function CFriendCtrl.ApplyDelBlackFriend(self, pid, name)
	local windowConfirmInfo = {
		msg = "#D" .. string.gsub(data.frienddata.FRIENDTEXT[define.Friend.Text.RemoveBlack].content,"#role",name),
		title = "解除黑名单",
		okCallback = function () netfriend.C2GSFriendUnshield(pid) end,	
		okStr = "确定",
		cancelStr = "取消",
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFriendCtrl.ShowBlackTip(self, pid, sMsg)
	local windowConfirmInfo = {
		msg = "#D" .. sMsg,
		title = "拉黑",
		okCallback = function () netfriend.C2GSFriendShield(pid) end,	
		okStr = "确定",
		cancelStr = "取消",
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CFriendCtrl.ApplyDelFriend(self, pid)
	local frdobj = self.m_FriendDict[pid]
	local sMsg = "#D你确定要将此好友删除？#n"
	if frdobj and frdobj.name then
		sMsg = string.gsub(data.frienddata.FRIENDTEXT[define.Friend.Text.RemoveFriend].content,"#role",frdobj.name)
	end
	local windowConfirmInfo = {
		msg = sMsg,
		title = "删除好友",
		okCallback = function () 
			netfriend.C2GSApplyDelFriend(pid)
			self:RemoveRecent(pid)
		end,	
		okStr = "确定",
		cancelStr = "取消",
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

--------------------下边的函数是保存all、black、recent数据到本地--------------------------------

--保存all、black、recent数据到本地
function CFriendCtrl.SaveFriendList(self)
	local frdDict = {}
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	for pid, frdobj in pairs(self.m_FriendDict) do
		if self:IsMyFriend(pid) or self:IsBlackFriend(pid) or self:IsRecentFriend(pid) then
			frdDict[tostring(pid)] = frdobj
		end
	end
	frdDict["version"] = 1
	IOTools.SaveJsonFile(file, frdDict)
end

function CFriendCtrl.LoadFriendList(self)
	--TODO:好友修改名字后导致与本地保存不一致，先临时return掉
	if true then
		return
	end
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	local frdDict = IOTools.LoadJsonFile(file)
	if not frdDict or type(frdDict) ~= type({}) then
		frdDict = {}
	end

	if frdDict["version"] and frdDict["version"] ~= self.m_Version then
		self:ClearFriendList()
		return
	else
		printc("好友版本一致，无需更新")
	end
	
	for pid, data in pairs(frdDict) do
		if tonumber(pid) then
			self.m_FriendDict[tonumber(pid)] = data
		end
	end
end

--删除本地all、black、recent数据
function CFriendCtrl.ClearFriendList(self)
	local path = IOTools.GetPersistentDataPath(string.format("/role/%d/friends", g_AttrCtrl.pid))
	IOTools.Delete(path)
end

--保存最近联系人数据到本地
function CFriendCtrl.SaveRecentList(self)
	-- if not self.m_SaveRecentTime then
	-- 	self.m_SaveRecentTime = 0
	-- end
	-- local iTime = g_TimeCtrl:GetTimeS()
	-- if iTime - self.m_SaveRecentTime > 60 then
		
	-- 	self.m_SaveRecentTime = iTime
	-- end
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/recent", g_AttrCtrl.pid))	
	IOTools.SaveJsonFile(file, self:GetRecentFriend())
end

function CFriendCtrl.LoadRecentList(self)
	--TODO:好友修改名字后导致与本地保存不一致，先临时return掉
	self.m_Friend["recent"] = {}
	local file = IOTools.GetPersistentDataPath(string.format("/role/%d/recent", g_AttrCtrl.pid))
	local recentList = IOTools.LoadJsonFile(file)
	if not recentList or type(recentList) ~= type({}) then
		recentList = {}
	end
	for k, pid in ipairs(recentList) do
		table.insert(self.m_Friend["recent"], tonumber(pid))
	end
	g_TalkCtrl:CheckRecentNotifyMsg()
	self.m_IsInitRecentData = true
end

---------------鲜花赠送的一些接口--------------

function CFriendCtrl.GetFlowerSameSexConfig(self)
	local list = {}
	for i = 1, 3 do
		local effect = "无"
		local effectConfig = data.frienddata.FLOWEREFFECT[data.frienddata.FLOWERSELECT[define.Flower.Type.Same].effect_list[i].effect]
		if effectConfig then
			effect = effectConfig.name
			effect = string.gsub(effect, "玫瑰", "")
			effect = string.gsub(effect, "康乃馨", "")
		end
		local item = {count = data.frienddata.FLOWERSELECT[define.Flower.Type.Same].effect_list[i].amount, effect = effect}
		table.insert(list, item)
	end
	return list
end

function CFriendCtrl.GetFlowerNotSameSexConfig(self)
	local list = {}
	for i = 1, 3 do
		local effect = "无"
		local effectConfig = data.frienddata.FLOWEREFFECT[data.frienddata.FLOWERSELECT[define.Flower.Type.NotSame].effect_list[i].effect]
		if effectConfig then
			effect = effectConfig.name
			effect = string.gsub(effect, "玫瑰", "")
			effect = string.gsub(effect, "康乃馨", "")
		end
		local item = {count = data.frienddata.FLOWERSELECT[define.Flower.Type.Same].effect_list[i].amount, effect = effect}
		table.insert(list, item)
	end
	return list
end

return CFriendCtrl