local CScoreShowView = class("CScoreShowView", CViewBase)

function CScoreShowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/ScoreShowView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CScoreShowView.OnCreateView(self)
	self.m_ScoreBox = self:NewUI(1, CBox)

	self.m_UpSp = self.m_ScoreBox:NewUI(1, CSprite)
	self.m_UpLbl = self.m_ScoreBox:NewUI(2, CLabel)
	self.m_AddTagBox = self.m_ScoreBox:NewUI(9, CBox)
	self.m_ReduceTagBox = self.m_ScoreBox:NewUI(10, CBox)
	self.m_AddLbl = self.m_ScoreBox:NewUI(11, CLabel)
	self.m_ReduceLbl = self.m_ScoreBox:NewUI(12, CLabel)
	self.m_Grid = self.m_ScoreBox:NewUI(13, CGrid)

	self.m_ScoreTotal = 6
	self.m_ScoreBoxList = {}
	for i=1, self.m_ScoreTotal, 1 do
		table.insert(self.m_ScoreBoxList, self.m_ScoreBox:NewUI(i+2, CTreasurePrizeBox))
	end
	self.m_ScoreBox:SetActive(false)
	
	self:InitContent()
end

function CScoreShowView.InitContent(self)
end

function CScoreShowView.RefreshUI(self, oScore, oOldScore)
	local oUpValue = oScore - oOldScore
	if oUpValue > 0 then
		local oLen = string.len(tostring(oScore))
		local oLen1 = string.len(tostring(oOldScore))
		if oLen > oLen1 then
			self:ShowScoreChange(oScore, oUpValue, oLen)
		else
			local oSetLength = 0
			for i=1, oLen1 do
				local oNumStr = string.sub(tostring(oScore), -i, -i)
				local oNumStr1 = string.sub(tostring(oOldScore), -i, -i)
				if oNumStr ~= oNumStr1 then
					oSetLength = i
				end
			end
			self:ShowScoreChange(oScore, oUpValue, oSetLength)
		end
		self.m_AddTagBox:SetActive(true)
		self.m_ReduceTagBox:SetActive(false)
		self.m_AddLbl:SetText(oUpValue)
	elseif oUpValue < 0 then
		local oLen = string.len(tostring(oScore))
		local oLen1 = string.len(tostring(oOldScore))
		if oLen < oLen1 then
			self:ShowScoreChange(oScore, oUpValue, oLen)
		else
			local oSetLength = 0
			for i=1, oLen1 do
				local oNumStr = string.sub(tostring(oScore), -i, -i)
				local oNumStr1 = string.sub(tostring(oOldScore), -i, -i)
				if oNumStr ~= oNumStr1 then
					oSetLength = i
				end
			end
			self:ShowScoreChange(oScore, oUpValue, oSetLength)
		end
		self.m_AddTagBox:SetActive(false)
		self.m_ReduceTagBox:SetActive(true)
		self.m_ReduceLbl:SetText(math.abs(oUpValue))
	end
end

function CScoreShowView.ShowScoreChange(self, Score, oUpValue, oSetLength)
	self.m_ScoreBox:SetActive(true)

	local oUpStr = tostring(math.abs(oUpValue))
	local oUpShowStr = ""
	for i = 1, string.len(oUpStr) do
		local oStr = string.sub(oUpStr, i, i)
		if oStr == "-" then
			oUpShowStr = oUpShowStr..oStr
		else
			oUpShowStr = oUpShowStr.."#mark_"..oStr
		end 
	end
	self.m_UpLbl:SetText(oUpShowStr)
	local PrizeNumList, realPrizeNumList = g_TreasureCtrl:GetEachNumList(Score, self.m_ScoreTotal)
	for i=1, self.m_ScoreTotal, 1 do
		if i <= self.m_ScoreTotal - #realPrizeNumList then
			self.m_ScoreBoxList[i]:SetActive(false)
		else
			self.m_ScoreBoxList[i]:SetActive(true)
		end
	end
	self.m_Grid:Reposition()
	--从个位开始赋值
	for i=self.m_ScoreTotal, 1, -1 do
		local oNum = PrizeNumList[self.m_ScoreTotal+1-i]
		local oRound
		if i <= self.m_ScoreTotal - (oSetLength or 0) then
			oRound = 0
		else
			oRound = (self.m_ScoreTotal-i+1)
		end
		if oUpValue > 0 then
			self.m_ScoreBoxList[i]:SetEachNum(oNum, oRound, 5, true)
		else
			self.m_ScoreBoxList[i]:SetEachNum(oNum, oRound, 5)
		end
	end

	local function onEnd()
		if self.m_ScoreEndTimer then
			Utils.DelTimer(self.m_ScoreEndTimer)
			self.m_ScoreEndTimer = nil
		end
		local function onEnd()
			if Utils.IsNil(self) then
				return false
			end			
			self:CloseView()
			return false
		end
		self.m_ScoreEndTimer = Utils.AddTimer(onEnd, 0, 0.5)
	end

	self.m_ScoreBoxList[self.m_ScoreTotal].m_Callback = onEnd
end

return CScoreShowView