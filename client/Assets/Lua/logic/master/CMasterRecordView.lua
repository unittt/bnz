local CMasterRecordView = class("CMasterRecordView", CViewBase)

function CMasterRecordView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Master/MasterRecordView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMasterRecordView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_TitleLbl = self:NewUI(3, CLabel)
	self.m_RewriteBtn = self:NewUI(4, CButton)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_Grid = self:NewUI(7, CGrid)
	self.m_BoxClone = self:NewUI(8, CBox)

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CMasterRecordView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RewriteBtn:AddUIEvent("click", callback(self, "OnClickRewriteBtn"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))
end

function CMasterRecordView.RefreshUI(self)
	if g_MasterCtrl.m_AnswerType == 1 then
		self.m_TitleLbl:SetText("师傅登记")
	else
		self.m_TitleLbl:SetText("徒弟登记")
	end
	self:SetRecordList()
end

function CMasterRecordView.SetRecordList(self)
	local optionCount = #g_MasterCtrl.m_HasAnswerList
	local GridList = self.m_Grid:GetChildList() or {}
	local oRecordBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRecordBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oRecordBox = GridList[i]
			end
			self:SetRecordBox(oRecordBox, g_MasterCtrl.m_HasAnswerList[i], i)
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

	self.m_Grid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CMasterRecordView.SetRecordBox(self, oRecordBox, oData, oIndex)
	oRecordBox:SetActive(true)
	oRecordBox.m_NameLbl = oRecordBox:NewUI(1, CLabel)
	oRecordBox.m_DescLbl = oRecordBox:NewUI(2, CLabel)

	if g_MasterCtrl.m_AnswerType == 1 then
		oRecordBox.m_NameLbl:SetText(data.masterdata.QUESTION[oIndex].submitstr)
		oRecordBox.m_DescLbl:SetText(data.masterdata.ANSWER[oData].content)
	else
		oRecordBox.m_NameLbl:SetText(data.masterdata.QUESTION[oIndex].submitstr2)
		local oNameStr = string.gsub(data.masterdata.ANSWER[oData].content, "徒弟", "师傅")
		oRecordBox.m_DescLbl:SetText(oNameStr)
	end

	self.m_Grid:AddChild(oRecordBox)
	self.m_Grid:Reposition()
end

--------------以下是点击事件--------------

function CMasterRecordView.OnClickRewriteBtn(self)
	g_MasterCtrl.m_QuesIndex = 1
	g_MasterCtrl.m_HasAnswerList = {}
	self:OnClose()
	CMasterAnswerView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CMasterRecordView.OnClickConfirmBtn(self)
	local oList = {}
	for k,v in ipairs(g_MasterCtrl.m_HasAnswerList) do
		table.insert(oList, {question_id = k, answer = v})
	end
	if g_MasterCtrl.m_AnswerType == 1 then
		netmentoring.C2GSToBeMentor(oList)
	else
		netmentoring.C2GSToBeApprentice(oList)
	end
	self:OnClose()
end

return CMasterRecordView