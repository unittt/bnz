local CYibaoMySelfPart = class("CYibaoMySelfPart", CPageBase)
-- 注意 oData.data.name 里名字前已经加上#g  导致颜色错误
function CYibaoMySelfPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TaskBoxList = {}
	self.m_YibaoTimer = nil
	for i = 1, 10, 1 do
		table.insert(self.m_TaskBoxList, self:NewUI(i, CYibaoTaskBox))
	end	
	self.m_PrizeBox = self:NewUI(11, CYibaoTaskBox)
	self.m_TaskGrid = self:NewUI(12, CGrid)
	self.m_TaskGrid:SetActive(false)
	self.m_PrizeNewBox = self:NewUI(13, CBox)
	self:InitPrizeNewBox()
	self.m_MainScrollView = self:NewUI(14, CScrollView)
	self.m_MainTable = self:NewUI(15, CTable)
	self.m_MainBoxClone = self:NewUI(16, CBox)
	self.m_MainHelpLbl = self:NewUI(17, CLabel)
	self.m_TipBtn = self:NewUI(18, CButton)

	self.m_MainBoxClone:SetActive(false)

	self:InitContent()
end

function CYibaoMySelfPart.InitPrizeNewBox(self)
	self.m_PrizeNewBox.m_IconSp = self.m_PrizeNewBox:NewUI(1, CSprite)
	self.m_PrizeNewBox.m_CountLbl = self.m_PrizeNewBox:NewUI(2, CLabel)
	self.m_PrizeNewBox.m_RedPointSp = self.m_PrizeNewBox:NewUI(3, CSprite)
	self.m_PrizeNewBox.m_DoneSp = self.m_PrizeNewBox:NewUI(4, CSprite)
	self.m_PrizeNewBox.m_DescLbl = self.m_PrizeNewBox:NewUI(5, CLabel)
	self.m_PrizeNewBox.m_Slider = self.m_PrizeNewBox:NewUI(6, CSlider)
	self.m_PrizeNewBox.m_SliderLbl = self.m_PrizeNewBox:NewUI(7, CLabel)
	self.m_PrizeNewBox.m_MainPrizeNewBox = self.m_PrizeNewBox:NewUI(8, CBox)
	self.m_PrizeNewBox.m_MainPrizeNewBox:SetActive(true)
	self:InitMainPrizeNewBox()
end

function CYibaoMySelfPart.InitMainPrizeNewBox(self)
	-- self.m_MainPrizeNewBox.m_TitleLbl = self.m_MainPrizeBox:NewUI(1, CLabel)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_ScrollView = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(2, CScrollView)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(3, CGrid)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_BoxClone = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(4, CBox)

	self.m_PrizeNewBox.m_MainPrizeNewBox.m_BoxClone:SetActive(false)
	self:SetMainPrizeNewInfo()
end

function CYibaoMySelfPart.SetMainPrizeNewInfo(self)
	self.m_PrizeNewBox.m_MainPrizeNewBox:SetActive(true)
	-- UITools.NearTarget(self.m_PrizeNewBox.m_IconSp, self.m_PrizeNewBox.m_MainPrizeNewBox, enum.UIAnchor.Side.Bottom)
	local oTaskConfig = g_TaskCtrl:GetYibaoMainTaskid().taskdata
	local oRewardId = string.gsub(oTaskConfig.submitRewardStr[1], "R", "")
	local oData = g_GuideHelpCtrl:GetRewardList("YIBAO", tonumber(oRewardId))--g_YibaoCtrl.m_YibaoMyselfMainInfo.itemreward_preview
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddMainPrizeNewBox(v)
		end
	end
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid:Reposition()
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_ScrollView:ResetPosition()

	-- g_UITouchCtrl:TouchOutDetect(self.m_PrizeNewBox.m_MainPrizeNewBox, callback(self.m_PrizeNewBox.m_MainPrizeNewBox, "SetActive", false))
end

function CYibaoMySelfPart.AddMainPrizeNewBox(self, oPrize)
	local oPrizeBox = self.m_PrizeNewBox.m_MainPrizeNewBox.m_BoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_IconSp:SpriteItemShape(DataTools.GetItemData(oPrize.item.id).icon)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrize, oPrizeBox))
	oPrizeBox.m_CountLbl:SetText(oPrize.amount)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid:AddChild(oPrizeBox)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid:Reposition()
	-- self.m_PrizeNewBox.m_MainPrizeNewBox.m_ScrollView:CullContentLater()
end

function CYibaoMySelfPart.SetMainList(self, bNotReset)
	local myselfData = g_YibaoCtrl:GetMyselfYibaoTaskData()
	local optionCount = #myselfData
	local TableList = self.m_MainTable:GetChildList() or {}
	local oMainBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #TableList then
				oMainBox = self.m_MainBoxClone:Clone(false)
				-- self.m_MainTable:AddChild(oOptionBtn)
			else
				oMainBox = TableList[i]
			end
			self:SetMainBox(oMainBox, myselfData[i])
		end

		if #TableList > optionCount then
			for i=optionCount+1,#TableList do
				TableList[i]:SetActive(false)
			end
		end
	else
		if TableList and #TableList > 0 then
			for _,v in ipairs(TableList) do
				v:SetActive(false)
			end
		end
	end

	self.m_MainTable:Reposition()
	if not bNotReset then
		self.m_MainScrollView:ResetPosition()
	end
end

function CYibaoMySelfPart.SetMainBox(self, oMainBox, oData)
	oMainBox:SetActive(true)
	oMainBox:SetGroup(self:GetInstanceID())
	oMainBox.m_IconSp = oMainBox:NewUI(1, CSprite)
	oMainBox.m_NameLbl = oMainBox:NewUI(2, CLabel)
	oMainBox.m_ItemBox = oMainBox:NewUI(3, CBox)
	oMainBox.m_StarBox = oMainBox:NewUI(4, CBox)
	oMainBox.m_InteractionBox = oMainBox:NewUI(5, CBox)
	oMainBox.m_DoneSp = oMainBox:NewUI(6, CSprite)
	oMainBox.m_RedPointSp = oMainBox:NewUI(7, CSprite)

	if oData.state == "done" then
		oMainBox.m_DoneSp:SetActive(true)
	else
		oMainBox.m_DoneSp:SetActive(false)
	end

	local type = 4
	if g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid) then
		type = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid).yibao_kind
	else
		type = oData.data.yibao_kind
	end
	if type == 4 then
		oMainBox.m_RedPointSp:SetActive(false)
		oMainBox.m_StarBox:SetActive(false)
		oMainBox.m_ItemBox:SetActive(false)
		oMainBox.m_InteractionBox:SetActive(true)

		self:SetMainInteractionBox(oMainBox, oData)
	elseif type == 2 then
		oMainBox.m_RedPointSp:SetActive(false)
		oMainBox.m_StarBox:SetActive(true)
		oMainBox.m_ItemBox:SetActive(false)
		oMainBox.m_InteractionBox:SetActive(false)

		self:SetMainStarBox(oMainBox, oData)
	elseif type == 3 then
		oMainBox.m_StarBox:SetActive(false)
		oMainBox.m_ItemBox:SetActive(true)
		oMainBox.m_InteractionBox:SetActive(false)

		self:SetMainItemBox(oMainBox, oData)
	end

	oMainBox:AddUIEvent("click", callback(self, "OnClickMainBox", oMainBox))

	self.m_MainTable:AddChild(oMainBox)
	self.m_MainTable:Reposition()
end

function CYibaoMySelfPart.SetMainItemBox(self, oMainBox, oData)
	oMainBox.m_ItemBox.m_CountLbl = oMainBox.m_ItemBox:NewUI(1, CLabel)
	oMainBox.m_ItemBox.m_PrizeLbl = oMainBox.m_ItemBox:NewUI(2, CLabel)
	oMainBox.m_ItemBox.m_HelpBtn = oMainBox.m_ItemBox:NewUI(3, CButton)
	oMainBox.m_ItemBox.m_DoBtn = oMainBox.m_ItemBox:NewUI(4, CButton)

	if g_YibaoCtrl.m_YibaoItemHelpTime[oData.taskid] and g_YibaoCtrl.m_YibaoItemHelpTime[oData.taskid] > 0 then
		oMainBox.m_ItemBox.m_HelpBtn:SetBtnGrey(true)
		oMainBox.m_ItemBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = false
		oMainBox.m_ItemBox.m_HelpBtn:SetText(os.date("%M:%S", g_YibaoCtrl.m_YibaoItemHelpTime[oData.taskid]))

		local time = g_YibaoCtrl.m_YibaoItemHelpTime[oData.taskid]

		if self.m_ItemTimer[oData.taskid] then
			Utils.DelTimer(self.m_ItemTimer[oData.taskid])
			self.m_ItemTimer[oData.taskid] = nil			
		end
		local function progress()
			if Utils.IsNil(oMainBox) then
				return false
			end
			time = time - 1
			oMainBox.m_ItemBox.m_HelpBtn:SetText(os.date("%M:%S", time))	
			if time <= 0 then
				time = 0
				oMainBox.m_ItemBox.m_HelpBtn:SetBtnGrey(false, "h7_an_1")
				oMainBox.m_ItemBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = true
				oMainBox.m_ItemBox.m_HelpBtn:SetText("求助")
				return false
			end
			return true
		end
		time = time + 1
		self.m_ItemTimer[oData.taskid] = Utils.AddTimer(progress, 1, 0)
	else
		oMainBox.m_ItemBox.m_HelpBtn:SetBtnGrey(false, "h7_an_1")
		oMainBox.m_ItemBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = true
		oMainBox.m_ItemBox.m_HelpBtn:SetText("求助")
	end

	local needitem
	local taskconfig = DataTools.GetTaskData(oData.taskid)

	if oData.state == "done" then
		oMainBox.m_RedPointSp:SetActive(false)
		needitem = oData.data.needitem
		oMainBox.m_ItemBox.m_CountLbl:SetText("数量:"..needitem[1].amount.."/"..needitem[1].amount)
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data.name)-- "[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		oMainBox.m_ItemBox.m_HelpBtn:SetActive(false)
		oMainBox.m_ItemBox.m_DoBtn:SetActive(false)
		oMainBox.m_ItemBox.m_PrizeLbl:SetActive(false)

		if oData.data.valuereward_preview and next(oData.data.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(oData.data.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_ItemBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_ItemBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_ItemBox.m_PrizeLbl:SetActive(false)
		end
	else
		needitem = oData.data:GetSValueByKey("needitem")
		oMainBox.m_ItemBox.m_CountLbl:SetText("数量:"..g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid).."/"..needitem[1].amount)
		if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
			oMainBox.m_RedPointSp:SetActive(true)
			oMainBox.m_ItemBox.m_DoBtn:SetText("上交")
		else
			oMainBox.m_RedPointSp:SetActive(false)
			oMainBox.m_ItemBox.m_DoBtn:SetText("购买")
		end
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data:GetSValueByKey("name"))--"[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		local leftHelpTime = g_YibaoCtrl.m_YibaoMyselfGatherMax-table.count(g_YibaoCtrl.m_YibaoMyselfGatherTasks)
		if leftHelpTime <= 0 and not table.index(g_YibaoCtrl.m_YibaoMyselfGatherTasks, oData.data:GetSValueByKey("taskid")) then
			oMainBox.m_ItemBox.m_HelpBtn:SetActive(false)
		else
			oMainBox.m_ItemBox.m_HelpBtn:SetActive(true)
		end
		oMainBox.m_ItemBox.m_DoBtn:SetActive(true)

		local doingInfo = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid)
		if doingInfo.valuereward_preview and next(doingInfo.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(doingInfo.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_ItemBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_ItemBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_ItemBox.m_PrizeLbl:SetActive(false)
		end
	end
	oMainBox.m_IconSp:SetActive(true)
	oMainBox.m_IconSp:SpriteItemShape(DataTools.GetItemData(needitem[1].itemid).icon)
	oMainBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickItemIconSp", oMainBox.m_IconSp, needitem[1].itemid))

	oMainBox.m_ItemBox.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickItemNewHelp", oData))
	oMainBox.m_ItemBox.m_DoBtn:AddUIEvent("click", callback(self, "OnClickItemNewDo", oData))
end

function CYibaoMySelfPart.SetMainStarBox(self, oMainBox, oData)
	oMainBox.m_StarBox.m_StarBgLbl = oMainBox.m_StarBox:NewUI(1, CLabel)
	oMainBox.m_StarBox.m_StarLbl = oMainBox.m_StarBox:NewUI(2, CLabel)
	oMainBox.m_StarBox.m_PrizeLbl = oMainBox.m_StarBox:NewUI(3, CLabel)
	oMainBox.m_StarBox.m_HelpBtn = oMainBox.m_StarBox:NewUI(4, CButton)
	oMainBox.m_StarBox.m_DoBtn = oMainBox.m_StarBox:NewUI(5, CButton)

	oMainBox.m_StarBox.m_StarBgLbl:SetText("#xing_bg".."#xing_bg".."#xing_bg".."#xing_bg".."#xing_bg")

	if g_YibaoCtrl.m_YibaoStarHelpTime[oData.taskid] and g_YibaoCtrl.m_YibaoStarHelpTime[oData.taskid] > 0 then
		oMainBox.m_StarBox.m_HelpBtn:SetBtnGrey(true)
		oMainBox.m_StarBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = false
		oMainBox.m_StarBox.m_HelpBtn:SetText(os.date("%M:%S", g_YibaoCtrl.m_YibaoStarHelpTime[oData.taskid]))

		local time = g_YibaoCtrl.m_YibaoStarHelpTime[oData.taskid]

		if self.m_StarTimer[oData.taskid] then
			Utils.DelTimer(self.m_StarTimer[oData.taskid])
			self.m_StarTimer[oData.taskid] = nil			
		end
		local function progress()
			if Utils.IsNil(oMainBox) then
				return false
			end
			time = time - 1
			oMainBox.m_StarBox.m_HelpBtn:SetText(os.date("%M:%S", time))
			if time <= 0 then
				time = 0
				oMainBox.m_StarBox.m_HelpBtn:SetBtnGrey(false, "h7_an_1")
				oMainBox.m_StarBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = true
				oMainBox.m_StarBox.m_HelpBtn:SetText("求升星")
				return false
			end
			return true
		end
		time = time + 1
		self.m_StarTimer[oData.taskid] = Utils.AddTimer(progress, 1, 0)
	else
		oMainBox.m_StarBox.m_HelpBtn:SetBtnGrey(false, "h7_an_1")
		oMainBox.m_StarBox.m_HelpBtn:GetComponent(classtype.BoxCollider).enabled = true
		oMainBox.m_StarBox.m_HelpBtn:SetText("求升星")
	end

	local taskconfig = DataTools.GetTaskData(oData.taskid)
	
	if oData.state == "done" then
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data.name)--"[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		oMainBox.m_StarBox.m_HelpBtn:SetActive(false)
		oMainBox.m_StarBox.m_DoBtn:SetActive(false)
		oMainBox.m_StarBox.m_StarLbl:SetText("")
		local starStr = ""
		for i=1, oData.data.star do
			starStr = starStr.."#xing_1"
		end
		oMainBox.m_StarBox.m_StarLbl:SetText(starStr)

		if oData.data.valuereward_preview and next(oData.data.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(oData.data.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_StarBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_StarBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_StarBox.m_PrizeLbl:SetActive(false)
		end
	else
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data:GetSValueByKey("name"))--"[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		oMainBox.m_StarBox.m_DoBtn:SetActive(true)

		local doingInfo = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid)
		if doingInfo.valuereward_preview and next(doingInfo.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(doingInfo.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_StarBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_StarBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_StarBox.m_PrizeLbl:SetActive(false)
		end

		oMainBox.m_StarBox.m_StarLbl:SetText("")
		local starStr = ""
		for i=1, doingInfo.star do
			starStr = starStr.."#xing_1"
		end
		oMainBox.m_StarBox.m_StarLbl:SetText(starStr)

		if doingInfo.star >= 5 then
			oMainBox.m_StarBox.m_HelpBtn:SetActive(false)
		else
			oMainBox.m_StarBox.m_HelpBtn:SetActive(true)
		end
	end
	
	if data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr ~= "" then
		oMainBox.m_IconSp:SetActive(true)
		oMainBox.m_IconSp:SpriteItemShape(tonumber(data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr))
	else
		oMainBox.m_IconSp:SetActive(false)
	end

	oMainBox.m_StarBox.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickStarNewHelp", oData))
	oMainBox.m_StarBox.m_DoBtn:AddUIEvent("click", callback(self, "OnClickStarNewDo", oData))
end

function CYibaoMySelfPart.SetMainInteractionBox(self, oMainBox, oData)
	oMainBox.m_InteractionBox.m_DescLbl = oMainBox.m_InteractionBox:NewUI(1, CLabel)
	oMainBox.m_InteractionBox.m_PrizeLbl = oMainBox.m_InteractionBox:NewUI(2, CLabel)
	oMainBox.m_InteractionBox.m_DoBtn = oMainBox.m_InteractionBox:NewUI(3, CButton)

	local taskconfig = DataTools.GetTaskData(oData.taskid)
	oMainBox.m_InteractionBox.m_DescLbl:SetText(taskconfig.description)
	if oData.state == "done" then
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data.name)--"[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		oMainBox.m_InteractionBox.m_DoBtn:SetActive(false)
		if oData.data.valuereward_preview and next(oData.data.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(oData.data.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_InteractionBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_InteractionBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_InteractionBox.m_PrizeLbl:SetActive(false)
		end
	else
		--oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText(oData.data:GetSValueByKey("name"))--"[244B4E]"..
		oMainBox.m_NameLbl:SetColor(Color.RGBAToColor("244B4EFF"))
		oMainBox.m_InteractionBox.m_DoBtn:SetActive(true)

		local doingInfo = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid)
		if doingInfo.valuereward_preview and next(doingInfo.valuereward_preview) then
			local prizeStr = ""
			for k,v in ipairs(doingInfo.valuereward_preview) do
				prizeStr = prizeStr..v.amount..g_YibaoCtrl:GetSubYibaoTaskPrizeConfig(v.sid)[2]
			end
			oMainBox.m_InteractionBox.m_PrizeLbl:SetActive(true)
			oMainBox.m_InteractionBox.m_PrizeLbl:SetText(prizeStr)
		else
			oMainBox.m_InteractionBox.m_PrizeLbl:SetActive(false)
		end
	end

	if data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr ~= "" then
		oMainBox.m_IconSp:SetActive(true)
		oMainBox.m_IconSp:SpriteItemShape(tonumber(data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr))
	else
		oMainBox.m_IconSp:SetActive(false)
	end

	oMainBox.m_InteractionBox.m_DoBtn:AddUIEvent("click", callback(self, "OnClickInteractionNewDo", oData))
end

-------------------------------------------------

function CYibaoMySelfPart.InitContent(self)
	self.m_StarTimer = {}
	self.m_ItemTimer = {}

	--暂时屏蔽宝箱预览
	-- self.m_PrizeNewBox:AddUIEvent("click", callback(self, "OnClickPrizeNewBox"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTips"))

	g_YibaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTaskEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CYibaoMySelfPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Yibao.Event.StarTime then
		self:SetMainList(true)
	elseif oCtrl.m_EventID == define.Yibao.Event.ItemTime then
		self:SetMainList(true)
	elseif oCtrl.m_EventID == define.Yibao.Event.UpdateMyselfYibaoInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Yibao.Event.UpdateMyselfDoneYibao then
		self:RefreshUI()
	end
end

function CYibaoMySelfPart.OnCtrlTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTask or oCtrl.m_EventID == define.Task.Event.DelTask
	or oCtrl.m_EventID == define.Task.Event.RefreshTask then
		self:RefreshUI()
	end
end

function CYibaoMySelfPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		self:RefreshUI()
	end
end

function CYibaoMySelfPart.RefreshUI(self, pbdata)
	if self.m_YibaoTimer then
		Utils.DelTimer(self.m_YibaoTimer)
		self.m_YibaoTimer = nil

		local function doDelay()
			if Utils.IsNil(self) then
				return false
			end

			self:DoShowUI(pbdata)

			return false
		end

		if not self.m_YibaoTimer then
			self.m_YibaoTimer = Utils.AddTimer(doDelay, 0.1, 0.5)
		end
	else
		self:DoShowUI(pbdata)
	end	
end

function CYibaoMySelfPart.DoShowUI(self, pbdata)
	local mask = (pbdata and {pbdata.mask} or {nil})[1]
	local owner = (pbdata and {pbdata.owner} or {nil})[1] --面板属于哪个玩家(pid)
	local create_day = (pbdata and {pbdata.create_day} or {nil})[1] --异宝创建日期（上行时使用）
	local seek_gather_tasks = (pbdata and {pbdata.seek_gather_tasks} or {nil})[1] --异宝寻物的已用求助的任务id
	local seek_gather_max = (pbdata and {pbdata.seek_gather_max} or {nil})[1] --异宝寻物的最大求助次数
	local done_yibao_info = (pbdata and {pbdata.done_yibao_info} or {nil})[1] --已经完成的异宝任务信息(因为此任务已经删除，但要显示在UI)
	local doing_yibao_info = (pbdata and {pbdata.doing_yibao_info} or {nil})[1] --正在进行的异宝任务信息(因为这个面板可以显示其他玩家的任务状况，自己看自己则不需要此数据)
	local main_yibao_info = (pbdata and {pbdata.main_yibao_info} or {nil})[1] --主任务信息，主要是预览奖励

	local donecount = table.count(g_YibaoCtrl.m_YibaoMyselfDoneInfo)
	local total = donecount + table.count(g_YibaoCtrl.m_YibaoMyselfDoingInfo)
	self.m_PrizeNewBox.m_Slider:SetValue(donecount/total)
	self.m_PrizeNewBox.m_SliderLbl:SetText(donecount.."/"..total)

	self:SetMainList(true)

	local leftHelpTime = g_YibaoCtrl.m_YibaoMyselfGatherMax-table.count(g_YibaoCtrl.m_YibaoMyselfGatherTasks)
	self.m_MainHelpLbl:SetText("寻物任务每天最多求助"..leftHelpTime.."/"..g_YibaoCtrl.m_YibaoMyselfGatherMax.."次，发起后无法更改求助任务")
end

--显示奖励tips
function CYibaoMySelfPart.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
end

-----------------以下是点击事件-------------------
function CYibaoMySelfPart.OnClickPrizeNewBox(self)
	self:SetMainPrizeNewInfo()
end

function CYibaoMySelfPart.OnClickTips(self)
	local zId = define.Instruction.Config.Yibao
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CYibaoMySelfPart.OnClickStarNewHelp(self, oData)
	nettask.C2GSYibaoSeekHelp(oData.taskid)
end

function CYibaoMySelfPart.OnClickStarNewDo(self, oData)
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	local doingInfo = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid)
	if doingInfo.star >= 5 then
		CTaskHelp.ClickTaskLogic(oData.data)
		CYibaoMainView:CloseView()
	else
		local starStr = ""
		for i=1, doingInfo.star do
			starStr = starStr.."#xing_1"
		end
		local windowConfirmInfo = {
			msg = "向帮派求助刷星可提高星级奖励\n当前星级\n"..starStr,
			title = "提示",
			okCallback = function ()
				CTaskHelp.ClickTaskLogic(oData.data)
				CYibaoMainView:CloseView()
			end,
			cancelCallback = function ()
				nettask.C2GSYibaoSeekHelp(oData.taskid)
			end,
			okStr = "直接前往",
			cancelStr = "求升星",
			pivot = 4, --Center
			-- color = Color.white,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end

function CYibaoMySelfPart.OnClickItemIconSp(self, oPrizeItemBox, oSid)
	-- local args = {
 --        widget = oPrizeItemBox,
 --        side = enum.UIAnchor.Side.Left,
 --        offset = Vector2.New(-10, 0)
 --    }
 --    g_WindowTipCtrl:SetWindowItemTip(oSid, args)

    g_WindowTipCtrl:SetWindowGainItemTip(oSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(oPrizeItemBox, oView.m_MainBox, enum.UIAnchor.Side.Left, Vector2.New(-10, 0))
	end, true)
end

function CYibaoMySelfPart.OnClickItemNewHelp(self, oData)
	nettask.C2GSYibaoSeekHelp(oData.taskid)
end

function CYibaoMySelfPart.OnClickItemNewDo(self, oData)
	local isCheckLimit = true
	if oData.state == "notdone" then
		local needitem = oData.data:GetSValueByKey("needitem")
		if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
			isCheckLimit = false
		end
	end
	
	local cb = nil
	if isCheckLimit then
		-- 不需要寻路，故不需要判断是否队伍中了
		-- if g_LimitCtrl:CheckIsLimit(true, true) then
		-- return
		-- end
	    cb = function ()
			-- 不自动寻路到商店，而是直接打开
			g_DialogueCtrl:ExecuteOpenShop(oData.data)
		end
	end
	CTaskHelp.ClickTaskLogic(oData.data, cb)
	CYibaoMainView:CloseView()
end

function CYibaoMySelfPart.OnClickInteractionNewDo(self, oData)
	-- 互动任务（寻路到某地去画图）
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	CTaskHelp.ClickTaskLogic(oData.data)
	CYibaoMainView:CloseView()
end

function CYibaoMySelfPart.OnClickMainBox(self, oMainBox)
	oMainBox.m_RedPointSp:SetActive(false)
end

return CYibaoMySelfPart