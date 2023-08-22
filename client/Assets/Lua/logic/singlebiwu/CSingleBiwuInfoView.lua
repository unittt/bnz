local CSingleBiwuInfoView = class("CSingleBiwuInfoView", CViewBase)

function CSingleBiwuInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SingleBiwu/SingleBiwuInfoView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSingleBiwuInfoView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GroupGrid = self:NewUI(2, CGrid)
	self.m_RankScroll = self:NewUI(3, CScrollView) 
	self.m_RankGrid = self:NewUI(4, CGrid)
	self.m_RankBoxClone = self:NewUI(5, CBox)
	self.m_SummonBox = self:NewUI(6, CBox)
	self.m_PartnerGrid = self:NewUI(7, CGrid)
	self.m_SwapPartnerBtn = self:NewUI(8, CButton)
	self.m_FindBtn = self:NewUI(9, CButton)
	self.m_TipsBtn = self:NewUI(10, CButton)
	self.m_FirstWinBtn = self:NewUI(11, CSprite)
	self.m_FirstWinGetSpr = self:NewUI(12, CSprite)
	self.m_FiveFightBtn = self:NewUI(13, CSprite)
	self.m_FiveFightGetSpr = self:NewUI(14, CSprite)
	self.m_LeftTimeL = self:NewUI(15, CLabel)
	self.m_MyInfoBox = self:NewUI(16, CBox)	

	self.m_RankBoxs = {}
	self.m_CurGroup = -1

	self:InitContent()
end

function CSingleBiwuInfoView.InitContent(self)
	self.m_RankBoxClone:SetActive(false)

	self:InitSummonBox()
	self:InitPartnerBox()
	self:InitMyInfoBox()
	self:InitGroupTab()
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FindBtn:AddUIEvent("click", callback(self, "OnClickMatch"))
	self.m_FirstWinBtn:AddUIEvent("click", callback(self, "OnClickGetReward", 0))
	self.m_FiveFightBtn:AddUIEvent("click", callback(self, "OnClickGetReward", 1))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTipsView"))
	self.m_SwapPartnerBtn:AddUIEvent("click", callback(self, "ShowPartnerView"))

	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonEvent"))
	g_SingleBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSigleBiwuEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))

	self:ChangeGroup(g_SingleBiwuCtrl.m_MyGroup)
	self:RefreshAll()
end

function CSingleBiwuInfoView.InitGroupTab(self)
	self.m_GroupGrid:InitChild(function (obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:AddUIEvent("click", callback(self, "ChangeGroup", idx))
		oBtn:SetGroup(self.m_GroupGrid:GetInstanceID())
		return oBtn
	end)
end

function CSingleBiwuInfoView.InitPartnerBox(self)
	self.m_PartnerGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_AddBtn = oBox:NewUI(1, CButton)
		oBox.m_IconSpr = oBox:NewUI(2, CSprite)
		oBox.m_AddBtn:AddUIEvent("click", callback(self, "ShowPartnerView"))
		return oBox
	end)
end

function CSingleBiwuInfoView.InitSummonBox(self)
	local oBox = self.m_SummonBox
	oBox.m_AddBtn = oBox:NewUI(1, CButton)
	oBox.m_IconSpr = oBox:NewUI(2, CSprite)
	oBox.m_GradeL = oBox:NewUI(3, CLabel)
	oBox.m_SwapBtn = oBox:NewUI(4, CButton)
	oBox.m_SummonNode = oBox:NewUI(5, CObject)

	oBox.m_AddBtn:AddUIEvent("click", callback(self, "ShowSummonView"))
	oBox.m_SwapBtn:AddUIEvent("click", callback(self, "ShowSummonView"))
end

function CSingleBiwuInfoView.InitMyInfoBox(self)
	local oBox = self.m_MyInfoBox
	oBox.m_MyGroupL = oBox:NewUI(1, CLabel)
	oBox.m_MyPointL = oBox:NewUI(2, CLabel)
	oBox.m_MyRankL = oBox:NewUI(3, CLabel)
	oBox.m_WinL = oBox:NewUI(4, CLabel)
	oBox.m_MaxWinL = oBox:NewUI(5, CLabel)
	oBox.m_FightCntL = oBox:NewUI(6, CLabel)
end

function CSingleBiwuInfoView.OnSummonEvent(self, oCtrl)
	if (oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and 
		oCtrl.m_EventData.id == g_SummonCtrl:GetFightid()) or
		oCtrl.m_EventID == define.Summon.Event.SetFightId then
		-- printc("刷新宠物")
		self:RefreshSummonBox()
	end
end

function CSingleBiwuInfoView.OnSigleBiwuEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SingleBiwu.Event.BiwuInfo then
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.SingleBiwu.Event.RefreshRankList then
		self:RefreshRankList(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.SingleBiwu.Event.BiwuCountTime or 
		oCtrl.m_EventID == define.SingleBiwu.Event.BiwuEndCountTime then
		self:RefreshLeftTime()
	end
end

function CSingleBiwuInfoView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart then
		self:CloseView()
	end
end

---------------------Refresh UI-----------------------------------
function CSingleBiwuInfoView.RefreshAll(self)
	self:RefreshMyInfo()
	self:RefreshRewardStatus()
	self:RefreshSummonBox()
	self:RefreshPartnerBox()
	self:RefreshLeftTime()
	self:RefreshFindButton()
end

function CSingleBiwuInfoView.RefreshMyInfo(self)
	local oBox = self.m_MyInfoBox
	local dInfo = g_SingleBiwuCtrl.m_SingleWarInfo
	local sGroup = define.SingleBiwu.Group[dInfo.group_id]
	local sRank = (dInfo.rank and dInfo.rank <= g_SingleBiwuCtrl.m_MaxRankLimit) and dInfo.rank or "未上榜"

	oBox.m_MyGroupL:SetText(sGroup)
	oBox.m_MyPointL:SetText(dInfo.point)
	oBox.m_MyRankL:SetText(sRank)
	oBox.m_WinL:SetText(dInfo.win)
	oBox.m_MaxWinL:SetText(dInfo.win_seri_max)
	oBox.m_FightCntL:SetText(dInfo.war_cnt.."/"..g_SingleBiwuCtrl.m_FightTotal)
end

function CSingleBiwuInfoView.RefreshRankList(self, lRankInfo)
	self.m_RankScroll:ResetPosition()
	for i,oBox in ipairs(self.m_RankBoxs) do
		oBox:SetActive(false)
	end
	if not lRankInfo then
		return
	end
	for i,dInfo in ipairs(lRankInfo) do
		local oBox = self.m_RankBoxs[i]
		if not oBox then
			oBox = self:CreateRankBox()
			self.m_RankBoxs[i] = oBox
			self.m_RankGrid:AddChild(oBox)
		end
		self:UpdateRankBox(oBox, dInfo, i)
	end
	self.m_RankGrid:Reposition()
end

function CSingleBiwuInfoView.CreateRankBox(self)
	local oBox = self.m_RankBoxClone:Clone()
	oBox.m_RankSpr = oBox:NewUI(1, CSprite)
	oBox.m_RankL = oBox:NewUI(2, CLabel)
	oBox.m_NameL = oBox:NewUI(3, CLabel)
	oBox.m_PointL = oBox:NewUI(4, CLabel)
	oBox.m_WinL = oBox:NewUI(5, CLabel)
	oBox.m_BgSpr = oBox:NewUI(6, CSprite)
	return oBox
end

function CSingleBiwuInfoView.UpdateRankBox(self, oBox, dInfo, iIndex)
	local dData = data.schooldata.DATA[dInfo.school]
	oBox:SetActive(true)
	oBox.m_RankL:SetActive(iIndex > 3)
	oBox.m_RankSpr:SetActive(iIndex <= 3)
	oBox.m_RankSpr:SetSpriteName("h7_no"..iIndex)
	oBox.m_RankL:SetText(iIndex)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_PointL:SetText(dInfo.point)
	oBox.m_WinL:SetText(dInfo.win_seri_max)
	if iIndex % 2  == 1 then  -- 奇数
        oBox.m_BgSpr:SetSpriteName("h7_di_3")
    else    -- 偶数
        oBox.m_BgSpr:SetSpriteName("h7_di_4")
    end 
    oBox:AddUIEvent("click", callback(self, "OnPlayerInfo", dInfo.pid))
end

function CSingleBiwuInfoView.RefreshRewardStatus(self)
	local bEnablebFirstReward = g_SingleBiwuCtrl.m_SingleWarInfo.reward_first == 1
	local bEnableFiveReward = g_SingleBiwuCtrl.m_SingleWarInfo.reward_five == 1
	local bGetFirstReward = g_SingleBiwuCtrl.m_SingleWarInfo.reward_first == 2
	local bGetFiveReward = g_SingleBiwuCtrl.m_SingleWarInfo.reward_five == 2

	if bEnablebFirstReward then
		self.m_FirstWinBtn:AddEffect("Circu", Vector2(0, 30))
	else
		self.m_FirstWinBtn:DelEffect("Circu")
	end
	if bEnableFiveReward then
		self.m_FiveFightBtn:AddEffect("Circu", Vector2(0, 30))
	else
		self.m_FiveFightBtn:DelEffect("Circu")
	end

	if bGetFirstReward then
		self.m_FirstWinBtn:SetSpriteName("h7_xiang_4")
		self.m_FirstWinBtn:MakePixelPerfect()
	end
	if bGetFiveReward then
		self.m_FiveFightBtn:SetSpriteName("h7_xiang_3")
		self.m_FiveFightBtn:MakePixelPerfect()
	end

	self.m_FirstWinBtn:SetGrey(bGetFirstReward)
	self.m_FiveFightBtn:SetGrey(bGetFiveReward)

	self.m_FirstWinGetSpr:SetActive(bGetFirstReward)
	self.m_FiveFightGetSpr:SetActive(bGetFiveReward)
end

function CSingleBiwuInfoView.RefreshSummonBox(self)
	local dInfo = g_SummonCtrl:GetCurFightSummonInfo()
	local oBox = self.m_SummonBox
	oBox.m_SummonNode:SetActive(dInfo ~= nil)
	if dInfo then
		oBox.m_IconSpr:SpriteAvatar(dInfo.model_info.shape)
		oBox.m_GradeL:SetText(dInfo.grade)
	end
end

function CSingleBiwuInfoView.RefreshPartnerBox(self)
	local lPartner = g_FormationCtrl:GetCurrentPartnerList()
	for i=1,4 do
		local oBox = self.m_PartnerGrid:GetChild(i)
		local iPartnerId = lPartner[i]
		oBox.m_IconSpr:SetActive(iPartnerId ~= nil)
		if iPartnerId ~= nil then
			local dPartner = g_PartnerCtrl:GetRecruitPartnerDataBySID(iPartnerId)
			local dInfo = DataTools.GetPartnerInfo(dPartner.sid)
			oBox.m_IconSpr:SpriteAvatar(dInfo.shape)
		end
	end
end

function CSingleBiwuInfoView.RefreshLeftTime(self)
	if g_SingleBiwuCtrl:IsActivityEnd() then
		self.m_LeftTimeL:SetText("(活动已结束)")
		return
	end
	local iLeftTime = 0
	local sTitle = ""
	if g_SingleBiwuCtrl:IsActivityStart() then
		sTitle = "活动结束时间："
		iLeftTime = g_SingleBiwuCtrl.m_BiwuEndCountTime
	else
		sTitle = "活动开始时间："
		iLeftTime = g_SingleBiwuCtrl.m_BiwuStartCountTime
	end
	local sLeftTime = string.format("(%s%s)", sTitle, g_TimeCtrl:GetLeftTime(iLeftTime))
	self.m_LeftTimeL:SetText(sLeftTime)
end

function CSingleBiwuInfoView.RefreshFindButton(self)
	if g_SingleBiwuCtrl:IsOverFightCnt() then
		self.m_FindBtn:SetGrey(true)
		return
	end
	if g_SingleBiwuCtrl:IsActivityStart() and g_SingleBiwuCtrl:IsInMatch() then
		self.m_FindBtn:SetText("返回匹配")
		return
	end
	self.m_FindBtn:SetText("开始匹配")
end

---------------------------click event or UI event--------------------------------------
function CSingleBiwuInfoView.OnPlayerInfo(self, pid)
	netplayer.C2GSGetPlayerInfo(pid)
end

function CSingleBiwuInfoView.OnClickMatch(self)
	if g_SingleBiwuCtrl:IsActivityEnd() then
		g_NotifyCtrl:FloatMsg("活动已结束")
	elseif not g_SingleBiwuCtrl:IsActivityStart() then
		g_NotifyCtrl:FloatMsg("活动准备中")
	elseif g_SingleBiwuCtrl:IsActivityStart() and g_SingleBiwuCtrl:IsInMatch() then
		CSingleBiwuPrepareView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	else
		nethuodong.C2GSSingleWarStartMatch()
	end
	if not g_SingleBiwuCtrl:IsOverFightCnt() then
		self:CloseView()
	end
end

function CSingleBiwuInfoView.OnClickGetReward(self, iType)
	local iFirstRewardStatus = g_SingleBiwuCtrl.m_SingleWarInfo.reward_first
	local iGetFiveRewardStatus = g_SingleBiwuCtrl.m_SingleWarInfo.reward_five

	if iType == 0 then
		if iFirstRewardStatus == 0 then
			g_NotifyCtrl:FloatMsg("请先完成相关战斗")
		elseif iFirstRewardStatus == 1 then
			nethuodong.C2GSSingleWarGetRewardFirst()
		end
	elseif iType == 1 then
		if iGetFiveRewardStatus == 0 then
			g_NotifyCtrl:FloatMsg("请先完成相关战斗")
		elseif iGetFiveRewardStatus == 1 then
			nethuodong.C2GSSingleWarGetRewardFive()
		end
	end
end

function CSingleBiwuInfoView.ChangeGroup(self, iGroup)
	if self.m_CurGroup == iGroup then
		return
	end
	self.m_CurGroup = iGroup
	local oGroupTab = self.m_GroupGrid:GetChild(iGroup)
	oGroupTab:SetSelected(true)
	nethuodong.C2GSSingleWarRank(iGroup)
end

function CSingleBiwuInfoView.ShowTipsView(self)
	local id = define.Instruction.Config.SingleBiwu
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CSingleBiwuInfoView.ShowPartnerView(self)
	CPartnerMainView:ShowView(function(oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Lineup"))
	end)
end

function CSingleBiwuInfoView.ShowSummonView(self)
	CSummonMainView:ShowView()
end

return CSingleBiwuInfoView