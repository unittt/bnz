local CChatAudioBox = class("CChatAudioBox", CBox)

function CChatAudioBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_AudioSpr = self:NewUI(4, CSprite)
	self.m_ClickBox = self:NewUI(5, CSprite)
	self.m_TimeLable = self:NewUI(6, CLabel)
	self.m_AudioSpr:SetSpriteName("#500_02")
	self.m_AudioSpr:PauseSpriteAnimation()
	self.m_Msg = nil
	
	g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

end

--语音协议返回，改变m_AudioSpr图片的状态
function CChatAudioBox.OnCtrlEvent(self, oCtrl)
	printc("oCtrl.m_EventData", oCtrl.m_EventData, ";self.m_AudioKey", self.m_AudioKey)
	if not oCtrl.m_EventData or not self.m_AudioKey then
		return
	end
	if oCtrl.m_EventData ~= self.m_AudioKey then
		self.m_AudioSpr:SetSpriteName("#500_02")
		self.m_AudioSpr:PauseSpriteAnimation()
		return
	end
	
	if oCtrl.m_EventID == define.Chat.Event.PlayAudio then
		-- printc("有播放语音通知下来")
		self.m_AudioSpr:SetSpriteName("#500_00")
		self.m_AudioSpr:StartSpriteAnimation()
	
	elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
		-- printc("有结束播放语音通知下来")
		self.m_AudioSpr:SetSpriteName("#500_02")
		self.m_AudioSpr:PauseSpriteAnimation()
	end
end

--根据消息来设置这条语音消息框的ui
function CChatAudioBox.SetMsg(self, oMsg)
	local dLink = oMsg:GetAudioLink()
	local sText = oMsg:GetText()
	local iType = oMsg:GetType()
	local prefixText, channel = oMsg:GetChannelPrefixText()	
	self.m_MsgLabel:SetRichText(dLink["sTranslate"])

	local channelMark = string.format("#chd<%d>", channel)
	
	-- local sName = "【"..oMsg:GetRoleInfo("name").."】"
	-- self.m_NameLabel:SetText(sName)
	local sName = "【"..oMsg:GetRoleInfo("name").."】"
	local titleConfig = data.titledata.INFO

	--帮派频道名字文本设置：优先称谓：玩家名-称谓 ; 没有称谓则：玩家名-帮派职位-荣誉称号
	if channel == define.Channel.Org then
		local iOrgPosition = oMsg:GetRoleInfo("position")		
		local OrgPosConfig = data.orgdata.POSITIONAUTHORITY[iOrgPosition]
		--屏蔽帮众显示
		if iOrgPosition == #data.orgdata.POSITIONAUTHORITY -1 then
			OrgPosConfig = nil
		end
		local iOrgHonor = oMsg:GetRoleInfo("honor")
		local OrgHonorConfig = data.orgdata.HONORID[iOrgHonor]
		local tTitleInfo = oMsg:GetRoleInfo("title_info")
		-- printc("帮派聊天，我的position:"..iOrgPosition)
		-- printc("帮派聊天，我的honor:"..iOrgHonor)
		local sNameDesc
		if tTitleInfo and next(tTitleInfo) and (tTitleInfo.tid ~= 0 or tTitleInfo.name ~= "") then			
			--优先称谓
			sNameDesc = self:GetPlayerName(oMsg)
		else
			sNameDesc = string.format("#F%s#n", sName)
			if iType == define.Chat.MsgType.Self then
				sNameDesc = string.format("#F%s#n", sName)..channelMark
			else
				sNameDesc = channelMark..string.format("#F%s#n", sName)
			end
			if OrgPosConfig and OrgHonorConfig then
				local sOrgPosition = OrgPosConfig.pos
				local sOrgHonor = OrgHonorConfig.name
				if iType == define.Chat.MsgType.Self then
					sNameDesc = string.format("#Q(%s)#n", sOrgHonor) .. string.format("#Q%s#n", sOrgPosition) .. " " .. string.format("#F%s#n", sName)..channelMark
				else
					sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format("#Q%s#n", sOrgPosition) .. string.format("#Q(%s)#n", sOrgHonor)
				end
			elseif not OrgPosConfig and OrgHonorConfig then
				local sOrgHonor = OrgHonorConfig.name
				if iType == define.Chat.MsgType.Self then
					sNameDesc = string.format("#Q%s#n", sOrgHonor) .. " " .. string.format("#F%s#n", sName)..channelMark
				else
					sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format("#Q%s#n", sOrgHonor)
				end
			elseif OrgPosConfig and not OrgHonorConfig then
				local sOrgPosition = OrgPosConfig.pos
				if iType == define.Chat.MsgType.Self then
					sNameDesc = string.format("#Q%s#n", sOrgPosition) .. " " .. string.format("#F%s#n", sName)..channelMark
				else
					sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format("#Q%s#n", sOrgPosition)
				end
			end
		end
		self.m_NameLabel:SetText(sNameDesc)
		
	else
	--其他频道名字文本设置：玩家名-称谓
		local sNameDesc = self:GetPlayerName(oMsg)
		self.m_NameLabel:SetText(sNameDesc)
	end

	self.m_ID = oMsg:GetRoleInfo("pid")
	self.m_AudioKey = dLink["sKey"]

	-- table.print(g_ChatCtrl.m_AutoPlayAudioList, "m_AutoPlayAudioList")
	-- printc("self.m_AudioKey", self.m_AudioKey)
	-- if dLink then
	-- 	local key = table.index(g_ChatCtrl.m_AutoPlayAudioList, self.m_AudioKey)
	-- 	if key then
	-- 		printc("自动播放语音")
	-- 		g_SpeechCtrl:PlayWithKey(self.m_AudioKey)
	-- 		table.remove(g_ChatCtrl.m_AutoPlayAudioList, key)
	-- 	end
	-- end

	local iTime = 1
	if dLink["iTime"] then
		iTime = tonumber(dLink["iTime"])
		if iTime > 30 then
			iTime = 30
		end
	end
	self.m_TimeLable:SetText(string.format("%d″", iTime))
	if iTime >= 30 then
		self.m_ClickBox:SetWidth(250)
	else
		if 250*(iTime/30) >= 45 then
			self.m_ClickBox:SetWidth(250*(iTime/30))
		else
			self.m_ClickBox:SetWidth(45)
		end
	end
	self.m_IconSpr:SpriteAvatar(oMsg:GetRoleInfo("icon"))
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	self.m_IconSpr:AddUIEvent("press", callback(self, "OnCallPlayer", oMsg:GetRoleInfo("pid"), oMsg:GetRoleInfo("name")))
	self.m_ClickBox:AddUIEvent("click", callback(self, "PlayAudio", dLink["sKey"]))
	self.m_MsgLabel:AddUIEvent("click", callback(self, "PlayAudio", dLink["sKey"]))

	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

--获取玩家的名字和称谓，格式：玩家名-称谓
function CChatAudioBox.GetPlayerName(self, oMsg)
	local iType = oMsg:GetType()
	local sNameDesc = self:GetPlayerNameByType(oMsg, iType)
	if iType == define.Chat.MsgType.Self then
		local oOriginName = sNameDesc
		local oOtherName = self:GetPlayerNameByType(oMsg, define.Chat.MsgType.Others)
		oOtherName = string.sub(oOtherName, 1, -3)
		oOtherName = string.gettitle(oOtherName, 44, "…")
		-- printc("1111111111", oOtherName)
		oOtherName = oOtherName.."#n"
		local oStart, oEnd = string.find(oOtherName, " #%u")
		local oStart2 = string.find(oOriginName, "#F")
		sNameDesc = (oStart and string.sub(oOtherName, oStart+1, -1) or "")..string.sub(oOriginName, oStart2, -1)
	else
		sNameDesc = string.sub(sNameDesc, 1, -3)
		sNameDesc = string.gettitle(sNameDesc, 44, "…")
		sNameDesc = sNameDesc.."#n"
	end
	return sNameDesc
end

function CChatAudioBox.GetPlayerNameByType(self, oMsg, oType)
	local tTitleInfo = oMsg:GetRoleInfo("title_info")
	local sName = "【"..oMsg:GetRoleInfo("name").."】"
	local iType = oType
	local titleConfig = data.titledata.INFO
	local prefixText, channel = oMsg:GetChannelPrefixText()
	local channelMark = string.format("#chd<%d>", channel)
	-- table.print(tTitleInfo,"聊天，我的title_info:")
	local sNameDesc = string.format("#F%s#n", sName)
	if iType == define.Chat.MsgType.Self then
		sNameDesc = string.format("#F%s#n", sName)..channelMark
	else
		sNameDesc = channelMark..string.format("#F%s#n", sName)
	end
	if tTitleInfo and next(tTitleInfo) then
		if tTitleInfo.tid and tTitleInfo.tid ~= 0 then
			if iType == define.Chat.MsgType.Self then
				sNameDesc = string.format(titleConfig[tTitleInfo.tid].text_color, titleConfig[tTitleInfo.tid].name) .. " " .. string.format("#F%s#n", sName)..channelMark
			else
				sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format(titleConfig[tTitleInfo.tid].text_color, titleConfig[tTitleInfo.tid].name)
			end
		end
		if tTitleInfo.name and tTitleInfo.name ~= "" then
			if iType == define.Chat.MsgType.Self then
				sNameDesc = string.format("#R%s#n", tTitleInfo.name) .. " " .. string.format("#F%s#n", sName)..channelMark
			else
				sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format("#R%s#n", tTitleInfo.name)
			end
		end
	end
	return sNameDesc
end

--点击这个语音消息框的语音条,播放语音,以一个key值播放
function CChatAudioBox.PlayAudio(self, sKey)
	g_SpeechCtrl:PlayWithKey(sKey)
end

--点击这个语音消息框的头像
function CChatAudioBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		netplayer.C2GSGetPlayerInfo(self.m_ID)
	end
end

--长按可以@玩家，现在只在帮派频道使用
function CChatAudioBox.OnCallPlayer(self, pid, name, oBtn, bPress)
	-- printc("长按可以@玩家")

	if bPress then
		if self.m_LongPressCallTimer then
			Utils.DelTimer(self.m_LongPressCallTimer)
			self.m_LongPressCallTimer = nil
		end
		local function count()
			if Utils.IsNil(self) then
				return false
			end
			if self.m_ID ~= g_AttrCtrl.pid then
				local oView = CChatMainView:GetView()
				if oView then
					if oView.m_ChatPage.m_CurChannel and oView.m_ChatPage.m_CurChannel == define.Channel.Org then
						local s = LinkTools.GenerateOrgPlayerCallLink(pid, name)
						if string.match(s, "%b{}") then
							oView.m_ChatPage.m_Input:ClearLink()
						end
						local sOri = oView.m_ChatPage.m_Input:GetText()
						oView.m_ChatPage.m_Input:SetText(sOri..s)
					end
				end
			end
			return false
		end
		self.m_LongPressCallTimer = Utils.AddTimer(count, 0, 1)
	else
		if self.m_LongPressCallTimer then
			Utils.DelTimer(self.m_LongPressCallTimer)
			self.m_LongPressCallTimer = nil
		end
	end
end

return CChatAudioBox