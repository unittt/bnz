local CScoreBox = class("CScoreBox" ,CBox)

function CScoreBox.ctor(self, obj)
	CBox.ctor(self ,obj)
	self.m_RefreshTimer = nil
	self.m_FloatTimer =nil
	self.m_LastScore = nil  --上一次的分数
	self.m_ListCache = {}
	self.m_TweenList = {}
	self.m_CSprite = self:NewUI(1, CSprite)
	self.m_UpLabel = self:NewUI(2, CLabel)
	for i=1,6 do
		table.insert(self.m_ListCache, self:NewUI(2+i, CBox))
	end
end

function CScoreBox.ShowInfo(self, CurScore)
	-- body
	if  CurScore == self.m_LastScore then
		self:SetActive(false)
		return
	end
	if  CurScore ~= self.m_LastScore then
		self.m_LastScore = g_NotifyCtrl.m_RecordScore
		g_NotifyCtrl:InitScore(CurScore)
		self.m_TweenList ={}

		if CurScore > self.m_LastScore then
			self.m_CSprite:SetSpriteName("h7_sheng")
		else
			self.m_CSprite:SetSpriteName("h7_jiang")
		end
		self.m_UpLabel:SetText(self:GetNumberString(math.abs(CurScore -self.m_LastScore) ))
		local len 
		if string.len(CurScore) >= string.len(self.m_LastScore) then
			len = string.len(CurScore)
			for i=1,string.len(CurScore)- string.len(self.m_LastScore)do
				self.m_LastScore ="0"..self.m_LastScore
			end
		else
			len = string.len(self.m_LastScore)
			for i=1,string.len(self.m_LastScore)-string.len(CurScore)  do
				CurScore = "0"..CurScore 
			end
		end
		for i=1,len do
			local list = self.m_ListCache[i]
			list:SetActive(true)
			local value = string.sub(self.m_LastScore,i,i)
			list:SetLocalPos(Vector3.New(-113+i*20, 54-value*54, 0)) --初始化位置
			local tweenpos = list:GetComponent(classtype.TweenPosition)
			table.insert(self.m_TweenList, tweenpos)
		end
		self:Play(CurScore-self.m_LastScore)
	end
end
	
function CScoreBox.Play(self, delta)
	-- if delta>0 then
	-- else
	-- end
	-- for i,list in ipairs(self.m_ListCache) do
	-- 	if list:GetActive() then
	-- 		for
	-- 	end
	-- end
end

function CScoreBox.SetTimer(self, iTime, cb)
	self.m_Callback = cb
	self.m_PastTime = 0
	self.m_LastTime = iTime
	if self.m_FloatTimer then
		Utils.DelTimer(self.m_FloatTimer)
		self.m_FloatTimer = nil
	end
	self.m_FloatTimer = Utils.AddTimer(callback(self, "AlphaAndCB"), 0, 0)
end

function CScoreBox.AlphaAndCB(self, t)
	local iLastTime = 0
	self.m_PastTime = self.m_PastTime + t
	if self.m_PastTime > iLastTime then
		local fAlpha = (2 - (self.m_PastTime - iLastTime))
		if fAlpha < 0 then
			if self.m_Callback then
				self.m_Callback(self)
			end
			return false
		else
			self:SetAlpha(fAlpha)
		end
	end
	return true
end
function CScoreBox.GetEachNumList(self,targetnum)
  --列表是尾插入，越后面的是越高位
  local realPrizeNumList = {}
  local num = targetnum
  while num ~= 0 do
    table.insert(realPrizeNumList,num%10)
    num = math.modf(num/10)
  end
  return realPrizeNumList
end

function CScoreBox.GetNumberString(self,markNum)
    if markNum == 0 then
        return "#mark_0"
    end
    local realPrizeNumList = self:GetEachNumList(markNum) 
    local numStr = ""
    for k,v in ipairs(realPrizeNumList) do
        numStr = "#mark_"..v..numStr
    end
    return numStr
   
end
return CScoreBox
