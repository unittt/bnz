local CTaskItemFindOpBox = class("CTaskItemFindOpBox", CBox)

function CTaskItemFindOpBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_OpTable = self:NewUI(1, CTable)
	self.m_OpBtn = self:NewUI(2, CButton)
	self.m_Bg = self:NewUI(3, CSprite)
	self.m_ArrowSpr = self:NewUI(4, CSprite)

	self.m_OpBtn:SetActive(false)
	self.m_ArrowSpr:SetActive(false)

	g_UITouchCtrl:TouchOutDetect(self.m_Bg, callback(self, "OnTouchOutDetect"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTaskItemFindOpBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshExtendTaskUI then
		self:RefreshUI()
	end
end

function CTaskItemFindOpBox.OnTouchOutDetect(self, gameObj)
    g_TaskCtrl:OnCloseTaskItemFindOpBox()
end

function CTaskItemFindOpBox.RefreshUI(self)
	self:SetBtnList()
end

function CTaskItemFindOpBox.SetBtnList(self)
	if not g_TaskCtrl.m_ExtendTaskData then
		return
	end

	local optionCount = #g_TaskCtrl.m_ExtendTaskData.options
	local GridList = self.m_OpTable:GetChildList() or {}
	local oBtnBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oBtnBox = self.m_OpBtn:Clone(false)
				-- self.m_OpTable:AddChild(oOptionBtn)
			else
				oBtnBox = GridList[i]
			end
			self:SetBtnBox(oBtnBox, g_TaskCtrl.m_ExtendTaskData.options[i], i)
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

	self.m_OpTable:Reposition()
	-- self.m_ScrollView:ResetPosition()

	self.m_Bg:SetHeight(50*optionCount + 22)
end

function CTaskItemFindOpBox.SetBtnBox(self, oBtnBox, oData, oIndex)
	oBtnBox:SetActive(true)
	oBtnBox:SetText(oData.text)
	if oData.state == 0 then
		oBtnBox:SetSpriteName("h7_an_1")
	elseif oData.state == 1 then
		oBtnBox:SetSpriteName("h7_an_5")
	elseif oData.state == 2 then
		oBtnBox:SetSpriteName("h7_an_2")
	else
		oBtnBox:SetSpriteName("h7_an_1")
	end	
	
	oBtnBox:AddUIEvent("click", callback(self, "OnClickBtnBox", oData, oIndex))

	self.m_OpTable:AddChild(oBtnBox)
	self.m_OpTable:Reposition()
end

function CTaskItemFindOpBox.OnClickBtnBox(self, oData, oIndex)
	if not g_TaskCtrl.m_ExtendTaskData then
		return
	end
	nettask.C2GSExtendTaskUIClick(g_TaskCtrl.m_ExtendTaskData.taskid, g_TaskCtrl.m_ExtendTaskData.sessionidx, oIndex)
end

return CTaskItemFindOpBox