local CUpdateNoticeView = class("CUpdateNoticeView", CViewBase)

function CUpdateNoticeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/UpdateNoticeView.prefab", cb)
	self.m_DepthType = "Fourth"
	self.m_ExtendClose = "Shelter"
end

function CUpdateNoticeView.OnCreateView(self)
	self.m_TipWidget = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	-- self.m_tipsDesc = self:NewUI(3, CLabel)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_tipBG = self:NewUI(5, CSprite)
	self.m_Table = self:NewUI(6, CTable)
	self.m_ItemClone = self:NewUI(7, CBox)

	self.m_LoginCb = nil

	self.m_ItemClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
end

function CUpdateNoticeView.RefreshUI(self, cb)
	g_UploadDataCtrl:SetDotUpload("14")
	self.m_LoginCb = cb
	-- if next(g_ServerPhoneCtrl.m_PostServerData) and g_ServerPhoneCtrl.m_PostServerData.info.server_info.infoList and next(g_ServerPhoneCtrl.m_PostServerData.info.server_info.infoList) then
	local oNoticeList = g_LoginPhoneCtrl:GetLocalUpdateNoticeFileData()
	if #oNoticeList <= 0 then
		g_NotifyCtrl:FloatMsg("暂无公告内容哦")
		self:OnClickClose()
		return
	end
	self:SetMessageList(oNoticeList)
	-- end	
end

function CUpdateNoticeView.SetMessageList(self, msgList)
	local optionCount = #msgList
	local GridList = self.m_Table:GetChildList() or {}
	local oMsg
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oMsg = self.m_ItemClone:Clone(false)
				-- self.m_Table:AddChild(oOptionBtn)
			else
				oMsg = GridList[i]
			end
			self:SetMessageBox(oMsg, msgList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Table:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CUpdateNoticeView.SetMessageBox(self, oMsg, oData)
	oMsg:SetActive(true)
	oMsg.m_TitleLbl = oMsg:NewUI(1, CLabel)
	oMsg.m_TitleBg = oMsg:NewUI(2, CSprite)
	oMsg.m_DescLbl = oMsg:NewUI(3, CLabel)

	oMsg.m_TitleLbl:SetRichText("[244B4E]"..oData.title)
	oMsg.m_DescLbl:SetRichText("[244B4E]"..(oData.content or ""))

	self.m_Table:AddChild(oMsg)
	self.m_Table:Reposition()
end

function CUpdateNoticeView.OnClickClose(self)
	g_UploadDataCtrl:SetDotUpload("15")
	if g_LoginPhoneCtrl:CheckIsVersionNew() then
		if self.m_LoginCb then
			self.m_LoginCb()
		end
		
		if g_ServerPhoneCtrl.m_PostServerData.info.server_info.notice_version then
			IOTools.SetClientData("loginphone_version", g_ServerPhoneCtrl.m_PostServerData.info.server_info.notice_version)
		end
	end
	--注意不能放置在函数前面，会销毁这个view的数据
	self:CloseView()
end

return CUpdateNoticeView