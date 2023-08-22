local CMasterAnswerView = class("CMasterAnswerView", CViewBase)

function CMasterAnswerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Master/MasterAnswerView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMasterAnswerView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_TitleLbl = self:NewUI(3, CLabel)
	self.m_QuesTitleLbl = self:NewUI(4, CLabel)
	self.m_QuesScrollView = self:NewUI(5, CScrollView)
	self.m_QuesGrid = self:NewUI(6, CGrid)
	self.m_QuesBoxClone = self:NewUI(7, CBox)
	self.m_ZimuLbl = self:NewUI(8, CLabel)
	self.m_ZimuScrollView = self:NewUI(9, CScrollView)
	self.m_ZimuGrid = self:NewUI(10, CGrid)
	self.m_ZimuBoxClone = self:NewUI(11, CBox)
	self.m_ProvBtn = self:NewUI(12, CButton)
	self.m_ProvLbl = self:NewUI(13, CLabel)
	self.m_ProvScrollView = self:NewUI(14, CScrollView)
	self.m_ProvGrid = self:NewUI(15, CGrid)
	self.m_ProvBoxClone = self:NewUI(16, CBox)
	self.m_ProgressLbl = self:NewUI(17, CLabel)
	self.m_BgSp = self:NewUI(18, CSprite)

	self.m_IsNotCheckOnLoadShow = true

	self.m_ZimuList = {"A", "B", "C", "F", "G", "H", "J", "L", "N", "Q", "S", "T", "X", "Y", "Z", "海外", "随意"}
	self.m_ProvList = {
		["A"] = {15, 16},
		["B"] = {17},
		["C"] = {18},
		["F"] = {19},
		["G"] = {20, 21, 22, 23},
		["H"] = {24, 25, 26, 27, 28, 29},
		["J"] = {30, 31, 32},
		["L"] = {33},
		["N"] = {34, 35},
		["Q"] = {36},
		["S"] = {37, 38, 39, 40, 41},
		["T"] = {42, 43},
		["X"] = {44, 45, 46},
		["Y"] = {47},
		["Z"] = {48},
	}
	self.m_ProvHaihua = 49
	self.m_ProvSuiyi = 50

	self:InitContent()
end

function CMasterAnswerView.InitContent(self)
	self.m_QuesBoxClone:SetActive(false)
	self.m_ZimuBoxClone:SetActive(false)
	self.m_ProvBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ProvBtn:AddUIEvent("click", callback(self, "OnClickProvBtn"))
end

function CMasterAnswerView.RefreshUI(self)
	if g_MasterCtrl.m_AnswerType == 1 then
		self.m_TitleLbl:SetText("师傅登记")
		self.m_DescLbl:SetText("为了找到更合适的徒弟，需要你协助回答几个简单的小问题：")
	else
		self.m_TitleLbl:SetText("徒弟登记")
		self.m_DescLbl:SetText("为了找到更合适的师傅，需要你协助回答几个简单的小问题：")
	end
	local oConfig = data.masterdata.QUESTION[g_MasterCtrl.m_QuesIndex]
	if not oConfig then
		return
	end
	if g_MasterCtrl.m_AnswerType == 1 then
		self.m_QuesTitleLbl:SetText(oConfig.content)
	else
		self.m_QuesTitleLbl:SetText(oConfig.content2)
	end
	if g_MasterCtrl.m_QuesIndex >= #data.masterdata.QUESTION then
		self.m_QuesScrollView:SetActive(false)
		-- self.m_ZimuLbl:SetActive(true)
		self.m_ZimuScrollView:SetActive(true)
		self.m_ProvBtn:SetActive(false)
		self.m_ProvLbl:SetActive(false)
		self.m_ProvScrollView:SetActive(false)
		self:SetZimuList()
		self.m_BgSp:SetHeight(200)
	else
		self.m_QuesScrollView:SetActive(true)
		-- self.m_ZimuLbl:SetActive(false)
		self.m_ZimuScrollView:SetActive(false)
		self.m_ProvBtn:SetActive(false)
		self.m_ProvLbl:SetActive(false)
		self.m_ProvScrollView:SetActive(false)
		self.m_BgSp:SetHeight(175)

		self:SetQuestionList(oConfig.choice, oConfig.question_id)
	end

	self.m_ProgressLbl:SetText(g_MasterCtrl.m_QuesIndex.."/"..#data.masterdata.QUESTION)
end

function CMasterAnswerView.SetQuestionList(self, oList, oQuesId)
	local optionCount = #oList
	local GridList = self.m_QuesGrid:GetChildList() or {}
	local oQuestionBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oQuestionBox = self.m_QuesBoxClone:Clone(false)
				-- self.m_QuesGrid:AddChild(oOptionBtn)
			else
				oQuestionBox = GridList[i]
			end
			self:SetQuestionBox(oQuestionBox, oList[i], oQuesId)
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

	self.m_QuesGrid:Reposition()
	-- self.m_QuesScrollView:ResetPosition()
end

function CMasterAnswerView.SetQuestionBox(self, oQuestionBox, oData, oQuesId)
	oQuestionBox:SetActive(true)
	oQuestionBox.m_NameLbl = oQuestionBox:NewUI(1, CLabel)

	local oNameStr
	if g_MasterCtrl.m_AnswerType == 1 then
		oNameStr = data.masterdata.ANSWER[oData].content
	else
		oNameStr = string.gsub(data.masterdata.ANSWER[oData].content, "徒弟", "师傅")
	end
	oQuestionBox.m_NameLbl:SetText(oNameStr)
	
	oQuestionBox:AddUIEvent("click", callback(self, "OnClickQuestionBox", oData, oQuesId))

	self.m_QuesGrid:AddChild(oQuestionBox)
	self.m_QuesGrid:Reposition()
end

function CMasterAnswerView.SetZimuList(self)
	local optionCount = #self.m_ZimuList
	local GridList = self.m_ZimuGrid:GetChildList() or {}
	local oZimuBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oZimuBox = self.m_ZimuBoxClone:Clone(false)
				-- self.m_ZimuGrid:AddChild(oOptionBtn)
			else
				oZimuBox = GridList[i]
			end
			self:SetZimuBox(oZimuBox, self.m_ZimuList[i])
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

	self.m_ZimuGrid:Reposition()
	-- self.m_ZimuScrollView:ResetPosition()
end

function CMasterAnswerView.SetZimuBox(self, oZimuBox, oData)
	oZimuBox:SetActive(true)
	oZimuBox.m_NameLbl = oZimuBox:NewUI(1, CLabel)

	oZimuBox.m_NameLbl:SetText(oData)

	oZimuBox:AddUIEvent("click", callback(self, "OnClickZimuBox", oData))

	self.m_ZimuGrid:AddChild(oZimuBox)
	self.m_ZimuGrid:Reposition()
end

function CMasterAnswerView.SetProvList(self, oList)
	local optionCount = #oList
	local GridList = self.m_ProvGrid:GetChildList() or {}
	local oProvBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oProvBox = self.m_ProvBoxClone:Clone(false)
				-- self.m_ProvGrid:AddChild(oOptionBtn)
			else
				oProvBox = GridList[i]
			end
			self:SetProvBox(oProvBox, oList[i])
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

	self.m_ProvGrid:Reposition()
	-- self.m_ProvScrollView:ResetPosition()
end

function CMasterAnswerView.SetProvBox(self, oProvBox, oData)
	oProvBox:SetActive(true)
	oProvBox.m_NameLbl = oProvBox:NewUI(1, CLabel)

	oProvBox.m_NameLbl:SetText(data.masterdata.ANSWER[oData].content)
	oProvBox:AddUIEvent("click", callback(self, "OnClickProvBox", oData))

	self.m_ProvGrid:AddChild(oProvBox)
	self.m_ProvGrid:Reposition()
end

------------------以下是点击事件-----------------

function CMasterAnswerView.OnClickProvBtn(self)
	self.m_QuesScrollView:SetActive(false)
	-- self.m_ZimuLbl:SetActive(true)
	self.m_ZimuScrollView:SetActive(true)
	self.m_ProvBtn:SetActive(false)
	self.m_ProvLbl:SetActive(false)
	self.m_ProvScrollView:SetActive(false)
	self:SetZimuList()
end

function CMasterAnswerView.OnClickQuestionBox(self, oData, oQuesId)
	g_MasterCtrl.m_HasAnswerList[oQuesId] = oData

	g_MasterCtrl.m_QuesIndex = g_MasterCtrl.m_QuesIndex + 1
	if g_MasterCtrl.m_QuesIndex > #data.masterdata.QUESTION then
		g_MasterCtrl.m_QuesIndex = 1
	else
		self:RefreshUI()
	end
end

function CMasterAnswerView.OnClickZimuBox(self, oData)
	if oData == "海外" then
		g_MasterCtrl.m_HasAnswerList[#data.masterdata.QUESTION] = self.m_ProvHaihua
		g_MasterCtrl.m_QuesIndex = 1
		self:OnClose()
		CMasterRecordView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	elseif oData == "随意" then
		g_MasterCtrl.m_HasAnswerList[#data.masterdata.QUESTION] = self.m_ProvSuiyi
		g_MasterCtrl.m_QuesIndex = 1
		self:OnClose()
		CMasterRecordView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	else
		self.m_QuesScrollView:SetActive(false)
		-- self.m_ZimuLbl:SetActive(false)
		self.m_ZimuScrollView:SetActive(false)
		self.m_ProvBtn:SetActive(true)
		self.m_ProvLbl:SetActive(true)
		self.m_ProvScrollView:SetActive(true)
		self:SetProvList(self.m_ProvList[oData])
	end
end

function CMasterAnswerView.OnClickProvBox(self, oData)
	g_MasterCtrl.m_HasAnswerList[#data.masterdata.QUESTION] = oData

	g_MasterCtrl.m_QuesIndex = 1
	self:OnClose()
	CMasterRecordView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

return CMasterAnswerView