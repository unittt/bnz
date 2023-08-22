local CChatCtrl = class("CChatCtrl", CCtrlBase)

function CChatCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_MsgObjs = {}
	self.m_ChannelMsgs = {}
	self.m_Filters = {}
	self.m_AudioFilters = {}
	self.m_IsLockRead = false
	self.m_HelpTips = {}
	self.m_MilesMsg = {}
	self.m_NeedLimitMsg = {["team"] = true}
	self.m_IsOrgCall = false
	--给CChatScrollPage调用
	self.m_IsOrgCallTips = false
	--给CChatScrollPage和talkpart调用
	self.m_IsChatRecording = false
	self.m_AutoPlayAudioList = {}

	self.m_IsLoadMsgData = false
	self.m_IsMessageRecord = false
	self.m_MessageList = {}
	self.m_IsChuanyin = false
	self.m_IsLoadSelfMessageData = false
	self.m_SelfChatMessageList = {}

	self:CheckColorInfoConfig()
end

--聊天协议数据返回
function CChatCtrl.AddMsg(self, dMsg)
	local iChannel = dMsg.channel
	if self:IsFilterChannel(iChannel) then
		print("已屏蔽该频道"..tostring(iChannel))
		return
	end
	local pid = CChatMsg.New(0, dMsg):GetRoleInfo("pid")
	
	if g_FriendCtrl:IsBlackFriend(pid) then
		return
	end
	
	self.m_IsChuanyin = dMsg.bubble ~= nil
	self:ClearUp(iChannel)
	local lMsgs = self.m_ChannelMsgs[iChannel]
	if not lMsgs then
		lMsgs = {}
	end
	local id = #self.m_MsgObjs + 1
	local oMsg = CChatMsg.New(id, dMsg)
	 --table.print("聊天协议数据返回",oMsg)
	
	table.insert(self.m_MsgObjs, oMsg)
	table.insert(lMsgs, id)
	self.m_ChannelMsgs[dMsg.channel] = lMsgs
	local isWar = g_WarCtrl:IsWar()
	
	local pid = oMsg:GetRoleInfo("pid")
	local oPlayer = nil
	if pid then
		if isWar then
			oPlayer = g_WarCtrl:GetWarriorByID(pid)
		else
			oPlayer = g_MapCtrl:GetPlayer(pid)
		end
	end
	
	if iChannel == define.Channel.World then
		if oMsg:GetType() == define.Chat.MsgType.Self then
			--不是千里传音开启倒计时
			if not g_ChatCtrl.m_IsChuanyin then
				self.m_LastWorldChatTime = g_TimeCtrl:GetTimeS()
			end
		end
	elseif iChannel == define.Channel.Current then
		--显示在频道发送消息的发送者头顶上的冒泡消息
		if oPlayer then
			oPlayer:ChatMsg(oMsg:GetValue("text"))
		end
	
	elseif iChannel == define.Channel.Team then
		if oPlayer then
			oPlayer:ChatMsg(oMsg:GetValue("text"))
		end
	elseif iChannel == define.Channel.Org then
		local callLink = oMsg:GetOrgCallLink()
		if callLink and tonumber(callLink.pid) == tonumber(g_AttrCtrl.pid) then
			self.m_IsOrgCall = true
		end
	end

	local oSpeechLink = LinkTools.FindLink(dMsg.text, "SpeechLink")
	if oSpeechLink and oMsg:GetType() ~= define.Chat.MsgType.Self then
		if not self:IsAudioFilter(iChannel) then
			-- printc("添加主动播放语音")
			--自动播放语音
			g_SpeechCtrl:AddPlayWithKey(oSpeechLink.sKey)
			-- table.insert(self.m_AutoPlayAudioList, oSpeechLink.sKey)
			-- local key = table.index(g_ChatCtrl.m_AutoPlayAudioList, oSpeechLink.sKey)
			-- if key then
			-- 	g_SpeechCtrl:PlayWithKey(oSpeechLink.sKey)
			-- 	table.remove(g_ChatCtrl.m_AutoPlayAudioList, key)
			-- end
		end
	end

	if not oSpeechLink and oMsg:GetType() == define.Chat.MsgType.Self then
		self:GetSelfChatMessageData()
		table.insert(self.m_SelfChatMessageList, 1, {text = oMsg:GetValue("text")})
		self:CheckSelfChatMessageData()
		self:SaveSelfChatMessageData(self.m_SelfChatMessageList)
	end

	--保存消息频道(6频道)消息在本地，测试使用
	if iChannel == define.Channel.Message and self.m_IsMessageRecord then
		-- printc("保存消息频道(6频道)消息在本地")
		self:GetSysMessageSaveData()
		table.insert(self.m_MessageList, 1, dMsg.text)
		local sLocalMsg = ""
		for k,v in ipairs(self.m_MessageList) do
			sLocalMsg = sLocalMsg .. v .. "\n"
		end
		self:SaveSysMessageData(sLocalMsg)
	end

	self:OnEvent(define.Chat.Event.AddMsg, oMsg)
end

function CChatCtrl.GS2CChatHistory(self, pbdata)
	for k,v in ipairs(pbdata.world_chat) do
		local dMsg = {
			channel = v.type,
			text = v.cmd,
		}
		if v.role_info.pid ~= 0 then
			dMsg.role_info = v.role_info
		end
		g_ChatCtrl:AddMsg(dMsg)
	end
	for k,v in ipairs(pbdata.org_chat) do
		local dMsg = {
			channel = v.type,
			text = v.cmd,
		}
		if v.role_info.pid ~= 0 then
			dMsg.role_info = v.role_info
		end
		g_ChatCtrl:AddMsg(dMsg)
	end
	for k,v in ipairs(pbdata.team_chat) do
		local dMsg = {
			channel = v.type,
			text = v.cmd,
		}
		if v.role_info.pid ~= 0 then
			dMsg.role_info = v.role_info
		end
		g_ChatCtrl:AddMsg(dMsg)
	end
end

function CChatCtrl.ClearUp(self, iChannel)
	local newMsgObjs = {}
	local lChannels = self:GetReceiveChannels(iChannel)
	--这里是控制频道显示的最大数量
	local iMax = 50
	local iAmount = 10
	local iCurAmount = 0
	for k, v in pairs(lChannels) do
		local n = 0
		if self.m_ChannelMsgs[v] then
			n = #self.m_ChannelMsgs[v]
		end
		iCurAmount = iCurAmount + n
	end
	if iCurAmount < iMax then
		return
	end
	local iDelAmount = 0
	for k, oMsg in pairs(self.m_MsgObjs) do
		if iDelAmount >= iAmount or not table.index(lChannels, oMsg:GetValue("channel")) then
			table.insert(newMsgObjs, oMsg)
		else
			iDelAmount = iDelAmount + 1
		end
	end

	self.m_MsgObjs = newMsgObjs
	self.m_ChannelMsgs = {}
	for i, oMsg in pairs(self.m_MsgObjs) do
		local lMsgs = self.m_ChannelMsgs[oMsg:GetValue("channel")]
		if not lMsgs then
			lMsgs = {}
		end
		table.insert(lMsgs, i)
		self.m_ChannelMsgs[oMsg:GetValue("channel")] = lMsgs
	end
end

--清空所有聊天数据
function CChatCtrl.ClearAll(self)
	self.m_MsgObjs = {}
	self.m_ChannelMsgs = {}
	local oChatView = CChatMainView:GetView()
	if oChatView then
		oChatView.m_ChatPage.m_MsgTable:Clear()
	end
	local oMainView = CMainMenuView:GetView()
	if oMainView then
		oMainView.m_LB.m_ChatBox.m_MsgTable:Clear()
	end
end

function CChatCtrl.ClearUpChannel(self, iChannel)
	if self.m_ChannelMsgs[iChannel] then
		self.m_ChannelMsgs[iChannel] = nil
	end
end

function CChatCtrl.GetReceiveChannels(self, iChannel)
	local t = {
		{define.Channel.Sys, define.Channel.Bulletin, define.Channel.Help, define.Channel.Rumour},
	}
	for k, lChannels in pairs(t) do
		if table.index(lChannels, iChannel) then
			return lChannels
		end
	end
	return {iChannel}
end

---------------以下是聊天频道屏蔽数据和自动播放语音设置数据----------------

--true是有屏蔽，false是没有屏蔽
function CChatCtrl.IsFilterChannel(self, iChannel)
	return self.m_Filters[iChannel]
end

function CChatCtrl.InitAudioFilter(self)
	local lChannels = IOTools.GetRoleData("audio_autoplay_channel") or {}
	self:RefreshAudioChannel(lChannels)
end

function CChatCtrl.RefreshFilterChannel(self, lChannels)
	self.m_Filters = {}
	for i, channel in ipairs(lChannels) do
		self.m_Filters[channel] = true
	end
end

--true是有屏蔽，false是没有屏蔽
function CChatCtrl.IsAudioFilter(self, iChannel)
	return self.m_AudioFilters[iChannel]
end

function CChatCtrl.RefreshAudioChannel(self, lChannels)
	self.m_AudioFilters = {}
	for i, channel in ipairs(lChannels) do
		self.m_AudioFilters[channel] = true
	end
	IOTools.SetRoleData("audio_autoplay_channel", lChannels)
end

function CChatCtrl.SetAudioChannel(self, iChannel, bSet)
	local lChannels = IOTools.GetRoleData("audio_autoplay_channel") or {}
	local index = table.index(lChannels, iChannel)
	if bSet then
		if not index then
			table.insert(lChannels, iChannel)
		end
	else
		if index then
			table.remove(lChannels, index)
		end
	end
	self.m_AudioFilters[iChannel] = bSet
	IOTools.SetRoleData("audio_autoplay_channel", lChannels)
end

--设置帮派弹幕是否显示,0关闭 1显示
function CChatCtrl.SetOrgBarrage(self, isOpen)
	IOTools.SetRoleData("org_barrage", isOpen)
end

function CChatCtrl.GetOrgBarrage(self)
	local orgbarrage = IOTools.GetRoleData("org_barrage")
	if not orgbarrage then
		self:SetOrgBarrage(1)
	end
	return IOTools.GetRoleData("org_barrage")
end

-------------------以下是帮助消息发送，本地处理-------------------

function CChatCtrl.StartHelpTip(self)
	self.m_HelpTimer = Utils.AddTimer(callback(self, "SendHelpTip"), 120, 0)
end

function CChatCtrl.SendHelpTip(self)
	if #self.m_HelpTips == 0 then
		local helpConfig = {}
		for k,v in pairs(data.chatdata.HELP) do
			if g_AttrCtrl.grade <= v.level then
				table.insert(helpConfig,v.content)
			end
		end
		local tips = table.copy(helpConfig)
		self.m_HelpTips = table.shuffle(tips)
	end
	if next(self.m_HelpTips) then
		local tip = self.m_HelpTips[1]
		table.remove(self.m_HelpTips, 1)
		local dMsg = {
			channel = define.Channel.Help,
			text = tip,
		}
		g_ChatCtrl:AddMsg(dMsg)
	end
	return true
end

function CChatCtrl.ResetHelpTips(self)
	self.m_HelpTips = {}
end

----------------以下是发送协议和接口---------------

--获取文字表情要发言的频道(世界、当前、帮派、队伍)
function CChatCtrl.GetTextEmojiChannel(self)
	local iChannel = define.Channel.Current
	local oView = CChatMainView:GetView()
	if oView then
		local curChannel = oView.m_ChatPage.m_CurChannel
		if curChannel and table.index({define.Channel.World, define.Channel.Current, define.Channel.Org, define.Channel.Team}, curChannel) then
			if not self:CheckChannelLimit(curChannel) then
				iChannel = curChannel
			end
		end
	end
	return iChannel
end

--通用接口，判断某个频道(世界、当前、帮派、队伍)是否可发言
function CChatCtrl.CheckChannelLimit(self, iChannel)
	if not table.index({define.Channel.World, define.Channel.Current, define.Channel.Org, define.Channel.Team}, iChannel) then
		return true
	end
	if g_ChatCtrl:IsFilterChannel(iChannel) then
		return true
	end
	if iChannel == define.Channel.World then
		if tonumber(data.chatdata.CHATCONFIG[define.Channel.World].grade_limit) > g_AttrCtrl.grade then
			return true
		end
	elseif iChannel == define.Channel.Org then
		if not (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) then
			return true
		end
	elseif iChannel == define.Channel.Team then
		if not g_TeamCtrl:IsJoinTeam() then
			return true
		end
	end
end

--发送协议
function CChatCtrl.SendMsg(self, sMsg, iChannel)
	if not self:CheckSendLimit(sMsg, iChannel) then
		print("客户端限制发送", sMsg, iChannel)
		return false
	end
	if iChannel == define.Channel.Team and not g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl:FloatMsg("请先创建或加入队伍！")
		return false
	end
	local oAudioStr = ""
	local dAudioLink = LinkTools.FindLink(sMsg, "SpeechLink")
	if dAudioLink then
		oAudioStr = dAudioLink["sTranslate"]
	end
	local oStr2, oAudioCount = string.gsub(oAudioStr, "[^%d]?%d[^%d]?", "")

	local oNoLinkStr = string.gsub(sMsg, "%b{}", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "#%d%d?", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "#%u", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "#n", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "%[u%]", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "%[/u%]", "")
	oNoLinkStr = string.gsub(oNoLinkStr, "%@([%w_]-)%@", "")
	local oStr, oCount = string.gsub(oNoLinkStr, "[^%d]?%d[^%d]?", "")	

	--检测到连续的数字，要屏蔽掉，自己本地显示别人看不到
	if oCount > 4 or oAudioCount > 4 then
		local dMsg = {
			channel = iChannel,
			text = sMsg,
			role_info = {
				grade = g_AttrCtrl.grade,
				icon = g_AttrCtrl.icon,
				name = g_AttrCtrl.name,
				pid = g_AttrCtrl.pid,
				position = g_AttrCtrl.org_pos,
				title_info = ( (g_AttrCtrl.title_info and data.titledata.INFO[g_AttrCtrl.title_info.tid] and data.titledata.INFO[g_AttrCtrl.title_info.tid].in_chat == 1 ) and {g_AttrCtrl.title_info} or {nil})[1],
			}
		}
		g_ChatCtrl:AddMsg(dMsg)
	else
		--禁言判断
		local oCheckStr
		if dAudioLink then
			oCheckStr = oAudioStr
		else
			oCheckStr = oNoLinkStr
		end
		local bIsContain, oId = g_JinYanCtrl:IsContainMaskWordTwo(oCheckStr)
		if bIsContain then
			netchat.C2GSChat(sMsg, iChannel, oId)
		else
			netchat.C2GSChat(sMsg, iChannel)
		end
	end
	return true
end

--检查发送限制
function CChatCtrl.CheckSendLimit(self, sMsg, iChannel)
	if iChannel == define.Channel.World then
		-- local iOpen = math.max(math.min(g_AttrCtrl.server_grade-20), 40)
		-- if g_AttrCtrl.grade < iOpen then
		-- 	g_NotifyCtrl:FloatMsg(string.format("世界发言需要人物等级%d级", iOpen))
		-- 	return false
		-- end
		-- local iLimitTime = math.max(120,300-g_AttrCtrl.grade*2)
		-- local iRemain = iLimitTime - (g_TimeCtrl:GetTimeS() - self.m_LastWorldChatTime)
		-- if iRemain > 0 then
		-- 	g_NotifyCtrl:FloatMsg(string.format("发送失败，%d秒以后才能发言", iRemain))
		-- 	return false
		--end
	end
	return true
end

--获取所有聊天数据接口
function CChatCtrl.GetMsgList(self, iChannel, iStart)
	local list = {}
	local iStart = iStart or 0
	if self.m_ChannelMsgs[iChannel] then
		for i, id in ipairs(self.m_ChannelMsgs[iChannel]) do 
			if id > iStart then
				local oMsg = self.m_MsgObjs[id]
				oMsg["pos"] = id
				table.insert(list, oMsg)
			end
		end
	end
	return list
end

--获取是否被别人@了的接口
function CChatCtrl.GetIsOrgCall(self)
	return self.m_IsOrgCall
end

--设置是否被别人@了的接口
function CChatCtrl.SetIsOrgCall(self, bSet)
	self.m_IsOrgCall = bSet
end

--添加一条特殊消息到某个频道
function CChatCtrl.SendLimitMsg(self, iChannel)
	if iChannel == define.Channel.Team then
		if self.m_NeedLimitMsg["team"] and not g_TeamCtrl:IsJoinTeam() then
			local dMsg = {channel = iChannel,
			text = "请先创建或加入队伍！"..LinkTools.GenerateCreateTeamLink()}
			g_ChatCtrl:AddMsg(dMsg)
			self.m_NeedLimitMsg["team"] = false
		end
	else
	end
end

--设置特殊消息的接口
function CChatCtrl.SetSendLimitMsg(self, sType, b)
	self.m_NeedLimitMsg[sType] = b
end

--设置聊天box的复制文字按钮只能出现一个
function CChatCtrl.SetCopyBtnEvent(self, msgBox)
	self:OnEvent(define.Chat.Event.CopyMsg, msgBox)
end

--发送千里传音
function CChatCtrl.SendMilesMsg(self, sMsg, bubbleType)
	netchat.C2GSChuanYin(sMsg, bubbleType)
end
--千里传音，暂时没有用
function CChatCtrl.AddMilesMsg(self, sMsg)
	--printc(table.print(sMsg,"接收千里传音:"))
	--table.insert(self.m_MilesMsg, sMsg)
	self:FloatBubbleMsg(sMsg)
	self:OnEvent(define.Chat.Event.Chuanyin)
end
function CChatCtrl.ResetBubblePos(self)
	self:OnEvent(define.Chat.Event.SetChuanyinPos)
end
--暂时没有用
function CChatCtrl.SetLockRead(self, b)
	self.m_IsLockRead = b
end

--保存消息频道(6频道)的数据在本地
function CChatCtrl.SaveSysMessageData(self, s)
	local path = IOTools.GetPersistentDataPath("/Log/messagelog")
	IOTools.SaveTextFile(path, s)
end

--获取消息频道(6频道)的数据
--本地保存文件会把key变为字符串,{"12":1}
function CChatCtrl.GetSysMessageSaveData(self)
	if not next(self.m_MessageList) and not self.m_IsLoadMsgData then
		local path = IOTools.GetPersistentDataPath("/Log/messagelog")
		local s = IOTools.LoadTextFile(path) or ""
		local t = string.split(s, "\n")
		self.m_MessageList = t
		self.m_IsLoadMsgData = true
	end
end

--保存自己发送到聊天频道数据在本地
function CChatCtrl.SaveSelfChatMessageData(self, t)
	local path = IOTools.GetRoleFilePath("/selfchatmessage")
	IOTools.SaveJsonFile(path, t)
end

--获取自己发送到聊天频道数据
--本地保存文件会把key变为字符串,{"12":1}
function CChatCtrl.GetSelfChatMessageData(self)
	if not self.m_IsLoadSelfMessageData then
		self.m_SelfChatMessageList = {}
		local path = IOTools.GetRoleFilePath("/selfchatmessage")
		local t = IOTools.LoadJsonFile(path) or {}
		for k,v in pairs(t) do
			self.m_SelfChatMessageList[tonumber(k)] = v
		end
		self:CheckSelfChatMessageData()
		self.m_IsLoadSelfMessageData = true
	end	
end

function CChatCtrl.CheckSelfChatMessageData(self)
	if #self.m_SelfChatMessageList > 9 then
		for i = 10, #self.m_SelfChatMessageList do
			table.remove(self.m_SelfChatMessageList, i)
		end
	end
end

function CChatCtrl.FloatBubbleMsg(self, sMsg)
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_LB.m_ChatBox:FloatBubbleMsg(sMsg)
	end
end

--屏蔽玩家输入颜色(如[FF0000])
function CChatCtrl.BlockColorInput(self, inputStr)
	local length = #inputStr
    local str = inputStr
    local tempStr = {}
	for i = 1,length do
		tempStr[i] = string.sub(str,i,i)
		--printc("----:",tempStr[i])
	end
	--printc("长度：",length)
	local indexTable = {}
	for j = 1,length do
		if tempStr[j] == '[' and tempStr[j + 7] == ']'then
		   local colorStr = string.sub(str,j+1,j+6)
           local _,num = string.gsub(colorStr,"[^%x]","")
          -- printc(num,"位置：",j,colorStr)
           if num == 0 then
           	  indexTable[#indexTable + 1] = j
           end
		end
	end
	--table.print(indexTable,"---nihppp-")
	for i =1,#indexTable do
		local temp = indexTable[i] - 8*(i-1)
	    str = string.gsub(str,'%['..string.sub(str,temp+1,temp+6)..'%]',"") 
	    --printc(str)	
	end
	return str
end

function CChatCtrl.ClearUpChannelMsg(self, iChannel)
	g_ChatCtrl:ClearUpChannel(iChannel)
	local oView = CChatMainView:GetView()
	if oView and oView.m_CurChannel == iChannel then
		oView.m_ChatPage:RefreshAllMsg()
	end
end

function CChatCtrl.CheckColorInfoConfig(self)
	self.m_ItemColorConfig = {}
	for k,v in pairs(data.colorinfodata.ITEM) do
		self.m_ItemColorConfig[v.colorkey] = v
	end
end

---------------禁言处理相关-------------------

function CChatCtrl.GS2CAllForbinInfo(self, pbdata)
	self.m_JinYanWordList = {}
	-- self.m_JinYanWordHashList = {}
	for k,v in pairs(pbdata.forbids) do
		local oStrList = string.split(v.words, "|")
		for g,h in pairs(oStrList) do
			table.insert(self.m_JinYanWordList, {word = h, id = v.id})
			-- self.m_JinYanWordHashList[h] = {word = h, id = v.id}
		end
	end
	g_JinYanCtrl:InitMaskTree(self.m_JinYanWordList, true)
end

function CChatCtrl.GS2CAddForbinInfo(self, pbdata)
	self.m_JinYanWordAddList = {}
	for k,v in pairs(pbdata.forbids) do
		local oStrList = string.split(v.words, "|")
		for g,h in pairs(oStrList) do
			table.insert(self.m_JinYanWordList, {word = h, id = v.id})
			table.insert(self.m_JinYanWordAddList, {word = h, id = v.id})
			-- self.m_JinYanWordHashList[h] = {word = h, id = v.id}
		end
	end
	g_JinYanCtrl:InitMaskTree(self.m_JinYanWordAddList, false)
end

function CChatCtrl.GS2CRemoveForbinInfo(self, pbdata)
	for k,v in pairs(pbdata.forbids) do
		self:RemoveForBinById(v)
	end
	g_JinYanCtrl:InitMaskTree(self.m_JinYanWordList, true)
end

function CChatCtrl.RemoveForBinById(self, oId)
	for k,v in pairs(self.m_JinYanWordList) do
		if v.id == oId then
			table.remove(self.m_JinYanWordList, k)
		end
	end
end

--------------------替换颜色相关---------------------

function CChatCtrl.ReplaceColor(self, oText, bIsMainMenu)
	if bIsMainMenu then
		--替换为主界面左下角的专用颜色
		for sLink in string.gmatch(oText, "%@([%w_]-)%@") do
			local oStr = sLink
			if data.colorinfodata.OTHER[oStr] then
				if string.find(data.colorinfodata.OTHER[oStr].colormainmenu, "#") then
					oText = string.gsub(oText, "%@([%w_]-)%@", data.colorinfodata.OTHER[oStr].colormainmenu, 1)
				else
					oText = string.gsub(oText, "%@([%w_]-)%@", "["..data.colorinfodata.OTHER[oStr].colormainmenu.."]", 1)
				end
			elseif g_ChatCtrl.m_ItemColorConfig[oStr] then
				if string.find(g_ChatCtrl.m_ItemColorConfig[oStr].colormainmenu, "#") then
					oText = string.gsub(oText, "%@([%w_]-)%@", g_ChatCtrl.m_ItemColorConfig[oStr].colormainmenu, 1)
				else
					oText = string.gsub(oText, "%@([%w_]-)%@", "["..g_ChatCtrl.m_ItemColorConfig[oStr].colormainmenu.."]", 1)
				end
			end
		end
	else
		--替换为聊天的专用颜色
		for sLink in string.gmatch(oText, "%@([%w_]-)%@") do
			local oStr = sLink
			if data.colorinfodata.OTHER[oStr] then
				if string.find(data.colorinfodata.OTHER[oStr].colorchat, "#") then
					oText = string.gsub(oText, "%@([%w_]-)%@", data.colorinfodata.OTHER[oStr].colorchat, 1)
				else
					oText = string.gsub(oText, "%@([%w_]-)%@", "["..data.colorinfodata.OTHER[oStr].colorchat.."]", 1)
				end
			elseif g_ChatCtrl.m_ItemColorConfig[oStr] then
				if string.find(g_ChatCtrl.m_ItemColorConfig[oStr].colorchat, "#") then
					oText = string.gsub(oText, "%@([%w_]-)%@", g_ChatCtrl.m_ItemColorConfig[oStr].colorchat, 1)
				else
					oText = string.gsub(oText, "%@([%w_]-)%@", "["..g_ChatCtrl.m_ItemColorConfig[oStr].colorchat.."]", 1)
				end
			end
		end	
	end
	return oText
end

return CChatCtrl