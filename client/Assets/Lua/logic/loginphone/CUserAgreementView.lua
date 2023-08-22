local CUserAgreementView = class("CUserAgreementView", CViewBase)

function CUserAgreementView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/UserAgreementView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CUserAgreementView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ContentLbl = self:NewUI(2, CLabel)
	self.m_LeftArrowBtn = self:NewUI(3, CButton)
	self.m_RightArrowBtn = self:NewUI(4, CButton)
	self.m_ChapterLbl = self:NewUI(5, CLabel)
	self.m_ReadDoneBtn = self:NewUI(6, CButton)
	self.m_ConfirmBtn = self:NewUI(7, CButton)
	self.m_ScrollView = self:NewUI(8, CScrollView)
	self.m_NotifySp = self:NewUI(9, CSprite)
	self.m_TitleLbl = self:NewUI(10, CLabel)

	self.m_TitleLbl:SetText("《#gamename》手游用户协议")

	local path = "Config/AgreementData/AgreementData_commom.bytes"
	if g_GameDataCtrl:GetGameType() == "specity" then
		path = string.format("Config/AgreementData/AgreementData_%s.bytes", g_GameDataCtrl:GetGameType())
	end

	local bytes = g_ResCtrl:Load(path)
	local data = decodejson(tostring(bytes))
	local list = {}
	for k,v in pairs(data.infoList) do
		table.insert(list, {data = v, id = k})
	end
	table.sort(list, function(a, b) return a.id < b.id end)

	self.m_ContentDict = list

	self.m_LoginCb = nil
	self.m_ChapterIndex = 1
	self.m_ReadDoneState = true
	self:CheckReadDoneState()
	
	self:InitContent()
end

function CUserAgreementView.InitContent(self)
	self.m_CloseBtn:SetActive(false)

	self.m_LeftArrowBtn:AddUIEvent("click", callback(self, "OnClickLeftArrow"))
	self.m_RightArrowBtn:AddUIEvent("click", callback(self, "OnClickRightArrow"))
	self.m_ReadDoneBtn:AddUIEvent("click", callback(self, "OnClickRedDone"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))

	self.m_ChapterIndex = 1
	self:ReadChapter(1)
end

function CUserAgreementView.SetLoginCallback(self, cb)
	self.m_LoginCb = cb
end

function CUserAgreementView.ReadChapter(self, index)
	if index < 1 then
		index = 1
	elseif index > #self.m_ContentDict then
		index = #self.m_ContentDict
	end
	self.m_ContentLbl:SetText("[244B4E]" .. self.m_ContentDict[index].data .. "[-]")
	self.m_ChapterLbl:SetText(index.."/"..#self.m_ContentDict)
	self.m_ScrollView:ResetPosition()
end

function CUserAgreementView.CheckReadDoneState(self)
	if self.m_ReadDoneState then
		self.m_ReadDoneBtn:SetSelected(true)
		self.m_ConfirmBtn:SetBtnGrey(false)
	else
		self.m_ReadDoneBtn:SetSelected(false)
		self.m_ConfirmBtn:SetBtnGrey(true)
	end
end

function CUserAgreementView.SetNotifySpEffect(self)
	local tween = self.m_NotifySp:GetComponent(classtype.TweenAlpha)
	tween.enabled = true
	self.m_NotifySp:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = 1
	tween:ResetToBeginning()
	-- tween.delay = define.Task.Time.MoveDown
	tween:PlayForward()
end

-----------------以下是点击事件----------------

function CUserAgreementView.OnClickLeftArrow(self)
	self.m_ChapterIndex = self.m_ChapterIndex - 1
	if self.m_ChapterIndex < 1 then
		self.m_ChapterIndex = 1
	end
	self:ReadChapter(self.m_ChapterIndex)
end

function CUserAgreementView.OnClickRightArrow(self)
	self.m_ChapterIndex = self.m_ChapterIndex + 1
	if self.m_ChapterIndex > #self.m_ContentDict then
		self.m_ChapterIndex = #self.m_ContentDict
	end
	self:ReadChapter(self.m_ChapterIndex)
end

function CUserAgreementView.OnClickRedDone(self)
	self.m_ReadDoneState = not self.m_ReadDoneState
	self:CheckReadDoneState()
end

function CUserAgreementView.OnClickConfirm(self)
	if not self.m_ReadDoneState then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.UserAgree].content)
		DOTween.DOShakePosition(self.m_ReadDoneBtn.m_Transform, 1, 2, 10, 90, false, true)
		self:SetNotifySpEffect()
	else		
		self:CloseView()
		--本地没有useragree纪录,是否设置useragree纪录
		if not IOTools.GetClientData("useragree") then
			if self.m_LoginCb then
				self.m_LoginCb()
			end
		end
		IOTools.SetClientData("useragree", 1)
	end
	
end

return CUserAgreementView