local CEverydayRankView = class("CEverydayRankView", CViewBase)

function CEverydayRankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Timelimit/EverydayRankView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CEverydayRankView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RankInfoBox = self:NewUI(2, CRankInfoBox)
	self.m_MyInfoBox = self:NewUI(3, CBox)
	self.m_HintBox = self:NewUI(4, CBox)
	self.m_RankTypeScroll = self:NewUI(5, CScrollView)
	self.m_RankTypeTable = self:NewUI(6, CTable)
	self.m_RankTypeBoxClone = self:NewUI(7, CBox)
	self.m_HonorBox = self:NewUI(8, CBox)
	self.m_HonorTipsL = self:NewUI(9, CLabel)
	self.m_RankTypeTitleL = self:NewUI(10, CLabel)
	self.m_TipsBtn = self:NewUI(11, CButton)
	self.m_LeftTimeL = self:NewUI(12, CLabel)

	self.m_CurId = -1
	self.m_CurInfo = nil 
	self.m_SendRecordList = {}
	self.m_LeftTimer = nil
	self.m_UpdateLock = true
	self:InitContent()
end

function CEverydayRankView.InitContent(self)
	self.m_RankTypeBoxClone:SetActive(false)
	self.m_RankTypeTitleL:SetActive(false)
	self.m_RankInfoBox:SetStyle("EverydayRank")
	self:InitHonorBox()
	self:InitMyInfoBox()
	self:RefreshAll()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTipsView"))
	self.m_HonorTipsL:AddUIEvent("click", callback(self, "OnClickRankHonor"))
	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRankCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimeLimitCtrlEvent"))
	g_UITouchCtrl:TouchOutDetect(self.m_HonorBox, callback(self, "OnTouchOutDetect"))
end

function CEverydayRankView.InitMyInfoBox(self)
	local oBox = self.m_MyInfoBox
	self.m_MyRankL = oBox:NewUI(1, CLabel)
	self.m_MyNameL = oBox:NewUI(2, CLabel)
	self.m_MyCntL = oBox:NewUI(3, CLabel)
	self.m_MyScoreL = oBox:NewUI(4, CLabel) 
end

function CEverydayRankView.InitHonorBox(self)
	local oBox = self.m_HonorBox
	oBox.m_HonorL = oBox:NewUI(1, CLabel)
	oBox.m_LimitTimeL = oBox:NewUI(2, CLabel)
	oBox.m_AttrL = oBox:NewUI(3, CLabel)

	oBox:SetActive(false)
end

function CEverydayRankView.OnTimeLimitCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.UpdateEverydayRank then
		self:RefreshAll()
	end
end

function CEverydayRankView.OnRankCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Rank.Event.UpdateRankInfo then
        --暂时屏蔽
        self.m_UpdateLock = self.m_CurId ~= oCtrl.m_EventData.idx
        if self.m_UpdateLock then
            return
        end
        self.m_CurInfo = oCtrl.m_EventData
        self:RefreshRankInfo(self.m_CurInfo)
        self:RefreshMyInfo()
    end
end

function CEverydayRankView.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.UpDateScore then
		if self.m_UpdateLock then
			return
		end
		self.m_MyRankValue = oCtrl.m_EventData
		self:RefreshMyInfo()
	end
end

function CEverydayRankView.GetTitleData(self, iRankId)
	local dTitleReward = data.rankdata.REWARD[iRankId]
	local iTitleItem = dTitleReward.title_list[1]
	local dItemData = DataTools.GetItemData(iTitleItem)
	local iTitle = tonumber(dItemData.item_formula)
	local dTitleData = data.titledata.INFO[iTitle]
	return dTitleData
end

-------------------------------------------------
function CEverydayRankView.RefreshAll(self)
	self:RefreshRankTypeTable()
	self:RefreshLeftTime()
end

function CEverydayRankView.RefreshLeftTime(self)
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local iLeftTime = g_TimelimitCtrl.m_EverydayRankEndTime - g_TimeCtrl:GetTimeS()
		if g_TimelimitCtrl.m_EverydayRankEndTime == 0 or iLeftTime <= 0 then
			self.m_LeftTimeL:SetText("")
			return
		end
		local sLeftTime = g_TimeCtrl:GetLeftTimeDHM(iLeftTime)
		self.m_LeftTimeL:SetText(sLeftTime)
		return true
	end
	Utils.AddTimer(update, 1, 0)
end

function CEverydayRankView.RefreshRankDesc(self)
	local dTitleData = self:GetTitleData(self.m_CurId)
	local sTitle = dTitleData.name
	local dRankData = self.m_RankData
	local sDesc = dRankData.rankdesc
	sDesc = string.gsub(sDesc, "#count", dRankData.count)
	sDesc = string.gsub(sDesc, "#title", sTitle)
	self.m_HonorTipsL:SetText(sDesc)
end

function CEverydayRankView.RefreshMyInfo(self)
	local iRank = g_RankCtrl.m_MyRank or 0
	local iValue = self.m_MyRankValue or 0
	local iPlayerScore = g_AttrCtrl.score

    if iRank > data.rankdata.INFO[self.m_CurId].count or iRank == 0 then 
        self.m_MyRankL:SetText("我的名次:榜外")
    else
        self.m_MyRankL:SetText("我的名次:"..iRank)
    end
    local iHeadCnt = #self.m_RankData.head
    local sTitle = self.m_RankData.head[iHeadCnt - 1]
    self.m_MyCntL:SetText(sTitle..":"..iValue)
    self.m_MyScoreL:SetText(iPlayerScore)
    self.m_MyNameL:SetText(g_AttrCtrl.name)
end

function CEverydayRankView.RefreshRankTypeTable(self)
	self.m_RankTypeTable:Clear()
		
	local lDefineRank = data.huodongdata.EVERYDAYRANK[1].stable_rank
	local iRandomRank = g_TimelimitCtrl.m_RandomRankIndex

	if iRandomRank and iRandomRank > 0 then
		self:AddTitle("随机榜：")
		self:AddRankType(iRandomRank)
	end

	local oTitleL = self.m_RankTypeTitleL:Clone()
	self:AddTitle("每日榜：")
	for i,v in ipairs(lDefineRank) do
		self:AddRankType(v)
	end
	self.m_RankTypeTable:Reposition()

	local oFirstBox = self.m_RankTypeTable:GetChild(2) --第一個是title，故從2算起
	if oFirstBox then
		self:OnClickRankType(oFirstBox, oFirstBox.m_RankId)
	end
end

function CEverydayRankView.AddTitle(self, sTitle)
	local oTitleL = self.m_RankTypeTitleL:Clone()
	oTitleL:SetText(sTitle)
	oTitleL:SetActive(true)
	self.m_RankTypeTable:AddChild(oTitleL)
end

function CEverydayRankView.AddRankType(self, iRankId)
	local oBox = self:CreateRankType()
	local dData = data.rankdata.INFO[iRankId]
	oBox.m_RankId = iRankId
	oBox.m_NameL:SetText(dData.name)
	oBox.m_SelNameL:SetText(dData.name)
	oBox:AddUIEvent("click", callback(self, "OnClickRankType", oBox, iRankId))
	self.m_RankTypeTable:AddChild(oBox)
end

function CEverydayRankView.CreateRankType(self)
	local oBox = self.m_RankTypeBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_SelNameL = oBox:NewUI(2, CLabel)
	oBox:SetActive(true)
	return oBox
end

function CEverydayRankView.RefreshRankInfo(self)
	self.m_HonorBox:SetActive(false)
    self.m_RankInfoBox:SetActive(true)
    self.m_MyInfoBox:SetActive(true)
    
    if self.m_CurInfo.page > 1 then 
        self.m_RankInfoBox:AddItemInfo(g_RankCtrl.m_RankList[self.m_CurId], self.m_CurInfo.page,self.m_CurInfo.idx)
        return
    end 
    
    self.m_RankInfoBox:InitInfo(self.m_CurId, g_RankCtrl.m_RankList[self.m_CurId], self.m_CurInfo.my_rank, self.m_CurInfo.page,callback(self, "GetUpdateInfo"))
end

function CEverydayRankView.ResetScrollView(self)
    self.m_RankInfoBox.m_ScrollView:ResetPosition()
end

function CEverydayRankView.GetUpdateInfo(self)
    if self.m_CurId ~= self.m_CurInfo.idx then
        return
    end
    local iPage = self.m_CurInfo.page + 1
    if iPage <= g_RankCtrl.m_RankTotalPage then
        if not self.m_SendRecordList[self.m_CurId][iPage] then
            g_RankCtrl:C2GSGetRankInfo(self.m_CurId, iPage)
            self.m_SendRecordList[self.m_CurId][iPage] = true
        end
    end
end

function CEverydayRankView.RefreshHonorBox(self)
	self.m_HonorBox:SetActive(true)
	local oBox = self.m_HonorBox
	local dTitleData = self:GetTitleData(self.m_CurId)
	local sLeftTime = g_TimeCtrl:GetLeftTimeDHMAlone(dTitleData.duration_time*60)

	oBox.m_HonorL:SetText(dTitleData.name)
	oBox.m_LimitTimeL:SetText(sLeftTime)
	oBox.m_AttrL:SetText(dTitleData.effect_desc)
end

-------------------------------------------------
function CEverydayRankView.OnClickRankType(self, oBox, iRankId)
	oBox:SetSelected(true)

	if self.m_CurId == iRankId then
        return
    end
    self:ResetScrollView()
    self.m_CurId = iRankId
    self.m_SendRecordList[self.m_CurId] = {}
    g_RankCtrl.m_MyRankValue = -1
    self.m_RankData = data.rankdata.INFO[self.m_CurId]  

    if not self.m_SendRecordList[self.m_CurId][1] then
        g_RankCtrl:C2GSGetRankInfo(self.m_CurId, 1)
        self.m_SendRecordList[self.m_CurId][1] = true
    end
    netplayer.C2GSGetScore(iRankId)
    self:RefreshRankDesc()
end

function CEverydayRankView.OnClickRankHonor(self)
	self:RefreshHonorBox()
end

function CEverydayRankView.OnTouchOutDetect(self, gameObj)
	if gameObj ~= self.m_HonorBox.m_GameObject then
		self.m_HonorBox:SetActive(false)
	end
end

function CEverydayRankView.ShowTipsView(self)
	local id = self.m_RankData.des
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CEverydayRankView.OnClose(self)
    self:CloseView()
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

return CEverydayRankView