module(..., package.seeall)

--GS2C--

function GS2CLoginFriend(pbdata)
	local friend_chat_list = pbdata.friend_chat_list
	local black_list = pbdata.black_list
	local friend_onlinestatus_list = pbdata.friend_onlinestatus_list
	--todo
	g_FriendCtrl:InitFriend(friend_onlinestatus_list)
	g_FriendCtrl:InitBlackList(black_list)
	g_TalkCtrl:InitOfflineMsg(friend_chat_list)
	g_FriendCtrl:InitOnlineState(friend_onlinestatus_list)
end

function GS2CAddFriend(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	for i = 1, #profile_list do
		profile_list[i] = g_NetCtrl:DecodeMaskData(profile_list[i], "friend")
	end
	-- table.print(profile_list,"解析后的添加好友数据")
	g_FriendCtrl:AddFriendList(profile_list)
end

function GS2CDelFriend(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:DelFriendList(pid_list)
end

function GS2CUpdateFriendDegree(pbdata)
	local pid = pbdata.pid
	local friend_degree = pbdata.friend_degree
	--todo
end

function GS2CAckChatTo(pbdata)
	local pid = pbdata.pid
	local message_id = pbdata.message_id
	--todo
	g_FriendCtrl:GS2CAckChatTo(pbdata)
end

function GS2CChatFrom(pbdata)
	local pid = pbdata.pid
	local msg = pbdata.msg
	local message_id = pbdata.message_id
	--todo
	netfriend.C2GSAckChatFrom(pid, message_id)
	g_TalkCtrl:AddMsg(pid, msg, message_id)
end

function GS2CRecommendFriends(pbdata)
	local recommend_friend_list = pbdata.recommend_friend_list
	--todo
	g_FriendCtrl:SetRecommendFriends(recommend_friend_list)
	
end

function GS2CStrangerProfile(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	g_FriendCtrl:AddStranger(profile_list)
end

function GS2CFriendShield(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:AddBlackFriend(pid_list)
end

function GS2CFriendUnshield(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:DelBlackFriend(pid_list)
end

function GS2COpenSendFlowerUI(pbdata)
	local pid = pbdata.pid
	local name = pbdata.name
	local icon = pbdata.icon
	local grade = pbdata.grade
	local friend_degree = pbdata.friend_degree
	local role_type = pbdata.role_type
	--todo
	g_FriendCtrl:GS2COpenSendFlowerUI(pbdata)
end

function GS2CSendFlowerSuccess(pbdata)
	local pid = pbdata.pid
	local bless = pbdata.bless
	--todo
	g_FriendCtrl:GS2CSendFlowerSuccess(pbdata)
end

function GS2CRefreshFriendProfile(pbdata)
	local profile = pbdata.profile
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(profile, "friend")
	g_FriendCtrl:GS2CRefreshFriendProfile(dDecode)
end

function GS2CVerifyFriend(pbdata)
	local pid = pbdata.pid
	local name = pbdata.name
	--todo
	g_FriendCtrl:GS2CVerifyFriend(pbdata)
end

function GS2CVerifyFriendConfirm(pbdata)
	local verify_list = pbdata.verify_list
	--todo
	g_FriendCtrl:GS2CVerifyFriendConfirm(pbdata)
end

function GS2CNotifyRefuseStrangerMsg(pbdata)
	local pid = pbdata.pid
	--todo
	g_FriendCtrl:GS2CNotifyRefuseStrangerMsg(pbdata)
end

function GS2CRefreshFriendProfileBoth(pbdata)
	local pid = pbdata.pid
	local both = pbdata.both
	--todo
	g_FriendCtrl:GS2CRefreshFriendProfileBoth(pbdata)
end

function GS2CPlayerProfile(pbdata)
	local profile_list = pbdata.profile_list
	local flag = pbdata.flag --1.结拜
	--todo
	g_JieBaiCtrl:GS2CPlayerProfile(profile_list, flag)
end


--C2GS--

function C2GSQueryFriendProfile(pid_list)
	local t = {
		pid_list = pid_list,
	}
	g_NetCtrl:Send("friend", "C2GSQueryFriendProfile", t)
end

function C2GSChatTo(pid, msg, message_id, forbid)
	local t = {
		pid = pid,
		msg = msg,
		message_id = message_id,
		forbid = forbid,
	}
	g_NetCtrl:Send("friend", "C2GSChatTo", t)
end

function C2GSAckChatFrom(pid, message_id)
	local t = {
		pid = pid,
		message_id = message_id,
	}
	g_NetCtrl:Send("friend", "C2GSAckChatFrom", t)
end

function C2GSApplyAddFriend(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSApplyAddFriend", t)
end

function C2GSApplyDelFriend(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSApplyDelFriend", t)
end

function C2GSFindFriend(pid, name)
	local t = {
		pid = pid,
		name = name,
	}
	g_NetCtrl:Send("friend", "C2GSFindFriend", t)
end

function C2GSFriendShield(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSFriendShield", t)
end

function C2GSFriendUnshield(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSFriendUnshield", t)
end

function C2GSSendFlower(pid, type, amount, bless, sys_bless)
	local t = {
		pid = pid,
		type = type,
		amount = amount,
		bless = bless,
		sys_bless = sys_bless,
	}
	g_NetCtrl:Send("friend", "C2GSSendFlower", t)
end

function C2GSOpenSendFlowerUI(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSOpenSendFlowerUI", t)
end

function C2GSVerifyFriend(pid, msg)
	local t = {
		pid = pid,
		msg = msg,
	}
	g_NetCtrl:Send("friend", "C2GSVerifyFriend", t)
end

function C2GSVerifyFriendComfirm(pid, result)
	local t = {
		pid = pid,
		result = result,
	}
	g_NetCtrl:Send("friend", "C2GSVerifyFriendComfirm", t)
end

function C2GSQueryPlayerProfile(pid_list, flag)
	local t = {
		pid_list = pid_list,
		flag = flag,
	}
	g_NetCtrl:Send("friend", "C2GSQueryPlayerProfile", t)
end

