local CYibaoOtherPart = class("CYibaoOtherPart", CPageBase)

function CYibaoOtherPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TaskBoxList = {}
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
	self.m_TipBtn = self:NewUI(17, CButton)

	self.m_MainBoxClone:SetActive(false)

	self:InitContent()
end

function CYibaoOtherPart.InitPrizeNewBox(self)
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

function CYibaoOtherPart.InitMainPrizeNewBox(self)
	-- self.m_MainPrizeNewBox.m_TitleLbl = self.m_MainPrizeBox:NewUI(1, CLabel)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_ScrollView = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(2, CScrollView)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_Grid = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(3, CGrid)
	self.m_PrizeNewBox.m_MainPrizeNewBox.m_BoxClone = self.m_PrizeNewBox.m_MainPrizeNewBox:NewUI(4, CBox)

	self.m_PrizeNewBox.m_MainPrizeNewBox.m_BoxClone:SetActive(false)
	self:SetMainPrizeNewInfo()
end

function CYibaoOtherPart.SetMainPrizeNewInfo(self)
	self.m_PrizeNewBox.m_MainPrizeNewBox:SetActive(true)
	-- UITools.NearTarget(self.m_PrizeNewBox.m_IconSp, self.m_PrizeNewBox.m_MainPrizeNewBox, enum.UIAnchor.Side.Bottom)
	local oTaskConfig = g_TaskCtrl:GetYibaoMainTaskid().taskdata
	local oRewardId = string.gsub(oTaskConfig.submitRewardStr[1], "R", "")
	local oData = g_GuideHelpCtrl:GetRewardList("YIBAO", tonumber(oRewardId)) --g_YibaoCtrl.m_YibaoOtherMainInfo.itemreward_preview
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

function CYibaoOtherPart.AddMainPrizeNewBox(self, oPrize)
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

function CYibaoOtherPart.SetMainList(self, bNotReset)
	local otherData = g_YibaoCtrl:GetOtherYibaoTaskData()
	local optionCount = #otherData
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
			self:SetMainBox(oMainBox, otherData[i])
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

function CYibaoOtherPart.SetMainBox(self, oMainBox, oData)
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

	local type = oData.data.yibao_kind
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

function CYibaoOtherPart.SetMainItemBox(self, oMainBox, oData)
	oMainBox.m_ItemBox.m_CountLbl = oMainBox.m_ItemBox:NewUI(1, CLabel)
	oMainBox.m_ItemBox.m_PrizeLbl = oMainBox.m_ItemBox:NewUI(2, CLabel)
	oMainBox.m_ItemBox.m_HelpBtn = oMainBox.m_ItemBox:NewUI(3, CButton)
	oMainBox.m_ItemBox.m_DoBtn = oMainBox.m_ItemBox:NewUI(4, CButton)
	oMainBox.m_ItemBox.m_HelpBtn:SetActive(false)

	local needitem
	local taskconfig = DataTools.GetTaskData(oData.taskid)

	if oData.state == "done" then
		oMainBox.m_RedPointSp:SetActive(false)
		needitem = oData.data.needitem
		oMainBox.m_ItemBox.m_CountLbl:SetText("数量:"..needitem[1].amount.."/"..needitem[1].amount)
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)
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
		needitem = oData.data.needitem
		oMainBox.m_ItemBox.m_CountLbl:SetText("数量:"..g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid).."/"..needitem[1].amount)
		if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
			oMainBox.m_RedPointSp:SetActive(true)
			oMainBox.m_ItemBox.m_DoBtn:SetText("上交")
		else
			oMainBox.m_RedPointSp:SetActive(false)
			oMainBox.m_ItemBox.m_DoBtn:SetText("上交")
		end
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)
		oMainBox.m_ItemBox.m_DoBtn:SetActive(true)

		local doingInfo = oData.data
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

	oMainBox.m_ItemBox.m_DoBtn:AddUIEvent("click", callback(self, "OnClickItemNewDo", oData))
end

function CYibaoOtherPart.SetMainStarBox(self, oMainBox, oData)
	oMainBox.m_StarBox.m_StarBgLbl = oMainBox.m_StarBox:NewUI(1, CLabel)
	oMainBox.m_StarBox.m_StarLbl = oMainBox.m_StarBox:NewUI(2, CLabel)
	oMainBox.m_StarBox.m_PrizeLbl = oMainBox.m_StarBox:NewUI(3, CLabel)
	oMainBox.m_StarBox.m_HelpBtn = oMainBox.m_StarBox:NewUI(4, CButton)
	oMainBox.m_StarBox.m_DoBtn = oMainBox.m_StarBox:NewUI(5, CButton)
	oMainBox.m_StarBox.m_HelpBtn:SetActive(false)
	oMainBox.m_StarBox.m_DoBtn:SetActive(false)

	oMainBox.m_StarBox.m_StarBgLbl:SetText("#xing_bg".."#xing_bg".."#xing_bg".."#xing_bg".."#xing_bg")

	local taskconfig = DataTools.GetTaskData(oData.taskid)
	
	if oData.state == "done" then
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)
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
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)

		local doingInfo = oData.data
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
	end

	if data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr ~= "" then
		oMainBox.m_IconSp:SetActive(true)
		oMainBox.m_IconSp:SpriteItemShape(tonumber(data.taskdata.TASK.YIBAO.TASK[oData.taskid].clientExtStr))
	else
		oMainBox.m_IconSp:SetActive(false)
	end
end

function CYibaoOtherPart.SetMainInteractionBox(self, oMainBox, oData)
	oMainBox.m_InteractionBox.m_DescLbl = oMainBox.m_InteractionBox:NewUI(1, CLabel)
	oMainBox.m_InteractionBox.m_PrizeLbl = oMainBox.m_InteractionBox:NewUI(2, CLabel)
	oMainBox.m_InteractionBox.m_DoBtn = oMainBox.m_InteractionBox:NewUI(3, CButton)
	oMainBox.m_InteractionBox.m_DoBtn:SetActive(false)

	local taskconfig = DataTools.GetTaskData(oData.taskid)
	oMainBox.m_InteractionBox.m_DescLbl:SetText(taskconfig.description)
	if oData.state == "done" then
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)
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
		oMainBox.m_NameLbl:SetColor(Color.white)
		oMainBox.m_NameLbl:SetText("[244B4E]"..oData.data.name)

		local doingInfo = oData.data
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
end

function CYibaoOtherPart.InitContent(self)
	--暂时屏蔽宝箱预览
	-- self.m_PrizeNewBox:AddUIEvent("click", callback(self, "OnClickPrizeNewBox"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	-- self:ShowRightContent()
end

function CYibaoOtherPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		self:RefreshUI()
	end
end

function CYibaoOtherPart.RefreshUI(self, pbdata)
	local donecount = table.count(g_YibaoCtrl.m_YibaoOtherDoneInfo)
	local total = donecount + table.count(g_YibaoCtrl.m_YibaoOtherDoingInfo)
	self.m_PrizeNewBox.m_Slider:SetValue(donecount/total)
	self.m_PrizeNewBox.m_SliderLbl:SetText(donecount.."/"..total)

	self:SetMainList(true)
end

--设置选中别人求助的任务
function CYibaoOtherPart.SetClickData(self)
	if not g_YibaoCtrl.m_YibaoOtherGiveHelpTaskid then
		return
	end
	local otherData = g_YibaoCtrl:GetOtherYibaoTaskData()
	local oData = nil
	local oDataIndex = nil
	for k,v in pairs(otherData) do
		if v.taskid == g_YibaoCtrl.m_YibaoOtherGiveHelpTaskid then
			oData = v
			oDataIndex = k
			break
		end
	end

	local oBox = self.m_MainTable:GetChild(oDataIndex)
	if oBox then
		-- oBox:SetSelected(true)
		oBox:ForceSelected(true)
		UITools.MoveToTarget(self.m_MainScrollView, oBox)
	end

	g_YibaoCtrl.m_YibaoOtherGiveHelpTaskid = nil
end

--显示奖励tips
function CYibaoOtherPart.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
end

-----------------以下是点击事件-------------------
function CYibaoOtherPart.OnClickPrizeNewBox(self)
	self:SetMainPrizeNewInfo()
end

function CYibaoOtherPart.OnClickTips(self)
	local zId = define.Instruction.Config.Yibao
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CYibaoOtherPart.OnClickItemIconSp(self, oPrizeItemBox, oSid)
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

function CYibaoOtherPart.OnClickItemNewDo(self, oData)
	local needitem = oData.data.needitem
	if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
		nettask.C2GSYibaoHelpSubmit(g_YibaoCtrl.m_YibaoOtherOwner, oData.taskid, g_YibaoCtrl.m_YibaoOtherCreateDay)
		CYibaoMainView:CloseView()
	else
		local oTaskInfo = {taskid = oData.data.taskid, tasktype = define.Task.TaskType.TASK_FIND_ITEM, needitem = oData.data.needitem, name = oData.data.name}
		local oTask = CTask.New(oTaskInfo)
		g_TaskCtrl.m_HelpOtherTaskData = {}
		g_TaskCtrl.m_HelpOtherTaskData[oData.data.taskid] = oTask
		g_DialogueCtrl:ExecuteOpenShop(oTask)
		g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb = function ()
			nettask.C2GSYibaoHelpSubmit(g_YibaoCtrl.m_YibaoOtherOwner, oData.taskid, g_YibaoCtrl.m_YibaoOtherCreateDay)
			CYibaoMainView:CloseView()
		end
		CTaskHelp.SetClickTaskShopSelect(oTask)
	end
end

function CYibaoOtherPart.OnClickMainBox(self, oMainBox)
	oMainBox.m_RedPointSp:SetActive(false)
end

return CYibaoOtherPart