local CJjcMainNewView = class("CJjcMainNewView", CViewBase)

function CJjcMainNewView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Jjc/JjcMainNewView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CJjcMainNewView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_RankLbl = self:NewUI(4, CLabel)
	self.m_ScoreLbl = self:NewUI(5, CLabel)
	self.m_LeftCountLbl = self:NewUI(6, CLabel)
	self.m_TipsBtn = self:NewUI(7, CButton)
	self.m_JifenBtn = self:NewUI(8, CButton)
	self.m_AddCountBtn = self:NewUI(9, CButton)
	self.m_DayPrizeBtn = self:NewUI(10, CButton)
	self.m_SeasonPrizeBtn = self:NewUI(11, CButton)
	self.m_FirstPrizeBtn = self:NewUI(12, CButton)
	self.m_FirstPrizeBtn.m_IgnoreCheckEffect = true
	self.m_InfoBtn = self:NewUI(13, CButton)
	self.m_RefreshBtn = self:NewUI(14, CButton)
	self.m_MessageScrollView = self:NewUI(15, CScrollView)
	self.m_MessageGrid = self:NewUI(16, CGrid)
	self.m_MessageBoxClone = self:NewUI(17, CBox)
	self.m_TopScrollView = self:NewUI(18, CScrollView)
	self.m_TopGrid = self:NewUI(19, CGrid)
	self.m_TopBoxClone = self:NewUI(20, CBox)

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CJjcMainNewView.InitContent(self)
	netjjc.C2GSOpenJJCMainUI()

	self.m_MessageBoxClone:SetActive(false)
	self.m_TopBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickJjcSingleTips"))
	self.m_DayPrizeBtn:AddUIEvent("click", callback(self, "OnClickShowDayPrize"))
	self.m_SeasonPrizeBtn:AddUIEvent("click", callback(self, "OnClickShowSeasonPrize"))
	self.m_AddCountBtn:AddUIEvent("click", callback(self, "OnClickAddCount"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickShowInfo"))
	self.m_JifenBtn:AddUIEvent("click", callback(self, "OnClickJifenBtn"))
	self.m_FirstPrizeBtn:AddUIEvent("click", callback(self, "OnClickFirstPrizeBtn"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefreshBtn"))
	g_JjcCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlJjcEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:RefreshSysEff()
end

function CJjcMainNewView.OnShowView(self)
	netopenui.C2GSOpenInterface(define.OpenUI.Type.Jjc)
	netjjc.C2GSJJCGetFightLog()
end

function CJjcMainNewView.OnHideView(self)
	netopenui.C2GSCloseInterface(define.OpenUI.Type.Jjc)
end

function CJjcMainNewView.OnCtrlJjcEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Jjc.Event.RefreshJJCMainUI then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCMainRefreshCountTime then
		self:RefreshJjcCountTime()
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCFightLog then
		self:SetMessageList()
	end
end

function CJjcMainNewView.OnCtrlAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        self:RefreshJjcPoint()
    end
end

function CJjcMainNewView.RefreshSysEff(self)
	g_SysUIEffCtrl:DelSysEff("JJC_SYS")
	g_SysUIEffCtrl:DelSysEff("JJC_SYS",2)
end

function CJjcMainNewView.RefreshUI(self)
	local model_info = {}
	model_info = table.copy(g_AttrCtrl.model_info)
	model_info.horse = nil
	self.m_ActorTexture:ChangeShape(model_info)
	self:RefreshRank()
	self:RefreshJjcPoint()
	self:RefreshJjcCountTime()
	self:RefreshFirstPrize()
	self:SetTargetList()
	self:SetMessageList()
end

function CJjcMainNewView.RefreshRank(self)
	if g_JjcCtrl.m_Rank == 0 then
		self.m_RankLbl:SetText("[244B4E]排  名：[a64e00]"..g_JjcCtrl.m_JjcOutSideRankStr)
	else
		self.m_RankLbl:SetText("[244B4E]排  名：[a64e00]"..g_JjcCtrl.m_Rank)
	end
	self.m_LeftCountLbl:SetText("[244B4E]挑战次数："..g_JjcCtrl.m_LeftCount)
end

function CJjcMainNewView.RefreshJjcPoint(self)
	self.m_ScoreLbl:SetText("[244B4E]积  分："..g_AttrCtrl.jjcpoint)
end

function CJjcMainNewView.RefreshJjcCountTime(self)
	if g_JjcCtrl.m_JjcMainRefreshCountTime > 0 then
		self.m_RefreshBtn:SetBtnGrey(true)
		self.m_RefreshBtn:GetComponent(classtype.BoxCollider).enabled = false
		self.m_RefreshBtn:SetText(os.date("#R%M:%S#n", g_JjcCtrl.m_JjcMainRefreshCountTime))
	else
		self.m_RefreshBtn:SetBtnGrey(false)
		self.m_RefreshBtn:GetComponent(classtype.BoxCollider).enabled = true
		self.m_RefreshBtn:SetText("刷新对手")
	end
end

function CJjcMainNewView.RefreshFirstPrize(self)
	self.m_FirstPrizeBtn.m_UIButton.tweenTarget = nil
	if g_JjcCtrl.m_JjcMainFirstGiftData == 0 then
		self.m_FirstPrizeBtn:SetColor(Color.RGBAToColor("FFFFFFFF"))
		self.m_FirstPrizeBtn:DelEffect("Circu")
	elseif g_JjcCtrl.m_JjcMainFirstGiftData == 1 then
		self.m_FirstPrizeBtn:SetColor(Color.RGBAToColor("FFFFFFFF"))
		self.m_FirstPrizeBtn:AddEffect("Circu")
	else
		self.m_FirstPrizeBtn:SetColor(Color.RGBAToColor("000000FF"))
		self.m_FirstPrizeBtn:DelEffect("Circu")
	end
end

function CJjcMainNewView.SetTargetList(self)
	local oList = g_JjcCtrl:GetJjcNewTargetList()
	local optionCount = #oList
	local GridList = self.m_TopGrid:GetChildList() or {}
	local oTargetBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTargetBox = self.m_TopBoxClone:Clone(false)
				-- self.m_TopGrid:AddChild(oOptionBtn)
			else
				oTargetBox = GridList[i]
			end
			self:SetTargetBox(oTargetBox, oList[i])
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

	self.m_TopGrid:Reposition()
	self.m_TopScrollView:ResetPosition()
	-- local oLastBox = self.m_TopGrid:GetChild(optionCount)
	-- if oLastBox then
	-- 	UITools.MoveToTarget(self.m_TopScrollView, oTargetBox)
	-- end
end

function CJjcMainNewView.SetTargetBox(self, oTargetBox, oData)
	oTargetBox:SetActive(true)
	oTargetBox.m_NameLbl = oTargetBox:NewUI(1, CLabel)
	oTargetBox.m_IconSp = oTargetBox:NewUI(2, CSprite)
	oTargetBox.m_OtherLbl = oTargetBox:NewUI(3, CLabel)
	oTargetBox.m_ItemBtn = oTargetBox:NewUI(4, CWidget)
	oTargetBox.m_ChallengeBtn = oTargetBox:NewUI(5, CButton)
	oTargetBox.m_LevelLbl = oTargetBox:NewUI(6, CLabel)
	oTargetBox.m_SchoolSp = oTargetBox:NewUI(7, CSprite)
	oTargetBox.m_RankSp = oTargetBox:NewUI(8, CSprite)
	oTargetBox.m_RankLbl = oTargetBox:NewUI(9, CLabel)
	oTargetBox.m_PartnerGrid = oTargetBox:NewUI(10, CGrid)

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_IconSp = oBox:NewUI(1, CSprite)
		oBox.m_LevelLbl = oBox:NewUI(2, CLabel)
		return oBox
	end
	oTargetBox.m_PartnerGrid:InitChild(init)
	local oChildList = oTargetBox.m_PartnerGrid:GetChildList() or {}
	for k,v in ipairs(oChildList) do
		if oData.data.fighters and oData.data.fighters[k] then
			v.m_IconSp:SpriteAvatar(oData.data.fighters[k].icon)
		else
			v.m_IconSp:SetSpriteName("empty")
		end
	end

	oTargetBox.m_NameLbl:SetText(oData.data.name)
	oTargetBox.m_IconSp:SpriteAvatar(oData.data.model.shape)
	oTargetBox.m_SchoolSp:SpriteSchool(oData.data.school)
	oTargetBox.m_LevelLbl:SetText(oData.data.grade.."级")
	if oData.type == 1 then
		oTargetBox.m_RankLbl:SetText("排名：")
		oTargetBox.m_RankSp:SetActive(true)
		if oData.data.rank == 1 then
			oTargetBox.m_RankSp:SetSpriteName("h7_diyi")
		elseif oData.data.rank == 2 then
			oTargetBox.m_RankSp:SetSpriteName("h7_dier")
		elseif oData.data.rank == 3 then
			oTargetBox.m_RankSp:SetSpriteName("h7_disan")
		else
			oTargetBox.m_RankSp:SetSpriteName("h7_disan")
		end
		oTargetBox.m_ChallengeBtn:SetActive(false)
	elseif oData.type == 2 then
		oTargetBox.m_RankSp:SetActive(false)
		oTargetBox.m_ChallengeBtn:SetActive(true)
		if oData.data.rank == 0 then
			oTargetBox.m_RankLbl:SetText("排名："..g_JjcCtrl.m_JjcOutSideRankStr)
		else
			oTargetBox.m_RankLbl:SetText("排名："..oData.data.rank)
		end			
	end
	
	oTargetBox.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickTargetChallenge", oData))

	self.m_TopGrid:AddChild(oTargetBox)
	self.m_TopGrid:Reposition()
end

function CJjcMainNewView.SetMessageList(self)
	local optionCount = #g_JjcCtrl.m_JjcFightLogList
	local GridList = self.m_MessageGrid:GetChildList() or {}
	local oMessageBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oMessageBox = self.m_MessageBoxClone:Clone(false)
				-- self.m_MessageGrid:AddChild(oOptionBtn)
			else
				oMessageBox = GridList[i]
			end
			self:SetMessageBox(oMessageBox, g_JjcCtrl.m_JjcFightLogList[i], i)
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

	self.m_MessageGrid:Reposition()
	-- self.m_MessageScrollView:ResetPosition()
end

function CJjcMainNewView.SetMessageBox(self, oMessageBox, oData, oIndex)
	oMessageBox:SetActive(true)
	oMessageBox.m_MsgLbl = oMessageBox:NewUI(1, CLabel)
	oMessageBox.m_BgSp = oMessageBox:NewUI(2, CSprite)

	-- local totalTime = g_TimeCtrl:GetTimeS() - oData.time
	-- oMsgBox.m_timeLbl:SetText(self:GetTimeDesc(totalTime))

	local resultstr = "[1d8e00]"..oData.fighter.."[-]向你发起了挑战"
	if oData.win == 1 then
		resultstr = "[1d8e00]"..oData.fighter.."[-]向你发起了挑战"
		resultstr = resultstr..",你[1d8e00]防守成功[-],排名不变"
	else
		resultstr = "[1d8e00]"..oData.fighter.."[-]挑战了你"
		if oData.rank and oData.rank ~= 0 then
			resultstr = resultstr..",你#R防守失败#n,排名降至#R"..oData.rank.."#n"
		else
			resultstr = resultstr..",你#R防守失败#n,排名降至#R"..g_JjcCtrl.m_JjcOutSideRankStr.."#n"
		end
	end
	oMessageBox.m_MsgLbl:SetText("[244B4E]"..resultstr)
	if oIndex%2 == 0 then
		oMessageBox.m_BgSp:SetSpriteName("h7_di_5")
	else
		oMessageBox.m_BgSp:SetSpriteName("h7_di_4")
	end

	self.m_MessageGrid:AddChild(oMessageBox)
	self.m_MessageGrid:Reposition()
end

----------------以下是点击事件----------------

function CJjcMainNewView.OnClickJjcSingleTips(self)
	local zId = define.Instruction.Config.JjcMain
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CJjcMainNewView.OnClickShowDayPrize(self)
	-- local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
	-- self:SetDayPrizeInfo(g_JjcCtrl:GetDayConfigPrize(rank))

	CJjcPrizeView:ShowView(function (oView)
		oView:RefreshUI(define.Jjc.PrizeType.Day, self.m_DayPrizeBtn)
	end)
end

function CJjcMainNewView.OnClickShowSeasonPrize(self)
	-- local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
	-- self:SetMonthPrizeInfo(g_JjcCtrl:GetMonthConfigPrize(rank))

	CJjcPrizeView:ShowView(function (oView)
		oView:RefreshUI(define.Jjc.PrizeType.Month, self.m_SeasonPrizeBtn)
	end)
end

function CJjcMainNewView.OnClickAddCount(self)
	if g_JjcCtrl.m_JjcMainHasBuy >= data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].hasbuy[2] then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.MainMaxTime].content)
	else
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.AddCount].content, "#num", self:GetJJCBuyTimeMoney(g_JjcCtrl.m_JjcMainHasBuy + 1)),
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSJJCBuyFightTimes()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	end
end

--传的参数需要加1，如g_JjcCtrl.m_JjcMainHasBuy + 1
function CJjcMainNewView.GetJJCBuyTimeMoney(self, hasbuy)
	for k,v in ipairs(data.jjcdata.BUYJJCTIME) do
		if v.hasbuy[1] <= hasbuy and (v.hasbuy[2] and v.hasbuy[2] or v.hasbuy[1]) >= hasbuy then
			return v.gold
		end
	end
	return data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].gold
end

function CJjcMainNewView.OnClickShowInfo(self)
	-- CJjcSingleSelectView:ShowView()
	CPartnerMainView:ShowView( function(oView)
		oView:ResetCloseBtn()
		oView:ShowSubPageByIndex(oView:GetPageIndex("Lineup"))
	end)
end

function CJjcMainNewView.OnClickJifenBtn(self)
	g_ShopCtrl:ShowScoreShop(102)
end

function CJjcMainNewView.OnClickFirstPrizeBtn(self)
	if g_JjcCtrl.m_JjcMainFirstGiftData == 0 then
		-- g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FirstNotGet].content)
		CJjcPrizeView:ShowView(function (oView)
			oView:RefreshUI(define.Jjc.PrizeType.First, self.m_FirstPrizeBtn)
		end)
		return
	elseif g_JjcCtrl.m_JjcMainFirstGiftData == 2 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FirstHasGet].content)
		return
	end
	netjjc.C2GSReceiveFirstGift()
end

function CJjcMainNewView.OnClickRefreshBtn(self)
	if g_JjcCtrl.m_JjcMainRefreshCountTime > 0 then
		return
	end
	netjjc.C2GSRefreshJJCTarget()
end

function CJjcMainNewView.OnClickTargetChallenge(self, oData)
	if oData.type == 1 then
		return
	end
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
		return
	end
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	if g_JjcCtrl.m_LeftCount <= 0 then
		if g_JjcCtrl.m_JjcMainHasBuy >= data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].hasbuy[2] then
			g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.MainMaxTime].content)
		else
			local windowConfirmInfo = {
				msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.AddCountBtn].content, "#num", self:GetJJCBuyTimeMoney(g_JjcCtrl.m_JjcMainHasBuy + 1)),
				title			= "提示",
				okCallback = function ()
					netjjc.C2GSJJCBuyFightTimes()
				end,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
				self.m_WinTipViwe = oView
			end)
		end
		return
	end
	local ValueStr = string.gsub(data.jjcdata.JJCGLOBAL[1].cd_cost, "minute", tostring(math.ceil(tonumber(g_JjcCtrl.m_JjcMainCountTime/60))))
	local Value = load(string.format([[return (%s)]], ValueStr))()
	if g_JjcCtrl.m_JjcMainCountTime and g_JjcCtrl.m_JjcMainCountTime > 0 then
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.SpeedTimeBtn].content, "#num", math.ceil(tonumber(Value))),
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSJJCClearCD()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
		return
	end
	netjjc.C2GSJJCStartFight({id = oData.data.id, type = oData.data.type})
	-- self:OnClose()
end

return CJjcMainNewView