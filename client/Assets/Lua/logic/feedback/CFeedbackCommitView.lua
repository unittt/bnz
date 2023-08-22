local CFeedbackCommitView = class("CFeedbackCommitView", CViewBase)

function CFeedbackCommitView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Feedback/FeedbackCommitView.prefab", cb)
	--self.m_GroupName = "main"
    self.m_ExtendClose = "Shelter"
    self.m_SelectType = 1
    self.m_ImageCount = 0
end

function CFeedbackCommitView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TagGrid = self:NewUI(2, CGrid)
	self.m_DescInput = self:NewUI(3, CInput)

	self.m_QQInput = self:NewUI(4, CInput)
	self.m_PhoneNumInput = self:NewUI(5, CInput)
	self.m_CommitBtn = self:NewUI(6, CButton)

	self.m_ImageBtnGrid = self:NewUI(7, CGrid)
	self.m_ImageBtnClone = self:NewUI(8, CButton)
	self.m_AddImageBtn = self:NewUI(9, CButton, true, false)

	self.m_ImagePreview = self:NewUI(10, CBox)
	self.m_PreviewCloseBtn = self.m_ImagePreview:NewUI(1, CButton)
	self.m_ImageScrollView = self.m_ImagePreview:NewUI(2, CScrollView)
	self.m_ImageGrid = self.m_ImagePreview:NewUI(3, CGrid)
	self.m_EmptyPart = self.m_ImagePreview:NewUI(4, CSprite)
	self.m_AddImagePart = self.m_ImagePreview:NewUI(5, CButton, true, false)
	self.m_ImagePart = self.m_ImagePreview:NewUI(6, CBox)

	self:InitContent()
end

function CFeedbackCommitView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommitBtn:AddUIEvent("click", callback(self, "OnCommit"))
	self.m_PreviewCloseBtn:AddUIEvent("click", callback(self, "OnClosePreview"))
	self.m_AddImagePart:AddUIEvent("click", callback(self, "OnAddImage"))

	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOpenSysEvent"))

	local groupId = self.m_TagGrid:GetInstanceID()
	local function Init(obj, idx)
		local oBtn = CSprite.New(obj)
		oBtn:SetGroup(groupId)
		oBtn:AddUIEvent("click", callback(self, "OnTagSelect", idx))
		return oBtn  
	end

	self.m_TagGrid:InitChild(Init)
	self.m_TagGrid:GetChild(1):SetSelected(true)

	self:RefreshImageGrid()

	self.m_DescInput:SetLimitLen(1000)
	self.m_DescInput:SetDefaultText("请详细描述您的问题，1000个字符以内")

	self.m_QQInput:SetLimitLen(10)
	self.m_QQInput:SetPermittedChars("0", "9")
	self.m_QQInput:SetDefaultText("非必填，只能填写数字")

	self.m_PhoneNumInput:SetLimitLen(11)
	self.m_PhoneNumInput:SetPermittedChars("0", "9")
	self.m_PhoneNumInput:SetDefaultText("非必填，只能填写数字")
end

function CFeedbackCommitView.RefreshImageGrid(self)
	self.m_ImageBtnGrid:Clear()

	if self.m_ImageCount > 0 then
		for i = 1, self.m_ImageCount do
			local oImgBtnClone = self.m_ImageBtnGrid:GetChild(i)
			if oImgBtnClone == nil then
				oImgBtnClone = self.m_ImageBtnClone:Clone(false)
				oImgBtnClone:SetActive(true)
				oImgBtnClone:AddUIEvent("click", callback(self, "OnShowImagePreview"))
				self.m_ImageBtnGrid:AddChild(oImgBtnClone)
			end
			oImgBtnClone:SetText("图片"..i)
		end
	end

	--如果图片数量已有3张,不在显示添加按钮
	if self.m_ImageCount < 3 then
		local oImgAddBtn = self.m_AddImageBtn:Clone(false)
		oImgAddBtn:SetActive(true)
		oImgAddBtn:AddUIEvent("click", callback(self, "OnAddImage"))
		self.m_ImageBtnGrid:AddChild(oImgAddBtn)
	end

	self.m_ImageBtnGrid:Reposition()
end

function CFeedbackCommitView.OnClosePreview(self)
	self.m_ImagePreview:SetActive(false)
end

function CFeedbackCommitView.OnShowImagePreview(self)
	if not self.m_ImagePreview:GetActive() then
		self.m_ImagePreview:SetActive(true)
		self:RefreshImagePreview()
	end
end

function CFeedbackCommitView.RefreshImagePreview(self)
	if not self.m_ImagePreview:GetActive() then
		return
	end

	self.m_ImageGrid:Clear()

	if self.m_ImageCount > 0 then
		self.m_EmptyPart:SetActive(false)
		self.m_AddImagePart:SetActive(false)

		for i = 1, self.m_ImageCount do
			local oImage = self.m_ImageGrid:GetChild(i)
			if oImage == nil then
				oImage = self.m_ImagePart:Clone(false)
				oImage.m_DelBtn = oImage:NewUI(1, CButton, false, false)
				oImage.m_DelBtn:AddUIEvent("click", callback(self, "OnDelImage", i))

				oImage:SetActive(true)
				self.m_ImageGrid:AddChild(oImage)
			end
		end

		local oImgAddPart = self.m_AddImagePart:Clone(false)
		oImgAddPart:SetActive(true)
		oImgAddPart:AddUIEvent("click", callback(self, "OnAddImage"))
		self.m_ImageGrid:AddChild(oImgAddPart)
	else
		self.m_EmptyPart:SetActive(true)
		self.m_AddImagePart:SetActive(true)
	end

	self.m_ImageGrid:Reposition()
	self.m_ImageScrollView:ResetPosition()
end

function CFeedbackCommitView.OnTagSelect(self, iType)
	if self.m_SelectType == iType then
		return
	end
	self.m_SelectType = iType
end

function CFeedbackCommitView.OnAddImage(self)

	if Utils.IsPC() then
		g_NotifyCtrl:FloatMsg("PC版暂不支持图片上传")
		return
	end

	if self.m_ImageCount >= 3 then
		g_NotifyCtrl:FloatMsg("最多只能上传3张图片！")
		return
	end
	
	-- 图片上传后需要清理
	local filename = IOTools.GetPersistentDataPath("/Feedback/"..tostring(self.m_ImageCount + 1)..".png")
	g_ImageCtrl:ReadAndCompressPhoto(filename, function(result)
		if result == enum.PickImageResult.Compress_succ then
			self.m_ImageCount = self.m_ImageCount + 1
			g_FeedbackCtrl:AddImagePath(self.m_ImageCount, filename)

			self:RefreshImageGrid()
			self:RefreshImagePreview()
		elseif result == enum.PickImageResult.Cancel then
			g_NotifyCtrl:FloatMsg("取消")
		else
			g_NotifyCtrl:FloatMsg("操作异常")
		end
	end)
end

function CFeedbackCommitView.OnDelImage(self, idx)
	local filename = g_FeedbackCtrl:DelImagePath(self.m_ImageCount)
	if filename then
		IOTools.Delete(filename)
	end
	self.m_ImageCount = self.m_ImageCount - 1
	self:RefreshImageGrid()
	self:RefreshImagePreview()
end

function CFeedbackCommitView.OnCommit(self)
	if self.m_SelectType < 1 then
		g_NotifyCtrl:FloatMsg("请选择一个标签")
		return
	end

	local descL = self.m_DescInput:GetText()
	if not descL or string.len(descL) < 1 then
		g_NotifyCtrl:FloatMsg("请填写提问描述后再进行提交！")
		return
	end

	local qqNumber = self.m_QQInput:GetText()
	local phoneNumber= self.m_PhoneNumInput:GetText()

	local msg = {
		type = self.m_SelectType,
		context = descL,
		qq_no = qqNumber,
		phone_no = phoneNumber,
	}
	g_FeedbackCtrl:CommitFeedbackMsg(msg)

	self:OnClose()
end

function CFeedbackCommitView.OnClose(self)
	self.m_ImageCount = 0
	CViewBase.OnClose(self)
end

function CFeedbackCommitView.OnOpenSysEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Change then
		local bFDSysOpen = g_OpenSysCtrl:GetOpenSysState("FEEDBACK") and g_FeedbackCtrl.m_bFeedbackOpen
		if not bFDSysOpen then
			g_NotifyCtrl:FloatMsg("客服反馈临时关闭")
			self:OnClose()
		end
	end
end

return CFeedbackCommitView