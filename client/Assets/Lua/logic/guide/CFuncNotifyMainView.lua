local CFuncNotifyMainView = class("CFuncNotifyMainView", CViewBase)

function CFuncNotifyMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/FuncNotifyMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CFuncNotifyMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_ArrowLeftBtn = self:NewUI(5, CButton)
	self.m_ArrowRightBtn = self:NewUI(6, CButton)

	g_GuideCtrl:AddGuideUI("preopen_close_btn", self.m_CloseBtn)
	
	self:InitContent()
end

function CFuncNotifyMainView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ArrowLeftBtn:AddUIEvent("click", callback(self, "OnClickArrow", 1))
	self.m_ArrowRightBtn:AddUIEvent("click", callback(self, "OnClickArrow", 2))

	g_GuideHelpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CFuncNotifyMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Guide.Event.PreOpen then
		self:SetPreOpenList(true)
	end
end

function CFuncNotifyMainView.RefreshUI(self, oId)
	self:SetPreOpenList()

	local oSelectId = oId or 1
	if #g_GuideHelpCtrl.m_PreOpenConfigList >= 3 then
		if oSelectId <= 1 then
			oSelectId = 2
		elseif oSelectId >= #g_GuideHelpCtrl.m_PreOpenConfigList then
			oSelectId = #g_GuideHelpCtrl.m_PreOpenConfigList - 1
		end
	end
	self:MoveToTargetId(oSelectId)
end

function CFuncNotifyMainView.MoveToTargetId(self, oId)
	local oBox = self.m_Grid:GetChild(oId)
	if not oBox then
		return
	end
	UITools.MoveToTarget(self.m_ScrollView, oBox)
end

function CFuncNotifyMainView.SetPreOpenList(self, bIsNotReset)
	local optionCount = #g_GuideHelpCtrl.m_PreOpenConfigList
	local GridList = self.m_Grid:GetChildList() or {}
	local oPreopenBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPreopenBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPreopenBox = GridList[i]
			end
			self:SetPreOpenBox(oPreopenBox, g_GuideHelpCtrl.m_PreOpenConfigList[i], i)
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
	if not bIsNotReset then
		self.m_ScrollView:ResetPosition()
	end
end

function CFuncNotifyMainView.SetPreOpenBox(self, oPreopenBox, oData, oIndex)
	oPreopenBox:SetActive(true)
	oPreopenBox.m_LevelLbl = oPreopenBox:NewUI(1, CLabel)
	oPreopenBox.m_IconSp = oPreopenBox:NewUI(2, CButton)
	oPreopenBox.m_NameLbl = oPreopenBox:NewUI(3, CLabel)
	oPreopenBox.m_HasFitSp = oPreopenBox:NewUI(4, CSprite)
	oPreopenBox.m_GetBtn = oPreopenBox:NewUI(5, CButton)
	oPreopenBox.m_HasGetSp = oPreopenBox:NewUI(6, CSprite)
	oPreopenBox.m_BoxBtn = oPreopenBox:NewUI(7, CWidget)
	oPreopenBox.m_ActorTexture = oPreopenBox:NewUI(8, CActorTexture)
	oPreopenBox.m_PrizeBox = oPreopenBox:NewUI(9, CBox)
	oPreopenBox.m_PrizeBox.m_IconSp = oPreopenBox.m_PrizeBox:NewUI(1, CSprite)
	oPreopenBox.m_PrizeBox.m_CountLbl = oPreopenBox.m_PrizeBox:NewUI(2, CLabel)
	oPreopenBox.m_PrizeBox.m_QualitySp = oPreopenBox.m_PrizeBox:NewUI(3, CSprite)
    
	oPreopenBox.m_HasGetSp:SetActive(false)
	oPreopenBox.m_ActorTexture:SetActive(false)
	oPreopenBox.m_PrizeBox.m_QualitySp:SetActive(false)

	oPreopenBox.m_LevelLbl:SetText(oData.reward_grade.."级")
	-- if oData.icon.type == 1 then
	-- 	oPreopenBox.m_ActorTexture:SetActive(true)
	-- 	oPreopenBox.m_IconSp:SetActive(false)
	-- 	local model_info = {}
	-- 	model_info.figure = tonumber(oData.icon.args)
	-- 	model_info.horse = nil
	-- 	oPreopenBox.m_ActorTexture:ChangeShape(model_info)
	-- else
	-- 	oPreopenBox.m_ActorTexture:SetActive(false)
	-- 	oPreopenBox.m_IconSp:SetActive(true)
	-- 	oPreopenBox.m_IconSp:SetSpriteName(oData.icon.args)
	-- 	oPreopenBox.m_IconSp:MakePixelPerfect()
	-- end

	oPreopenBox.m_IconSp:SetSpriteName(oData.viewicon)
	oPreopenBox.m_IconSp:MakePixelPerfect()
	if g_AttrCtrl.grade >= oData.reward_grade then
		oPreopenBox.m_HasFitSp:SetSpriteName("h7_yidacheng")
	else
		oPreopenBox.m_HasFitSp:SetSpriteName("h7_weidacheng")
	end
	local oIsGet = g_GuideHelpCtrl:GetIsPreOpenHasRewarded(oData.id)
	if g_AttrCtrl.grade >= oData.reward_grade and oIsGet then
		oPreopenBox.m_GetBtn:SetSpriteName("h7_an_5")
		oPreopenBox.m_GetBtn:SetText("已领取")
		if not g_GuideCtrl.m_Flags["PreOpen"] then
			oPreopenBox.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = true
		else
			oPreopenBox.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
		end
		oPreopenBox.m_GetBtn:SetTextColor(Color.RGBAToColor("526A6CFF"))
	elseif g_AttrCtrl.grade >= oData.reward_grade and not oIsGet then
		oPreopenBox.m_GetBtn:SetSpriteName("h7_an_2")
		oPreopenBox.m_GetBtn:SetText("领取")
		oPreopenBox.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = true
		oPreopenBox.m_GetBtn:SetTextColor(Color.RGBAToColor("EEFFFBFF"))
	elseif g_AttrCtrl.grade < oData.reward_grade then
		oPreopenBox.m_GetBtn:SetSpriteName("h7_an_5")
		oPreopenBox.m_GetBtn:SetText("领取")
		oPreopenBox.m_GetBtn:GetComponent(classtype.BoxCollider).enabled = false
		oPreopenBox.m_GetBtn:SetTextColor(Color.RGBAToColor("526A6CFF"))
	end
	local oPrizeList = g_GuideHelpCtrl:GetRewardList("PREOPEN", oData.rewardid)
	if oPrizeList[1] then
		oPreopenBox.m_PrizeBox:SetActive(true)
		oPreopenBox.m_PrizeBox.m_CountLbl:SetText(oPrizeList[1].amount)
		oPreopenBox.m_PrizeBox:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrizeList[1], oPreopenBox.m_PrizeBox))
		if oPrizeList[1].type == 1 then
			oPreopenBox.m_PrizeBox.m_QualitySp:SetActive(true)
			oPreopenBox.m_PrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oPrizeList[1].item.id, oPrizeList[1].item.quality or 0 ))
			oPreopenBox.m_PrizeBox.m_IconSp:SpriteItemShape(oPrizeList[1].item.icon)	
		elseif oPrizeList[1].type == 2 then
			oPreopenBox.m_PrizeBox.m_IconSp:SpriteAvatar(oPrizeList[1].partner.shape)
		elseif oPrizeList[1].type == 3 then
			oPreopenBox.m_PrizeBox.m_IconSp:SpriteAvatar(oPrizeList[1].ride.shape)
		end
	else
		oPreopenBox.m_PrizeBox:SetActive(false)
	end

	if oData.id == g_GuideHelpCtrl.m_PreOpenGuideId then
		g_GuideCtrl:AddGuideUI("preopen_get_btn", oPreopenBox.m_GetBtn)
	elseif oData.id == g_GuideHelpCtrl.m_RideGuideId then
		g_GuideCtrl:AddGuideUI("preopen_ride_get_btn", oPreopenBox.m_GetBtn)
	elseif oData.id == g_GuideHelpCtrl.m_WingGuideId then
		g_GuideCtrl:AddGuideUI("preopen_wing_get_btn", oPreopenBox.m_GetBtn)
	end

	oPreopenBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPreOpenIcon", oData))
	oPreopenBox.m_GetBtn:AddUIEvent("click", callback(self, "OnClickGetPreOpen", oData))

	self.m_Grid:AddChild(oPreopenBox)
	self.m_Grid:Reposition()
end

function CFuncNotifyMainView.OnClickPrizeBox(self, oPrize, oPrizeBox)
	if oPrize.type == 1 then
		local args = {
	        widget = oPrizeBox,
	        side = enum.UIAnchor.Side.Top,
	        offset = Vector2.New(0, 0)
	    }
	    g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
	elseif oPrize.type == 2 then
		g_PartnerCtrl.m_PartnerNotSelectFirst = true
		CPartnerMainView:ShowView(function (oView)
			oView:ResetCloseBtn()
			oView:SetSpecificPartnerIDNode(oPrize.partner.id)
		end)
	elseif oPrize.type == 3 then
		CHorseMainView:ShowView(function (oView)
			oView:ShowSpecificPart(oView:GetPageIndex("detail"))
			oView:ChooseDetailPartHorse(oPrize.ride.id)
		end)
	end
end

function CFuncNotifyMainView.OnClickPreOpenIcon(self, oData)
	local oScheduleSid = tonumber(oData.desc)
	if oData.desc ~= "" and not oScheduleSid then
		CSimpleDescTipsView:ShowView(function (oView)
			oView:RefreshUI(oData.desc)
		end)
	elseif oScheduleSid then
		CScheduleInfoView:ShowView(function(oView)
			oView.m_IsCouldClickClose = true
			oView:SetScheduleID(oScheduleSid)
		end)
	end
end

function CFuncNotifyMainView.OnClickGetPreOpen(self, oData)
	if not oData then
		return
	end
	local oIsGet = g_GuideHelpCtrl:GetIsPreOpenHasRewarded(oData.id)
	if not oIsGet and g_AttrCtrl.grade >= oData.reward_grade then
		if oData.id == g_GuideHelpCtrl.m_PreOpenGuideId then
			g_GuideHelpCtrl.m_IsPreOpenPrizeGet = true
		elseif oData.id == g_GuideHelpCtrl.m_RideGuideId then
			g_GuideHelpCtrl.m_IsRidePrizeGet = true
		end
		netplayer.C2GSRewardPreopenGift(oData.id)
	end
end

function CFuncNotifyMainView.OnClickArrow(self, oIndex)
	if oIndex == 1 then
		self.m_ScrollView:Scroll(-2)
	elseif oIndex == 2 then
		self.m_ScrollView:Scroll(2)
	end
end

return CFuncNotifyMainView