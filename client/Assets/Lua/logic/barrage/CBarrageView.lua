local CBarrageView = class("CBarrageView", CViewBase)

function CBarrageView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Barrage/BarrageView.prefab", cb)
	--界面设置
	self.m_DepthType = "Barrage"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CBarrageView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_LabelClone = self:NewUI(3, CLabel)
	self.m_BattleBox = self:NewUI(4, CBox)
	self.m_PlotBox = self:NewUI(5, CBox)
	self.m_LabelNode = self:NewUI(6, CWidget)
	self:SetBattleBox()
	self:SetPlotBox()

	self.m_Test = false
	self.m_BattleOpenState = true
	self.m_BattleInputOpenState = false
	self.m_BattleWatchOpenState = true
	self.m_BattleWatchInputOpenState = false
	self.m_PlotOpenState = true
	self.m_OrgOpenState = true

	self.m_ChannelNum = data.barragedata.GLOBAL[1].showrow
	self.m_EachChannelItemNum = 3
	self.m_EachLabelTime = 8
	self.m_LabelIntervalTime = 1

	self.m_OriginOffsetX = 100

	local originHeight = UnityEngine.Screen.height - 150
	self.m_HeightList = {}
	for i = 1, self.m_ChannelNum do
		self.m_HeightList[i] = originHeight - ((i-1)*20)
	end

	self.m_LabelCacheList = {}
	self.m_TweenList = {}

	self.m_ChannelShowingList = {}
	for i=1, self.m_ChannelNum do
		self.m_ChannelShowingList[i] = {}
	end
	self.m_LastTextWidth = nil
	self.m_LastTimeMark = nil
	self.m_LastDelay = nil
	self.m_PartState = 1

	-- printc("CBarrageView.OnCreateView", data.barragedata.GLOBAL[1].battle_showname)


	self:InitContent()

end


function CBarrageView.SetBattleBox(self)
	self.m_BattleBox.m_SendBox = self.m_BattleBox:NewUI(1, CBox)
	self.m_BattleBox.m_SendBox.m_Bg = self.m_BattleBox.m_SendBox:NewUI(1, CSprite)
	self.m_BattleBox.m_SendBox.m_SpeenchBtn = self.m_BattleBox.m_SendBox:NewUI(2, CButton)
	self.m_BattleBox.m_SendBox.m_Input = self.m_BattleBox.m_SendBox:NewUI(3, CBarrageInput)
	self.m_BattleBox.m_SendBox.m_InputLbl = self.m_BattleBox.m_SendBox:NewUI(4, CLabel)
	self.m_BattleBox.m_SendBox.m_EmojiBtn = self.m_BattleBox.m_SendBox:NewUI(5, CButton)
	self.m_BattleBox.m_SendBox.m_SendBtn = self.m_BattleBox.m_SendBox:NewUI(6, CButton)
	self.m_BattleBox.m_OpenBtn = self.m_BattleBox:NewUI(2, CButton)

	self.m_BattleBox.m_ComeOutBtn = self.m_BattleBox:NewUI(3, CButton)
	self.m_BattleBox.m_ContentObj = self.m_BattleBox:NewUI(4, CObject)
	self.m_BattleBox.m_DescObj = self.m_BattleBox:NewUI(5, CObject)
end

function CBarrageView.SetPlotBox(self)
	self.m_PlotBox.m_SendBox = self.m_PlotBox:NewUI(1, CBox)
	self.m_PlotBox.m_SendBox.m_Bg = self.m_PlotBox.m_SendBox:NewUI(1, CSprite)
	self.m_PlotBox.m_SendBox.m_SpeenchBtn = self.m_PlotBox.m_SendBox:NewUI(2, CButton)
	self.m_PlotBox.m_SendBox.m_Input = self.m_PlotBox.m_SendBox:NewUI(3, CBarrageInput)
	self.m_PlotBox.m_SendBox.m_InputLbl = self.m_PlotBox.m_SendBox:NewUI(4, CLabel)
	self.m_PlotBox.m_SendBox.m_EmojiBtn = self.m_PlotBox.m_SendBox:NewUI(5, CButton)
	self.m_PlotBox.m_SendBox.m_SendBtn = self.m_PlotBox.m_SendBox:NewUI(6, CButton)
	self.m_PlotBox.m_OpenBtn = self.m_PlotBox:NewUI(2, CButton)
end

function CBarrageView.InitContent(self)
	self.m_LabelClone:SetActive(false)
	self.m_BattleBox:SetActive(false)
	self.m_PlotBox:SetActive(false)
	self.m_BattleBox.m_ContentObj:SetActive(false)
	self.m_BattleBox.m_ComeOutBtn:SetActive(true)
	self.m_BattleBox.m_DescObj:SetActive(true)

	self.m_Widget:GetComponent(classtype.BoxCollider).enabled = false

	self.m_BattleBox.m_SendBox.m_SpeenchBtn:AddUIEvent("press", callback(self, "OnBattleSpeech"))
	self.m_BattleBox.m_SendBox.m_EmojiBtn:AddUIEvent("click", callback(self, "OnBattleEmoji"))
	-- self.m_BattleBox.m_SendBox.m_Input:AddUIEvent("submit", callback(self, "OnBattleSubmit"))
	self.m_BattleBox.m_SendBox.m_SendBtn:AddUIEvent("click", callback(self, "OnBattleSubmit"))
	self.m_BattleBox.m_OpenBtn:AddUIEvent("click", callback(self, "OnClickOpenBattleBarrage"))
	self.m_BattleBox.m_ComeOutBtn:AddUIEvent("click", callback(self, "OnClickOpenBattleContent"))

	self.m_PlotBox.m_SendBox.m_SpeenchBtn:AddUIEvent("press", callback(self, "OnPlotSpeech"))
	self.m_PlotBox.m_SendBox.m_EmojiBtn:AddUIEvent("click", callback(self, "OnPlotEmoji"))
	-- self.m_PlotBox.m_SendBox.m_Input:AddUIEvent("submit", callback(self, "OnPlotSubmit"))
	self.m_PlotBox.m_SendBox.m_SendBtn:AddUIEvent("click", callback(self, "OnPlotSubmit"))
	self.m_PlotBox.m_OpenBtn:AddUIEvent("click", callback(self, "OnClickOpenPlotBarrage"))

	g_BarrageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CBarrageView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Barrage.Event.BattleBarrage then
		self:RefreshBattleUI()
	elseif oCtrl.m_EventID == define.Barrage.Event.OrgBarrage then
		self:RefreshOrgUI()
	end
end

function CBarrageView.RefreshEmptyUI(self)
	self.m_BattleBox:SetActive(false)
	self.m_PlotBox:SetActive(false)
end

--打开自己战斗界面时的弹幕ui
function CBarrageView.RefreshBattleUI(self, bResetData)
	self.m_PartState = 1
	self.m_BattleBox:SetActive(true)
	self.m_PlotBox:SetActive(false)
	self:CheckBattleOpenState()
	self:CheckBattleInputOpenState()
	self.m_BattleBox.m_SendBox.m_Input:SetText("")

	if bResetData then
		self:ResetDataAndUI()
	end

	if self.m_Test then
		g_BarrageCtrl.m_TextDataList = {}
		for k,v in ipairs(self:GetTextList()) do
			local list = {}
			table.copy(v, list)
			g_BarrageCtrl.m_TextId = g_BarrageCtrl.m_TextId + 1
			list.textid = g_BarrageCtrl.m_TextId
			table.insert(g_BarrageCtrl.m_TextDataList, list)
		end
	end

	-- if self.m_TreasureTimer then
	-- 	Utils.DelTimer(self.m_TreasureTimer)
	-- 	self.m_TreasureTimer = nil
	-- end

	local data = g_BarrageCtrl.m_TextDataList[1]
	if next(g_BarrageCtrl.m_TextDataList) and data and ((not g_BarrageCtrl.m_MovingList[data.textid] and g_BarrageCtrl.m_MovingList[data.textid-1]) or not next(g_BarrageCtrl.m_MovingList)) then
		local channel, pos
		if self.m_Test then
			channel, pos = self:CheckChannelShowingList()
		else
			channel, pos = self:CheckChannelShowingList()
		end
		
		table.remove(g_BarrageCtrl.m_TextDataList, 1)
		self:AddLabel(data, channel, pos)
		
		-- local function set()
		-- 	if Utils.IsNil(self) then
		-- 		return false
		-- 	end
		-- 	local delay = 0
		-- 	local ratio = 1 / 70
		-- 	if self.m_LastTextWidth then
		-- 		delay = ratio * self.m_LastTextWidth
		-- 	else
		-- 		delay = 0
		-- 	end
		-- 	local function delayfunc()
		-- 		if Utils.IsNil(self) then
		-- 			return false
		-- 		end
				
		-- 		return false
		-- 	end
		-- 	Utils.AddTimer(delayfunc, 0, delay)	
			
		-- 	if not next(g_BarrageCtrl.m_TextDataList) then
		-- 		if self.m_TreasureTimer then
		-- 			Utils.DelTimer(self.m_TreasureTimer)
		-- 			self.m_TreasureTimer = nil
		-- 			return false
		-- 		end
		-- 	end
		-- 	return true
		-- end
		-- if not self.m_TreasureTimer then
		-- 	self.m_TreasureTimer = Utils.AddTimer(set, self.m_LabelIntervalTime, self.m_LabelIntervalTime)
		-- end
	end
end

--重置数据和ui
function CBarrageView.ResetDataAndUI(self)
	--管理数据
	self.m_ChannelShowingList = {}
	for i=1, self.m_ChannelNum do
		self.m_ChannelShowingList[i] = {}
	end

	--管理ui
	self.m_LabelCacheList = {}
	local GridList = self.m_Grid:GetChildList() or {}
	for k,v in ipairs(GridList) do
		v:SetActive(false)
		v:SetPos(self:GetWorldPos(Vector3.New(UnityEngine.Screen.width + self.m_OriginOffsetX, 0, 0)))
		local list = {id = v:GetInstanceID(), obj = v}
		table.insert(self.m_LabelCacheList, list)
	end

	for k,v in pairs(self.m_TweenList) do
		v:Kill(false)
	end
	self.m_TweenList = {}
end

--打开自己观战界面时的弹幕ui
function CBarrageView.RefreshBattleWatchUI(self)
	self.m_PartState = 1
	self.m_PlotBox:SetActive(false)
	self.m_BattleBox.m_ComeOutBtn:SetActive(false)
	self.m_BattleBox.m_DescObj:SetActive(false)
	self.m_BattleBox.m_OpenBtn:SetActive(false)
	self:CheckBattleWatchOpenState()
	self:CheckBattleWatchInputOpenState()
	self.m_BattleBox.m_SendBox.m_Input:SetText("")
end

--打开自己剧情时的弹幕ui
function CBarrageView.RefreshPlotUI(self)
	self.m_PartState = 2
	self.m_BattleBox:SetActive(false)
	self.m_PlotBox:SetActive(true)
	self:CheckPlotOpenState()
	self.m_PlotBox.m_SendBox.m_Input:SetText("")
end

--打开帮派的弹幕ui
function CBarrageView.RefreshOrgUI(self)
	self.m_PartState = 3
	self.m_BattleBox:SetActive(false)
	self.m_PlotBox:SetActive(false)
	self:SetOrgOpenState(g_ChatCtrl:GetOrgBarrage() == 1)
	self:CheckOrgOpenState()

	local data = g_BarrageCtrl.m_TextDataList[1]
	if next(g_BarrageCtrl.m_TextDataList) and data and ((not g_BarrageCtrl.m_MovingList[data.textid] and g_BarrageCtrl.m_MovingList[data.textid-1]) or not next(g_BarrageCtrl.m_MovingList)) then
		local channel, pos = self:CheckChannelShowingList()
		
		table.remove(g_BarrageCtrl.m_TextDataList, 1)
		self:AddLabel(data, channel, pos)
	end
end

--设置一条条弹幕ui
function CBarrageView.SetLabelList(self)
	
end

--设置一条条弹幕ui
function CBarrageView.AddLabel(self, oData, channel, pos)
	local oLabel
	if next(self.m_LabelCacheList) then
		oLabel = self.m_LabelCacheList[1].obj
		table.remove(self.m_LabelCacheList, 1)
	else
		oLabel = self.m_LabelClone:Clone(false)
	end

	self:SetLabelBox(oLabel, oData, channel, pos)
end

--设置一条条弹幕ui
function CBarrageView.SetLabelBox(self, oLabel, oData, channel, pos)
	oLabel:SetActive(true)
	local sName = oData.value
	if self.m_PartState == 1 and data.barragedata.GLOBAL[1].battle_showname == 1 and oData.name ~= "" then
		sName = oData.name..":"..oData.value
	end
	if self.m_PartState == 2 and data.barragedata.GLOBAL[1].plot_showname == 1 and oData.name ~= "" then
		sName = oData.name..":"..oData.value
	end
	if self.m_PartState == 3 and data.barragedata.GLOBAL[1].org_showname == 1 and oData.name ~= "" then
		sName = oData.name..":"..oData.value
	end
	oLabel:SetRichText(string.format(data.colorinfodata.OTHER.barrage.color, sName))
	self.m_Grid:AddChild(oLabel, true)

	table.insert(self.m_ChannelShowingList[channel], oData)
	-- self.m_ChannelShowingList[channel][pos] = oData
	--真正有用的是channel
	oLabel:SetPos(self:GetWorldPos(Vector3.New(UnityEngine.Screen.width + self.m_OriginOffsetX, self.m_HeightList[channel], 0)))
	
	local function movestart()
		-- oLabel:SetActive(true)
		self.m_LastTimeMark = g_TimeCtrl:GetTimeS()
		g_BarrageCtrl.m_MovingList[oData.textid] = true
		if next(g_BarrageCtrl.m_TextDataList) and g_BarrageCtrl.m_MovingList[oData.textid] and not g_BarrageCtrl.m_MovingList[oData.textid+1] then
			local channel1, pos1
			if self.m_Test then
				channel1, pos1 = self:CheckChannelShowingList()
			else
				channel1, pos1 = self:CheckChannelShowingList()
			end
			local data = g_BarrageCtrl.m_TextDataList[1]
			table.remove(g_BarrageCtrl.m_TextDataList, 1)
			self:AddLabel(data, channel1, pos1)
		end		
	end

	local function moveend()
		--管理数据
		-- table.remove(self.m_ChannelShowingList[channel], pos)
		-- self.m_ChannelShowingList[channel][pos] = nil
		for k,v in pairs(self.m_ChannelShowingList[channel]) do
			if v.textid == oData.textid then
				table.remove(self.m_ChannelShowingList[channel], k)
				break
			end
		end
		
		--管理ui
		oLabel:SetActive(false)
		local index = self:GetIsLabelCacheExist(oLabel:GetInstanceID())
		local list = {id = oLabel:GetInstanceID(), obj = oLabel}
		if index then
			table.remove(self.m_LabelCacheList, index)
			table.insert(self.m_LabelCacheList, index, list)
		else		
			table.insert(self.m_LabelCacheList, list)
		end
	end

	local Width = UITools.CalculateRelativeWidgetBounds(oLabel.m_Transform).size.x
	local lastwidth = self.m_LastTextWidth == nil and 0 or self.m_LastTextWidth
	local tweentime = 0
	local ratio = 1 / 120 --self.m_EachLabelTime/(UnityEngine.Screen.width)
	local delaytime = (ratio *  (Width+UnityEngine.Screen.width))
	if delaytime <= 0 then
		tweentime = 0
	else
		tweentime = delaytime
	end

	--delay上一个text从delay到开始理论用时
	local delay = 0
	if self.m_LastTextWidth then
		delay = ratio * self.m_LastTextWidth
		if delay > 10 then
			delay = 10
		elseif delay < 2 then
			-- delay = 2
		end
	else
		delay = 0
	end
	--deltatime上一个text到现在的text的时间实际的间隔用时
	if self.m_LastTimeMark then
		local deltatime = g_TimeCtrl:GetTimeS() - self.m_LastTimeMark
		if deltatime > 0 then
			local compare = delay - deltatime
			if compare < 0 then
				delay = 0
			end
		end
	end
	-- printc("CBarrageView.SetLabelBox m_LastTextWidth" ..lastwidth, " delay", delay, " tweentime"..tweentime.. " cur Width"..Width, " channel"..channel, " height"..self.m_HeightList[channel])
	
	local tween = DOTween.DOLocalMoveX(oLabel.m_Transform, -UnityEngine.Screen.width - Width, tweentime)
	self.m_LastTextWidth = Width
	self.m_LastDelay = delay
	table.insert(self.m_TweenList, tween)
	DOTween.SetDelay(tween, delay)
	DOTween.SetEase(tween, 1)
	DOTween.OnStart(tween, movestart)
	DOTween.OnComplete(tween, moveend)
end

--获取是否有没使用的obj
function CBarrageView.GetIsLabelCacheExist(self, id)
	for k,v in ipairs(self.m_LabelCacheList) do
		if v.id == id then
			return k
		end
	end
	return false
end

--检查设置一条条弹幕的数据，应该插入到哪个位置，时刻在变
function CBarrageView.CheckChannelShowingList(self, limitRow)
	local channel = 1
	local pos = 1
	if not limitRow then
		for i=1, self.m_ChannelNum do
			if table.count(self.m_ChannelShowingList[i]) < self.m_EachChannelItemNum then
				for j=1, self.m_EachChannelItemNum do
					if not self.m_ChannelShowingList[i][j] then
						pos = j
						break
					end
				end
				channel = i
				break
			end
		end
	else
		channel = limitRow
	end
	return channel, pos
end

function CBarrageView.GetTextList(self)
	if self.m_Test then
		local list = {
			{name = "", value = "红红火火"},
			{name = "", value = "哈哈哈哈哈哈哈了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			{name = "", value = "哼哼哈哈呵呵呵"},
			{name = "", value = "吼吼吼吼吼吼吼吼吼"},
			{name = "", value = "hhhhhhh"},
			{name = "", value = "gg"},
			{name = "", value = "6666666666666666"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的了多少积分角度考虑的"},
			{name = "", value = "吼吼吼吼吼吼吼吼吼"},
			{name = "", value = "吼吼吼吼吼吼吼吼吼"},
			{name = "", value = "吼吼吼吼吼吼吼吼吼"},
			{name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
			-- {name = "", value = "吼吼吼吼吼吼吼吼吼"},
		}
		return list
	end
end

--[[
function CBarrageView.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

]]

----------------以下是点击事件--------------

--------------以下是战斗界面相关--------------

function CBarrageView.OnBattleSpeech(self, oBtn, bPress)
	if bPress then
		-- printc("CBarrageView.OnBattleSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartBattleRecord(oBtn)
	else
		-- printc("CBarrageView.OnBattleSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndBattleRecord()
	end
end

--开始录音
function CBarrageView.StartBattleRecord(self, oBtn)
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
			oView:SetRecordBtn(oBtn)
			oView:BeginRecord(nil, nil, 1, self, 6)
		end)
end

--结束录音
function CBarrageView.EndBattleRecord(self)
	local oView = CSpeechRecordView:GetView()
	if oView then
		oView:EndRecord(nil, nil, 1)
	end
end

--点击表情按钮
function CBarrageView.OnBattleEmoji(self)
	-- printc("CBarrageView.OnBattleEmoji")
	COnlyEmojiView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendBattleText"))
			-- oView:SetWidget(self.m_BattleBox.m_EmojiBtn)
		end
	)
end

--添加链接，只能有一个链接
function CBarrageView.AppendBattleText(self, s)
	-- printc("CBarrageView.AppendBattleText", s)
	if self.m_TipTimer then
		return
	end
	if string.match(s, "%b{}") then
		self.m_BattleBox.m_SendBox.m_Input:ClearLink()
	end
	local sOri = self.m_BattleBox.m_SendBox.m_Input:GetText()
	local _, count = string.gsub(sOri..s, "#%d+", "")
	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end

	self.m_BattleBox.m_SendBox.m_Input:SetText(sOri..s)
end

--点击发送按钮
function CBarrageView.OnBattleSubmit(self)
	-- printc("CBarrageView.OnBattleSubmit ")
	local sText = self.m_BattleBox.m_SendBox.m_Input:GetText()

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

	netbulletbarrage.C2GSWarBulletBarrage(sText)
end

----------------以下是剧情相关-------------

function CBarrageView.OnPlotSpeech(self, oBtn, bPress)
	if bPress then
		-- printc("CBarrageView.OnPlotSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartPlotRecord(oBtn)
	else
		-- printc("CBarrageView.OnPlotSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndPlotRecord()
	end
end

--开始录音
function CBarrageView.StartPlotRecord(self, oBtn)
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
			oView:SetRecordBtn(oBtn)
			oView:BeginRecord(nil, nil, 2, self, 6)
		end)
end

--结束录音
function CBarrageView.EndPlotRecord(self)
	local oView = CSpeechRecordView:GetView()
	if oView then
		oView:EndRecord(nil, nil, 2)
	end
end

--点击表情按钮
function CBarrageView.OnPlotEmoji(self)
	-- printc("CBarrageView.OnPlotEmoji ")
	COnlyEmojiView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendPlotText"))
			-- oView:SetWidget(self.m_PlotBox.m_EmojiBtn)
		end
	)
end

--添加链接，只能有一个链接
function CBarrageView.AppendPlotText(self, s)
	-- printc("CBarrageView.AppendPlotText ")
	if self.m_TipTimer then
		return
	end
	if string.match(s, "%b{}") then
		self.m_PlotBox.m_SendBox.m_Input:ClearLink()
	end
	local sOri = self.m_PlotBox.m_SendBox.m_Input:GetText()
	local _, count = string.gsub(sOri..s, "#%d+", "")
	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end

	self.m_PlotBox.m_SendBox.m_Input:SetText(sOri..s)
end

--点击发送按钮
function CBarrageView.OnPlotSubmit(self)
	-- printc("CBarrageView.OnPlotSubmit ")
	local sText = self.m_PlotBox.m_SendBox.m_Input:GetText()

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
end

----------------战斗界面状态------------

function CBarrageView.OnClickOpenBattleBarrage(self)
	self.m_BattleOpenState = not self.m_BattleOpenState
	self:CheckBattleOpenState()
end

function CBarrageView.CheckBattleOpenState(self)
	if self.m_BattleOpenState then
		self.m_BattleBox.m_OpenBtn:SetSelected(true)
		self.m_Grid:SetActive(true)
	else
		self.m_BattleBox.m_OpenBtn:SetSelected(false)
		self.m_Grid:SetActive(false)
	end
end

function CBarrageView.OnClickOpenBattleContent(self)
	self.m_BattleInputOpenState = not self.m_BattleInputOpenState
	self:CheckBattleInputOpenState()
end

function CBarrageView.CheckBattleInputOpenState(self)
	if self.m_BattleInputOpenState then
		self.m_BattleBox.m_ContentObj:SetActive(true)
	else
		self.m_BattleBox.m_ContentObj:SetActive(false)
	end
end

---------------观战界面状态-----------------

function CBarrageView.SetBattleWatchOpenState(self, bIsOpen)
	self.m_BattleWatchOpenState = bIsOpen
	self:CheckBattleWatchOpenState()
end

function CBarrageView.CheckBattleWatchOpenState(self)
	if self.m_BattleWatchOpenState then
		self.m_Grid:SetActive(true)
	else
		self.m_Grid:SetActive(false)
	end
end

function CBarrageView.SetBattleWatchInputOpenStatee(self, bIsOpen)
	self.m_BattleWatchInputOpenState = bIsOpen
	self:CheckBattleWatchInputOpenState()
end

function CBarrageView.CheckBattleWatchInputOpenState(self)
	if self.m_BattleWatchInputOpenState then
		self.m_BattleBox.m_SendBox:SetActive(true)
	else
		self.m_BattleBox.m_SendBox:SetActive(false)
	end
end

---------------剧情界面状态-------------

function CBarrageView.OnClickOpenPlotBarrage(self)
	self.m_PlotOpenState = not self.m_PlotOpenState
	self:CheckPlotOpenState()
end

function CBarrageView.CheckPlotOpenState(self)
	if self.m_PlotOpenState then
		self.m_PlotBox.m_OpenBtn:SetSelected(true)
		self.m_Grid:SetActive(true)
	else
		self.m_PlotBox.m_OpenBtn:SetSelected(false)
		self.m_Grid:SetActive(false)
	end
end

--------------帮派状态--------------

function CBarrageView.SetOrgOpenState(self, bIsOpen)
	self.m_OrgOpenState = bIsOpen
	self:CheckOrgOpenState()
end

function CBarrageView.CheckOrgOpenState(self)
	if self.m_OrgOpenState then
		self.m_Grid:SetActive(true)
	else
		self.m_Grid:SetActive(false)
	end
end

return CBarrageView