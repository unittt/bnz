local CBarrageSendBox = class("CBarrageSendBox", CBox)

function CBarrageSendBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Bg = self:NewUI(1, CSprite)
	self.m_SpeenchBtn = self:NewUI(2, CButton)
	self.m_Input = self:NewUI(3, CBarrageInput)
	self.m_InputLbl = self:NewUI(4, CLabel)
	self.m_EmojiBtn = self:NewUI(5, CButton)
	self.m_SendBtn = self:NewUI(6, CButton)

	self.m_state = 0

	self:AddEvent()

end

function CBarrageSendBox.AddEvent(self)

	self.m_SpeenchBtn:AddUIEvent("press", callback(self, "OnSpeech"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnSubmit"))

end


function CBarrageSendBox.OnSpeech(self, oBtn, bPress)
	if bPress then
		-- printc("CBarrageView.OnBattleSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
	else
		-- printc("CBarrageView.OnBattleSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CBarrageSendBox.StartRecord(self, oBtn)
	--printc("--------------------开始录音")
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
			oView:SetRecordBtn(oBtn)
			oView:BeginRecord(nil, nil, 1, self, 6)
		end)
end

--结束录音
function CBarrageSendBox.EndRecord(self)
	--printc("--------------------结束录音")
	local oView = CSpeechRecordView:GetView()
	if oView then
		oView:EndRecord(nil, nil, 1)
	end
end

--点击表情按钮
function CBarrageSendBox.OnEmoji(self)
	-- printc("---------------------添加表情")
	COnlyEmojiView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendBattleText"))
		end
	)
end


--添加链接，只能有一个链接
function CBarrageSendBox.AppendBattleText(self, s)

	if string.match(s, "%b{}") then
		self.m_Input:ClearLink()
	end
	local sOri = self.m_Input:GetText()
	local _, count = string.gsub(sOri..s, "#%d+", "")
	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end

	self.m_Input:SetText(sOri..s)
end

function CBarrageSendBox.SetState(self, state)
	self.m_State = state
end

--点击发送按钮
function CBarrageSendBox.OnSubmit(self)

	local sText = self.m_Input:GetText()

	local linkStr = {}
	for sLink in string.gmatch(sText, "%b{}") do
		table.insert(linkStr, sLink)
	end	
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	local iEmojiCnt = 0
	local function emoji(s)
		iEmojiCnt = iEmojiCnt + 1
		if iEmojiCnt > 5 then
			return string.sub(s, 5)
		else
			return s
		end
	end
	local count = 0
	sText, count = string.gsub(sText, "#%d+", emoji)
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = g_ChatCtrl:BlockColorInput(sText)
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	local index = 1
	for sLink in string.gmatch(sText, "%b{}") do
		if linkStr[index] then
			sText = string.replace(sText, sLink, linkStr[index])
		end
		index = index + 1
	end

	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end
	if not sText or sText == "" then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.NoInput].content)
		return
	end

	if self.m_State == define.Barrage.State.WatchWarOrWar then

		netbulletbarrage.C2GSWarBulletBarrage(sText)

	elseif self.m_State == define.Barrage.State.Plot then 

		if g_PlotCtrl.m_CurTriggerPlot then

			local curTime  = g_TimeCtrl:GetTimeS()
			--当前剧情播放到哪个时刻
			local moment =  curTime - g_PlotCtrl.m_StartTime
			moment = math.floor(moment)
			netbulletbarrage.C2GSStoryBulletBarrage(g_PlotCtrl.m_CurTriggerPlot, moment, sText)

			--自己的弹幕
			g_BarrageCtrl:InsertPlotData({name = g_AttrCtrl.name, msg = sText, isShowName = data.barragedata.GLOBAL[1].plot_showname == 1})

		end 

	end 

	self.m_Input:SetText("")
	
end


return CBarrageSendBox