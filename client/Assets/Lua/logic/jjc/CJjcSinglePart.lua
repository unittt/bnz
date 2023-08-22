local CJjcSinglePart = class("CJjcSinglePart", CPageBase)

function CJjcSinglePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CurClickBuddyBox = nil
	self.m_TargeBoxPos = {}
	--暂时屏蔽
	-- for i = 1, 5, 1 do
	-- 	self.m_TargeBoxPos[i] = Vector3.New(-375 + (i-1)*180, 7, 0)
	-- end
	for i = 1, 5, 1 do
		self.m_TargeBoxPos[i] = Vector3.New(-375 + (i-1)*225, 7, 0)
	end
	self.m_ChallengeGroupList = {}
	self.m_HelpList = {}
	for i = 1, 5, 1 do
		table.insert(self.m_ChallengeGroupList, self:NewUI(i, CJjcSingleBox))
	end
	g_GuideCtrl:AddGuideUI("jjc_item1_challenge_btn", self.m_ChallengeGroupList[2].m_ChallengeBtn)
	self.m_MessageBtn = self:NewUI(6, CButton)
	self.m_RankLbl = self:NewUI(7, CLabel)
	self.m_DayScrolllView = self:NewUI(8, CScrollView)
	self.m_SeasonScrollView = self:NewUI(9, CScrollView)
	self.m_DayGrid = self:NewUI(10, CGrid)
	self.m_SeasonGrid = self:NewUI(11, CGrid)
	self.m_SeasonTitleLbl= self:NewUI(12, CLabel)
	self.m_ChooseZhenfaBtn = self:NewUI(13, CButton)
	self.m_SummonBox = self:NewUI(14, CJjcHelpBox)
	for i = 15, 18, 1 do
		table.insert(self.m_HelpList, self:NewUI(i, CJjcHelpBox))
	end

	self.m_BuddyInfoBox = self:NewUI(19, CBox)
	self.m_BuddyInfoBox.m_SummonBox = self.m_BuddyInfoBox:NewUI(1, CJjcHelpBox)
	self.m_BuddyInfoBox.m_HelpList = {}
	for i = 2, 5, 1 do
		table.insert(self.m_BuddyInfoBox.m_HelpList, self.m_BuddyInfoBox:NewUI(i, CJjcHelpBox))
	end

	self.m_BuddyListBox = self:NewUI(20, CBox)
	self.m_BuddyListBox.m_ScrollView = self.m_BuddyListBox:NewUI(1, CScrollView)
	self.m_BuddyListBox.m_Grid = self.m_BuddyListBox:NewUI(2, CGrid)
	self.m_BuddyListBox.m_BoxClone = self.m_BuddyListBox:NewUI(3, CBox)
	self.m_BuddyListBox.m_Bg = self.m_BuddyListBox:NewUI(4, CSprite)

	self.m_MessageListBox = self:NewUI(21, CBox)
	self.m_MessageListBox.m_ScrollView = self.m_MessageListBox:NewUI(1, CScrollView)
	self.m_MessageListBox.m_Table = self.m_MessageListBox:NewUI(2, CTable)
	self.m_MessageListBox.m_BoxClone = self.m_MessageListBox:NewUI(3, CBox)

	self.m_ZhenfaListBox = self:NewUI(22, CBox)
	self.m_ZhenfaListBox.m_ScrollView = self.m_ZhenfaListBox:NewUI(1, CScrollView)
	self.m_ZhenfaListBox.m_Grid = self.m_ZhenfaListBox:NewUI(2, CGrid)
	self.m_ZhenfaListBox.m_BoxClone = self.m_ZhenfaListBox:NewUI(3, CBox)
	self.m_ZhenfaListBox.m_Bg = self.m_ZhenfaListBox:NewUI(4, CSprite)

	self.m_DayBoxClone = self:NewUI(23, CBox)
	self.m_SeasonBoxClone = self:NewUI(24, CBox)

	self.m_ZhenfaLbl = self:NewUI(25, CLabel)

	self.m_SummonListBox = self:NewUI(26, CBox)
	self.m_SummonListBox.m_ScrollView = self.m_SummonListBox:NewUI(1, CScrollView)
	self.m_SummonListBox.m_Grid = self.m_SummonListBox:NewUI(2, CGrid)
	self.m_SummonListBox.m_BoxClone = self.m_SummonListBox:NewUI(3, CBox)
	self.m_SummonListBox.m_Bg = self.m_SummonListBox:NewUI(4, CSprite)

	self.m_MessageRedPointSp = self:NewUI(27, CSprite)

	self.m_DayPrizeBtn = self:NewUI(28, CButton)
	self.m_SeasonPrizeBtn = self:NewUI(29, CButton)
	self.m_DayPrizeTimeLbl = self:NewUI(30, CLabel)
	self.m_SeasonPrizeTimeLbl = self:NewUI(31, CLabel)
	self.m_TipsBtn = self:NewUI(32, CButton)
	self.m_ScoreLbl = self:NewUI(33, CLabel)	
	self.m_LeftCountValueLbl = self:NewUI(34, CLabel)
	self.m_AddCountBtn = self:NewUI(35, CButton)
	self.m_LeftTimeValueLbl = self:NewUI(36, CLabel)
	self.m_SpeedTimeBtn = self:NewUI(37, CButton)
	self.m_InfoBtn = self:NewUI(38, CButton)
	self.m_TopGroupList = {}
	for i = 39, 41, 1 do
		table.insert(self.m_TopGroupList, self:NewUI(i, CJjcSingleBox))
	end
	self.m_ZhenfaBox = self:NewUI(42, CBox)
	self.m_DayPrizeBox = self:NewUI(43, CBox)
	self.m_SeasonPrizeBox = self:NewUI(44, CBox)
	self.m_SelfZhenfaBox = self:NewUI(45, CBox)
	self.m_SelfZhenfaBox.m_IconSp = self.m_SelfZhenfaBox:NewUI(2, CSprite)
	self.m_SelfZhenfaBox.m_LevelLbl = self.m_SelfZhenfaBox:NewUI(3, CLabel)
	self.m_SelfZhenfaBox.m_NameLbl = self.m_SelfZhenfaBox:NewUI(8, CLabel)

	self.m_JifenBtn = self:NewUI(46, CButton)
	self.m_FirstPrizeBtn = self:NewUI(47, CButton)
	self.m_FirstPrizeBtn.m_IgnoreCheckEffect = true
	self.m_RefreshBtn = self:NewUI(48, CButton)

	self:InitContent()
end

function CJjcSinglePart.InitContent(self)
	g_JjcCtrl.m_JjcMainBuddyClick = nil
	g_JjcCtrl.m_JjcMainSummonClick = nil

	self.m_BuddyListBox.m_BoxClone:SetActive(false)
	self.m_SummonListBox.m_BoxClone:SetActive(false)
	self.m_MessageListBox.m_BoxClone:SetActive(false)
	self.m_ZhenfaListBox.m_BoxClone:SetActive(false)
	self.m_DayBoxClone:SetActive(false)
	self.m_SeasonBoxClone:SetActive(false)
	self.m_MessageListBox:SetActive(false)
	self.m_ZhenfaListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(false)
	self.m_SummonListBox:SetActive(false)

	self.m_MessageListBox.m_ScrollView:SetCullContent(self.m_MessageListBox.m_Table)
	-- self.m_ZhenfaListBox.m_ScrollView:SetCullContent(self.m_ZhenfaListBox.m_Grid)
	-- self.m_BuddyListBox.m_ScrollView:SetCullContent(self.m_BuddyListBox.m_Grid)

	self.m_MessageBtn:AddUIEvent("click", callback(self, "OnClickMessage"))
	-- self.m_ChooseZhenfaBtn:AddUIEvent("click", callback(self, "OnClickChooseZhenfa"))
	self.m_SummonBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickSummonBox"))
	self.m_SummonBox.m_DownBtn:AddUIEvent("click", callback(self, "OnClickSummonDown"))
	self.m_SummonBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddSummon"))
	for k, oBox in ipairs(self.m_HelpList) do
		oBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickBuddyBox", k))
		oBox.m_DownBtn:AddUIEvent("click", callback(self, "OnClickBuddyDown", k))
		oBox.m_SwapBtn:AddUIEvent("click", callback(self, "OnClickBuddySwap", k))
		oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddBuddy", k))
	end
	self.m_DayPrizeBtn:AddUIEvent("click", callback(self, "OnClickShowDayPrize"))
	self.m_SeasonPrizeBtn:AddUIEvent("click", callback(self, "OnClickShowSeasonPrize"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickJjcSingleTips"))
	self.m_AddCountBtn:AddUIEvent("click", callback(self, "OnClickAddCount"))
	self.m_SpeedTimeBtn:AddUIEvent("click", callback(self, "OnClickSpeedTime"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickShowInfo"))
	self.m_SelfZhenfaBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickChooseZhenfa"))

	self.m_JifenBtn:AddUIEvent("click", callback(self, "OnClickJifenBtn"))
	self.m_FirstPrizeBtn:AddUIEvent("click", callback(self, "OnClickFirstPrizeBtn"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefreshBtn"))

	self:SetMessageRedPoint()

	g_JjcCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFormationEvent"))
end

--协议通知返回
function CJjcSinglePart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Jjc.Event.RefreshJJCMainUI then
		self:RefreshJJCMainUI(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCTargetLineup then
		self:SetTargetBuddyInfo(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCFightLog then
		self.m_MessageRedPointSp:SetActive(false)
		if next(oCtrl.m_EventData) then
			self:SetMessageInfo(oCtrl.m_EventData)
		else
			g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoMessage].content)
		end
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCMessageRedPoint then
		self:SetMessageRedPoint()
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCMainCountTime then
		if g_JjcCtrl.m_JjcMainCountTime > 0 then
			self.m_LeftTimeValueLbl:SetText("挑战冷却:"..os.date("#R%M:%S#n", g_JjcCtrl.m_JjcMainCountTime))
		else
			self.m_LeftTimeValueLbl:SetText("挑战冷却:"..os.date("#R%M:%S#n", 0))
		end
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCMainRefreshCountTime then
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
end

function CJjcSinglePart.OnCtrlFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.UpdateAllFormation then
		printc("CJjcSinglePart.OnCtrlFormationEvent")
		table.print(oCtrl.m_EventData, "CJjcSinglePart.OnCtrlFormationEvent")
		self:SetZhenfaListInfo(g_FormationCtrl:GetAllFormationInfo())
	end
end

--刷新竞技part界面ui
--有对应的数据下发才会刷新对应的ui部分
function CJjcSinglePart.RefreshJJCMainUI(self, oData)
	local mask = oData.mask
	local rank = oData.rank
	local infos = oData.infos
	local lineup = oData.lineup
	local fighttimes = oData.fighttimes
	local fightcd = oData.fightcd
	local hasbuy = oData.hasbuy
	local top3 = oData.top3

	self.m_DayPrizeTimeLbl:SetText("每日0点结算")

	if g_JjcCtrl.m_JjcOldMainInfo.nextseason and g_JjcCtrl.m_JjcOldMainInfo.nextseason ~= 0 and g_JjcCtrl.m_JjcMainNextSeason ~= 0 
		and g_JjcCtrl.m_JjcOldMainInfo.nextseason ~= g_JjcCtrl.m_JjcMainNextSeason then
		g_JjcCtrl.m_Rank = 0
		g_JjcCtrl.m_JjcMainInfo.rank = 0
	end

	if g_JjcCtrl.m_JjcMainNextSeason ~= 0 then
		self.m_SeasonPrizeTimeLbl:SetActive(true)
		self.m_SeasonPrizeTimeLbl:SetText(string.format("%s月%s号结算", os.date("%m", g_JjcCtrl.m_JjcMainNextSeason), os.date("%d", g_JjcCtrl.m_JjcMainNextSeason)))
	else
		self.m_SeasonPrizeTimeLbl:SetActive(false)
	end

	if fighttimes then
		self.m_LeftCountValueLbl:SetText("剩余挑战次数:"..fighttimes.."次") --.."/"..data.jjcdata.JJCGLOBAL[1].fight_max.."次")
	end
	if g_JjcCtrl.m_JjcMainCountTime > 0 then
		self.m_LeftTimeValueLbl:SetText("挑战冷却:"..os.date("#R%M:%S#n", g_JjcCtrl.m_JjcMainCountTime))
	else
		self.m_LeftTimeValueLbl:SetText("挑战冷却:"..os.date("#R%M:%S#n", 0))
	end
	if g_JjcCtrl.m_JjcMainRefreshCountTime > 0 then
		self.m_RefreshBtn:SetBtnGrey(true)
		self.m_RefreshBtn:GetComponent(classtype.BoxCollider).enabled = false
		self.m_RefreshBtn:SetText(os.date("#R%M:%S#n", g_JjcCtrl.m_JjcMainRefreshCountTime))
	else
		self.m_RefreshBtn:SetBtnGrey(false)
		self.m_RefreshBtn:GetComponent(classtype.BoxCollider).enabled = true
		self.m_RefreshBtn:SetText("刷新对手")
	end

	if g_JjcCtrl.m_Rank == 0 then
		self.m_RankLbl:SetText(g_JjcCtrl.m_JjcOutSideRankStr)
	else
		self.m_RankLbl:SetText(g_JjcCtrl.m_Rank)
	end
	self.m_ScoreLbl:SetText(g_AttrCtrl.score)

	g_JjcCtrl:GetJjcMainInfoSaveData()
	local curRank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
	--暂时屏蔽
	--有排名向前变化特殊表现
	-- if rank and infos and g_JjcCtrl.m_InitTime > 1 and next(g_JjcCtrl.m_JjcOldMainInfo) and g_JjcCtrl.m_JjcOldMainInfo.infos
	-- 	and ((not g_JjcCtrl.m_JjcOldMainInfo.rank or g_JjcCtrl.m_JjcOldMainInfo.rank == 0) and 100000 or g_JjcCtrl.m_JjcOldMainInfo.rank) > curRank then
	-- 	self.m_ChallengeGroupList[1]:SetSingleHeroInfo(fighttimes, fightcd)
	-- 	if g_JjcCtrl.m_JjcOldMainInfo.infos and next(g_JjcCtrl.m_JjcOldMainInfo.infos) then
	-- 		local list = {}
	-- 		for k,v in ipairs(g_JjcCtrl.m_JjcOldMainInfo.infos) do
	-- 			list[k] = v				
	-- 		end
	-- 		table.sort(list, function (a, b) return a.rank > b.rank end)		
	-- 		for i=2, 5 do
	-- 			self.m_ChallengeGroupList[i]:SetSingleTargetInfo(list[i-1], true)
	-- 			self.m_ChallengeGroupList[i]:SetLocalPos(self.m_TargeBoxPos[i-1])
	-- 		end
	-- 	end

	-- 	local tween = DOTween.DOLocalMoveY(self.m_ChallengeGroupList[1].m_Transform, define.Jjc.Pos.DownY, define.Jjc.Time.MoveUp)
	-- 	DOTween.SetEase(tween, 1)

	-- 	local function moveoutcompletedelay()
	-- 		if infos and next(infos) then
	-- 			local list = {}
	-- 			for k,v in ipairs(infos) do
	-- 				list[k] = v				
	-- 			end
	-- 			table.sort(list, function (a, b) return a.rank > b.rank end)		
	-- 			for i=2, 5 do
	-- 				self.m_ChallengeGroupList[i]:SetSingleTargetInfo(list[i-1])
	-- 			end

	-- 			for i=2, 5 do
	-- 				self.m_ChallengeGroupList[i]:SetLocalPos(Vector3.New(define.Jjc.Pos.InPosX, self.m_TargeBoxPos[i-1].y, self.m_TargeBoxPos[i-1].z))
	-- 				local tween = DOTween.DOLocalMoveX(self.m_ChallengeGroupList[i].m_Transform, self.m_TargeBoxPos[i-1].x, define.Jjc.Time.MoveIn)
	-- 				DOTween.SetEase(tween, 1)
	-- 				DOTween.SetDelay(tween, define.Jjc.Time.MoveIn*(i-2))
	-- 			end
	-- 		end
	-- 	end
	-- 	for i=2, 4 do
	-- 		local tween = DOTween.DOLocalMoveX(self.m_ChallengeGroupList[i].m_Transform, define.Jjc.Pos.OutPosX, define.Jjc.Time.MoveOut)
	-- 		--Linear = 1,InSine = 2,OutSine = 3,InOutSine = 4,InQuad = 5,
	-- 		DOTween.SetEase(tween, 1)
	-- 		DOTween.SetDelay(tween, define.Jjc.Time.MoveOut*(i-2) + define.Jjc.Time.MoveUp)
	-- 	end
	-- 	local tween = DOTween.DOLocalMoveX(self.m_ChallengeGroupList[5].m_Transform, define.Jjc.Pos.OutPosX, define.Jjc.Time.MoveOut)
	-- 	DOTween.SetEase(tween, 1)
	-- 	DOTween.SetDelay(tween, define.Jjc.Time.MoveOut*(3) + define.Jjc.Time.MoveUp)
	-- 	DOTween.OnComplete(tween, moveoutcompletedelay)

	-- 	g_JjcCtrl:SaveJjcMainInfoData(g_JjcCtrl.m_JjcMainInfo)
	-- else		
	-- end
	self.m_ChallengeGroupList[1]:SetSingleHeroInfo(fighttimes, fightcd)
	if infos and next(infos) then
		local list = {}
		for k,v in ipairs(infos) do
			list[k] = v				
		end
		table.sort(list, function (a, b) return a.rank > b.rank end)
		for i=2, 5 do
			self.m_ChallengeGroupList[i]:SetSingleTargetInfo(list[i-1])
			self.m_ChallengeGroupList[i]:SetLocalPos(self.m_TargeBoxPos[i-1])
		end
	end

	if top3 then
		self.m_TopGroupList[1]:SetTopTargetInfo(g_JjcCtrl.m_JjcMainTopList[2])
		self.m_TopGroupList[2]:SetTopTargetInfo(g_JjcCtrl.m_JjcMainTopList[1])
		self.m_TopGroupList[3]:SetTopTargetInfo(g_JjcCtrl.m_JjcMainTopList[3])
	end

	if oData.first_gift_status then
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
end

function CJjcSinglePart.GetSeasonLeftDay(self, year, month, day)
	year = tonumber(year)
	month = tonumber(month)
	day = tonumber(day)
	local monthday = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	if (year%4 == 0 and year%100 ~= 0) or year%400 == 0 then
		monthday[2] = 29
	end
	return monthday[month] - day + 1
end

function CJjcSinglePart.GetDayConfigRatio(self, grade)
	local config = {}
	grade = grade == 0 and 1 or grade
	for k,v in ipairs(data.jjcdata.DAYRATIO) do
		if v.grade[1] <= grade and (v.grade[2] and v.grade[2] or v.grade[1]) >= grade then
			config = v
			break
		end
	end
	return config
end

function CJjcSinglePart.GetMonthConfigRatio(self, grade)
	local config = {}
	grade = grade == 0 and 1 or grade
	for k,v in ipairs(data.jjcdata.MONTHRATIO) do
		if v.grade[1] <= grade and (v.grade[2] and v.grade[2] or v.grade[1]) >= grade then
			config = v
			break
		end
	end
	return config
end

function CJjcSinglePart.ResetAllBuddyBox(self)
	g_JjcCtrl.m_JjcMainBuddyClick = nil
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcMainBuddyList[k] then
			oBox:SetBuddyBox(g_JjcCtrl.m_JjcMainBuddyList[k])
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcSinglePart.SetSelectBuddy(self, idx)
	if not g_JjcCtrl.m_JjcMainBuddyList[idx] or g_JjcCtrl.m_JjcMainBuddyClick then
		return
	end
	g_JjcCtrl.m_JjcMainBuddyClick = idx
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcMainBuddyList[k] then
			if k == idx then
				oBox:DownBuddyState(g_JjcCtrl.m_JjcMainBuddyList[k])
			else
				oBox:SwapBuddyState(g_JjcCtrl.m_JjcMainBuddyList[k])
			end
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcSinglePart.ResetSummonBox(self)
	g_JjcCtrl.m_JjcMainSummonClick = nil
	self.m_SummonBox:SetSummonBox(g_JjcCtrl.m_JjcMainSummonid, g_JjcCtrl.m_JjcMainSummonicon, g_JjcCtrl.m_JjcMainSummonlv)
end

function CJjcSinglePart.SetSelectSummon(self)
	if g_JjcCtrl.m_JjcMainSummonClick then
		return
	end
	g_JjcCtrl.m_JjcMainSummonClick = 1
	self.m_SummonBox:DownSummonState(g_JjcCtrl.m_JjcMainSummonid, g_JjcCtrl.m_JjcMainSummonicon, g_JjcCtrl.m_JjcMainSummonlv)
end

function CJjcSinglePart.SetZhenfaInfo(self)
	local zhenfaConfig = data.formationdata.BASEINFO[g_JjcCtrl.m_JjcMainFmtid]
	local zhenfaStr
	self.m_SelfZhenfaBox.m_IconSp:SetSpriteName(zhenfaConfig.icon)
	if g_JjcCtrl.m_JjcMainFmtid == 1 then
		-- zhenfaStr = zhenfaConfig.name
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(false)
	else
		-- zhenfaStr = zhenfaConfig.name.." "..g_JjcCtrl.m_JjcMainFmtlv.."级"
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(true)
		self.m_SelfZhenfaBox.m_LevelLbl:SetText(g_JjcCtrl.m_JjcMainFmtlv)
	end
	self.m_SelfZhenfaBox.m_NameLbl:SetText(zhenfaConfig.name)
end

function CJjcSinglePart.SetTargetBuddyInfo(self, oData)
	self.m_BuddyInfoBox:SetActive(true)
	self.m_BuddyInfoBox.m_SummonBox:SetTargetSummonBox(oData.lineup.summicon, oData.lineup.summlv)
	self:ResetAllTargetBuddyBox(oData.lineup.fighters)
	local oBox = self.m_ChallengeGroupList[1]
	for k,v in ipairs(self.m_ChallengeGroupList) do
		if v.m_SingleId == oData.target.id and v.m_SingleType == oData.target.type then
			oBox = v
			break
		end
	end
	for k,v in ipairs(self.m_TopGroupList) do
		if v.m_TopId == oData.target.id and v.m_TopType == oData.target.type then
			oBox = v
			break
		end
	end
	UITools.NearTarget(oBox.m_ActorTexture, self.m_BuddyInfoBox, enum.UIAnchor.Side.Bottom)

	g_UITouchCtrl:TouchOutDetect(self.m_BuddyInfoBox, callback(self.m_BuddyInfoBox, "SetActive", false))
end

function CJjcSinglePart.ResetAllTargetBuddyBox(self, oData)
	for k, oBox in ipairs(self.m_BuddyInfoBox.m_HelpList) do
		if oData[k] then
			oBox:SetBuddyBox(oData[k])
		else
			oBox:AddTargetBuddyState()
		end
	end
end

function CJjcSinglePart.SetMessageInfo(self, oData)
	self.m_MessageListBox:SetActive(true)
	-- UITools.NearTarget(self.m_MessageBtn, self.m_MessageListBox, enum.UIAnchor.Side.Bottom)
	self.m_MessageListBox.m_Table:Clear()
	if oData.logs and next(oData.logs) then
		local list = {}
		table.copy(oData.logs, list)
		table.sort(list, function(a, b) return a.time > b.time end)

		for k,v in ipairs(list) do
			self:AddMsgBox(v)
		end
	end
	self.m_MessageListBox.m_Table:Reposition()
	self.m_MessageListBox.m_ScrollView:ResetPosition()
	g_UITouchCtrl:TouchOutDetect(self.m_MessageListBox, callback(self.m_MessageListBox, "SetActive", false))
end

function CJjcSinglePart.AddMsgBox(self, oMsg)
	local oMsgBox = self.m_MessageListBox.m_BoxClone:Clone()
	
	oMsgBox:SetActive(true)
	oMsgBox.m_timeLbl = oMsgBox:NewUI(1, CLabel)
	oMsgBox.m_contentLbl = oMsgBox:NewUI(2, CLabel)

	local totalTime = g_TimeCtrl:GetTimeS() - oMsg.time
	oMsgBox.m_timeLbl:SetText(self:GetTimeDesc(totalTime))

	local resultstr = "#G"..oMsg.fighter.."#n向你发起了挑战,"
	if oMsg.win == 1 then
		resultstr = resultstr.."你#G防守成功#n,排名不变"
	else
		if oMsg.rank and oMsg.rank ~= 0 then
			resultstr = resultstr.."你#R防守失败#n,排名下降至#R"..oMsg.rank.."#n"
		else
			resultstr = resultstr.."你#R防守失败#n,排名下降至#R"..g_JjcCtrl.m_JjcOutSideRankStr.."#n"
		end
	end
	oMsgBox.m_contentLbl:SetText("#W"..resultstr.."#n")

	self.m_MessageListBox.m_Table:AddChild(oMsgBox)
	self.m_MessageListBox.m_Table:Reposition()
	self.m_MessageListBox.m_ScrollView:CullContentLater()
end

--设置消息红点
function CJjcSinglePart.SetMessageRedPoint(self)
	if g_JjcCtrl.m_JjcMessageRedPoint then
		self.m_MessageRedPointSp:SetActive(true)
	else
		self.m_MessageRedPointSp:SetActive(false)
	end
end

function CJjcSinglePart.GetTimeDesc(self, time)
	if time < 60 then
		return time.."秒前"
	elseif time >= 60 and time < 3600 then
		return math.floor(time/(60)).."分钟前"
	elseif time >= 3600 and time < 24*3600 then
		return math.floor(time/(3600)).."小时前"
	elseif time >= 24*3600 then
		return math.floor(time/(24*3600)).."天前"
	end
end

function CJjcSinglePart.SetZhenfaListInfo(self, oData)
	-- table.print(oData, "CJjcSinglePart.SetZhenfaListInfo")
	self.m_ZhenfaListBox:SetActive(true)
	UITools.NearTarget(self.m_SelfZhenfaBox.m_IconSp, self.m_ZhenfaListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -30, 0))
	self.m_ZhenfaListBox.m_Grid:Clear()

	if oData and next(oData) then
		local list = {}
		for k,v in pairs(oData) do
			if v.grade > 0 then
				table.insert(list, v)
			end
		end
		local width = 110
		if #list <= 3 then
			self.m_ZhenfaListBox.m_Bg:SetHeight(width * #list)
			self.m_ZhenfaListBox:SetHeight(width * #list)
		else
			self.m_ZhenfaListBox.m_Bg:SetHeight(width * 3)
			self.m_ZhenfaListBox:SetHeight(width * 3)
		end
		for k,v in ipairs(list) do
			self:AddZhenfaBox(v)
		end
	end

	self.m_ZhenfaListBox.m_Grid:Reposition()
	self.m_ZhenfaListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_ZhenfaListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0.1)

	g_UITouchCtrl:TouchOutDetect(self.m_ZhenfaListBox, callback(self.m_ZhenfaListBox, "SetActive", false))
end

function CJjcSinglePart.AddZhenfaBox(self, oZhenfa)
	local oZhenfaBox = self.m_ZhenfaListBox.m_BoxClone:Clone()
	
	oZhenfaBox:SetActive(true)
	oZhenfaBox.m_IconSp = oZhenfaBox:NewUI(1, CSprite)
	oZhenfaBox.m_nameLbl = oZhenfaBox:NewUI(2, CLabel)
	oZhenfaBox.m_UpBtn = oZhenfaBox:NewUI(3, CButton)
	local zhenfaConfig = data.formationdata.BASEINFO[oZhenfa.fmt_id]
	local zhenfaStr
	if oZhenfa.fmt_id == 1 then
		zhenfaStr = zhenfaConfig.name
	else
		zhenfaStr = zhenfaConfig.name.." "..oZhenfa.grade.."级"
	end
	oZhenfaBox.m_IconSp:SetSpriteName(zhenfaConfig.icon)
	oZhenfaBox.m_nameLbl:SetText(zhenfaStr)
	oZhenfaBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectZhenfa", oZhenfa))
	self.m_ZhenfaListBox.m_Grid:AddChild(oZhenfaBox)
	self.m_ZhenfaListBox.m_Grid:Reposition()
	-- self.m_ZhenfaListBox.m_ScrollView:CullContentLater()
end

function CJjcSinglePart.SetBuddyListInfo(self, oData, idx)
	self.m_BuddyListBox:SetActive(true)
	UITools.NearTarget(self.m_HelpList[idx].m_AddBtn, self.m_BuddyListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -18, 0))
	self.m_BuddyListBox.m_Grid:Clear()

	if oData and next(oData) then
		local width = 110
		if #oData <= 3 then
			self.m_BuddyListBox.m_Bg:SetHeight(width * #oData)
			self.m_BuddyListBox:SetHeight(width * #oData)
		else
			self.m_BuddyListBox.m_Bg:SetHeight(width * 3)
			self.m_BuddyListBox:SetHeight(width * 3)
		end

		for k,v in ipairs(oData) do
			self:AddBuddyBox(v)
		end
	end

	self.m_BuddyListBox.m_Grid:Reposition()
	self.m_BuddyListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_BuddyListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0.1)

	g_UITouchCtrl:TouchOutDetect(self.m_BuddyListBox, callback(self.m_BuddyListBox, "SetActive", false))
end

function CJjcSinglePart.AddBuddyBox(self, oBuddy)
	local oBuddyBox = self.m_BuddyListBox.m_BoxClone:Clone()
	
	oBuddyBox:SetActive(true)
	oBuddyBox.m_IconSprite = oBuddyBox:NewUI(1, CSprite)
	oBuddyBox.m_Quality = oBuddyBox:NewUI(2, CSprite)
	oBuddyBox.m_StartGrid = oBuddyBox:NewUI(3, CGrid)
	oBuddyBox.m_StartClone = oBuddyBox:NewUI(4, CSprite)
	oBuddyBox.m_NameLabel = oBuddyBox:NewUI(5, CLabel)
	oBuddyBox.m_GradeLabel = oBuddyBox:NewUI(6, CLabel)
	oBuddyBox.m_TypeSprite = oBuddyBox:NewUI(7, CSprite)
	oBuddyBox.m_FactionIcon = oBuddyBox:NewUI(8, CSprite)
	oBuddyBox.m_FactionName = oBuddyBox:NewUI(9, CLabel)
	oBuddyBox.m_TipSprite = oBuddyBox:NewUI(10, CSprite)
	oBuddyBox.m_UpBtn = oBuddyBox:NewUI(12, CButton)
	oBuddyBox.m_StartClone:SetActive(false)

	local partnerData = g_PartnerCtrl:GetRecruitPartnerDataByID(oBuddy.id)
	oBuddyBox.m_IconSprite:SpriteAvatar(oBuddy.shape)
	local quality = (partnerData and partnerData.quality or oBuddy.quality) - 1
	oBuddyBox.m_Quality:SetItemQuality(quality)
	oBuddyBox.m_NameLabel:SetText(oBuddy.name)
	local gradeStr = partnerData and partnerData.grade .. "级" or ""
	oBuddyBox.m_GradeLabel:SetText(gradeStr)
	-- local partnerType = DataTools.GetPartnerType(oBuddy.type)
	oBuddyBox.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[oBuddy.type])
	local schoolInfo = data.schooldata.DATA[oBuddy.school]
	oBuddyBox.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	oBuddyBox.m_FactionName:SetText(schoolInfo.name)
	oBuddyBox.m_TipSprite:SetActive(g_JjcCtrl:GetIsJjcMainBuddyIsInFight(oBuddy.serverid))
	self:SetStart(oBuddyBox, partnerData and partnerData.upper or 0)

	oBuddyBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectBuddy", oBuddy))
	self.m_BuddyListBox.m_Grid:AddChild(oBuddyBox)
	self.m_BuddyListBox.m_Grid:Reposition()
	-- self.m_BuddyListBox.m_ScrollView:CullContentLater()
end

function CJjcSinglePart.SetStart(self, oBox, count)
	local startBoxList = oBox.m_StartGrid:GetChildList()
	local startBox = nil
	for i=1,5 do
		if i > #startBoxList then
			startBox = oBox.m_StartClone:Clone()
			oBox.m_StartGrid:AddChild(startBox)
			startBox:SetActive(true)
		else
			startBox = startBoxList[i]
		end
		startBox:SetGrey(i > count)
	end
end

function CJjcSinglePart.SetSummonListInfo(self, oData)
	self.m_SummonListBox:SetActive(true)
	UITools.NearTarget(self.m_SummonBox.m_AddBtn, self.m_SummonListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -13, 0))
	self.m_SummonListBox.m_Grid:Clear()

	if oData and next(oData) then
		local width = 110
		if #oData <= 3 then
			self.m_SummonListBox.m_Bg:SetHeight(width * #oData)
			self.m_SummonListBox:SetHeight(width * #oData)
		else
			self.m_SummonListBox.m_Bg:SetHeight(width * 3)
			self.m_SummonListBox:SetHeight(width * 3)
		end

		for k,v in ipairs(oData) do
			self:AddSummonBox(v)
		end
	end

	self.m_SummonListBox.m_Grid:Reposition()
	self.m_SummonListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_SummonListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0.1)

	g_UITouchCtrl:TouchOutDetect(self.m_SummonListBox, callback(self.m_SummonListBox, "SetActive", false))
end

function CJjcSinglePart.AddSummonBox(self, oSummon)
	local oSummonBox = self.m_SummonListBox.m_BoxClone:Clone()
	
	oSummonBox:SetActive(true)
	oSummonBox.m_IconSprite = oSummonBox:NewUI(1, CSprite)
	oSummonBox.m_Quality = oSummonBox:NewUI(2, CSprite)
	oSummonBox.m_StartGrid = oSummonBox:NewUI(3, CGrid)
	oSummonBox.m_StartClone = oSummonBox:NewUI(4, CSprite)
	oSummonBox.m_NameLabel = oSummonBox:NewUI(5, CLabel)
	oSummonBox.m_GradeLabel = oSummonBox:NewUI(6, CLabel)
	oSummonBox.m_TypeSprite = oSummonBox:NewUI(7, CSprite)
	oSummonBox.m_FactionIcon = oSummonBox:NewUI(8, CSprite)
	oSummonBox.m_FactionName = oSummonBox:NewUI(9, CLabel)
	oSummonBox.m_TipSprite = oSummonBox:NewUI(10, CSprite)
	oSummonBox.m_UpBtn = oSummonBox:NewUI(12, CButton)
	oSummonBox.m_StartGrid:SetActive(false)
	oSummonBox.m_StartClone:SetActive(false)
	oSummonBox.m_FactionIcon:SetActive(false)
	oSummonBox.m_FactionName:SetActive(false)

	oSummonBox.m_IconSprite:SpriteAvatar(oSummon.model_info.shape)
	-- local quality = (partnerData and partnerData.quality or oSummon.quality) - 1
	-- oSummonBox.m_Quality:SetItemQuality(quality)
	local nameStr = oSummon.name == oSummon.basename and oSummon.basename or oSummon.basename.."("..oSummon.name..")"
	oSummonBox.m_NameLabel:SetText(nameStr)
	local gradeStr = oSummon.grade .. "级" or ""
	oSummonBox.m_GradeLabel:SetText(gradeStr)
	-- oSummonBox.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[oSummon.type])
	-- local schoolInfo = data.schooldata.DATA[oSummon.school]
	-- oSummonBox.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	-- oSummonBox.m_FactionName:SetText(schoolInfo.name)
	if g_JjcCtrl.m_JjcMainSummonid == 0 then
		oSummonBox.m_TipSprite:SetActive(false)
	else
		oSummonBox.m_TipSprite:SetActive(g_JjcCtrl.m_JjcMainSummonid == oSummon.id)
	end
	-- self:SetStart(oSummonBox, partnerData and partnerData.upper or 0)

	oSummonBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectSummon", oSummon))
	self.m_SummonListBox.m_Grid:AddChild(oSummonBox)
	self.m_SummonListBox.m_Grid:Reposition()
	-- self.m_SummonListBox.m_ScrollView:CullContentLater()
end

function CJjcSinglePart.SetDayPrizeInfo(self, oData)
	self.m_DayPrizeBox:SetActive(true)
	self.m_DayGrid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddDayPrizeBox(v)
		end
	end
	self.m_DayGrid:Reposition()
	self.m_DayScrolllView:ResetPosition()
	UITools.NearTarget(self.m_DayPrizeTimeLbl, self.m_DayPrizeBox, enum.UIAnchor.Side.Bottom)
	

	g_UITouchCtrl:TouchOutDetect(self.m_DayPrizeBox, callback(self.m_DayPrizeBox, "SetActive", false))
end

function CJjcSinglePart.AddDayPrizeBox(self, oPrize)
	local oPrizeBox = self.m_DayBoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
	local oItemConfig = DataTools.GetItemData(oPrize.sid)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickDayPrizeBox", oPrize, oPrizeBox))
	local grade = g_AttrCtrl.grade >= 200 and 200 or g_AttrCtrl.grade
	local ValueStr = string.gsub(oPrize.amont,"k",tostring(self:GetDayConfigRatio(grade).ratio))
	local Value = load(string.format([[return (%s)]], ValueStr))()
	oPrizeBox.m_CountLbl:SetText(math.floor(tonumber(Value)))
	self.m_DayGrid:AddChild(oPrizeBox)
	self.m_DayGrid:Reposition()
	-- self.m_DayScrolllView:CullContentLater()
end

--显示奖励tips
function CJjcSinglePart.OnClickDayPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.TopRight,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

function CJjcSinglePart.SetMonthPrizeInfo(self, oData)
	self.m_SeasonPrizeBox:SetActive(true)
	self.m_SeasonGrid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddMonthPrizeBox(v)
		end
	end
	self.m_SeasonGrid:Reposition()
	self.m_SeasonScrollView:ResetPosition()
	UITools.NearTarget(self.m_SeasonPrizeTimeLbl, self.m_SeasonPrizeBox, enum.UIAnchor.Side.Bottom)
	

	g_UITouchCtrl:TouchOutDetect(self.m_SeasonPrizeBox, callback(self.m_SeasonPrizeBox, "SetActive", false))
end

function CJjcSinglePart.AddMonthPrizeBox(self, oPrize)
	local oPrizeBox = self.m_SeasonBoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
	local oItemConfig = DataTools.GetItemData(oPrize.sid)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickMonthPrizeBox", oPrize, oPrizeBox))
	local grade = g_AttrCtrl.grade >= 200 and 200 or g_AttrCtrl.grade
	local ValueStr = string.gsub(oPrize.amont,"k",tostring(self:GetMonthConfigRatio(grade).ratio))
	local Value = load(string.format([[return (%s)]], ValueStr))()
	oPrizeBox.m_CountLbl:SetText(math.floor(tonumber(Value)))
	self.m_SeasonGrid:AddChild(oPrizeBox)
	self.m_SeasonGrid:Reposition()
	-- self.m_SeasonScrollView:CullContentLater()
end

--显示奖励tips
function CJjcSinglePart.OnClickMonthPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.TopRight,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

--------------以下是点击事件--------------

function CJjcSinglePart.OnClickMessage(self)
	netjjc.C2GSJJCGetFightLog()
end

function CJjcSinglePart.OnClickChooseZhenfa(self)
	if g_FormationCtrl:GetCurrentFmt() == 0 then
		netformation.C2GSAllFormationInfo()
	else
		local fmtlist = g_FormationCtrl:GetAllFormationInfo()
		self:SetZhenfaListInfo(fmtlist)
	end
end

function CJjcSinglePart.OnClickBuddyBox(self, idx)
	if g_JjcCtrl.m_JjcMainBuddyClick then
		if g_JjcCtrl.m_JjcMainBuddyClick == idx then
			self:ResetAllBuddyBox()
		end
	else
		self:SetSelectBuddy(idx)
	end
end

function CJjcSinglePart.OnClickBuddyDown(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	for k,v in ipairs(list) do
		if k == idx then
			table.remove(list, k)
			break
		end
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSinglePart.OnClickBuddySwap(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	local tempid = idlist[idx]
	idlist[idx] = idlist[g_JjcCtrl.m_JjcMainBuddyClick]
	idlist[g_JjcCtrl.m_JjcMainBuddyClick] = tempid
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSinglePart.OnClickAddBuddy(self, idx)	
	-- table.print(g_PartnerCtrl:GetPartnerDataList(), "CJjcSinglePart.OnClickAddBuddy")
	local oPartnerList = g_PartnerCtrl:GetPartnerDataList(true)
	if next(oPartnerList) then
		self:SetBuddyListInfo(oPartnerList, idx)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoBuddy].content)
	end
end

function CJjcSinglePart.OnClickSummonBox(self)
	if g_JjcCtrl.m_JjcMainSummonClick then
		self:ResetSummonBox()
	else
		self:SetSelectSummon()
	end
end

function CJjcSinglePart.OnClickSummonDown(self)
	netjjc.C2GSSetJJCSummon(0)	
end

function CJjcSinglePart.OnClickAddSummon(self)
	table.print(g_SummonCtrl.m_SummonsSort, "CJjcSinglePart.OnClickAddSummon")
	if next(g_SummonCtrl.m_SummonsSort) then
		self:SetSummonListInfo(g_SummonCtrl.m_SummonsSort)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoSummon].content)
	end
end

function CJjcSinglePart.OnClickSelectZhenfa(self, oZhenfa)
	local isNotify = false
	if #self.m_ZhenfaListBox.m_Grid:GetChildList() <= 0 then
		isNotify = true
	elseif #self.m_ZhenfaListBox.m_Grid:GetChildList() == 1 and oZhenfa.fmt_id == 1 then
		isNotify = true
	end
	if isNotify then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoZhenfa].content)
	end
	self.m_ZhenfaListBox:SetActive(false)
	netjjc.C2GSSetJJCFormation(oZhenfa.fmt_id)	
end

function CJjcSinglePart.OnClickSelectBuddy(self, oBuddy)
	self.m_BuddyListBox:SetActive(false)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	if table.index(idlist, oBuddy.serverid) then
		return
	end
	if #idlist <= 3 then
		table.insert(idlist, oBuddy.serverid)
	end
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSinglePart.OnClickSelectSummon(self, oSummon)
	self.m_SummonListBox:SetActive(false)
	netjjc.C2GSSetJJCSummon(oSummon.id)	
end

function CJjcSinglePart.OnClickShowDayPrize(self)
	-- local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
	-- self:SetDayPrizeInfo(g_JjcCtrl:GetDayConfigPrize(rank))

	CJjcPrizeView:ShowView(function (oView)
		oView:RefreshUI(define.Jjc.PrizeType.Day, self.m_DayPrizeBtn)
	end)
end

function CJjcSinglePart.OnClickShowSeasonPrize(self)
	-- local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
	-- self:SetMonthPrizeInfo(g_JjcCtrl:GetMonthConfigPrize(rank))

	CJjcPrizeView:ShowView(function (oView)
		oView:RefreshUI(define.Jjc.PrizeType.Month, self.m_SeasonPrizeBtn)
	end)
end

function CJjcSinglePart.OnClickJjcSingleTips(self)
	local zId = define.Instruction.Config.JjcMain
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CJjcSinglePart.OnClickAddCount(self)
	if g_JjcCtrl.m_JjcMainHasBuy >= data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].hasbuy[2] then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.MainMaxTime].content)
	else
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.AddCount].content, "#num", self:GetJJCBuyTimeMoney(g_JjcCtrl.m_JjcMainHasBuy + 1).."元宝"),
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
function CJjcSinglePart.GetJJCBuyTimeMoney(self, hasbuy)
	for k,v in ipairs(data.jjcdata.BUYJJCTIME) do
		if v.hasbuy[1] <= hasbuy and (v.hasbuy[2] and v.hasbuy[2] or v.hasbuy[1]) >= hasbuy then
			return v.gold
		end
	end
	return data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].gold
end

function CJjcSinglePart.OnClickSpeedTime(self)
	if g_JjcCtrl.m_JjcMainCountTime > 0 then
		local ValueStr = string.gsub(data.jjcdata.JJCGLOBAL[1].cd_cost, "minute", tostring(math.ceil(tonumber(g_JjcCtrl.m_JjcMainCountTime/60))))
		local Value = load(string.format([[return (%s)]], ValueStr))()
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.SpeedTime].content, "#num", math.ceil(tonumber(Value)).."元宝"),
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSJJCClearCD()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	else
		g_NotifyCtrl:FloatMsg("当前没有冷却时间,无需加速哦")
	end
end

function CJjcSinglePart.OnClickShowInfo(self)
	-- self.m_ZhenfaBox:SetActive(true)
	-- UITools.NearTarget(self.m_InfoBtn, self.m_ZhenfaBox, enum.UIAnchor.Side.Bottom)

	-- local function hide()
	-- 	self.m_ZhenfaListBox:SetActive(false)
	-- 	self.m_SummonListBox:SetActive(false)
	-- 	self.m_BuddyListBox:SetActive(false)
	-- 	self.m_ZhenfaBox:SetActive(false)
	-- end
	-- g_UITouchCtrl:TouchOutDetect(self.m_ZhenfaBox, hide)
	CJjcSingleSelectView:ShowView()
end

function CJjcSinglePart.OnClickJifenBtn(self)
	g_ShopCtrl:ShowScoreShop(102)
end

function CJjcSinglePart.OnClickFirstPrizeBtn(self)
	if g_JjcCtrl.m_JjcMainFirstGiftData == 0 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FirstNotGet].content)
		return
	elseif g_JjcCtrl.m_JjcMainFirstGiftData == 2 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FirstHasGet].content)
		return
	end
	netjjc.C2GSReceiveFirstGift()
end

function CJjcSinglePart.OnClickRefreshBtn(self)
	if g_JjcCtrl.m_JjcMainRefreshCountTime > 0 then
		return
	end
	netjjc.C2GSRefreshJJCTarget()
end

return CJjcSinglePart