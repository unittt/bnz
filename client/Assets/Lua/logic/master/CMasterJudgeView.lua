local CMasterJudgeView = class("CMasterJudgeView", CViewBase)

function CMasterJudgeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Master/MasterJudgeView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMasterJudgeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_TitleLbl = self:NewUI(3, CLabel)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_Grid = self:NewUI(5, CGrid)
	self.m_BoxClone = self:NewUI(6, CBox)

	self.m_IsNotCheckOnLoadShow = true

	self.m_DescStr = "恭喜你升到了#grade级！你的师傅在这一阶段的成长中对你有帮助吗，评价一下！"
	self.m_AnswerStrList = {"师傅对我尽心协助", "师傅对我帮助一般", "师傅对我没啥帮助"}

	self:InitContent()
end

function CMasterJudgeView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CMasterJudgeView.RefreshUI(self)
	self.m_DescLbl:SetText(string.gsub(self.m_DescStr, "#grade", g_MasterCtrl.m_JudgeGrade))
	self:SetJudgeList()
end

function CMasterJudgeView.SetJudgeList(self)
	local optionCount = #self.m_AnswerStrList
	local GridList = self.m_Grid:GetChildList() or {}
	local oJudgeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oJudgeBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oJudgeBox = GridList[i]
			end
			self:SetJudgeBox(oJudgeBox, self.m_AnswerStrList[i], i)
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

function CMasterJudgeView.SetJudgeBox(self, oJudgeBox, oData, oIndex)
	oJudgeBox:SetActive(true)
	oJudgeBox.m_NameLbl = oJudgeBox:NewUI(1, CLabel)

	oJudgeBox.m_NameLbl:SetText(oData)

	oJudgeBox:AddUIEvent("click", callback(self, "OnClickJudgeBox", oData, oIndex))

	self.m_Grid:AddChild(oJudgeBox)
	self.m_Grid:Reposition()
end

function CMasterJudgeView.OnClickJudgeBox(self, oData, oIndex)
	netother.C2GSCallback(g_MasterCtrl.m_JudgeSessionidx, oIndex)
	self:OnClose()
end

return CMasterJudgeView