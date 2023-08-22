local CEmojiLinkView = class("CEmojiLinkView", CViewBase)

function CEmojiLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/EmojiLinkView.prefab", cb)

	-- self.m_ExtendClose = "ClickOut"
	-- self.m_BehindStrike = true
end

function CEmojiLinkView.OnCreateView(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_EmojiPart = self:NewPage(2, CChatEmojiPart)
	self.m_Container = self:NewUI(3, CWidget)
	self.m_TextBtn = self:NewUI(4, CButton)
	self.m_ItemPart = self:NewPage(5, CChatItemPart)
	self.m_SummonPart = self:NewPage(6, CChatSummonPart)
	self.m_AttrCardPart = self:NewPage(7, CChatAttrCardPart)
	self.m_AttrCardBtn = self:NewUI(8, CSprite)
	self.m_TaskPart = self:NewPage(9, CChatTaskPart)
	self.m_MessagePart = self:NewPage(10, CChatMessagePart)
	self.m_SkillPart = self:NewPage(11, CChatSkillPart)
	self.m_PartnerPart = self:NewPage(12, CChatPartnerPart)
	self.m_TitlePart = self:NewPage(13, CChatTitlePart)
	self.m_TextEmojiPart = self:NewPage(14, CChatTextEmojiPart)
	self.m_TextBtn:SetActive(false)
	local t = {"表情", "道具", "消息", "伙伴", "任务", "宠物", "技能", "称谓", "文字", "红包"} --
	for k, v in ipairs(t) do
		if v ~= "红包" or (v == "红包" and g_OpenSysCtrl:GetOpenSysState(define.System.RedPacket)) then
			local oBtn = self.m_TextBtn:Clone()
			-- oBtn:SetText(v)
			oBtn:SetSpriteName(self:GetIconName(v))
			if v == "消息" or v == "文字" then
				oBtn:SetSize(85, 55)
			else
				oBtn:SetSize(55, 58)
			end
			oBtn:SetActive(true)
			oBtn:SetGroup(self.m_BtnGrid:GetInstanceID())
			oBtn.m_Idx = k
			oBtn:AddUIEvent("click", callback(self, "ShowPart", v))
			self.m_BtnGrid:AddChild(oBtn)
		end
	end
	self.m_SendFunc = nil
	self:InitContent()

	if not (g_GuideCtrl.m_UpdateInfo.guide_type == g_GuideCtrl.m_OrgChatGuideType) then
		g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	end
end

function CEmojiLinkView.GetIconName(self, sName)
	if sName == "表情" then
		return "h7_biaoqing"
	elseif sName == "道具" then
		return "h7_baoguo"
	elseif sName == "宠物" then
		return "h7_chongwu"
	elseif sName == "伙伴" then
		return "h7_huoban"
	elseif sName == "任务" then
		return "h7_renwu_1"
	elseif sName == "技能" then
		return "h7_jineng"
	elseif sName == "消息" then
		return "h7_shurulishi"
	elseif sName == "红包" then
		return "h7_hongbao"
	elseif sName == "称谓" then
		return "h7_chengwei"
	elseif sName == "文字" then
		return "h7_wenzibiaoqing"
	else
		return "biaoqing"
	end
end

function CEmojiLinkView.ShowPart(self, sName)
	self.m_EmojiPart:HidePage()
	self.m_ItemPart:HidePage()
	self.m_SummonPart:HidePage()
	self.m_AttrCardPart:HidePage()
	self.m_TaskPart:HidePage()
	self.m_TitlePart:HidePage()
	if sName == "表情" then
		self:ShowSubPage(self.m_EmojiPart)
	elseif sName == "道具" then
		self:ShowSubPage(self.m_ItemPart)	
	elseif sName == "宠物" then
		self:ShowSubPage(self.m_SummonPart)
	elseif sName == "伙伴" then
		self:ShowSubPage(self.m_PartnerPart)
	elseif sName == "任务" then
		self:ShowSubPage(self.m_TaskPart)
	elseif sName == "技能" then
		self:ShowSubPage(self.m_SkillPart)
	elseif sName == "消息" then
		self:ShowSubPage(self.m_MessagePart)
	elseif sName == "红包" then
		self:CloseView()
		CChatMainView:CloseView()
		netredpacket.C2GSQueryAll(define.RedPacket.Channel.World)
	elseif sName == "称谓" then
		self:ShowSubPage(self.m_TitlePart)
	elseif sName == "文字" then
		self:ShowSubPage(self.m_TextEmojiPart)
	end
end

function CEmojiLinkView.InitContent(self)
	self.m_AttrCardBtn:SetGroup(self.m_BtnGrid:GetInstanceID())
	self.m_AttrCardBtn:AddUIEvent("click",function ()
		self:ShowSubPage(self.m_AttrCardPart)
	end)
	-- UITools.ResizeToRootSize(self.m_Container)
	self:ShowEmojiPart()
end

function CEmojiLinkView.ShowEmojiPart(self)
	self.m_BtnGrid:GetChild(1):SetSelected(true)
	self:ShowSubPage(self.m_EmojiPart)
end

function CEmojiLinkView.SetSendFunc(self, f)
	self.m_SendFunc = f
end

function CEmojiLinkView.Send(self, s, isClearInput)
	if self.m_SendFunc then
		self.m_SendFunc(s, isClearInput)
	end
end

function CEmojiLinkView.SetViewAnchor(self, left, bottom, right, top)
	self.m_Container:SetAnchorTarget(self.m_GameObject, 0, 0, 0, 0)
    self.m_Container:SetAnchor("leftAnchor", left, 0)
    self.m_Container:SetAnchor("bottomAnchor", bottom, 0)
    self.m_Container:SetAnchor("rightAnchor", right, 0)
    self.m_Container:SetAnchor("topAnchor", top, 0)
    self.m_Container:ResetAndUpdateAnchors()
end

return CEmojiLinkView