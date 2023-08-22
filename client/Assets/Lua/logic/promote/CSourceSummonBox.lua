local CSourceSummonBox = class("CSourceSummonBox", CBox)

function CSourceSummonBox.ctor(self ,obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_ExplainBtn = self:NewUI(1, CButton)
	-- self.m_KindBtn = self:NewUI(2, CButton)
	self.m_ExplainPart = self:NewUI(3, CBox)
	self.m_ExplainSV = self:NewUI(4, CScrollView)
	self.m_ExplainGrid = self:NewUI(5, CTable)
	self.m_ExplainBoxClone = self:NewUI(6, CBox)

	self.m_KindPart = self:NewUI(7, CBox)
	self.m_KindSV = self:NewUI(8, CScrollView)
	self.m_KindGrid = self:NewUI(9, CTable)
	self.m_KindBoxClone = self:NewUI(10, CBox)
	self.m_Btn = self:NewUI(11, CButton)
	self.m_JieShaoLabel = self:NewUI(12, CLabel)
	self.m_JieShao1Label = self:NewUI(13, CLabel)
	self.m_FenLeiLabel = self:NewUI(14, CLabel)
	self.m_FenLei1Label = self:NewUI(15, CLabel)
	self:InitContent()
end

function CSourceSummonBox.InitContent(self)
	-- body
	-- self.m_ExplainBtn:AddUIEvent("click", callback(self, "OnBtnClick", true))
	-- self.m_KindBtn:AddUIEvent("click", callback(self, "OnBtnClick", false))
	-- self.m_ExplainBtn:SetGroup(self:GetInstanceID())
	-- self.m_KindBtn:SetGroup(self:GetInstanceID())

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))

	self.m_Btn:AddUIEvent("click", callback(self, "JumpToSummonView"))
	local explaindata = data.sourcebookdata.SUMMONDES

	self.m_JieShaoLabel:SetText(explaindata[1].cat_name)
	self.m_JieShao1Label:SetText(explaindata[1].cat_name)

	self.m_ExplainGrid:Clear()
	local explainlist = self.m_ExplainGrid:GetChildList()
	for i,v in ipairs(explaindata) do
		local box = nil
		if i>#explainlist then
			box = self.m_ExplainBoxClone:Clone()
			box:SetActive(true)
			self.m_ExplainGrid:AddChild(box)

			box.title = box:NewUI(1, CLabel)
			box.text = box:NewUI(2, CLabel)
 			box.btn = box:NewUI(3, CButton)
 			box.btn:SetGroup(self.m_ExplainGrid:GetInstanceID())
 			box.btnlab = box:NewUI(4, CLabel)
		else
			box = explainlist[i]
		end
		box.title:SetText(v.title)
		box.text:SetText(v.des)
		-- local w,h = box.text:GetSize
		box.btnlab:SetText(v.btnname)
		box.btn:AddUIEvent("click", callback(self, "OnJumpToSummonView", v.view, v.tab, v.idx))
	end 
	self.m_ExplainGrid:Reposition()
	self.m_ExplainSV:ResetPosition()

	local kinddata = data.sourcebookdata.SUMMONKIND

	self.m_FenLeiLabel:SetText(kinddata[1].cat_name)
	self.m_FenLei1Label:SetText(kinddata[1].cat_name)
	self.m_KindGrid:Clear()
	for i,v in ipairs(kinddata) do
		local box = nil
		
		box = self.m_KindBoxClone:Clone()
		self.m_KindGrid:AddChild(box)
		box:SetActive(true)
		box.title = box:NewUI(1, CLabel)
		box.text = box:NewUI(2, CLabel)
 	
		box.title:SetText(v.subcat_title)
		box.text:SetText(v.des)
	end
	self.m_KindGrid:Reposition()
	self.m_KindSV:ResetPosition()

	-- self.m_ExplainBtn:ForceSelected(true)
	-- self.m_KindBtn:ForceSelected(false)

	self.m_ExplainPart:SetActive(true)
	self.m_KindPart:SetActive(false)

end

function CSourceSummonBox.OnJumpToSummonView(self, view, tab, idx)
	-- body
	if  next(g_SummonCtrl.m_SummonsDic) == nil then
	 	CSummonMainView:ShowView(function(oView)
		-- body
			oView:ShowSubPageByIndex(3)
		end)
		return
	end

	if tonumber(tab) == 1 then
		CSummonMainView:ShowView(function(oView)
		-- body
			oView:ShowSubPageByIndex(tonumber(tab))
			oView.m_PropertyPart.m_TabDict[idx]:SetSelected(true)
			oView.m_PropertyPart:OnClickPageBtn(idx)
		end)
	elseif tonumber(tab) == 2 then
		CSummonMainView:ShowView(function(oView)
		-- body
			oView:ShowSubPageByIndex(tonumber(tab))
			oView.m_AdjustPart.m_TabDict[idx]:SetSelected(true)
			oView.m_AdjustPart:OnClickPageBtn(idx)
		end)
	end
	
end

function CSourceSummonBox.RefreshUI(self, idx)
	self.m_ExplainPart:SetActive(idx == 1)
	self.m_KindPart:SetActive(idx ~= 1)
end

function CSourceSummonBox.JumpToSummonView(self)
	-- body
	CSummonMainView:ShowView(function (oView)
		-- body
		oView:ShowSubPageByIndex(3)
	end)
end

function CSourceSummonBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshSourceSummonInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

return CSourceSummonBox