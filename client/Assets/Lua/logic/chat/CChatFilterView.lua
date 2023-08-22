local CChatFilterView = class("CChatFilterView", CViewBase)

function CChatFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/ChatFilterView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CChatFilterView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_BoxGrid = self:NewUI(3, CGrid)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_AudioGrid = self:NewUI(5, CGrid)

	self:InitContent()
end

function CChatFilterView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_BoxClone:SetActive(false)
	local lChannels = {
		{channel=define.Channel.World, text="世界频道"},
		{channel=define.Channel.Team, text="队伍频道"},
		{channel=define.Channel.Message, text="消息频道"},
	}
	for i, dInfo in ipairs(lChannels) do
		local oBox = self.m_BoxClone:Clone()
		oBox:SetActive(true)
		oBox.m_SelBtn = oBox:NewUI(1, CButton)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		oBox.m_Channel = dInfo.channel
		oBox.m_SelBtn:SetSelected(g_ChatCtrl:IsFilterChannel(dInfo.channel))
		oBox.m_Label:AddUIEvent("click", callback(self, "SwitchSelected", oBox.m_SelBtn))
		oBox.m_Label:SetText(dInfo.text)
		self.m_BoxGrid:AddChild(oBox)
	end
	--暂时屏蔽
	--帮派弹幕是特殊处理
	 local oBox = self.m_BoxClone:Clone()
	 oBox:SetActive(true)
	 oBox.m_SelBtn = oBox:NewUI(1, CButton)
	 oBox.m_Label = oBox:NewUI(2, CLabel)
	 oBox.m_Channel = 10001
	 oBox.m_SelBtn:SetSelected(g_ChatCtrl:GetOrgBarrage() == 0)
	 oBox.m_Label:AddUIEvent("click", callback(self, "SwitchSelected", oBox.m_SelBtn))
	 oBox.m_Label:SetText("帮派弹幕")
	 self.m_BoxGrid:AddChild(oBox)

	local aChannels = {
		{channel=define.Channel.World, text="世界频道"},
		{channel=define.Channel.Team, text="队伍频道"},
		{channel=define.Channel.Org, text="帮派频道"},
	}
	for i, dInfo in ipairs(aChannels) do
		local oBox = self.m_BoxClone:Clone()
		oBox:SetActive(true)
		oBox.m_SelBtn = oBox:NewUI(1, CButton)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		oBox.m_Channel = dInfo.channel
		oBox.m_SelBtn:SetSelected(not g_ChatCtrl:IsAudioFilter(dInfo.channel))	
		oBox.m_Label:AddUIEvent("click", callback(self, "SwitchSelected", oBox.m_SelBtn))
		oBox.m_Label:SetText(dInfo.text)
		self.m_AudioGrid:AddChild(oBox)
	end
end

function CChatFilterView.SwitchSelected(self, oBtn)
	oBtn:SetSelected(not oBtn:GetSelected())
end

function CChatFilterView.OnConfirm(self)
	local list = {}
	local isOrgBarrageOpen = 1
	for i, oBox in ipairs(self.m_BoxGrid:GetChildList()) do
		if oBox.m_SelBtn:GetSelected() and oBox.m_Channel ~= 10001 then
			table.insert(list, oBox.m_Channel)
		elseif  oBox.m_SelBtn:GetSelected() and oBox.m_Channel == 10001 then
			isOrgBarrageOpen = 0
		end
	end
	g_ChatCtrl:RefreshFilterChannel(list)
	g_ChatCtrl:SetOrgBarrage(isOrgBarrageOpen)

	local audiolist = {}
	for i, oBox in ipairs(self.m_AudioGrid:GetChildList()) do
		if not oBox.m_SelBtn:GetSelected() then
			table.insert(audiolist, oBox.m_Channel)
		end
	end
	g_ChatCtrl:RefreshAudioChannel(audiolist)
	self:CloseView()
end

return CChatFilterView