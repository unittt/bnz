local CChatMainView = class("CChatMainView", CViewBase)
CChatMainView.g_LastChannel = nil
CChatMainView.g_LastInput = ""

function CChatMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/ChatMainView.prefab", cb)
end

--创建聊天主界面完毕回调
function CChatMainView.OnCreateView(self)
	self.m_ChatPage = self:NewUI(1, CChatScrollPage)
	self.m_ChannelGrid = self:NewUI(2, CGrid)
	self.m_Btns = {}
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_Contanier = self:NewUI(4, CWidget)
	self.m_ChannelBtnClone = self:NewUI(5, CBox)
	self.m_PreView = nil

	self:InitContent()

	local tween = self.m_Contanier:GetComponent(classtype.TweenPosition)
    tween.enabled = true
    self.m_Contanier:SetLocalPos(Vector3.New(-560, -15, 0))
    tween.from = Vector3.New(-560, -15, 0)
    tween.to = Vector3.New(0, -15, 0)
    tween.duration = 0.2
    tween:ResetToBeginning()
    -- tween.delay = define.Task.Time.MoveDown
    tween:PlayForward()
    tween.onFinished = function ()
        tween.enabled = false
        g_GuideCtrl:AddGuideUI("chatview_org_btn", self.m_Btns[define.Channel.Org])
		self:ResizeWindow()
    end
    g_ScreenResizeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "ResizeWindow"))
end

function CChatMainView.ResizeWindow(self)
	if C_api.ScreenResizeManager.Instance:IsNeedResize() then
        g_ScreenResizeCtrl:ResizePanel(self.m_GameObject)
        -- local bg = transform.Find("ModuleBgBoxCollider(Clone)")
        -- if bg ~= nil then
        --     C_api.ScreenResizeManager.Instance:ScreenFilling(bg.GetComponent<UIWidget>())
        -- end
    end
end

--初始化执行
function CChatMainView.InitContent(self)
	-- UITools.ResizeToRootSize(self.m_Contanier)
	self.m_ChannelBtnClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	local list = self:GetOpenChannels()
	for i, tInfo in ipairs(list) do
		local oBtn = self.m_ChannelBtnClone:Clone()
		local selectSp = oBtn:NewUI(1, CSprite)
		local descLbl = oBtn:NewUI(2, CLabel)
		local selLbl = oBtn:NewUI(3, CLabel)
		oBtn:SetActive(true)
		local text = define.Channel.Ch2Text[tInfo.send]
		descLbl:SetText(text)
		selLbl:SetText(text)
		
		-- if not(g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) and define.Channel.Org == tInfo.send then
		-- 	oBtn:SetGroup(8)
		-- 	selectSp:SetActive(false)
		-- else
		oBtn:SetGroup(self.m_ChannelGrid:GetInstanceID())
		-- 	selectSp:SetActive(true)
		-- end
		
		oBtn.m_ExtraReceives = tInfo.extra_receives or {}
		oBtn:AddUIEvent("click", callback(self, "SwitchChannel", tInfo.send))
		self.m_Btns[tInfo.send] = oBtn
		self.m_ChannelGrid:AddChild(oBtn)
	end
	if CChatMainView.g_LastChannel then
		self:SwitchChannel(CChatMainView.g_LastChannel)
	else
		self:SwitchChannel(define.Channel.World)
	end
	self.m_ChatPage.m_Input:SetText(CChatMainView.g_LastInput)
end

--获取开放的频道以及频道的顺序
function CChatMainView.GetOpenChannels(self)
	-- local t = {
	-- 	{send=define.Channel.Sys, 
	-- 	 extra_receives={
	-- 		define.Channel.Bulletin,
	-- 		define.Channel.Help,
	-- 		define.Channel.Rumour,}},
	-- 	{send=define.Channel.World,},
	-- 	{send=define.Channel.Org},
	-- 	{send=define.Channel.Current},
	-- 	{send=define.Channel.Team},		
	-- 	{send=define.Channel.Message},
	-- }
	local config = {}
	for k,v in pairs(data.chatdata.CHATCONFIG) do
		config[k] = v
	end
	table.sort(config, function (a,b) return a.sort < b.sort end)
	local channel = {}
	for k,v in ipairs(config) do
		if v.define == define.Channel.Sys then
			table.insert(channel,{send=define.Channel.Sys,
			extra_receives={define.Channel.Bulletin,define.Channel.Help,define.Channel.Rumour,}})
		else
			table.insert(channel,{send=v.define})
		end		
	end
	return channel
end

--切换到某个频道的通用接口
function CChatMainView.SwitchChannel(self, iChannel)
	-- if not(g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) and define.Channel.Org == iChannel then
	-- 	g_NotifyCtrl:FloatMsg("您还没加入任何帮派")
	-- 	return
	-- end
	if self:TurnToSysChannel(iChannel) then
		iChannel = self:TurnToSysChannel(iChannel)
	end
	if self.m_CurChannel ~= iChannel then
		-- printc("切换到频道:"..iChannel)
		self.m_CurChannel = iChannel
		local oBtn = self.m_Btns[iChannel]
		oBtn:SetSelected(true)
		self.m_ChatPage:SetExtraReceives(oBtn.m_ExtraReceives)
		self.m_ChatPage:SetChannel(iChannel)
		self.m_CurChannel = iChannel
	end
end

--转化一些特殊系统频道(如帮助，传闻等)为系统频道
function CChatMainView.TurnToSysChannel(self, iChannel)
	local channelList = {define.Channel.Bulletin,define.Channel.Help,define.Channel.Rumour,}
	if table.index(channelList, iChannel) then
		return define.Channel.Sys
	end
	return
end

-----------------下边是聊天界面和其他界面打开关闭相关------------------

function CChatMainView.CloseView(self)
	if Utils.IsNil(self) then
		return
	end
	if Utils.IsNil(self.m_Contanier) then
		if self.m_ChatPage then
			CChatMainView.g_LastInput = self.m_ChatPage.m_Input:GetText()
		end
		CChatMainView.g_LastChannel = self.m_CurChannel
		self:ResumePreviousView(true)
		CViewBase.CloseView(self)
	else
		local tween = self.m_Contanier:GetComponent(classtype.TweenPosition)
	    tween.enabled = true
	    tween.from = Vector3.New(0, -15, 0)
	    tween.to = Vector3.New(-560, -15, 0)
	    tween.duration = 0.2
	    tween:ResetToBeginning()
	    -- tween.delay = define.Task.Time.MoveDown
	    tween:PlayForward()
	    tween.onFinished = function ()
	        tween.enabled = false
	        if self.m_ChatPage then
				CChatMainView.g_LastInput = self.m_ChatPage.m_Input:GetText()
			end
			CChatMainView.g_LastChannel = self.m_CurChannel
			self:ResumePreviousView(true)
			CViewBase.CloseView(self)
	    end
	end
end

function CChatMainView.SetPreviousView(self, oView)
	oView:SetActive(false)
	self.m_PreView = oView
end

function CChatMainView.ResumePreviousView(self)
	if self.m_PreView then
		self.m_PreView:SetActive(true)
	end
end

function CChatMainView.OnClickClose(self)
	self:CloseView()
end

return CChatMainView