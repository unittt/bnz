local COfferRewardView = class("COfferRewardView", CViewBase)

function COfferRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/OfferReward/OfferRewardView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Fourth"

	self.m_ItemSid = g_OfferRewardCtrl.m_ItemSid
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
end

function COfferRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_MainScrollView = self:NewUI(2, CScrollView)
	self.m_MainGrid = self:NewUI(3, CGrid)
	self.m_MainBoxClone = self:NewUI(4, CBox)
	self.m_ItemBox = self:NewUI(5, CBox)
	self.m_ItemBoxIconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp = self.m_ItemBox:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemBoxCountDescLbl = self.m_ItemBox:NewUI(4, CLabel)
	self.m_RefreshBtn = self:NewUI(6, CButton)
	self.m_TipsBtn = self:NewUI(7, CButton)
	self.m_DoneLbl = self:NewUI(8, CLabel)
	self.m_PrizeScrollView = self:NewUI(9, CScrollView)
	self.m_PrizeGrid = self:NewUI(10, CGrid)
	self.m_PrizeBoxClone = self:NewUI(11, CBox)
	self.m_MainBoxClone:SetActive(false)
	self.m_PrizeBoxClone:SetActive(false)
	
	self:InitContent()
end

function COfferRewardView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefreshBtn"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
end

function COfferRewardView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
	end
end

function COfferRewardView.OnScheduleCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Schedule.Event.RefreshMainUI or oCtrl.m_EventID == define.Schedule.Event.RefreshSchedule then
        self:RefreshDoneLbl()
    end
end

function COfferRewardView.OnTaskCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Task.Event.RefreshXuanShang then
        self:RefreshUI()
    end
end

function COfferRewardView.RefreshUI(self)
	self:RefreshDoneLbl()
	self:RefreshItem()
	self:SetPrizeList()
	self:SetMainList()
end

function COfferRewardView.RefreshDoneLbl(self)
	-- local xuanshangScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.XUANSHANG)
	-- if not xuanshangScheduleData then
	-- 	self.m_DoneLbl:SetText("[244B4E]今日追捕次数：[1d8e00]0/"..data.taskdata.XUANSHANGCONFIG[1].max_times)
	-- 	return
	-- end
	-- self.m_DoneLbl:SetText("[244B4E]今日追捕次数：[1d8e00]"..xuanshangScheduleData.times.."/"..xuanshangScheduleData.maxtimes)

	self.m_DoneLbl:SetText("[244B4E]今日追捕次数：[1d8e00]"..g_TaskCtrl.m_XuanShangHasDoneTime.."/"..data.taskdata.XUANSHANGCONFIG[1].max_times)
end

function COfferRewardView.RefreshItem(self)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	self.m_ItemBoxIconSp:SpriteItemShape(self.m_ItemConfig.icon)
	self.m_ItemBoxBorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig.id, self.m_ItemConfig.quality or 0 ))
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl:SetText("[0fff32]"..iAmount)
		self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl:SetText("[ffb398]"..iAmount)
		self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("cd0000"))
	end
end

function COfferRewardView.SetMainList(self)
	local optionCount = #g_TaskCtrl.m_XuanShangAceTaskData
	self.m_MainGrid:Clear()
	local GridList = self.m_MainGrid:GetChildList() or {}
	local oMainBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oMainBox = self.m_MainBoxClone:Clone(false)
				-- self.m_MainGrid:AddChild(oOptionBtn)
			else
				oMainBox = GridList[i]
			end
			self:SetMainBox(oMainBox, g_TaskCtrl.m_XuanShangAceTaskData[i])
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

	self.m_MainGrid:Reposition()
	-- self.m_MainScrollView:ResetPosition()
end

function COfferRewardView.SetMainBox(self, oMainBox, oData)
	oMainBox:SetActive(true)
	oMainBox.m_ActorTexture = oMainBox:NewUI(1, CActorTexture)
	oMainBox.m_NameLbl = oMainBox:NewUI(2, CLabel)
	oMainBox.m_StarGrid = oMainBox:NewUI(3, CGrid)
	oMainBox.m_StarClone = oMainBox:NewUI(4, CSprite)
	oMainBox.m_GoBtn = oMainBox:NewUI(5, CButton)
	oMainBox.m_HasGetSp = oMainBox:NewUI(6, CSprite)
	oMainBox.m_HasFinishSp = oMainBox:NewUI(7, CSprite)
	oMainBox.m_StarClone:SetActive(false)

	local oNpcData = DataTools.GetTaskNpcByTaskType(oData.npcid, define.Task.TaskCategory.XUANSHANG.NAME)
	local model_info = {}
	model_info.shape = oNpcData.figureid
	-- model_info.rendertexSize = 1
	oMainBox.m_ActorTexture:ChangeShape(model_info)
	oMainBox.m_NameLbl:SetText(oNpcData.name)
	self:SetStart(oMainBox, oData.star)
	--1未接受 2已接受 3已完成
	if oData.status == 1 then
		oMainBox.m_GoBtn:SetActive(true)
		oMainBox.m_HasGetSp:SetActive(false)
		oMainBox.m_HasFinishSp:SetActive(false)
	elseif oData.status == 2 then
		oMainBox.m_GoBtn:SetActive(false)
		oMainBox.m_HasGetSp:SetActive(true)
		oMainBox.m_HasFinishSp:SetActive(false)
	elseif oData.status == 3 then
		oMainBox.m_GoBtn:SetActive(false)
		oMainBox.m_HasGetSp:SetActive(false)
		oMainBox.m_HasFinishSp:SetActive(true)
	else
		oMainBox.m_GoBtn:SetActive(false)
		oMainBox.m_HasGetSp:SetActive(false)
		oMainBox.m_HasFinishSp:SetActive(false)
	end

	oMainBox.m_GoBtn:AddUIEvent("click", callback(self, "OnClickMainBoxGoBtn", oData))

	self.m_MainGrid:AddChild(oMainBox)
	self.m_MainGrid:Reposition()
end

function COfferRewardView.SetStart(self, oBox, count)
	local startBoxList = oBox.m_StarGrid:GetChildList()
	local startBox = nil
	for i=1,5 do
		if i > #startBoxList then
			startBox = oBox.m_StarClone:Clone()
			oBox.m_StarGrid:AddChild(startBox)
			startBox:SetActive(true)
		else
			startBox = startBoxList[i]
		end
		startBox:SetGrey(i > count)
	end
end

function COfferRewardView.SetPrizeList(self)
    local optionCount = #g_OfferRewardCtrl.m_OfferRewardPrizeConfig
    local GridList = self.m_PrizeGrid:GetChildList() or {}
    local oPrizeItemBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPrizeItemBox = self.m_PrizeBoxClone:Clone(false)
                -- self.m_PrizeGrid:AddChild(oOptionBtn)
            else
                oPrizeItemBox = GridList[i]
            end
            self:SetPrizeBox(oPrizeItemBox, g_OfferRewardCtrl.m_OfferRewardPrizeConfig[i])
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

    self.m_PrizeGrid:Reposition()
    self.m_PrizeScrollView:ResetPosition()
end

function COfferRewardView.SetPrizeBox(self, oPrizeItemBox, oData)
    oPrizeItemBox:SetActive(true)
    oPrizeItemBox.m_IconSp = oPrizeItemBox:NewUI(1, CSprite)
    oPrizeItemBox.m_CountLbl = oPrizeItemBox:NewUI(2, CLabel)
    oPrizeItemBox.m_QualitySp = oPrizeItemBox:NewUI(3, CSprite)
    oPrizeItemBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
    oPrizeItemBox.m_IconSp:SpriteItemShape(oData.item.icon)
    oPrizeItemBox.m_Data = oData
    if oData.amount > 0 then
        oPrizeItemBox.m_CountLbl:SetActive(true)
        oPrizeItemBox.m_CountLbl:SetText(oData.amount)
    else
        oPrizeItemBox.m_CountLbl:SetActive(false)
    end
    
    oPrizeItemBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, oPrizeItemBox, oData))

    self.m_PrizeGrid:AddChild(oPrizeItemBox)
    self.m_PrizeGrid:Reposition()
end

function COfferRewardView.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

--------------以下为点击事件-------------

function COfferRewardView.OnClickMainBoxGoBtn(self, oData)
	nettask.C2GSAcceptXuanShangTask(oData.taskid)
end

function COfferRewardView.OnClickItemBox(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	    oView.m_DepthType = "Fourth"
		g_ViewCtrl:TopView(oView)
	 end)
end

function COfferRewardView.OnClickRefreshBtn(self)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	if iAmount <= 0 then 
	    -- g_NotifyCtrl:FloatMsg(name .. "不足")
        g_QuickGetCtrl:CheckLackItemInfo({
        	itemlist = {{sid = self.m_ItemSid, count = iAmount, amount = 1}},
        	depthType = "Fourth",
        	exchangeCb = function()
    			nettask.C2GSRefreshXuanShang(1)
        	end
        })
	    return
	end 
	nettask.C2GSRefreshXuanShang()
end

function COfferRewardView.OnClickTipsBtn(self)
	local zContent = {title = data.instructiondata.DESC[10055].title,desc = data.instructiondata.DESC[10055].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

return COfferRewardView