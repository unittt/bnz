local CSpiritInfoView = class("CSpiritInfoView", CViewBase)

function CSpiritInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Spirit/SpiritInfoView.prefab", cb)
	--界面设置
	self.m_DepthType = "Top"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSpiritInfoView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_InputLbl = self:NewUI(3, CLabel)
	self.m_SendBtn = self:NewUI(4, CButton)
	self.m_OptionScrollView = self:NewUI(5, CScrollView)
	self.m_OptionGrid = self:NewUI(6, CGrid)
	self.m_OptionBoxClone = self:NewUI(7, CBox)
	self.m_MsgScrollView = self:NewUI(8, CScrollView)
	self.m_MsgTable = self:NewUI(9, CTable)
	self.m_MsgRightBoxClone = self:NewUI(10, CBox)
	self.m_MsgLeftBoxClone = self:NewUI(11, CBox)
	self.m_ItemScrollView = self:NewUI(12, CScrollView)
	self.m_ItemGrid = self:NewUI(13, CGrid)
	self.m_ItemBoxClone = self:NewUI(14, CBox)
	self.m_MsgDragWidget = self:NewUI(15, CWidget)
	self.m_ItemDragWidget = self:NewUI(16, CWidget)
	self.m_WebViewWidget = self:NewUI(17, CWidget)

	self.m_MsgColor = "[63432c]"

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CSpiritInfoView.InitContent(self)
	self.m_OptionBoxClone:SetActive(false)
	self.m_MsgRightBoxClone:SetActive(false)
	self.m_MsgLeftBoxClone:SetActive(false)
	self.m_ItemBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnClickSendBtn"))
	g_SpiritCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSpiritEvent"))
end

function CSpiritInfoView.OnCtrlSpiritEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Spirit.Event.Question then
		self:SetMsgList()
	end
end

function CSpiritInfoView.RefreshUI(self)
	-- self:SetOptionList()
	-- self:OnClickOptionBox(self.m_OptionGrid:GetChild(1), data.spiritdata.SPIRITOPTION[1])

	-- local oUrl = "http://xlwz.demigame.com/qa/"
	local oUrl = g_SpiritCtrl:GetUrl()
	printc("oUniWebView显示加载, url："..oUrl)
    local oUniWebView = C_api.UniWebViewExtHelper.CreateUniWebView(self.m_WebViewWidget.m_UIWidget, oUrl)
    self.m_UniWebView = oUniWebView
    if oUniWebView then
    	local function onShow()
    		printc("oUniWebView显示成功")
    		if oUniWebView then
    			oUniWebView:Show(false, 0, 0.4, nil)
    		end
    	end
    	oUniWebView.backButtonEnable = false
    	oUniWebView.OnLoadComplete = onShow
    	oUniWebView:CleanCache()
    	oUniWebView:Load()
    end
end

function CSpiritInfoView.OnShowView(self)
	if Utils.IsNil(self) then
		return
	end
	if self.m_UniWebView then
    	local function onShow()
    		printc("self.m_UniWebView显示成功")
    		if self.m_UniWebView then
    			self.m_UniWebView:Show(false, 0, 0.4, nil)
    		end
    	end
    	self.m_UniWebView.backButtonEnable = false
    	self.m_UniWebView.OnLoadComplete = onShow
    	self.m_UniWebView:CleanCache()
    	self.m_UniWebView:Load()
    end
end

function CSpiritInfoView.OnHideView(self)
	if Utils.IsNil(self) then
		return
	end
	if self.m_UniWebView then
		self.m_UniWebView:Hide(false, 0, 0.4, nil)
	end
end

function CSpiritInfoView.SetOptionList(self)
	local optionCount = #data.spiritdata.SPIRITOPTION
	local GridList = self.m_OptionGrid:GetChildList() or {}
	local oOptionBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oOptionBox = self.m_OptionBoxClone:Clone(false)
				-- self.m_OptionGrid:AddChild(oOptionBtn)
			else
				oOptionBox = GridList[i]
			end
			self:SetOptionBox(oOptionBox, data.spiritdata.SPIRITOPTION[i])
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

	self.m_OptionGrid:Reposition()
	-- self.m_OptionScrollView:ResetPosition()
end

function CSpiritInfoView.SetOptionBox(self, oOptionBox, oData)
	oOptionBox:SetActive(true)
	oOptionBox.m_NameLbl = oOptionBox:NewUI(1, CLabel)
	oOptionBox.m_SelNameLbl = oOptionBox:NewUI(2, CLabel)

	oOptionBox:SetGroup(self:GetInstanceID())
	oOptionBox.m_NameLbl:SetText(oData.name)
	oOptionBox.m_SelNameLbl:SetText(oData.name)
	
	oOptionBox:AddUIEvent("click", callback(self, "OnClickOptionBox", oOptionBox, oData))

	self.m_OptionGrid:AddChild(oOptionBox)
	self.m_OptionGrid:Reposition()
end

function CSpiritInfoView.SetItemList(self, oList)
	self.m_MsgScrollView:SetActive(false)
	self.m_ItemScrollView:SetActive(true)
	self.m_MsgDragWidget:SetActive(false)
	self.m_ItemDragWidget:SetActive(true)
	local optionCount = #oList
	local GridList = self.m_ItemGrid:GetChildList() or {}
	local oItemBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oItemBox = self.m_ItemBoxClone:Clone(false)
				-- self.m_ItemGrid:AddChild(oOptionBtn)
			else
				oItemBox = GridList[i]
			end
			self:SetItemBox(oItemBox, oList[i])
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

	self.m_ItemGrid:Reposition()
	-- self.m_ItemScrollView:ResetPosition()
end

function CSpiritInfoView.SetItemBox(self, oItemBox, oData)
	oItemBox:SetActive(true)
	oItemBox.m_NameLbl = oItemBox:NewUI(1, CLabel)

	local oConfig = data.spiritdata.SPIRITITEM[oData]
	oItemBox.m_NameLbl:SetText(oConfig.name)
	
	oItemBox:AddUIEvent("click", callback(self, "OnClickItemBox", oData))

	self.m_ItemGrid:AddChild(oItemBox)
	self.m_ItemGrid:Reposition()
end

function CSpiritInfoView.SetMsgList(self)
	self.m_MsgScrollView:SetActive(true)
	self.m_ItemScrollView:SetActive(false)
	self.m_MsgDragWidget:SetActive(true)
	self.m_ItemDragWidget:SetActive(false)
	self.m_MsgTable:Clear()
	local optionCount = #g_SpiritCtrl.m_MsgList
	local GridList = self.m_MsgTable:GetChildList() or {}
	local oMsgBox

	for i=1,optionCount do
		if g_SpiritCtrl.m_MsgList[i].type == 1 then
			oMsgBox = self.m_MsgLeftBoxClone:Clone(false)
			self:SetLeftMsgBox(oMsgBox, g_SpiritCtrl.m_MsgList[i])
		else
			oMsgBox = self.m_MsgRightBoxClone:Clone(false)
			self:SetRightMsgBox(oMsgBox, g_SpiritCtrl.m_MsgList[i])
		end
	end

	self.m_MsgTable:Reposition()
	self.m_MsgScrollView:ResetPosition()
end

function CSpiritInfoView.SetLeftMsgBox(self, oMsgBox, oData)
	oMsgBox:SetActive(true)
	oMsgBox.m_IconSp = oMsgBox:NewUI(1, CSprite)
	oMsgBox.m_MsgLbl = oMsgBox:NewUI(2, CLabel)
	oMsgBox.m_NameLbl = oMsgBox:NewUI(3, CLabel)
	oMsgBox.m_MsgKuangSp = oMsgBox:NewUI(4, CSprite)

	oMsgBox.m_IconSp:SpriteAvatar(g_AttrCtrl.icon)
	oMsgBox.m_MsgLbl:SetText(self.m_MsgColor..oData.msg)

	self.m_MsgTable:AddChild(oMsgBox)
	self.m_MsgTable:Reposition()
end

function CSpiritInfoView.SetRightMsgBox(self, oMsgBox, oData)
	oMsgBox:SetActive(true)
	oMsgBox.m_IconSp = oMsgBox:NewUI(1, CSprite)
	oMsgBox.m_MsgLbl = oMsgBox:NewUI(2, CLabel)
	oMsgBox.m_NameLbl = oMsgBox:NewUI(3, CLabel)
	oMsgBox.m_MsgKuangSp = oMsgBox:NewUI(4, CSprite)
	oMsgBox.m_PosWidget	= oMsgBox:NewUI(5, CWidget)
	oMsgBox.m_SolveBtn = oMsgBox:NewUI(6, CButton)
	oMsgBox.m_NotSolveBtn = oMsgBox:NewUI(7, CButton)
	oMsgBox.m_DescLbl = oMsgBox:NewUI(8, CLabel)
	oMsgBox.m_AnswerResultLbl = oMsgBox:NewUI(9, CLabel)

	oMsgBox.m_PosWidget:SetLocalPos(Vector3.New(582, -39, 0))
	oMsgBox.m_MsgLbl:SetRichText(self.m_MsgColor..oData.msg)
	oMsgBox.m_SolveBtn:SetActive(true)
	oMsgBox.m_NotSolveBtn:SetActive(true)
	oMsgBox.m_DescLbl:SetText("此次回答是否解决了您的问题？")
	oMsgBox.m_AnswerResultLbl:SetText("")

	oMsgBox.m_SolveBtn:AddUIEvent("click", callback(self, "OnClickSolveBtn", oMsgBox, oData))
	oMsgBox.m_NotSolveBtn:AddUIEvent("click", callback(self, "OnClickNotSolveBtn", oMsgBox, oData))

	self.m_MsgTable:AddChild(oMsgBox)
	self.m_MsgTable:Reposition()
end

---------------以下是点击事件---------------

function CSpiritInfoView.OnClickSendBtn(self)
	local oInputStr = self.m_Input:GetText()
	if not oInputStr or oInputStr == "" then
		g_NotifyCtrl:FloatMsg("请输入要提问的内容")
		return
	end
	local oConfig = self:GetItemConfigByStr(oInputStr)
	if oConfig then
		local oRandomConfig = g_SpiritCtrl:GetRandomItemConfig(oConfig.id)
		local oMsgStr = oConfig.content.."\n您可能还感兴趣："..string.format("{link32,%d}", oRandomConfig[1].id).."、"..string.format("{link32,%d}", oRandomConfig[2].id)
		table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 2, msg = oMsgStr})
		table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 1, msg = oInputStr})	
		self:SetMsgList()
	else
		table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 2, msg = "可能是您的问题不够详细，暂时没找到答案。可以换一些问法再试试喔！"})
		table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 1, msg = oInputStr})		
		self:SetMsgList()
	end
	self.m_Input:SetText("")
end

function CSpiritInfoView.GetItemConfigByStr(self, oInputStr)
	if not oInputStr or oInputStr == "" then
		return
	end
	for k,v in ipairs(data.spiritdata.SPIRITITEM) do
		local _, oCount = string.gsub(oInputStr, v.name, "")
		if oCount > 0 then
			return v
		end
	end
end

function CSpiritInfoView.OnClickOptionBox(self, oOptionBox, oData)
	if oOptionBox then
		oOptionBox:SetSelected(true)
	end
	self:SetItemList(oData.options)
	g_SpiritCtrl.m_MsgList = {}
end

function CSpiritInfoView.OnClickItemBox(self, oData)
	g_SpiritCtrl.m_MsgList = {}
	local oRandomConfig = g_SpiritCtrl:GetRandomItemConfig(oData)
	local oMsgStr = data.spiritdata.SPIRITITEM[oData].content.."\n您可能还感兴趣："..string.format("{link32,%d}", oRandomConfig[1].id).."、"..string.format("{link32,%d}", oRandomConfig[2].id)
	table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 2, msg = oMsgStr})
	table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 1, msg = data.spiritdata.SPIRITITEM[oData].name})
	self:SetMsgList()
end

function CSpiritInfoView.OnClickSolveBtn(self, oMsgBox, oData)
	oMsgBox.m_SolveBtn:SetActive(false)
	oMsgBox.m_NotSolveBtn:SetActive(false)
	oMsgBox.m_DescLbl:SetText("")
	oMsgBox.m_AnswerResultLbl:SetText("谢谢您对精灵的支持！")
end

function CSpiritInfoView.OnClickNotSolveBtn(self, oMsgBox, oData)
	oMsgBox.m_SolveBtn:SetActive(false)
	oMsgBox.m_NotSolveBtn:SetActive(false)
	oMsgBox.m_DescLbl:SetText("")
	oMsgBox.m_AnswerResultLbl:SetText("谢谢反馈，精灵会继续努力的！")
end

return CSpiritInfoView