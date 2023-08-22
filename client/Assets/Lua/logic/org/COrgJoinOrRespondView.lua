local COrgJoinOrRespondView = class("COrgJoinOrRespondView", CViewBase)

function COrgJoinOrRespondView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/JoinOrRespondOrgView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function COrgJoinOrRespondView.OnCreateView(self)
	self.m_TitleSpr = self:NewUI(1, CSprite)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TabBtnGrid = self:NewUI(3, CTabGrid)
	self.m_JoinPart = self:NewPage(4, COrgJoinPart)
	self.m_RespondPart = self:NewPage(5, COrgRespondPart)
	self.m_OrgGuideWidget = self:NewUI(6, CWidget)

	g_GuideCtrl:AddGuideUI("joinorgview_close_btn", self.m_CloseBtn)
	g_GuideCtrl:AddGuideUI("org_guide_widget", self.m_OrgGuideWidget)

	self:InitContent()

	self.m_JumpToRespond = false
end

function COrgJoinOrRespondView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- 分页按钮
	local groupid = self.m_TabBtnGrid:GetInstanceID()
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(groupid)
		if idx == 1 then
			g_AudioCtrl:SetRecordInfo(groupid, oBtn:GetInstanceID())
		end
		oBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)

	--TODO:tab和title的图片待替换
	self.m_PartInfoList = {
		{name = "join", title = "h7_join_org", part = self.m_JoinPart},
		{name = "respond", title = "h7_respond_org", part = self.m_RespondPart},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, v))
	end

    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))

end

function COrgJoinOrRespondView.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.GetRespondOrgList then
		if self.m_JumpToRespond then
			self:ShowSubPageByIndex(2)
		end
	end
end

function COrgJoinOrRespondView.ShowSubPageByIndex(self, tabIndex, args)
	if not args then
		args = self.m_PartInfoList[tabIndex]
	end
	if tabIndex == 2 then
		if self.m_JumpToRespond then
			self.m_JumpToRespond = false
			if #g_OrgCtrl.m_RespondOrgList <= 0 then
				g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1010].content)
				self:ShowSubPageByIndex(1)
				return
			end
		else
			-- netorg.C2GSReadyOrgList()  
			self.m_JumpToRespond = true
			return
		end
	end
	self.m_TitleSpr:SetSpriteName(args.title)
	self.m_TitleSpr:MakePixelPerfect()
	self.m_TabBtnGrid:SetTabSelect(args.btn)
	CGameObjContainer.ShowSubPageByIndex(self, tabIndex, args)
end

return COrgJoinOrRespondView