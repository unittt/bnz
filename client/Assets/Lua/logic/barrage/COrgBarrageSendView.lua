local COrgBarrageSendView = class("COrgBarrageSendView", CViewBase)

function COrgBarrageSendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Barrage/OrgBarrageSendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function COrgBarrageSendView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SendBox = self:NewUI(2, CBox)
	self.m_CountLbl = self:NewUI(3, CLabel)
	self.m_ItemBox = self:NewUI(4, CBox)
	self.m_ItemBox.m_IconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_DescLbl = self:NewUI(5, CLabel)
	self:SetSendBox()
	
	self:InitContent()
end

function COrgBarrageSendView.SetSendBox(self)
	self.m_SendBox.m_SpeenchBtn = self.m_SendBox:NewUI(1, CButton)
	self.m_SendBox.m_Input = self.m_SendBox:NewUI(2, CBarrageInput)
	self.m_SendBox.m_InputLbl = self.m_SendBox:NewUI(3, CLabel)
	self.m_SendBox.m_EmojiBtn = self.m_SendBox:NewUI(4, CButton)
	self.m_SendBox.m_SendBtn = self.m_SendBox:NewUI(5, CButton)
end

function COrgBarrageSendView.InitContent(self)
	-- self.m_SendBox.m_SpeenchBtn:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemTips"))
	self.m_SendBox.m_SpeenchBtn:AddUIEvent("press", callback(self, "OnSpeech"))
	self.m_SendBox.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_SendBox.m_SendBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	-- self.m_SendBox.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function COrgBarrageSendView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		self:RefreshUI()
	end
end

function COrgBarrageSendView.RefreshUI(self)
	self.m_CountLbl:SetText(g_ItemCtrl:GetBagItemAmountBySid(define.Barrage.OrgItem))
	self.m_ItemBox.m_IconSp:SpriteItemShape(DataTools.GetItemData(define.Barrage.OrgItem).icon)
	self.m_DescLbl:SetText(data.barragedata.TEXT[define.Barrage.Text.ItemTips].content)
end

------------------以下是点击事件--------------

--显示道具tips
function COrgBarrageSendView.OnClickItemTips(self)
	local args = {
        widget = self.m_ItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(define.Barrage.OrgItem, args)
end

function COrgBarrageSendView.OnSpeech(self, oBtn, bPress)
	if bPress then
		-- printc("COrgBarrageSendView.OnSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
	else
		-- printc("COrgBarrageSendView.OnSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function COrgBarrageSendView.StartRecord(self, oBtn)
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
			oView:SetRecordBtn(oBtn)
			oView:BeginRecord(nil, nil, 3, self, 6)
		end)
end

--结束录音
function COrgBarrageSendView.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		oView:EndRecord(nil, nil, 3)
	end
end

--点击表情按钮
function COrgBarrageSendView.OnEmoji(self)
	-- printc("COrgBarrageSendView.OnEmoji")
	COnlyEmojiView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
			-- oView:SetWidget(self.m_EmojiBtn)
		end
	)
end

--添加链接，只能有一个链接
function COrgBarrageSendView.AppendText(self, s)
	-- printc("COrgBarrageSendView.AppendText", s)
	if self.m_TipTimer then
		return
	end
	if string.match(s, "%b{}") then
		self.m_SendBox.m_Input:ClearLink()
	end
	local sOri = self.m_SendBox.m_Input:GetText()
	local _, count = string.gsub(sOri..s, "#%d+", "")
	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end

	self.m_SendBox.m_Input:SetText(sOri..s)
end

--点击发送按钮
function COrgBarrageSendView.OnSubmit(self)
	-- printc("COrgBarrageSendView.OnSubmit ")


	if g_AttrCtrl.org_status ~= COrgCtrl.ORG_STATUS_HAS_ORG then
		g_NotifyCtrl:FloatMsg("请先加入帮派! (＞﹏＜)")
		return 
	end

	if g_ItemCtrl:GetBagItemAmountBySid(define.Barrage.OrgItem) == 0 then 
		g_NotifyCtrl:FloatMsg("传音符数量不足! (＞﹏＜)")
		return 
	end 

	local sText = self.m_SendBox.m_Input:GetText()

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
 
	netbulletbarrage.C2GSOrgBulletBarrage(sText)
	self:CloseView()
	
end

return COrgBarrageSendView