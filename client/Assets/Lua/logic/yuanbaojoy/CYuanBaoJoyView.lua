local CYuanBaoJoyView = class("CYuanBaoJoyView", CViewBase)

function CYuanBaoJoyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/YuanBaoJoy/YuanBaoJoyView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CYuanBaoJoyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TipsBtn = self:NewUI(2, CButton)
	self.m_LeftTimeLbl = self:NewUI(3, CLabel)
	self.m_RecordScrollView = self:NewUI(4, CScrollView)
	self.m_RecordTable = self:NewUI(5, CTable)
	self.m_RecordBoxClone = self:NewUI(6, CLabel)
	self.m_JoyTimeLbl = self:NewUI(7, CLabel)
	self.m_PrizeScrollView = self:NewUI(8, CScrollView)
	self.m_PrizeGrid = self:NewUI(9, CGrid)
	self.m_PrizeBoxClone = self:NewUI(10, CBox)
	self.m_GoldCountLbl = self:NewUI(11, CLabel)
	self.m_GoldDescLbl = self:NewUI(12, CLabel)
	self.m_OneBtn = self:NewUI(13, CButton)
	self.m_TenBtn = self:NewUI(14, CButton)
	self.m_OneNameLbl = self:NewUI(15, CLabel)
	self.m_OneMoneyLbl = self:NewUI(16, CLabel)
	self.m_OneMoneyIconSp = self:NewUI(17, CSprite)
	self.m_TenNameLbl = self:NewUI(18, CLabel)
	self.m_TenMoneyLbl = self:NewUI(19, CLabel)
	self.m_TenMoneyIconSp = self:NewUI(20, CSprite)
	self.m_ItemBox = self:NewUI(21, CBox)
	self.m_ItemIconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemDescLbl = self.m_ItemBox:NewUI(2, CLabel)
	self.m_PrizeBoxList = {}
	self.m_PrizeBox = self:NewUI(22, CBox)
	for i = 1, 14 do
		local oBox = self.m_PrizeBox:NewUI(i, CBox)
		oBox.m_IconSp = oBox:NewUI(1, CSprite)
		oBox.m_BorderSp = oBox:NewUI(2, CSprite)
		oBox.m_CountLbl = oBox:NewUI(3, CLabel)
		oBox.m_MarkSp = oBox:NewUI(4, CSprite)
		oBox.m_NameLbl = oBox:NewUI(5, CLabel)
		oBox.m_LightSp = oBox:NewUI(6, CSprite)
		oBox.m_MarkSp:SetActive(false)
		oBox.m_LightSp:SetActive(false)
		table.insert(self.m_PrizeBoxList, oBox)
	end

	self.m_OneBtn.m_UIButton.tweenTarget = nil
	self.m_TenBtn.m_UIButton.tweenTarget = nil
	self.m_OneBtn:GetComponent(classtype.BoxCollider).enabled = true
	self.m_TenBtn:GetComponent(classtype.BoxCollider).enabled = true
	self.m_OneBtn:SetBtnGrey(false)
	self.m_TenBtn:SetBtnGrey(false)

	self.m_ItemSid = data.yuanbaojoydata.CONFIG[1].hditem
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
	self.m_TenTime = data.yuanbaojoydata.CONFIG[1].item_cost10
	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CYuanBaoJoyView.InitContent(self)
	self.m_RecordBoxClone:SetActive(false)
	self.m_PrizeBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	self.m_OneBtn:AddUIEvent("click", callback(self, "OnClickOneBtn"))
	self.m_TenBtn:AddUIEvent("click", callback(self, "OnClickTenBtn"))
	self.m_ItemIconSp:AddUIEvent("click", callback(self, "OnClickItemTips"))
	
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_YuanBaoJoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlYuanBaoJoyEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWelfareEvent"))

	self:RefreshPrizeList()
end

function CYuanBaoJoyView.OnShowView(self)
	netopenui.C2GSOpenInterface(define.OpenUI.Type.YuanBaoJoy)
	nethuodong.C2GSGoldCoinPartyGetRewardInfo()
end

function CYuanBaoJoyView.OnHideView(self)
	netopenui.C2GSCloseInterface(define.OpenUI.Type.YuanBaoJoy)
end

function CYuanBaoJoyView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
	end
end

function CYuanBaoJoyView.OnCtrlYuanBaoJoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.YuanBaoJoy.Event.RefreshInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.YuanBaoJoy.Event.RefreshPrizeEffect then
		self:RefreshPrizeEffect()
	end
end

function CYuanBaoJoyView.OnCtrlWelfareEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        self:RefreshTime()
    end
end

function CYuanBaoJoyView.RefreshUI(self)
	self:SetRecordList()
	self.m_JoyTimeLbl:SetText("当天狂欢次数："..g_YuanBaoJoyCtrl.m_BaoxiangPoint)
	self:SetBaoxiangList()
	self:RefreshTime()
	self:RefreshGoldInfo()
	self:RefreshItem()
end

function CYuanBaoJoyView.RefreshTime(self)
	if g_YuanBaoJoyCtrl.m_EndTime <= 0 then
		return
	end
	local oLeftTime = g_YuanBaoJoyCtrl.m_EndTime - g_TimeCtrl:GetTimeS()
	if oLeftTime > 0 then
		self.m_LeftTimeLbl:SetText("[244B4E]活动剩余时间：[1d8e00]"..g_TimeCtrl:GetLeftTimeDHM(oLeftTime))
	else
		self.m_LeftTimeLbl:SetText("[244B4E]活动剩余时间：[1d8e00]已结束")
	end
end

function CYuanBaoJoyView.RefreshGoldInfo(self)
	self.m_GoldCountLbl:SetText(g_YuanBaoJoyCtrl.m_AllGoldCoin)
	self.m_GoldDescLbl:SetText("每次元宝狂欢的20%计入奖池")
end

function CYuanBaoJoyView.RefreshItem(self)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	self.m_ItemIconSp:SpriteItemShape(self.m_ItemConfig.icon)

	if iAmount > 0 then
		self.m_ItemDescLbl:SetText("[244B4E]"..self.m_ItemConfig.name.."：[1d8e00]"..iAmount)
	else
		self.m_ItemDescLbl:SetText("[244B4E]"..self.m_ItemConfig.name.."：[af302a]"..iAmount)	
	end

	if iAmount <= 0 then
		self.m_OneMoneyLbl:SetActive(true)
		self.m_OneMoneyIconSp:SetActive(true)
		self.m_TenMoneyLbl:SetActive(true)
		self.m_TenMoneyIconSp:SetActive(true)
		self.m_OneMoneyLbl:SetText(data.yuanbaojoydata.CONFIG[1].goldcoin_cost1)
		self.m_TenMoneyLbl:SetText(data.yuanbaojoydata.CONFIG[1].goldcoin_cost10)
		self.m_OneNameLbl:SetLocalPos(Vector3.New(-37.9, 0, 0))
		self.m_OneMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_TenNameLbl:SetLocalPos(Vector3.New(-37.9, 0, 0))
		self.m_TenMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_OneBtn:SetWidth(187)
		self.m_TenBtn:SetWidth(187)
	elseif iAmount > 0 and iAmount < self.m_TenTime then
		self.m_OneMoneyLbl:SetActive(false)
		self.m_OneMoneyIconSp:SetActive(false)
		self.m_TenMoneyLbl:SetActive(true)
		self.m_TenMoneyIconSp:SetActive(true)
		self.m_OneMoneyLbl:SetText(data.yuanbaojoydata.CONFIG[1].goldcoin_cost1)
		self.m_TenMoneyLbl:SetText(data.yuanbaojoydata.CONFIG[1].goldcoin_cost10)
		self.m_OneNameLbl:SetLocalPos(Vector3.New(0, 0, 0))
		-- self.m_OneMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_TenNameLbl:SetLocalPos(Vector3.New(-37.9, 0, 0))
		self.m_TenMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_OneBtn:SetWidth(128)
		self.m_TenBtn:SetWidth(187)
	elseif iAmount >= self.m_TenTime then
		self.m_OneMoneyLbl:SetActive(false)
		self.m_OneMoneyIconSp:SetActive(false)
		self.m_TenMoneyLbl:SetActive(false)
		self.m_TenMoneyIconSp:SetActive(false)
		self.m_OneNameLbl:SetLocalPos(Vector3.New(0, 0, 0))
		-- self.m_OneMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_TenNameLbl:SetLocalPos(Vector3.New(0, 0, 0))
		-- self.m_TenMoneyLbl:SetLocalPos(Vector3.New(19.2, 0, 0))
		self.m_OneBtn:SetWidth(128)
		self.m_TenBtn:SetWidth(128)
	end
end

function CYuanBaoJoyView.RefreshPrizeList(self)
	for k,v in ipairs(self.m_PrizeBoxList) do
		local oConfig = g_YuanBaoJoyCtrl.m_PrizeConfigList[k]
		if oConfig then
			local oSidStr = string.gsub(oConfig.itemsid, "%b()", "")
			local oItemSid = tonumber(oSidStr)
			local oItemConfig
			if k <= 3 then
				oItemConfig = nil
				v.m_NameLbl:SetText(oConfig.name)
				if k == 1 then
					v.m_IconSp:SetStaticSprite("MiscAtlas", "h7_20jc")
				elseif k == 2 then
					v.m_IconSp:SetStaticSprite("MiscAtlas", "h7_50jc")
				elseif k == 3 then
					v.m_IconSp:SetStaticSprite("MiscAtlas", "h7_30jc")
				end
				v.m_CountLbl:SetText("")
			else
				oItemConfig = DataTools.GetItemData(oItemSid)
				v.m_IconSp:SpriteItemShape(oItemConfig.icon)
				v.m_BorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ))
				v.m_NameLbl:SetText("")
				v.m_CountLbl:SetText(oConfig.amount)
			end

			if oConfig.rare > 3 then
				v.m_MarkSp:SetActive(true)
			else
				v.m_MarkSp:SetActive(false)
			end
			v.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeTips", v.m_IconSp, oItemConfig))
		end
	end
end

function CYuanBaoJoyView.SetRecordList(self)
	local optionCount = #g_YuanBaoJoyCtrl.m_RecordList
	local GridList = self.m_RecordTable:GetChildList() or {}
	local oRecordBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRecordBox = self.m_RecordBoxClone:Clone(false)
				-- self.m_RecordTable:AddChild(oOptionBtn)
			else
				oRecordBox = GridList[i]
			end
			self:SetRecordBox(oRecordBox, g_YuanBaoJoyCtrl.m_RecordList[i])
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

	self.m_RecordTable:Reposition()
	-- self.m_RecordScrollView:ResetPosition()
end

function CYuanBaoJoyView.SetRecordBox(self, oRecordBox, oData)
	oRecordBox:SetActive(true)
	local oConfig = g_YuanBaoJoyCtrl.m_PrizeConfigHashList[oData.pos]
	local oSidStr = string.gsub(oConfig.itemsid, "%b()", "")
	local oItemSid = tonumber(oSidStr)
	local oItemConfig = DataTools.GetItemData(oItemSid)
	if oData.pos == 12 or oData.pos == 13 or oData.pos == 14 then
		oRecordBox:SetText("[63432C]恭喜[244B4E]"..oData.name.."[-]\n获得[1d8e00]"..oConfig.name..oItemConfig.name.."[-]")
	else
		oRecordBox:SetText("[63432C]恭喜[244B4E]"..oData.name.."[-]\n获得[1d8e00]"..oItemConfig.name.."[-]")
	end

	self.m_RecordTable:AddChild(oRecordBox)
	self.m_RecordTable:Reposition()
end

function CYuanBaoJoyView.SetBaoxiangList(self)
	local optionCount = #data.yuanbaojoydata.BAOXIANGREWARD
	local GridList = self.m_PrizeGrid:GetChildList() or {}
	local oBaoxiangBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oBaoxiangBox = self.m_PrizeBoxClone:Clone(false)
				-- self.m_PrizeGrid:AddChild(oOptionBtn)
			else
				oBaoxiangBox = GridList[i]
			end
			self:SetBaoxiangBox(oBaoxiangBox, data.yuanbaojoydata.BAOXIANGREWARD[i])
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
	-- self.m_PrizeScrollView:ResetPosition()
end

function CYuanBaoJoyView.SetBaoxiangBox(self, oBaoxiangBox, oData)
	oBaoxiangBox:SetActive(true)
	oBaoxiangBox.m_BaoxiangSp = oBaoxiangBox:NewUI(1, CSprite)
	oBaoxiangBox.m_RedPointSp = oBaoxiangBox:NewUI(2, CSprite)
	oBaoxiangBox.m_TimeLbl = oBaoxiangBox:NewUI(3, CLabel)

	oBaoxiangBox.m_RedPointSp:SetActive(false)
	oBaoxiangBox.m_IgnoreCheckEffect = true
	-- oBaoxiangBox:DelEffect("Circu")
	if not g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] or g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 0 then
		oBaoxiangBox.m_BaoxiangSp:SetGrey(false)
		oBaoxiangBox.m_BaoxiangSp:SetSpriteName("h7_xiang_1")
	elseif g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 1 then
		oBaoxiangBox.m_BaoxiangSp:SetGrey(false)
		oBaoxiangBox.m_BaoxiangSp:SetSpriteName("h7_xiang_1")
		oBaoxiangBox.m_RedPointSp:SetActive(true)
		-- oBaoxiangBox:AddEffect("Circu")
	elseif g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 2 then
		oBaoxiangBox.m_BaoxiangSp:SetGrey(true)
		oBaoxiangBox.m_BaoxiangSp:SetSpriteName("h7_xiang_3")
	end
	oBaoxiangBox.m_TimeLbl:SetText(oData.degree.."次")

	oBaoxiangBox:AddUIEvent("click", callback(self, "OnClickBaoxiangBox", oData))

	self.m_PrizeGrid:AddChild(oBaoxiangBox)
	self.m_PrizeGrid:Reposition()
end

function CYuanBaoJoyView.RefreshPrizeEffect(self)
	local oCount = table.count(g_YuanBaoJoyCtrl.m_PrizeShowRewardList)
	if oCount == 1 then
		local oPos = g_YuanBaoJoyCtrl.m_PrizeShowRewardList[1].pos
		local function onCb()
			if oPos ~= 12 and oPos ~= 13 and oPos ~= 14 then
				local oSidStr = string.gsub(g_YuanBaoJoyCtrl.m_PrizeConfigHashList[oPos].itemsid, "%b()", "")
				local oItemSid = tonumber(oSidStr)
				local oItemData = DataTools.GetItemData(oItemSid)
				netnotify.GS2CItemNotify({sid = oItemSid, amount = g_YuanBaoJoyCtrl.m_PrizeShowRewardList[1].amount, type = 0})
				g_NotifyCtrl:FloatItemBox(oItemData.icon)
			end
		end
		local oIndex = g_YuanBaoJoyCtrl.m_PrizeConfigHashList[oPos].sort
		self:OnShowPrizeEffect(oIndex, onCb, true)
	elseif oCount > 1 then
		local function onCb()

			local oPrizeList = g_YuanBaoJoyCtrl:GetPrizeTenShowList()
			local function onFuyuanShowEnd()
				for k,v in ipairs(oPrizeList) do
					if tonumber(v.sid) then
						netnotify.GS2CItemNotify({sid = v.sid, amount = v.amount, type = 0})
					end
				end
			end
			CFuyuanTreasureRewardView:ShowView(function (oView)
	            oView:SetData(oPrizeList, onFuyuanShowEnd)
	        end)
		end
		local oPos, oValue = g_YuanBaoJoyCtrl:GetPrizeRadioMinToPos()
		local oIndex = g_YuanBaoJoyCtrl.m_PrizeConfigHashList[oPos].sort
		self:OnShowPrizeEffect(oIndex, onCb, false)		
	end
end

function CYuanBaoJoyView.OnShowPrizeEffect(self, oIndex, cb, bShowLastEffect)
	self.m_OneBtn:GetComponent(classtype.BoxCollider).enabled = false
	self.m_TenBtn:GetComponent(classtype.BoxCollider).enabled = false
	self.m_OneBtn:SetBtnGrey(true)
	self.m_TenBtn:SetBtnGrey(true)
	if self.m_PrizeShowTimer then
		Utils.DelTimer(self.m_PrizeShowTimer)
		self.m_PrizeShowTimer = nil
	end
	local oNeedTime = oIndex + 14*2
	for k,v in pairs(self.m_PrizeBoxList) do
		v.m_LightSp:SetActive(false)
	end
	local oShowTime = 0
	local oLastBox = nil
	local function onShow()
		if Utils.IsNil(self) then
			if cb then cb() end
			return false
		end
		if oShowTime >= oNeedTime then
			return false
		end
		if oLastBox then
			oLastBox.m_LightSp:SetActive(false)
		end
		oShowTime = oShowTime + 1
		local oShowIndex = oShowTime % 14 == 0 and 14 or oShowTime % 14
		self.m_PrizeBoxList[oShowIndex].m_LightSp:SetActive(true)
		oLastBox = self.m_PrizeBoxList[oShowIndex]
		if oShowTime >= oNeedTime then
			self.m_OneBtn:GetComponent(classtype.BoxCollider).enabled = true
			self.m_TenBtn:GetComponent(classtype.BoxCollider).enabled = true
			self.m_OneBtn:SetBtnGrey(false)
			self.m_TenBtn:SetBtnGrey(false)
			if bShowLastEffect then
				self.m_PrizeBoxList[oShowIndex]:DelEffect("Screen")
				self.m_PrizeBoxList[oShowIndex]:AddEffect("Screen", "ui_eff_0098")
			end
			if cb then cb() end
		end
		return true
	end
	self.m_PrizeShowTimer = Utils.AddTimer(onShow, 0.05, 0)
end

-----------------以下是点击事件----------------

function CYuanBaoJoyView.OnClickTips(self)
	local zId = 13010
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CYuanBaoJoyView.OnClickBaoxiangBox(self, oData)
	if g_YuanBaoJoyCtrl:CheckIsYuanBaoJoyEnd() then
		return
	end
	if g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 2 then
		return
	end

	local itemlist = g_GuideHelpCtrl:GetRewardList("GOLDCOINPARTY", oData.reward)

	local title = "宝箱奖励"

	local desc = nil
	local hideBtn = nil
	local cb = nil

	if not g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] or g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 0 then
		hideBtn = true
		desc = "领取宝箱将获得丰厚的奖励"
	elseif g_YuanBaoJoyCtrl.m_BaoxiangRewardList[oData.index] == 1 then
		cb = function ( ... )
			nethuodong.C2GSGoldCoinPartyGetDegreeReward(oData.index)
		end
	end 

	g_WindowTipCtrl:ShowItemBoxView({
		title = title,
        hideBtn = hideBtn,
        items = itemlist,
        comfirmText = "领取",
        desc = desc,
        comfirmCb = cb
	})
	
end

function CYuanBaoJoyView.OnClickOneBtn(self)
	if g_YuanBaoJoyCtrl:CheckIsYuanBaoJoyEnd() then
		return
	end
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	if iAmount <= 0 then
		if g_YuanBaoJoyCtrl.m_QuestionState then
			local windowConfirmInfo = {
				msg = "是否花费"..data.yuanbaojoydata.CONFIG[1].goldcoin_cost1.."#cur_1狂欢1次？",
				title = "提示",
				okCallback = function (oView)
					if oView.m_NotNotifyBtn:GetSelected() then
						g_YuanBaoJoyCtrl.m_QuestionState = false
					else
						g_YuanBaoJoyCtrl.m_QuestionState = true
					end
					if data.yuanbaojoydata.CONFIG[1].goldcoin_cost1 > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
		                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(data.yuanbaojoydata.TEXT[1003].content)
		            else
		                nethuodong.C2GSGoldCoinPartyGetLotteryReward(1, 1)
		            end
				end,
				cancelCallback = function (oView)
					
				end,
				okStr = "确定",
				cancelStr = "取消",
				notnotifytype = "YuanBaoJoy",
				notnotifytext = "本次登录不再提示",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			if data.yuanbaojoydata.CONFIG[1].goldcoin_cost1 > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(data.yuanbaojoydata.TEXT[1003].content)
            else
                nethuodong.C2GSGoldCoinPartyGetLotteryReward(1, 1)
            end
		end
	else
		nethuodong.C2GSGoldCoinPartyGetLotteryReward(1, 2)
	end
end

function CYuanBaoJoyView.OnClickTenBtn(self)
	if g_YuanBaoJoyCtrl:CheckIsYuanBaoJoyEnd() then
		return
	end
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	if iAmount < self.m_TenTime then
		if g_YuanBaoJoyCtrl.m_QuestionState then
			local windowConfirmInfo = {
				msg = "是否花费"..data.yuanbaojoydata.CONFIG[1].goldcoin_cost10.."#cur_1狂欢"..self.m_TenTime.."次？",
				title = "提示",
				okCallback = function (oView)
					if oView.m_NotNotifyBtn:GetSelected() then
						g_YuanBaoJoyCtrl.m_QuestionState = false
					else
						g_YuanBaoJoyCtrl.m_QuestionState = true
					end
					if data.yuanbaojoydata.CONFIG[1].goldcoin_cost10 > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
		                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(data.yuanbaojoydata.TEXT[1003].content)
		            else
		                nethuodong.C2GSGoldCoinPartyGetLotteryReward(10, 1)
		            end
				end,
				cancelCallback = function (oView)
					
				end,
				okStr = "确定",
				cancelStr = "取消",
				notnotifytype = "YuanBaoJoy",
				notnotifytext = "本次登录不再提示",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			if data.yuanbaojoydata.CONFIG[1].goldcoin_cost10 > g_AttrCtrl.goldcoin then --+ g_AttrCtrl.rplgoldcoin
                g_QuickGetCtrl:OnShowNotEnoughGoldCoin(data.yuanbaojoydata.TEXT[1003].content)
            else
                nethuodong.C2GSGoldCoinPartyGetLotteryReward(10, 1)
            end
		end
	else
		nethuodong.C2GSGoldCoinPartyGetLotteryReward(10, 2)
	end
end

function CYuanBaoJoyView.OnClickItemTips(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CYuanBaoJoyView.OnClickPrizeTips(self, oPrizeBox, oItemConfig)
	if not oItemConfig then
		return
	end
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 10)
    }
    g_WindowTipCtrl:SetWindowItemTip(oItemConfig.id, args)
end

function CYuanBaoJoyView.OnClose(self)
    self:CloseView()
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

return CYuanBaoJoyView