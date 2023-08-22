local CChatMsgBox = class("CChatMsgBox", CBox)

function CChatMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_OrgLabel = self:NewUI(4, CLabel)
	self.m_CopyBtn = self:NewUI(5, CButton)
	self.m_MsgKuangSp = self:NewUI(6, CSprite)
	self.m_Msg = nil
	self.m_MsgText = ""

	self.m_CopyBtn:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_CopyBtn, callback(self.m_CopyBtn, "SetActive", false))
	self.m_MsgLabel:AddUIEvent("press", callback(self, "OnLongPressMsg"))
	self.m_CopyBtn:AddUIEvent("click", callback(self, "OnTextCopy"))

	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

--有复制文字按钮出现了通知返回
function CChatMsgBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.CopyMsg then
		if oCtrl.m_EventData ~= self then
			self.m_CopyBtn:SetActive(false)
		end
	end
end

--设置这个聊天框的ui
function CChatMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	local iType = oMsg:GetType()
	local prefixText, channel = oMsg:GetChannelPrefixText()
	printc("chatbox设置sText"..sText.." prefixText"..prefixText)
	self.m_MsgLabel:SetRichText(prefixText)

	local sCountText = string.gettitle(sText, 24)
	local oStr2, oCount2 = string.gsub(sText, "#%d+", "")
	if oCount2 > 0 then
		self.m_MsgLabel:SetSpacingY(5)
	else
		self.m_MsgLabel:SetSpacingY(1)
	end
	local oStr, oCount = string.gsub(sCountText, "#%d+", "")
	if oCount > 0 then
		self.m_MsgKuangSp:SetAnchorTarget(self.m_MsgLabel.m_GameObject, 0, 0, 0, 0)		
		self.m_MsgKuangSp:SetAnchor("topAnchor", 12, 1)
        self.m_MsgKuangSp:SetAnchor("bottomAnchor", -10, 0)
        if iType == define.Chat.MsgType.Self then
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -12, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 12, 1)
        else
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -16, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 12, 1)
        end       
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	else
		self.m_MsgKuangSp:SetAnchorTarget(self.m_MsgLabel.m_GameObject, 0, 0, 0, 0)
		self.m_MsgKuangSp:SetAnchor("topAnchor", 8, 1)
        self.m_MsgKuangSp:SetAnchor("bottomAnchor", -10, 0)
        if iType == define.Chat.MsgType.Self then
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -12, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 12, 1)
        else
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -16, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 12, 1)
        end
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	end

	UITools.NearTarget(self.m_MsgLabel, self.m_CopyBtn, enum.UIAnchor.Side.Center)
	
	--这个是获取点击复制按钮时文本
	self.m_MsgText = LinkTools.GetPrintedText(sText)

	local channelMark = string.format("#chd<%d>", channel)
	
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
	self.m_OrgLabel:SetActive(false)	
	self.m_ID = oMsg:GetRoleInfo("pid")
	self.m_IconSpr:SpriteAvatar(oMsg:GetRoleInfo("icon"))
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	self.m_IconSpr:AddUIEvent("press", callback(self, "OnCallPlayer", oMsg:GetRoleInfo("pid"), oMsg:GetRoleInfo("name")))
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

--获取玩家的名字和称谓，格式：玩家名-称谓
function CChatMsgBox.GetPlayerName(self, oMsg)
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

function CChatMsgBox.GetPlayerNameByType(self, oMsg, oType)
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

--点击这个聊天框的头像按钮
function CChatMsgBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		netplayer.C2GSGetPlayerInfo(self.m_ID)
	end
end

--长按可以@玩家，现在只在帮派频道使用
function CChatMsgBox.OnCallPlayer(self, pid, name, oBtn, bPress)
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

--长按出现复制按钮
function CChatMsgBox.OnLongPressMsg(self, oBtn, bPress)
	if bPress then
		if self.m_LongPressMsgTimer then
			Utils.DelTimer(self.m_LongPressMsgTimer)
			self.m_LongPressMsgTimer = nil
		end
		local function count()
			if Utils.IsNil(self) then
				return false
			end
			self.m_CopyBtn:SetActive(true)
			g_ChatCtrl:SetCopyBtnEvent(self)
			UITools.NearTarget(self.m_MsgLabel, self.m_CopyBtn, enum.UIAnchor.Side.Center)
			return false
		end
		self.m_LongPressMsgTimer = Utils.AddTimer(count, 0, 1)
	else
		if self.m_LongPressMsgTimer then
			Utils.DelTimer(self.m_LongPressMsgTimer)
			self.m_LongPressMsgTimer = nil
		end
	end
end

--点击复制按钮
function CChatMsgBox.OnTextCopy(self)
	-- NGUI.NGUITools.clipboard = self.m_MsgText
	C_api.Utils.SetClipBoardText(self.m_MsgText)
	self.m_CopyBtn:SetActive(false)
end

return CChatMsgBox