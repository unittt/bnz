local CJjcGroupDetailBox = class("CJjcGroupDetailBox", CBox)

function CJjcGroupDetailBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ChallengeGroupList = {}
	self.m_HelpList = {}
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RankLbl = self:NewUI(2, CLabel)
	self.m_CountLbl = self:NewUI(3, CLabel)
	self.m_ResetBtn = self:NewUI(4, CButton)
	self.m_ChallengeScrollView = self:NewUI(5, CScrollView)
	self.m_ChallengeGrid = self:NewUI(6, CGrid)
	for i = 7, 11, 1 do
		table.insert(self.m_ChallengeGroupList, self:NewUI(i, CJjcSingleBox))
	end
	self.m_PrizeScrollView = self:NewUI(12, CScrollView)
	self.m_PrizeGrid = self:NewUI(13, CGrid)
	self.m_PrizeBoxClone = self:NewUI(14, CBox)
	self.m_PrizeGetBtn = self:NewUI(15, CButton)
	self.m_ZhenfaLbl = self:NewUI(16, CLabel)
	self.m_ChooseZhenfaBtn = self:NewUI(17, CButton)
	self.m_SummonBox = self:NewUI(18, CJjcHelpBox)
	for i = 19, 22, 1 do
		table.insert(self.m_HelpList, self:NewUI(i, CJjcHelpBox))
	end
	self.m_HelpBtn = self:NewUI(23, CButton)

	self.m_BuddyInfoBox = self:NewUI(24, CBox)
	self.m_BuddyInfoBox.m_SummonBox = self.m_BuddyInfoBox:NewUI(1, CJjcHelpBox)
	self.m_BuddyInfoBox.m_HelpList = {}
	for i = 2, 5, 1 do
		table.insert(self.m_BuddyInfoBox.m_HelpList, self.m_BuddyInfoBox:NewUI(i, CJjcHelpBox))
	end

	self.m_BuddyListBox = self:NewUI(25, CBox)
	self.m_BuddyListBox.m_ScrollView = self.m_BuddyListBox:NewUI(1, CScrollView)
	self.m_BuddyListBox.m_Grid = self.m_BuddyListBox:NewUI(2, CGrid)
	self.m_BuddyListBox.m_BoxClone = self.m_BuddyListBox:NewUI(3, CBox)
	self.m_BuddyListBox.m_Bg = self.m_BuddyListBox:NewUI(4, CSprite)

	self.m_ZhenfaListBox = self:NewUI(26, CBox)
	self.m_ZhenfaListBox.m_ScrollView = self.m_ZhenfaListBox:NewUI(1, CScrollView)
	self.m_ZhenfaListBox.m_Grid = self.m_ZhenfaListBox:NewUI(2, CGrid)
	self.m_ZhenfaListBox.m_BoxClone = self.m_ZhenfaListBox:NewUI(3, CBox)
	self.m_ZhenfaListBox.m_Bg = self.m_ZhenfaListBox:NewUI(4, CSprite)

	self.m_SummonListBox = self:NewUI(27, CBox)
	self.m_SummonListBox.m_ScrollView = self.m_SummonListBox:NewUI(1, CScrollView)
	self.m_SummonListBox.m_Grid = self.m_SummonListBox:NewUI(2, CGrid)
	self.m_SummonListBox.m_BoxClone = self.m_SummonListBox:NewUI(3, CBox)
	self.m_SummonListBox.m_Bg = self.m_SummonListBox:NewUI(4, CSprite)

	self.m_FriendListBox = self:NewUI(28, CBox)
	self.m_FriendListBox.m_ScrollView = self.m_FriendListBox:NewUI(1, CScrollView)
	self.m_FriendListBox.m_Grid = self.m_FriendListBox:NewUI(2, CGrid)
	self.m_FriendListBox.m_BoxClone = self.m_FriendListBox:NewUI(3, CFriendItem)
	self.m_FriendListBox.m_Bg = self.m_FriendListBox:NewUI(4, CSprite)

	self.m_ZhenfaBox = self:NewUI(29, CBox)
	self.m_SelfZhenfaBox = self:NewUI(30, CBox)
	self.m_SelfZhenfaBox.m_IconSp = self.m_SelfZhenfaBox:NewUI(2, CSprite)
	self.m_SelfZhenfaBox.m_LevelLbl = self.m_SelfZhenfaBox:NewUI(3, CLabel)
	self.m_SelfZhenfaBox.m_NameLbl = self.m_SelfZhenfaBox:NewUI(8, CLabel)	
	self.m_TipsBtn = self:NewUI(31, CButton)
	self.m_InfoBtn = self:NewUI(32, CButton)
	self.m_ZhuzhanBox = self:NewUI(33, CBox)
	self.m_ZhuzhanFriendBtn = self:NewUI(34, CButton)
	self.m_ZhuzhanBuddyBtn = self:NewUI(35, CButton)

	self.m_ZhuzhanSelectTab = 1

	self:InitContent()
end

function CJjcGroupDetailBox.InitContent(self)
	g_JjcCtrl.m_JjcChallengeBuddyClick = nil
	g_JjcCtrl.m_JjcChallengeSummonClick = nil

	self.m_BuddyListBox.m_BoxClone:SetActive(false)
	self.m_SummonListBox.m_BoxClone:SetActive(false)
	self.m_ZhenfaListBox.m_BoxClone:SetActive(false)
	self.m_FriendListBox.m_BoxClone:SetActive(false)
	self.m_PrizeBoxClone:SetActive(false)
	self.m_ZhenfaListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(false)
	self.m_SummonListBox:SetActive(false)
	self.m_FriendListBox:SetActive(false)
	self.m_PrizeGetBtn:SetActive(false)

	-- self.m_ZhenfaListBox.m_ScrollView:SetCullContent(self.m_ZhenfaListBox.m_Grid)

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

	-- self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickReset"))
	self.m_PrizeGetBtn:AddUIEvent("click", callback(self, "OnClickPrizeGet"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_SelfZhenfaBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickChooseZhenfa"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickJjcGroupTips"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickShowInfo"))
	self.m_ZhuzhanFriendBtn:AddUIEvent("click", callback(self, "OnClickZhuzhanTab", 1))
	self.m_ZhuzhanBuddyBtn:AddUIEvent("click", callback(self, "OnClickZhuzhanTab", 2))
	self.m_ZhuzhanFriendBtn:SetGroup(self:GetInstanceID())
	self.m_ZhuzhanBuddyBtn:SetGroup(self:GetInstanceID())

	g_JjcCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFormationEvent"))
end

--协议通知返回
function CJjcGroupDetailBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Jjc.Event.JJCChallengeMainInfoUI then
		local oView = CJjcMainView:GetView()
		oView.m_GroupPart:ShowDetailBox()
		self:RefreshJJCChallengeMainInfoUI(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Jjc.Event.JJCChallengeTargetLineup then
		self:SetTargetBuddyInfo(oCtrl.m_EventData)
	end
end

function CJjcGroupDetailBox.OnCtrlFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.UpdateAllFormation then
		printc("CJjcGroupDetailBox.OnCtrlFormationEvent")
		table.print(oCtrl.m_EventData, "CJjcGroupDetailBox.OnCtrlFormationEvent")
		self:SetZhenfaListInfo(g_FormationCtrl:GetAllFormationInfo())
	end
end

--刷新挑战详情界面ui
--有对应的数据下发才会刷新对应的ui部分
function CJjcGroupDetailBox.RefreshJJCChallengeMainInfoUI(self, pbdata)
	local mask = pbdata.mask
	local difficulty = pbdata.difficulty
	local targets = pbdata.targets
	local lineup = pbdata.lineup
	local beats = pbdata.beats
	local times = pbdata.times

	if difficulty then
		self.m_RankLbl:SetText(self:GetDifficultyText(g_JjcCtrl.m_JjcChallengeChooseDifficulty).."难度")
	end
	if targets then
		self:SetTargetUI()
	end
	if lineup then
		self.m_SummonBox:SetSummonBox(g_JjcCtrl.m_JjcChallengeSummonid, g_JjcCtrl.m_JjcChallengeSummonicon, g_JjcCtrl.m_JjcChallengeSummonlv)
		self:ResetAllBuddyBox()
		self:ResetSummonBox()
		self:SetZhenfaInfo()
	end
	if beats then
		if table.count(g_JjcCtrl.m_JjcChallengeKillList) >= 5 then
			-- self.m_PrizeGetBtn:SetActive(true)
			self.m_ResetBtn:SetGrey(true)
			self.m_ResetBtn:GetComponent(classtype.BoxCollider).enabled = false
		else
			-- self.m_PrizeGetBtn:SetActive(false)
			self.m_ResetBtn:SetGrey(false)
			self.m_ResetBtn:GetComponent(classtype.BoxCollider).enabled = true
		end
	end

	if times then
		self.m_CountLbl:SetText(g_JjcCtrl.m_JjcChallengeResetTime.."次")
	end

	self:SetPrizeInfo(self:GetConfigPrize())
end

function CJjcGroupDetailBox.GetDifficultyText(self, idx)
	if idx == 1 then
		return "勇士"
	elseif idx == 2 then
		return "大师"
	elseif idx == 3 then
		return "宗师"
	else
		return ""
	end
end

function CJjcGroupDetailBox.SetTargetUI(self)
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeTargetList) do
		if self.m_ChallengeGroupList[k] then
			self.m_ChallengeGroupList[k]:SetGroupTargetInfo(v)
		end
	end
end

function CJjcGroupDetailBox.ResetAllBuddyBox(self)
	g_JjcCtrl.m_JjcChallengeBuddyClick = nil
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcChallengeBuddyList[k] then
			oBox:SetBuddyBox(g_JjcCtrl.m_JjcChallengeBuddyList[k])
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcGroupDetailBox.SetSelectBuddy(self, idx)
	if not g_JjcCtrl.m_JjcChallengeBuddyList[idx] or g_JjcCtrl.m_JjcChallengeBuddyClick then
		return
	end
	g_JjcCtrl.m_JjcChallengeBuddyClick = idx
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcChallengeBuddyList[k] then
			if k == idx then
				oBox:DownBuddyState(g_JjcCtrl.m_JjcChallengeBuddyList[k])
			else
				oBox:SwapBuddyState(g_JjcCtrl.m_JjcChallengeBuddyList[k])
			end
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcGroupDetailBox.ResetSummonBox(self)
	g_JjcCtrl.m_JjcChallengeSummonClick = nil
	self.m_SummonBox:SetSummonBox(g_JjcCtrl.m_JjcChallengeSummonid, g_JjcCtrl.m_JjcChallengeSummonicon, g_JjcCtrl.m_JjcChallengeSummonlv)
end

function CJjcGroupDetailBox.SetSelectSummon(self)
	if g_JjcCtrl.m_JjcChallengeSummonClick then
		return
	end
	g_JjcCtrl.m_JjcChallengeSummonClick = 1
	self.m_SummonBox:DownSummonState(g_JjcCtrl.m_JjcChallengeSummonid, g_JjcCtrl.m_JjcChallengeSummonicon, g_JjcCtrl.m_JjcChallengeSummonlv)
end

function CJjcGroupDetailBox.SetZhenfaInfo(self)
	local zhenfaConfig = data.formationdata.BASEINFO[g_JjcCtrl.m_JjcChallengeFmtid]
	local zhenfaStr
	self.m_SelfZhenfaBox.m_IconSp:SetSpriteName(zhenfaConfig.icon)
	if g_JjcCtrl.m_JjcChallengeFmtid == 1 then
		-- zhenfaStr = zhenfaConfig.name
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(false)
	else
		-- zhenfaStr = zhenfaConfig.name.." "..g_JjcCtrl.m_JjcChallengeFmtlv.."级"
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(true)
		self.m_SelfZhenfaBox.m_LevelLbl:SetText(g_JjcCtrl.m_JjcChallengeFmtlv)
	end
	self.m_SelfZhenfaBox.m_NameLbl:SetText(zhenfaConfig.name)
end

function CJjcGroupDetailBox.SetTargetBuddyInfo(self, oData)
	self.m_BuddyInfoBox:SetActive(true)
	self.m_BuddyInfoBox.m_SummonBox:SetTargetSummonBox(oData.lineup.summicon, oData.lineup.summlv)
	self:ResetAllTargetBuddyBox(oData.lineup.fighters)
	local oBox = self.m_ChallengeGroupList[1]
	for k,v in ipairs(self.m_ChallengeGroupList) do
		if v.m_GroupId == oData.target.id and v.m_GroupType == oData.target.type then
			oBox = v
			break
		end
	end
	UITools.NearTarget(oBox.m_ActorTexture, self.m_BuddyInfoBox, enum.UIAnchor.Side.Bottom)
	g_UITouchCtrl:TouchOutDetect(self.m_BuddyInfoBox, callback(self.m_BuddyInfoBox, "SetActive", false))
end

function CJjcGroupDetailBox.ResetAllTargetBuddyBox(self, oData)
	for k, oBox in ipairs(self.m_BuddyInfoBox.m_HelpList) do
		if oData[k] then
			oBox:SetBuddyBox(oData[k])
		else
			oBox:AddTargetBuddyState()
		end
	end
end

function CJjcGroupDetailBox.SetZhenfaListInfo(self, oData)
	-- table.print(oData, "CJjcGroupDetailBox.SetZhenfaListInfo")
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

function CJjcGroupDetailBox.AddZhenfaBox(self, oZhenfa)
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

function CJjcGroupDetailBox.SetBuddyListInfo(self, oData)
	self.m_BuddyListBox:SetActive(true)
	UITools.NearTarget(self.m_ZhuzhanBuddyBtn, self.m_BuddyListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -6, 0))
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

	-- g_UITouchCtrl:TouchOutDetect(self.m_BuddyListBox, callback(self.m_BuddyListBox, "SetActive", false))
end

function CJjcGroupDetailBox.AddBuddyBox(self, oBuddy)
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
	local quality = ((partnerData and {partnerData.quality} or {oBuddy.quality})[1]) - 1
	oBuddyBox.m_Quality:SetItemQuality(quality)
	oBuddyBox.m_NameLabel:SetText(oBuddy.name)
	local gradeStr = partnerData and partnerData.grade .. "级" or ""
	oBuddyBox.m_GradeLabel:SetText(gradeStr)
	-- local partnerType = DataTools.GetPartnerType(oBuddy.type)
	oBuddyBox.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[oBuddy.type])
	local schoolInfo = data.schooldata.DATA[oBuddy.school]
	oBuddyBox.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	oBuddyBox.m_FactionName:SetText(schoolInfo.name)
	oBuddyBox.m_TipSprite:SetActive(g_JjcCtrl:GetIsJjcChallengeBuddyIsInFight(oBuddy.serverid))
	self:SetStart(oBuddyBox, (partnerData and {partnerData.upper} or {0})[1])

	oBuddyBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectBuddy", oBuddy))
	self.m_BuddyListBox.m_Grid:AddChild(oBuddyBox)
	self.m_BuddyListBox.m_Grid:Reposition()
	-- self.m_BuddyListBox.m_ScrollView:CullContentLater()
end

function CJjcGroupDetailBox.SetStart(self, oBox, count)
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

function CJjcGroupDetailBox.SetSummonListInfo(self, oData)
	self.m_SummonListBox:SetActive(true)
	UITools.NearTarget(self.m_SummonBox.m_AddBtn, self.m_SummonListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -25, 0))
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

function CJjcGroupDetailBox.AddSummonBox(self, oSummon)
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
	if g_JjcCtrl.m_JjcChallengeSummonid == 0 then
		oSummonBox.m_TipSprite:SetActive(false)
	else
		oSummonBox.m_TipSprite:SetActive(g_JjcCtrl.m_JjcChallengeSummonid == oSummon.id)
	end
	-- self:SetStart(oSummonBox, partnerData and partnerData.upper or 0)

	oSummonBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectSummon", oSummon))
	self.m_SummonListBox.m_Grid:AddChild(oSummonBox)
	self.m_SummonListBox.m_Grid:Reposition()
	-- self.m_SummonListBox.m_ScrollView:CullContentLater()
end

function CJjcGroupDetailBox.SetFriendListInfo(self, oData)
	self.m_FriendListBox:SetActive(true)
	-- UITools.NearTarget(self.m_HelpBtn, self.m_FriendListBox, enum.UIAnchor.Side.Bottom)
	self.m_FriendListBox.m_Grid:Clear()

	if oData and next(oData) then
		local width = 110
		if #oData <= 3 then
			self.m_FriendListBox.m_Bg:SetHeight(width * #oData)
			self.m_FriendListBox:SetHeight(width * #oData)
		else
			self.m_FriendListBox.m_Bg:SetHeight(width * 3)
			self.m_FriendListBox:SetHeight(width * 3)
		end

		for k,v in ipairs(oData) do
			self:AddFriendBox(v)
		end
	end

	self.m_FriendListBox.m_Grid:Reposition()
	self.m_FriendListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_FriendListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0.1)

	-- g_UITouchCtrl:TouchOutDetect(self.m_FriendListBox, callback(self.m_FriendListBox, "SetActive", false))
end

function CJjcGroupDetailBox.AddFriendBox(self, oPid)
	local oFriendBox = self.m_FriendListBox.m_BoxClone:Clone()
	
	oFriendBox:SetActive(true)
	oFriendBox:SetPlayer(oPid)

	oFriendBox.m_ExpandBtn:AddUIEvent("click", callback(self, "OnClickInviteFriend", oPid))
	self.m_FriendListBox.m_Grid:AddChild(oFriendBox)
	self.m_FriendListBox.m_Grid:Reposition()
	-- self.m_FriendListBox.m_ScrollView:CullContentLater()
end

function CJjcGroupDetailBox.GetConfigPrize(self)
	local config = data.jjcdata.CHALLENGEREWARD[g_JjcCtrl.m_JjcChallengeChooseDifficulty]
	local list = {}
	for k,v in pairs(config.item) do
		list[k] = v
	end
	--暂时屏蔽竞技场积分
	-- local item = {amont = config.point, sid = 1010,}
	-- table.insert(list, item)
	return list
end

function CJjcGroupDetailBox.SetPrizeInfo(self, oData)
	self.m_PrizeGrid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddPrizeBox(v)
		end
	end
	self.m_PrizeGrid:Reposition()
	self.m_PrizeScrollView:ResetPosition()
end

function CJjcGroupDetailBox.AddPrizeBox(self, oPrize)
	local oPrizeBox = self.m_PrizeBoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
	local oItemConfig = DataTools.GetItemData(oPrize.sid)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrize, oPrizeBox))
	local ValueStr = string.gsub(oPrize.amont,"level",tostring(g_AttrCtrl.grade))
	local Value = load(string.format([[return (%s)]], ValueStr))()
	oPrizeBox.m_CountLbl:SetText(math.floor(tonumber(Value)))
	-- oPrizeBox.m_CountLbl:SetText(oPrize.amont)
	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
	-- self.m_PrizeScrollView:CullContentLater()
end

function CJjcGroupDetailBox.ShowZhuzhanView(self, isShowTips)
	if self.m_ZhuzhanSelectTab == 1 then
		self.m_ZhuzhanFriendBtn:SetSelected(true)
		
		self.m_BuddyListBox:SetActive(false)

		local frdlist = {}
		table.copy(g_FriendCtrl:GetMyFriend(), frdlist)
		table.sort(frdlist, g_FriendCtrl.JJCSort)
		table.print(frdlist, "CJjcGroupDetailBox.OnClickHelp")
		for k,v in ipairs(frdlist) do
			local frdobj = g_FriendCtrl:GetFriend(v)
			if frdobj and (frdobj.grade - g_AttrCtrl.grade) > 10 then
				table.remove(frdlist, k)
			end
		end
		if next(frdlist) then
			if g_JjcCtrl:GetIsFriendInvite() and isShowTips then
				g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.OnlyOneFriend].content)
				return
			end
			if #g_JjcCtrl.m_JjcChallengeBuddyList >= 4 then
				g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FullHelp].content)
				return
			end
			self:SetFriendListInfo(frdlist)
		else
			g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoFriend].content)
		end
	else
		self.m_ZhuzhanBuddyBtn:SetSelected(true)
		self.m_FriendListBox:SetActive(false)
		table.print(g_PartnerCtrl:GetPartnerDataList(), "CJjcGroupDetailBox.OnClickAddBuddy")
		if next(g_PartnerCtrl:GetPartnerDataList()) then
			self:SetBuddyListInfo(g_PartnerCtrl:GetPartnerDataList())
		else
			g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoBuddy].content)
		end
	end
end

-----------------以下是点击事件------------------

function CJjcGroupDetailBox.OnClickReset(self)
	if g_JjcCtrl.m_JjcChallengeResetTime <= 0 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.ChallengeResetNoTime].content)
	else
		local windowConfirmInfo = {
			msg				= data.jjcdata.TEXT[define.Jjc.Text.ChallengeReset].content,
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSResetChallengeTarget()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	end
end

function CJjcGroupDetailBox.OnClickPrizeGet(self)
	-- self:SetActive(false)
	-- CJjcMainView.ShowView(function (oView)
	-- 	oView:ShowGroupPart()
	-- end)
	netjjc.C2GSGetChallengeReward()
end

function CJjcGroupDetailBox.OnClickChooseZhenfa(self)
	if g_FormationCtrl:GetCurrentFmt() == 0 then
		netformation.C2GSAllFormationInfo()
	else
		local fmtlist = g_FormationCtrl:GetAllFormationInfo()
		self:SetZhenfaListInfo(fmtlist)
	end
end

function CJjcGroupDetailBox.OnClickBuddyBox(self, idx)
	if g_JjcCtrl.m_JjcChallengeBuddyClick then
		if g_JjcCtrl.m_JjcChallengeBuddyClick == idx then
			self:ResetAllBuddyBox()
		end
	else
		self:SetSelectBuddy(idx)
	end
end

function CJjcGroupDetailBox.OnClickBuddyDown(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeBuddyList) do
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
		table.insert(idlist, {id = v.id, type = v.type})
	end
	netjjc.C2GSSetChallengeFighter(idlist)
end

function CJjcGroupDetailBox.OnClickBuddySwap(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, {id = v.id, type = v.type})
	end
	local tempid = idlist[idx]
	idlist[idx] = idlist[g_JjcCtrl.m_JjcChallengeBuddyClick]
	idlist[g_JjcCtrl.m_JjcChallengeBuddyClick] = tempid
	netjjc.C2GSSetChallengeFighter(idlist)
end

function CJjcGroupDetailBox.OnClickAddBuddy(self, idx)	
	-- table.print(g_PartnerCtrl:GetPartnerDataList(), "CJjcGroupDetailBox.OnClickAddBuddy")
	-- if next(g_PartnerCtrl:GetPartnerDataList()) then
	-- 	self:SetBuddyListInfo(g_PartnerCtrl:GetPartnerDataList(), idx)
	-- else
	-- 	g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoBuddy].content)
	-- end
	self.m_ZhuzhanBox:SetActive(true)
	UITools.NearTarget(self.m_HelpList[idx].m_AddBtn, self.m_ZhuzhanBox, enum.UIAnchor.Side.Bottom)

	g_UITouchCtrl:TouchOutDetect(self.m_ZhuzhanBox, callback(self.m_ZhuzhanBox, "SetActive", false))

	if g_JjcCtrl:GetIsFriendInvite() then
		self.m_ZhuzhanSelectTab = 2
	else
		self.m_ZhuzhanSelectTab = 1
	end
	self:ShowZhuzhanView()
end

function CJjcGroupDetailBox.OnClickSummonBox(self)
	if g_JjcCtrl.m_JjcChallengeSummonClick then
		self:ResetSummonBox()
	else
		self:SetSelectSummon()
	end
end

function CJjcGroupDetailBox.OnClickSummonDown(self)
	netjjc.C2GSSetChallengeSummon(0)
end

function CJjcGroupDetailBox.OnClickAddSummon(self)
	table.print(g_SummonCtrl.m_SummonsSort, "CJjcGroupDetailBox.OnClickAddSummon")
	if next(g_SummonCtrl.m_SummonsSort) then
		self:SetSummonListInfo(g_SummonCtrl.m_SummonsSort)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoSummon].content)
	end
end

function CJjcGroupDetailBox.OnClickSelectZhenfa(self, oZhenfa)
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
	netjjc.C2GSSetChallengeFormation(oZhenfa.fmt_id)
end

--type1是玩家，2是伙伴
function CJjcGroupDetailBox.OnClickSelectBuddy(self, oBuddy)
	self.m_ZhuzhanBox:SetActive(false)
	self.m_BuddyListBox:SetActive(false)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, {id = v.id, type = v.type})
	end

	for k,v in pairs(idlist) do
		if v.id == oBuddy.serverid and v.type == 2 then
			return
		end
	end
	-- if table.index(idlist, {id = oBuddy.serverid, type = 2}) then
	-- 	return
	-- end
	if #idlist <= 3 then
		table.insert(idlist, {id = oBuddy.serverid, type = 2})
	end
	netjjc.C2GSSetChallengeFighter(idlist)
end

function CJjcGroupDetailBox.OnClickSelectSummon(self, oSummon)
	self.m_SummonListBox:SetActive(false)
	netjjc.C2GSSetChallengeSummon(oSummon.id)	
end

function CJjcGroupDetailBox.OnClickHelp(self)
	if g_JjcCtrl:GetIsFriendInvite() then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.OnlyOneFriend].content)
		return
	end
	if #g_JjcCtrl.m_JjcChallengeBuddyList >= 4 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.FullHelp].content)
		return
	end

	local frdlist = {}
	table.copy(g_FriendCtrl:GetMyFriend(), frdlist)
	table.sort(frdlist, g_FriendCtrl.JJCSort)
	table.print(frdlist, "CJjcGroupDetailBox.OnClickHelp")
	for k,v in ipairs(frdlist) do
		local frdobj = g_FriendCtrl:GetFriend(v)
		if frdobj and (frdobj.grade - g_AttrCtrl.grade) > 10 then
			table.remove(frdlist, k)
		end
	end
	if next(frdlist) then
		self:SetFriendListInfo(frdlist)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoFriend].content)
	end
end

function CJjcGroupDetailBox.OnClickInviteFriend(self, oPid)
	self.m_ZhuzhanBox:SetActive(false)
	self.m_FriendListBox:SetActive(false)

	if g_JjcCtrl:GetIsFriendInvite() then
		return
	end
	if #g_JjcCtrl.m_JjcChallengeBuddyList >= 4 then
		return
	end

	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, {id = v.id, type = v.type})
	end

	for k,v in pairs(idlist) do
		if v.id == oPid and v.type == 1 then
			return
		end
	end
	-- if table.index(idlist, {id = oPid, type = 1}) then
	-- 	return
	-- end
	if #idlist <= 3 then
		table.insert(idlist, {id = oPid, type = 1})
	end
	netjjc.C2GSSetChallengeFighter(idlist)
end

function CJjcGroupDetailBox.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.TopRight,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

function CJjcGroupDetailBox.OnClickJjcGroupTips(self)
	local zId = define.Instruction.Config.JjcGroup
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CJjcGroupDetailBox.OnClickShowInfo(self)
	-- self.m_ZhenfaBox:SetActive(true)
	-- UITools.NearTarget(self.m_InfoBtn, self.m_ZhenfaBox, enum.UIAnchor.Side.Bottom)

	-- local function hide()
	-- 	self.m_ZhenfaListBox:SetActive(false)
	-- 	self.m_SummonListBox:SetActive(false)
	-- 	self.m_ZhuzhanBox:SetActive(false)
	-- 	self.m_ZhenfaBox:SetActive(false)
	-- end
	-- g_UITouchCtrl:TouchOutDetect(self.m_ZhenfaBox, hide)
	CJjcGroupDetailSelectView:ShowView()
end

function CJjcGroupDetailBox.OnClickZhuzhanTab(self, index)
	self.m_ZhuzhanSelectTab = index
	self:ShowZhuzhanView(true)
end

return CJjcGroupDetailBox