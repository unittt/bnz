local CJieBaiCtrl = class("CJieBaiCtrl", CCtrlBase)

function CJieBaiCtrl.ctor(self)

	CCtrlBase.ctor(self)
	self:Clear()

end 

function CJieBaiCtrl.Clear(self)
	self.m_JieBaiInfo = nil
	self.m_KickOutActivity = nil
	self.m_InviteActivity = nil
	self.m_JieBaiValidInviter = nil
	self.m_Cb = nil
	self.m_ProfileList = nil
	self.m_PbRedPoint = {}
	self:SetJieBaiBtnClickState(false)
end

------------------------c2gs
function CJieBaiCtrl.C2GSJieBaiCreate(self)
	

	nethuodong.C2GSJieBaiCreate()

end

function CJieBaiCtrl.C2GSJBInvite(self, pid)
	
	nethuodong.C2GSJBInvite(pid)

end

function CJieBaiCtrl.C2GSJBKickInvite(self, pid)
	
	nethuodong.C2GSJBKickInvite(pid)

end

function CJieBaiCtrl.C2GSJBArgeeInvite(self)
	
	nethuodong.C2GSJBArgeeInvite()

end

function CJieBaiCtrl.C2GSJBDisgrgeeInvite(self)
	
	nethuodong.C2GSJBDisgrgeeInvite()

end

--退出结拜
function CJieBaiCtrl.C2GSQuitJieBai(self)
	
	nethuodong.C2GSQuitJieBai()

end

--解散结拜
function CJieBaiCtrl.C2GSReleaseJieBai(self)
	
	nethuodong.C2GSReleaseJieBai()

end

--结拜准备
function CJieBaiCtrl.C2GSJBPreStart(self)
	
	nethuodong.C2GSJBPreStart()

end

function CJieBaiCtrl.C2GSJBJoinYiShi(self)
	
	nethuodong.C2GSJBJoinYiShi()

end

function CJieBaiCtrl.C2GSQueryPlayerProfile(self, pidList, flag, cb)
	
	flag = flag or 1
	netfriend.C2GSQueryPlayerProfile(pidList, flag)
	self.m_QueryCb = cb

end

function CJieBaiCtrl.C2GSJBSetTitle(self, title)
	
	nethuodong.C2GSJBSetTitle(title)

end

function CJieBaiCtrl.C2GSJBSetMingHao(self, name)
	
	nethuodong.C2GSJBSetMingHao(name)

end

function CJieBaiCtrl.C2GSJBJingJiu(self)
	
	nethuodong.C2GSJBJingJiu()

end

function CJieBaiCtrl.C2GSJBEnounce(self, enounce)
	
	nethuodong.C2GSJBEnounce(enounce)

end


function CJieBaiCtrl.C2GSJBKickMember(self, pid)
	
	nethuodong.C2GSJBKickMember(pid)

end

function CJieBaiCtrl.C2GSJBVoteKickMember(self, op)
	
	nethuodong.C2GSJBVoteKickMember(op)

end

function CJieBaiCtrl.C2GSJBGetValidInviter(self)
	
	nethuodong.C2GSJBGetValidInviter()

end

----------------------gs2c
function CJieBaiCtrl.GS2CJiaBaiCreate(self, info)
	
	local ct = {allinviter = {}}
	table.copy(info, ct)
	self.m_JieBaiInfo = ct
	CJieBaiMainView:ShowView()
	self:OnEvent(define.JieBai.Event.JieBaiCreate)

end

function CJieBaiCtrl.GS2CJBAddInviter(self, inviterInfo)
	
	local pid = inviterInfo.pid
	local inviter = self:GetJieBaiInviterByPid(pid)
	if inviter then 
		inviter.pid = pid
		inviter.invitestate = inviterInfo.invitestate
		self:OnEvent(define.JieBai.Event.JieBaiInfoChange)
	else
		table.insert(self.m_JieBaiInfo.allinviter, inviterInfo)
		self:OnEvent(define.JieBai.Event.JieBaiInfoChange)
	end 

end

function CJieBaiCtrl.GS2CJBRefreshInviter(self, inviterInfo)
	
	local pid = inviterInfo.pid
	local inviter = self:GetJieBaiInviterByPid(pid)
	if inviter then 
		inviter.pid = pid
		inviter.invitestate = inviterInfo.invitestate
		self:InviterChange(true, inviter)
		self:OnEvent(define.JieBai.Event.JieBaiInfoChange)
	end 

end

function CJieBaiCtrl.GS2CJBBecomeInviter(self, inviterInfo)
	
	self:BecomeInviterConfirmTip(inviterInfo)

end

function CJieBaiCtrl.GS2CJBRemoveInviter(self, pid)
	
	self:RemoveInviterByPid(pid)
	self:OnEvent(define.JieBai.Event.JieBaiInfoChange)

end

function CJieBaiCtrl.GS2CJBRefresh(self, info)
	
	local ct = {allinviter = {}}
	table.copy(info, ct)
	self.m_JieBaiInfo = ct
	self:YiShiStateHandle()
	self:RefreshNpc()
	self:OnEvent(define.JieBai.Event.JieBaiInfoChange)

end


function CJieBaiCtrl.GS2CJBMemberOnLogin(self, info)
	
	local ct = {allinviter = {}}
	table.copy(info, ct)
	self.m_JieBaiInfo = ct
	self:YiShiStateHandle()
	self:OnEvent(define.JieBai.Event.JieBaiCreate)

end

function CJieBaiCtrl.GS2CJBRemoveJieBai(self)
	
	if self.m_InviterTipView then 
		self.m_InviterTipView:Clear()
		self.m_InviterTipView = nil
	end 

	if not self.m_JieBaiInfo then 
		return
	end 

	local isSponsor = self:IsJieBaiSponsor()

	if isSponsor then 
		local view = CJieBaiMainView:GetView()
		if view then 
			view:OnClose()
		end 
	else
		local view = CJieBaiInvitedMainView:GetView()
		if view then 
			view:OnClose()
		end 
	end 

	local inviteFriendView = CJieBaiInviteFriendView:GetView()
	if inviteFriendView then 
		inviteFriendView:OnClose()
	end 

	local oView = CJieBaiTeamView:GetView()
	if oView then 
		oView:OnClose()
	end 

	self.m_JieBaiInfo = nil
	self.m_KickOutActivity = nil
	self.m_InviteActivity = nil
	self:SetJieBaiBtnClickState(false)
	self:OnEvent(define.JieBai.Event.JieBaiRemove)

end

function CJieBaiCtrl.GS2CPlayerProfile(self, profileList, flag)
	
	if flag == 1 then 
		self.m_ProfileList = profileList
		if self.m_QueryCb then 
			self.m_QueryCb()
			self.m_QueryCb = nil
		end 
	end 

end

function CJieBaiCtrl.GS2CJBInvitedOnLogin(self, info)
	
	self.m_JieBaiInfo = info
	self:YiShiStateHandle()
	self:OnEvent(define.JieBai.Event.JieBaiLogin)

end

function CJieBaiCtrl.GS2CJBInviterOnLogin(self, inviterInfo)
	
	self:BecomeInviterConfirmTip(inviterInfo)

end

function CJieBaiCtrl.GS2CJBYiShiChuiCu(self)
	
	self:EnterYiShiTip()

end

function CJieBaiCtrl.GS2CJBHejiu(self)
	
	local oView = CJieBaiDeclarationView:GetView()
	if oView then 
		oView:OnClose()
	end 

	self:ViewOnClose()

	CJieBaiDeclarationAniView:ShowView()

end

function CJieBaiCtrl.GS2CJBValidInviter(self, list)
	
	self.m_JieBaiValidInviter = list
	if self.m_Cb then 
		self.m_Cb()
		self.m_Cb = nil
	end 

end

function CJieBaiCtrl.GS2CJBAddMember(self, memberInfo)
	
	local allmember = self.m_JieBaiInfo.allmember
	table.insert(allmember, memberInfo)
	self:OnEvent(define.JieBai.Event.JieBaiInfoChange)

end

function CJieBaiCtrl.GS2CJBBecomeMember(self, info)
	
	self.m_JieBaiInfo = info
	self:OnEvent(define.JieBai.Event.JieBaiCreate)

end

function CJieBaiCtrl.GS2CJBRemoveMember(self, pid)
	
	self:RemoveMember(pid)
	self:OnEvent(define.JieBai.Event.JieBaiInfoChange)

end

function CJieBaiCtrl.GS2CJiaBaiClickNpc(self, flag)
	
	if flag == 1 then 
		self:ShowIntruction(10065)
	elseif flag == 2 then 
		self:ShowIntruction(10066)
	elseif flag == 3 then 
		if self:IsJieBaiCreate() then 
			self:ShowJieBaiView()
		else
			self:JieBaiCreate()
		end 
	end  

end

function CJieBaiCtrl.GS2CJBRedPoint(self, iRedPoint)
	local iKey = define.JieBai.RedPoint.KickMember
	local iOldRedPoint = self.m_PbRedPoint[iKey]
	self.m_PbRedPoint[iKey] = iRedPoint
	if iOldRedPoint ~= iRedPoint then
		self:OnEvent(define.JieBai.Event.ProtoRedPointChange)
	end
end

--------------------interface--------------------------------
function CJieBaiCtrl.AddJieBaiBtnEffect(self, btn)

	if btn and self.m_JieBaiInfo then
		local hadClick = IOTools.GetClientData("JieBaiBtnEffect") 
		if not hadClick then 
			btn:AddEffect("Circu")
		end 
	end 

end

function CJieBaiCtrl.DelJieBaiBtnEffect(self, btn)
	
	if btn then 
		btn:DelEffect("Circu")
	end 

end

function CJieBaiCtrl.SetJieBaiBtnClickState(self, state)
	
	IOTools.SetClientData("JieBaiBtnEffect", state)

end

function CJieBaiCtrl.RemoveMember(self, pid)
	
	local allmember = self.m_JieBaiInfo.allmember
	for k, v in ipairs(allmember) do 
		if v.pid == pid then 
			table.remove(allmember, k)
		end 
	end 

end

function CJieBaiCtrl.IsHadVote(self)
	
	local kickout = self.m_JieBaiInfo.kickout
	if not kickout or not next(kickout) then 
		return
	end 

	if kickout.agreelist then 
		for k, pid in ipairs(kickout.agreelist) do 
			if pid == g_AttrCtrl.pid then 
				return true
			end 
		end 
	end

	if kickout.disagreelist then 
		for k, pid in ipairs(kickout.disagreelist) do 
			if pid == g_AttrCtrl.pid then 
				return true
			end 
		end 
	end 

	return false

end

function CJieBaiCtrl.CreateInviteActivity(self)

	self.m_InviteActivity = nil

	local jiebaiSate = self:GetJieBaiState()

	if jiebaiSate == define.JieBai.State.AfterYiShi then 
		local inviteAnnounce =  self.m_JieBaiInfo.allinviter 
		if not inviteAnnounce or not next(inviteAnnounce) then
			self.m_InviteActivity = nil
			return
		end 

		local inviter = inviteAnnounce[1].owner
		local beInviter = inviteAnnounce[1].pid
		local state = 1

		local inviterName = nil
		local beInviterName = nil

		local frd = g_FriendCtrl:GetFriend(inviter)
		if frd then 
			inviterName = frd.name
		else
			inviterName = g_AttrCtrl.name
		end

		frd = g_FriendCtrl:GetFriend(beInviter)
		if frd then 
			beInviterName = frd.name
		else
			beInviterName = g_AttrCtrl.name
		end 

		if inviterName and beInviterName then 
			local activity = {}
			activity.state = state
			activity.inviterName = inviterName
			activity.beInviterName = beInviterName
			self.m_InviteActivity = activity
		end
	end 

end

function CJieBaiCtrl.GetInviteActivity(self)

	self:CreateInviteActivity()
	return self.m_InviteActivity

end

function CJieBaiCtrl.GetKickOutActivity(self)
	
	self:CreateKickOutActivity()
	return self.m_KickOutActivity

end

function CJieBaiCtrl.CreateKickOutActivity(self)
	
	self.m_KickOutActivity = nil

	local kickout = self.m_JieBaiInfo.kickout

	if not kickout or not next(kickout) then
		self.m_KickOutActivity  = nil
		return
	end 

	local activityInfo = {}
	local sponsorPid = kickout.owner
	local beInvotePid = kickout.pid
	local startTime = kickout.time
	local sponsorName = nil
	local beInvoteName = nil
	if sponsorPid == g_AttrCtrl.pid then 
		sponsorName = g_AttrCtrl.name
	else
		local frd = g_FriendCtrl:GetFriend(sponsorPid)
		if frd then 
			sponsorName = frd.name
		end 
		
	end

	if beInvotePid == g_AttrCtrl.pid then 
		beInvoteName = g_AttrCtrl.name
	else
		local frd = g_FriendCtrl:GetFriend(beInvotePid)
		if frd then 
			beInvoteName = frd.name
		end 
	end 

	if sponsorName and beInvoteName then 
		local agreeCnt = kickout.agreelist and #kickout.agreelist or 0
		local disAgreeCnt = kickout.disagreelist and #kickout.disagreelist or 0
		local totalCnt = agreeCnt + disAgreeCnt

		local post = sponsorName .. "发起了对" .. beInvoteName .. "的请离," .. tostring(agreeCnt) .. "/" .. tostring(totalCnt) .. "已同意请离"

		activityInfo.post = post
		activityInfo.sponsorPid = sponsorPid

		local curTime = g_TimeCtrl:GetTimeS()
		local jiebaiConfig = data.huodongdata.JIEBAI_CONFIG[1]
		local voteTime = jiebaiConfig.vote_time
		local remainTime = startTime + voteTime - curTime
		activityInfo.remainTime = remainTime

		self.m_KickOutActivity = activityInfo
	end 

end

function CJieBaiCtrl.GetValidInviterList(self)
	
	return self.m_JieBaiValidInviter

end

function CJieBaiCtrl.QureyValidInviter(self, cb)
	
	self:C2GSJBGetValidInviter()
	self.m_Cb = cb

end

--获取除自己和老大之外的其他成员列表
function CJieBaiCtrl.GetOtherMemberList(self)
	
	local otherList = {}
	local sponsor = self.m_JieBaiInfo.owner
	local allmember = self:GetMemberList()
	for k, v in ipairs(allmember) do 
		if v.pid ~= g_AttrCtrl.pid and v.pid ~= sponsor then 
			table.insert(otherList, v)
		end  
	end 

	return otherList

end


function CJieBaiCtrl.GetJieYiValue(self)
	
	if not self.m_JieBaiInfo.jieyi then 
		return 0
	end 

	return self.m_JieBaiInfo.jieyi

end

function CJieBaiCtrl.GetDeclaration(self)
	
	return self.m_JieBaiInfo.enounce

end

function CJieBaiCtrl.IsShowReturnBtn(self)
	
	if not self.m_JieBaiInfo then 
		return false
	end 

	local mapId = g_MapCtrl:GetMapID()
	if mapId ~= 510000 then 
		return false
	end

	local ysstate = self.m_JieBaiInfo.ysstate
	if ysstate == define.JieBai.YiShiState.SetTitle or ysstate == define.JieBai.YiShiState.SetName then
		local setNameView = CJieBaiSetNameView:GetView()
		local setTitleView = CJieBaiSetTitleView:GetView()
		if not setNameView and not setTitleView then 
			return true
		end 
	end 

	return false 

end

function CJieBaiCtrl.ViewOnClose(self)
	
	local ysstate = self.m_JieBaiInfo.ysstate
	if ysstate == define.JieBai.YiShiState.SetTitle or ysstate == define.JieBai.YiShiState.SetName then 
		self:OnEvent(define.JieBai.Event.ViewOnClose)
	end  
	
end

function CJieBaiCtrl.RetrunYiShi(self)
	
	local ysstate = self.m_JieBaiInfo.ysstate
	if ysstate == define.JieBai.YiShiState.SetTitle then 
		local isSponsor = self:IsJieBaiSponsor()
		if isSponsor then 
			CJieBaiSetTitleView:ShowView()
		end 
	elseif ysstate == define.JieBai.YiShiState.SetName then 
		CJieBaiSetNameView:ShowView()
	end 

end

function CJieBaiCtrl.GetMingHao(self, pid)
	
	local title = self:GetTitle()

	if not title then 
		return
	end 

	local member = self:GetMemberByPid(pid)

	if not member then 
		member = self:GetInviterByPid(pid)
	end 

	if member and  member.minghao and member.minghao ~= "" then 
		return member.minghao
	end 

end

function CJieBaiCtrl.GetTitleMingHao(self, pid)

	local title = self:GetTitle()

	if not title or title == "" then 
		return
	end 

	local state = self:GetJieBaiState()
	local info = nil
	if state == define.JieBai.State.AfterYiShi then 
		info = self:GetMemberByPid(pid)
	else
		info = self:GetJieBaiInviterByPid(pid)
		if not info then 
			info =  self:GetMemberByPid(pid)
		end 
	end 

	if not info then 
		return
	end 

	local minghao = info.minghao or ""
	
	return title .. "." .. minghao

end

function CJieBaiCtrl.GetTitle(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	return self.m_JieBaiInfo.title

end

function CJieBaiCtrl.RefreshNpc(self)
	
	local yiShiState = self:GetCurYiShiState()
	if yiShiState then 
		if yiShiState ~= define.JieBai.YiShiState.Open then 
			local liuNpc = g_MapCtrl:GetNpcByType(1001)
			if liuNpc then 
				if liuNpc.m_NpcAoi.func_group == "huodong.jiebai" then 
					liuNpc:SetWenHaoMark(false)
				end 
			end 
			local shiyiNpc = g_MapCtrl:GetNpcByType(1002) 
			if shiyiNpc then 
				if shiyiNpc.m_NpcAoi.func_group == "huodong.jiebai" then 
					shiyiNpc:SetWenHaoMark(true)
				end 
			end 
		end 
	end 

end

--阶段处理
function CJieBaiCtrl.YiShiStateHandle(self)

	local state = self.m_JieBaiInfo.state

	local sponsorId = self.m_JieBaiInfo.owner

	if state == define.JieBai.State.InYiShi then 
		local ysstate = self.m_JieBaiInfo.ysstate
		ysstate = ysstate or 0
		if ysstate == define.JieBai.YiShiState.Open then 
			--预开启
			self:TryOpenYiShiView()
		elseif ysstate == define.JieBai.YiShiState.Select then 
			--收集
			local tip = self:GetTextTip(1028)
			CJieBaiYiShiTipView:ShowView(function ( oView )
				oView:SetInfo(tip)
			end)
		elseif  ysstate == define.JieBai.YiShiState.SetTitle then 
			--设置称号
			local isSponsor = self:IsJieBaiSponsor()
			CDialogueOptionView:CloseView()
			if isSponsor then 
				local tip = self:GetTextTip(1031)
				local openView = function ()
					CJieBaiSetTitleView:ShowView()
				end
				CJieBaiYiShiTipView:ShowView(function ( oView )
					oView:SetInfo(tip, 3, openView)
				end)
			else
				local time = data.huodongdata.JIEBAI_CONFIG[1].settitle_time
				CJieBaiWaitView:ShowView(function ( oView )
					oView:SetTime(time)
				end)
			end 
		elseif ysstate == define.JieBai.YiShiState.SetName then 
			--设置名号
			local waitView = CJieBaiWaitView:GetView()
			if waitView then 
				waitView:ForceClose()
			end 

			local titleView = CJieBaiSetTitleView:GetView()
			if titleView then 
				titleView:OnClose()
			end 

			local setNameView = CJieBaiSetNameView:GetView()
			if not setNameView then 
				local tip = self:GetTextTip(1036)
				local openView = function ()
					CJieBaiSetNameView:ShowView()
				end
				CJieBaiYiShiTipView:ShowView(function ( oView )
					oView:SetInfo(tip, 3, openView)
				end)
			end 
		elseif  ysstate == define.JieBai.YiShiState.Drink then 
			--喝酒
			local setNameView = CJieBaiSetNameView:GetView()
			if setNameView then 
				setNameView:OnClose()
			end 

			local heJiuView = CJieBaiDeclarationView:GetView()
			if not heJiuView then 
				local tip = self:GetTextTip(1038)
				local openView = function ()
					CJieBaiDeclarationView:ShowView()
				end
				CJieBaiYiShiTipView:ShowView(function ( oView )
					oView:SetInfo(tip, 3, openView)
				end)
			end 
		end
	elseif state == define.JieBai.State.AfterYiShi then 
		local oView = CJieBaiDeclarationAniView:GetView()
		if oView then 
			oView:OnClose()
		end 
	end 

end

function CJieBaiCtrl.TryOpenYiShiView(self)
	
	local mapId = g_MapCtrl:GetMapID()
	if mapId ~= 510000 then 
		local oView = CJieBaiCountDownView:GetView()
		if oView then 
			oView:OnClose()
		end 
	else

		local inviteMainView = CJieBaiInvitedMainView:GetView()
		if inviteMainView then 
			inviteMainView:OnClose()
		end 

		CJieBaiCountDownView:ShowView()
	end 

end

function CJieBaiCtrl.GetCurYiShiState(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	local ysstate = self.m_JieBaiInfo.ysstate

	return ysstate or 0

end

--获取仪式各个阶段的剩余时间
function CJieBaiCtrl.GetYiShiStateTime(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	local curTime = g_TimeCtrl:GetTimeS()

	local jiebaiConfig = data.huodongdata.JIEBAI_CONFIG[1]

	local ysstate = self.m_JieBaiInfo.ysstate

	local ysTime = self.m_JieBaiInfo.ysstarttime

	ysstate = ysstate or 0

	if ysstate == define.JieBai.YiShiState.Open then 
		local openTime = jiebaiConfig.yishi_prestart_time
		return ysTime + openTime - curTime
	elseif ysstate == define.JieBai.YiShiState.Select then 
		local selectTime = jiebaiConfig.collect_box_time
		return ysTime + selectTime - curTime
	elseif  ysstate == define.JieBai.YiShiState.SetTitle then 
		local setTitleTime = jiebaiConfig.settitle_time
		return ysTime + setTitleTime - curTime
	elseif ysstate == define.JieBai.YiShiState.SetName then 
		local setNameTime = jiebaiConfig.setminghao_time
		return ysTime + setNameTime - curTime
	elseif  ysstate == define.JieBai.YiShiState.Drink then 
		local drinkTime = jiebaiConfig.sethejiu_time
		return ysTime + drinkTime - curTime
	end 


end

function CJieBaiCtrl.EnterYiShiTip(self)

	if not self.m_JieBaiInfo then 
		return
	end 
	
	local tip =  g_JieBaiCtrl:GetTextTip(1018)
	local sponsorPid = self.m_JieBaiInfo.owner

	local frdobj = g_FriendCtrl:GetFriend(sponsorPid)
	local sponsorName = nil
	if frdobj then
		sponsorName = frdobj.name
	else
		sponsorName = g_AttrCtrl.name
	end 

	if sponsorName then 
		tip = string.gsub(tip, "#role",  sponsorName)
		local windowConfirmInfo = {
		    msg = tip,
		    okCallback = function()
		    	self:C2GSJBJoinYiShi()
		    end,
		    pivot = enum.UIWidget.Pivot.Center,
		    okStr = "确定",
		    cancelStr = "取消"
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end 

end

function CJieBaiCtrl.BecomeInviterConfirmTip(self, inviterInfo)
	
	local info = inviterInfo.invite_info
	if not info then 
		return
	end 

	local tip =  g_JieBaiCtrl:GetTextTip(1011)
	local sponsorPid = info.owner

	local fun = function ()
		local playerProfile = self:GetPlayerProfile(sponsorPid)
		if playerProfile then
			local sponsorName = playerProfile.name
			tip = string.gsub(tip, "#role",  sponsorName)
			local windowConfirmInfo = {
			    msg = tip,
			    okCallback = function(tipView)
				    local inviteConsume = data.huodongdata.JIEBAI_CONFIG[1].agree_invite
				    local curSilver = g_AttrCtrl.silver
			    	if curSilver < inviteConsume then 
			    		g_NotifyCtrl:FloatMsg(g_JieBaiCtrl:GetTextTip(1012))
			    		-- CCurrencyView:ShowView(function(oView)
			    		-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
			    		-- end)
						g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
			    	else
			    		self:C2GSJBArgeeInvite()
			    		if self.m_InviterTipView then 
			    			self.m_InviterTipView:Clear()
			    			self.m_InviterTipView = nil
			    		end 
			    	end 
			   
			    end,
			    cancelCallback = function()
			    	self:C2GSJBDisgrgeeInvite()
			    end ,   
			    pivot = enum.UIWidget.Pivot.Center,
			    okStr = "同意",
			    cancelStr = "不同意",
			    okButNotClose = true,
			    closeType = 3,
			}
			g_WindowTipCtrl:SetJieBaiWindowConfirm(windowConfirmInfo, function (oView)
				self.m_InviterTipView = oView
			end)
		end 
	end

	self:C2GSQueryPlayerProfile({sponsorPid}, nil, fun)

end

function CJieBaiCtrl.ShowJieBaiView(self)

	if not self.m_JieBaiInfo then 
		return
	end 


	local state = self:GetJieBaiState()

	if state == define.JieBai.State.AfterYiShi then 
		CJieBaiTeamView:ShowView()
	else
		local isSponsor = self:IsJieBaiSponsor()

		if isSponsor then 
			CJieBaiMainView:ShowView()
		else
			CJieBaiInvitedMainView:ShowView()
		end 
	end 
	
end


--是否结拜发起者
function CJieBaiCtrl.IsJieBaiSponsor(self)
	
	if not self.m_JieBaiInfo then 
		return
	end 

	local sponsorId = self.m_JieBaiInfo.owner
	return g_AttrCtrl.pid == sponsorId

end

function CJieBaiCtrl.JieBaiCreate(self)
	
	local createConsume = data.huodongdata.JIEBAI_CONFIG[1].create_resume
	local curSilver = g_AttrCtrl.silver
	local tip =  g_JieBaiCtrl:GetTextTip(1004)
	local windowConfirmInfo = {
	    msg = tip,
	    okCallback = function()
	    	if curSilver < createConsume then 
	    		g_NotifyCtrl:FloatMsg(g_JieBaiCtrl:GetTextTip(1012))
	    		-- CCurrencyView:ShowView(function(oView)
	    		-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
	    		-- end)
				g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
	    	else
	    		self:C2GSJieBaiCreate()
	    	end 
	   
	    end, 
	    pivot = enum.UIWidget.Pivot.Center,
	    okStr = "同意",
	    cancelStr = "再考虑一下",	 
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)

end

--结拜阶段
function CJieBaiCtrl.GetJieBaiState(self)
	
	if not self.m_JieBaiInfo then 
		return
	end 

	return self.m_JieBaiInfo.state

end

function CJieBaiCtrl.IsJieBaiCreate(self)
	
	return self.m_JieBaiInfo and true or false

end

function CJieBaiCtrl.GetMemberByPid(self, pid)
	
	for k, v in ipairs( self.m_JieBaiInfo.allmember) do 
		if v.pid == pid then 
			return v
		end 
	end 

end

function CJieBaiCtrl.GetInviterByPid(self, pid)
	
	for k, v in ipairs( self.m_JieBaiInfo.allinviter) do 
		if v.pid == pid then 
			return v
		end 
	end 

end

--获取被邀请者信息
function CJieBaiCtrl.GetJieBaiInviterByPid(self, pid)
	
	if not self.m_JieBaiInfo then 
		return
	end

	for k, v in ipairs( self.m_JieBaiInfo.allinviter) do 
		if v.pid == pid then 
			return v
		end 
	end 
	
end

function CJieBaiCtrl.RemoveInviterByPid(self, pid)
	
	if not self.m_JieBaiInfo then 
		return
	end

	for k, v in ipairs( self.m_JieBaiInfo.allinviter) do 
		if v.pid == pid then 
			table.remove(self.m_JieBaiInfo.allinviter, k)
			break
		end 
	end 

	self:InviterChange(false)

end


--剩下可邀请人数
function CJieBaiCtrl.GetRemainInviteCount(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	local allInviter = self.m_JieBaiInfo.allinviter
	local count = #allInviter
	local remainCount = 4 - count
	return remainCount

end

--结拜邀请的剩余时间
function CJieBaiCtrl.GetJieBaiLeftTime(self)

	if not self.m_JieBaiInfo then 
		return
	end
	
	local inviteTime = data.huodongdata.JIEBAI_CONFIG[1].invite_time
	local createTime = self.m_JieBaiInfo.createtime
	local curTime = g_TimeCtrl:GetTimeS()
	return createTime + inviteTime - curTime

end

function CJieBaiCtrl.GetJieBaiColdTime(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	if not self.m_JieBaiInfo.createystime then 
		return
	end 

	local curTime = g_TimeCtrl:GetTimeS()
	local cd = data.huodongdata.JIEBAI_CONFIG[1].yishi_cd
	return  self.m_JieBaiInfo.createystime + cd - curTime

end

function CJieBaiCtrl.IsInvitedCountEnough(self)
	
	return self:GetRemainInviteCount() == 0

end


function CJieBaiCtrl.IsHadInviter(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	if not next(self.m_JieBaiInfo.allinviter) then 
		return false
	end 

	return true

end

function CJieBaiCtrl.IsAllInviterConfirm(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	for k, v in ipairs(self.m_JieBaiInfo.allinviter) do 
		if v.invitestate == 0 then 
			return false
		end 
	end 

	return true

end

function CJieBaiCtrl.IsInvitersOnLine(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	for k, v in ipairs(self.m_JieBaiInfo.allinviter) do 
		if v.pid ~= g_AttrCtrl.pid then 
			local isOnLine = g_FriendCtrl:GetOnlineState(v.pid) ~= 0
			if not isOnLine then 
				return false
			end 
		end
	end 

	return true

end

function CJieBaiCtrl.IsInviterOnLine(self, pid)
	
	for k, v in ipairs(self.m_JieBaiInfo.allinviter) do 
		if v.pid == pid then 
			if pid == g_AttrCtrl.pid then 
				return true
			else
				local isOnLine = g_FriendCtrl:GetOnlineState(v.pid) ~= 0
				return isOnLine
			end 

		end  
	end 

	return true

end

function CJieBaiCtrl.IsInColdTime(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	if not self.m_JieBaiInfo.createystime then 
		return
	end

	local coldTime = self:GetJieBaiColdTime()

	return  coldTime > 0 and true or false

end

--[pid]
function CJieBaiCtrl.GetAllInvitersPid(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	local idList = {}
	table.insert(idList, self.m_JieBaiInfo.owner)
	for k, v in ipairs(self.m_JieBaiInfo.allinviter) do 
		table.insert(idList, v.pid)
	end 

	return idList

end

function CJieBaiCtrl.GetAllMemberPidList(self)
	
	local idList = {}
	for k, v in ipairs(self.m_JieBaiInfo.allmember) do 
		table.insert(idList, v.pid)
	end 

	return idList

end

function CJieBaiCtrl.IsMemberFull(self)

	return self:GetCanInviterCnt() <= 0
	-- local list = self:GetAllMemberPidList()
	-- local max = self:GetMaxMemberCnt()
	-- if #list >= max then 
	-- 	return true
	-- end 
	-- return false 

end

--获取发起者信息  lv,icon,name,pid,school
function CJieBaiCtrl.GetSponsorInfo(self)
	
	if not self.m_JieBaiInfo then 
		return
	end 

	local sponsorInfo = {}
	local pid = self.m_JieBaiInfo.owner
	if g_AttrCtrl.pid == pid then 
		sponsorInfo.pid = pid
		sponsorInfo.icon = g_AttrCtrl.model_info.shape
		sponsorInfo.name = g_AttrCtrl.name
		sponsorInfo.lv = g_AttrCtrl.grade
		sponsorInfo.school = g_AttrCtrl.school
	else
		local frdInfo = g_FriendCtrl:GetFriend(pid)
		sponsorInfo.pid = pid
		sponsorInfo.icon = frdInfo.icon
		sponsorInfo.name = frdInfo.name
		sponsorInfo.lv = frdInfo.grade
		sponsorInfo.school = frdInfo.school
	end 

	return sponsorInfo

end

--获取符合条件的朋友
function CJieBaiCtrl.GetFriendList(self)
	
	local friendShipConditon = data.huodongdata.JIEBAI_CONFIG[1].friend_degree
	local friendList = {}
	local frdlist = g_FriendCtrl:GetMyFriend()	
	for k, pid in ipairs(frdlist) do 
		local frdobj = g_FriendCtrl:GetFriend(pid)
		if frdobj then 
			local lv = frdobj.grade
			local friendShip = frdobj.friend_degree
			local isOnLine = g_FriendCtrl:GetOnlineState(pid) ~= 0 
			if (lv >= self:GetSysPlayLv()) and (friendShip >= friendShipConditon) and isOnLine then 
				local info = {}
				info.pid = pid
				info.name = frdobj.name
				info.icon = frdobj.icon
				info.lv = frdobj.grade
				info.friendShip = frdobj.friend_degree
				info.school = frdobj.school
				local invitedInfo = self:GetJieBaiInviterByPid(pid)
				info.IsInvited = invitedInfo and true or false
				table.insert(friendList, info)
			end
		end 
	end 

	return friendList

end


function CJieBaiCtrl.GetPlayerProfile(self, pid)
	
	if not self.m_ProfileList then 
		return
	end 

	for k, v in ipairs(self.m_ProfileList) do 
		if v.pid == pid then 
			return v
		end 
	end 

end

function CJieBaiCtrl.GetMemberList(self)
	
	local memberList = {}
	local allmember = self.m_JieBaiInfo.allmember

	for k, v in ipairs(allmember) do 
		local pid = v.pid
		local playerProfile = g_FriendCtrl:GetFriend(pid)
		if playerProfile then 
			local info = {}
			info.pid = pid
			info.name = playerProfile.name
			info.icon = playerProfile.icon
			info.lv = playerProfile.grade
			info.friendShip = playerProfile.friend_degree
			info.school = playerProfile.school
			info.titleMingHao = self:GetTitleMingHao(pid)
			table.insert(memberList, info)
		else
			local info = {}
			info.pid = pid
			info.name = g_AttrCtrl.name
			info.icon = g_AttrCtrl.model_info.shape
			info.lv =  g_AttrCtrl.grade
			info.school = g_AttrCtrl.school
			info.titleMingHao = self:GetTitleMingHao(pid)
			table.insert(memberList, info)
		end  	
 
	end 

	return memberList

end

--获取发起者和邀请者id列表
function CJieBaiCtrl.GetSponsorInviterIdList(self)
	
	local idList = {}
	local allInviter = self.m_JieBaiInfo.allinviter
	for k, v in ipairs(allInviter) do 
		local pid = v.pid
		table.insert(idList, pid) 
	end 

	local sponsor = self:GetSponsorInfo()
	table.insert(idList, 1, sponsor.pid)

	return idList

end

--获取被邀请者列表
function CJieBaiCtrl.GetInvitedList(self)
	
	if not self.m_JieBaiInfo then 
		return
	end

	local invitedList = {}
	local allInviter = self.m_JieBaiInfo.allinviter

	for k, v in ipairs(allInviter) do 
		local pid = v.pid
		local frdobj = g_FriendCtrl:GetFriend(pid)
		if frdobj then 
			local info = {}
			info.pid = pid
			info.name = frdobj.name
			info.icon = frdobj.icon
			info.lv = frdobj.grade
			info.friendShip = frdobj.friend_degree
			info.school = frdobj.school
			info.state = v.invitestate
			table.insert(invitedList, info)
		else
			local info = {}
			info.pid = pid
			info.name = g_AttrCtrl.name
			info.icon = g_AttrCtrl.model_info.shape
			info.lv =  g_AttrCtrl.grade
			info.school = g_AttrCtrl.school
			info.state = v.invitestate
			table.insert(invitedList, info)
		end    
	end 

	return invitedList

end

function CJieBaiCtrl.GetInvitedInfoByPid(self, pid)
	
	local invitedList = self:GetInvitedList()
	for k, v in ipairs(invitedList) do 
		if v.pid == pid then 
			return v
		end 
	end 

end

function CJieBaiCtrl.GetSysPlayLv(self)
	
	return data.opendata.OPEN.JIEBAI.p_level

end

function CJieBaiCtrl.ShowIntruction(self, id)
	
	if data.instructiondata.DESC[id] ~= nil then 
	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)
	end 

end

function CJieBaiCtrl.GetTextTip(self, id)
    
    local config = data.huodongdata.JIEBAI_TEXT[id]
    if config then 
        return config.content
    end 

end

function CJieBaiCtrl.GetRandomTitle(self)

	local randomTitleList = data.randomnamedata.JIEBAITITLE
	local info = table.randomvalue(randomTitleList)
	return info.title

end

function CJieBaiCtrl.GetRandomMingHao(self)
	
	local randomMingHaoList = data.randomnamedata.JIEBAIMINGHAO
	local info = table.randomvalue(randomMingHaoList)
	return info.minghao

end

function CJieBaiCtrl.InviterChange(self, flag, inviterInfo)

	if flag then 
		if inviterInfo.invitestate == 1 then 
			self.m_InviterChange = true
			self:OnEvent(define.JieBai.Event.InviteChange)
		end
	else
		self.m_InviterChange = true
		self:OnEvent(define.JieBai.Event.InviteChange)
	end 

	self.m_InviterChange = false

end

function CJieBaiCtrl.ResetInviterChangeState(self)
	
	self.m_InviterChange = false
	self:OnEvent(define.JieBai.Event.InviteChange)

end

function CJieBaiCtrl.IsShowRedPoint(self)
	
	local state = self:GetJieBaiState()
	if state == define.JieBai.State.BeforeYiShi then 
		local isSponsor = self:IsJieBaiSponsor()
		local oView = CJieBaiMainView:GetView()
		if not oView and isSponsor then 
			if self.m_InviterChange then 
				return true
			end 
		end 
	else
		for i, v in pairs(self.m_PbRedPoint) do
			if v ~= 0 then
				return true
			end
		end
	end 

end

--获取最大的成员上限
function CJieBaiCtrl.GetMaxMemberCnt(self)
	
	return self.m_JieBaiInfo.invite_limit
	-- local inviteCntConfig = data.huodongdata.JIEBAI_INVITECNT
	-- local jieyiValue = self:GetJieYiValue()

	-- if inviteCntConfig[jieyiValue] then 
	-- 	return inviteCntConfig[jieyiValue].limit
	-- end 	

	-- local t = {}
	-- for k, v in pairs(inviteCntConfig) do 
	-- 	table.insert(t, k)
	-- end 
	-- table.insert(t, jieyiValue)
	-- table.sort(t)
	-- local index = 1
	-- for k, v in ipairs(t) do
	-- 	if v == jieyiValue then 
	-- 		index = k - 1
	-- 	end  
	-- end 

	-- local jieyicnt = t[index]
	-- if inviteCntConfig[jieyicnt] then 
	-- 	return inviteCntConfig[jieyicnt].limit
	-- end 
 
end

-- 是否禁止结拜场景(活动，战斗)
function CJieBaiCtrl.IsInForbitMap(self)
	if g_WarCtrl:IsWar() then
		return true
	else
		local dMap = DataTools.GetMapInfo(g_MapCtrl.m_MapID)
		local sVirtual = dMap.virtual_game
		if sVirtual ~= "" then
			return true
		end
	end
	return false
end

function CJieBaiCtrl.ResetKickRedPoint(self)
	local iKey = define.JieBai.RedPoint.KickMember
	local iRedPoint = self.m_PbRedPoint[iKey]
	if iRedPoint and iRedPoint ~= 0 then
		nethuodong.C2GSJBClickRedPoint({iRedPoint})
	end
end

-- 是否有免费改名机会
function CJieBaiCtrl.IsSetNameFree(self)
	local iState = self:GetJieBaiState()
	local bFree = false
	if iState == define.JieBai.State.AfterYiShi then
		local allMember = self.m_JieBaiInfo.allmember
		if allMember then
			local iPid = g_AttrCtrl.pid
			for k, v in ipairs(allMember) do
				if v.pid == iPid then
					bFree = v.free_minghao == 1
					break
				end
			end
		end
	end
	return bFree
end

-- 还能邀请多少人
function CJieBaiCtrl.GetCanInviterCnt(self)
	local iLimit = self.m_JieBaiInfo.invite_limit or 0
	if iLimit > 0 then
		local iMember = #self.m_JieBaiInfo.allmember
		local iInvited = #self.m_JieBaiInfo.allinviter
		iLimit = iLimit - iMember - iInvited
	end
	return iLimit
end

return CJieBaiCtrl