local CBarragePopView = class("CBarragePopView", CViewBase)

function CBarragePopView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Barrage/BarragePopView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondTop"

end

function CBarragePopView.OnCreateView(self)

	self.m_LabelNode = self:NewUI(1, CWidget)
	self.m_LabelClone = self:NewUI(2, CLabel)

	--Label之间的间隔
	self.m_Interval = 40
	--label运动时间
	self.m_MovingTime = 10
	--优先显示的chanelId队列，暂时优先显示1,2chanel
	self.m_PriorityChanelList = {1,2}
	--普通channelId队列
	self.m_NormalChannelList = {3,4,5,6}
	--运动中的Label列表
	self.m_MovingLabelList = {}
	--缓存的Label对象
	self.m_CacheLabelList = {}
	--缓存的数量
	self.m_CacheCount = 10
	--channel位置
	self.m_ChannelPosList = {}
	--弹幕弹出频率
	self.m_PopFrequency = 0.2
	--弹幕类型
	self.m_Type = 0
	--距离屏幕顶部的距离
	self.m_TopDis = UnityEngine.Screen.height * 0.15

	self:InitChannelPos()


end

--开始弹幕
function CBarragePopView.StartBarrage(self)
	
	local fun = function ( ... )

		if not Utils.IsNil(self) then 
			self:PopInfo()
			self:ClearLabels()
			return true
		else
			return false
		end 

	end

	self.m_Timer = Utils.AddTimer(fun, self.m_PopFrequency, 1)

end

--结束弹幕
function CBarragePopView.StopBarrage(self)
	
	if self.m_Timer then 

		Utils.DelTimer(self.m_Timer)

		self:CloseView()

	end 

end


--从消息队列中取出消息,并生成label对象
function CBarragePopView.PopInfo(self)
	--printc("---------------------------pop")

	if not next(g_BarrageCtrl.m_TextDataList) then
		return
	end 

	if self:IsAllChannelEmptyPos() then 
		if next(g_BarrageCtrl.m_TextDataList) then
			local info = g_BarrageCtrl.m_TextDataList[1]
		    table.remove(g_BarrageCtrl.m_TextDataList, 1)
			local oLabel = nil
			if next(self.m_CacheLabelList) then 
				oLabel = self.m_CacheLabelList[1]
				table.remove(self.m_CacheLabelList, 1)
			else
				oLabel = self.m_LabelClone:Clone()
			end 

			self:SetInfoToLabel(oLabel, info)
			oLabel:SetParent(self.m_LabelNode.m_Transform)
			self:SetOLabelToChanel(oLabel)
			oLabel:SetActive(true)
			self:StartToMove(oLabel)


		end	
	end 

end

--clear运动列表中的对象
function CBarragePopView.ClearLabels(self)

	for k, v in ipairs(self.m_MovingLabelList) do 
		if v then 
			for j, oLabel in ipairs(v) do

				if  oLabel and oLabel.isMoveEnd then
					if #self.m_CacheLabelList <= self.m_CacheCount then
						table.insert(self.m_CacheLabelList, oLabel)
						oLabel:SetActive(false)	
						oLabel.isMoveEnd = false		
					else 
						oLabel:Destroy()
					end
					table.remove(v, j)
					
				end
			end 
		end 
	end

end



--初始化channel位置
function CBarragePopView.InitChannelPos(self)
	
	local channelCount = #self.m_PriorityChanelList + #self.m_NormalChannelList
	local ScreenHeight = UnityEngine.Screen.height
	local range = ScreenHeight * 0.5
	local eachChannelHeight = math.floor(range / channelCount)
	for i=1, channelCount do 
		self.m_ChannelPosList[i] = ScreenHeight - self.m_TopDis - eachChannelHeight * (i - 1)
	end

end

function CBarragePopView.SetInfoToLabel(self, oLabel, info)
	
	local msg = info.msg
	if info.isShowName then 
		msg = "[1849FFFF]" .. info.name .. "[-]" .. ": " .. info.msg
	end 

	oLabel:SetRichText(string.format(data.colorinfodata.OTHER.barrage.color, msg))

end

--设置label的位置
function CBarragePopView.SetLabelPos(self, oLabel, channelId)

	local screenPosY = self.m_ChannelPosList[channelId]
	local screenPosX = UnityEngine.Screen.width
	local oUICamera = g_CameraCtrl:GetUICamera()
	local wPos = oUICamera:ScreenToWorldPoint(Vector3.New(screenPosX, screenPosY, 0))
	oLabel:SetPos(wPos)

end

--将label放置到chanel中
function CBarragePopView.SetOLabelToChanel(self, oLabel)
		
	local channelId = self.m_PriorityChanelList[1]
	table.remove(self.m_PriorityChanelList, 1)
	table.insert(self.m_PriorityChanelList, channelId)
	if self:IsChannelEmptyPos(channelId) then 
		self:SetLabelPos(oLabel, channelId)
		local oLabelTable = self.m_MovingLabelList[channelId] or {}
		table.insert(oLabelTable, oLabel)
		self.m_MovingLabelList[channelId] = oLabelTable

	else
		channelId = self.m_PriorityChanelList[1]
		table.remove(self.m_PriorityChanelList, 1)
		table.insert(self.m_PriorityChanelList, channelId)
		if self:IsChannelEmptyPos(channelId)  then 
			self:SetLabelPos(oLabel, channelId)
			local oLabelTable = self.m_MovingLabelList[channelId] or {}
			table.insert(oLabelTable, oLabel)
			self.m_MovingLabelList[channelId] = oLabelTable
		else
			for j, i in ipairs(self.m_NormalChannelList) do 

				if self:IsChannelEmptyPos(i) then 
					self:SetLabelPos(oLabel, i)
					local oLabelTable = self.m_MovingLabelList[i] or {}
					table.insert(oLabelTable, oLabel)
					self.m_MovingLabelList[i] = oLabelTable
					break
				end 

			end  
		end 
	end 


end

function CBarragePopView.IsAllChannelEmptyPos(self)
	
	for k, v in ipairs(self.m_PriorityChanelList) do 
		if self:IsChannelEmptyPos(v) then 
			return true
		end 
	end 

	for k, v in ipairs(self.m_NormalChannelList) do 
		if self:IsChannelEmptyPos(v) then 
			return true
		end 
	end 

	return false

end

--判断该chanel是否有位置
function CBarragePopView.IsChannelEmptyPos(self, channelId)
	
	if next(self.m_MovingLabelList) then
		for k, v in ipairs(self.m_MovingLabelList) do
			if k == channelId then 
				local count = #v
				local lastLabel = v[count]
				if lastLabel then 
					local lp = self:CalculateLabelRightPos(lastLabel)
					if (lp + self.m_Interval) <= UnityEngine.Screen.width then 
						return true
					else 
						return false
					end 
				end
			end 
		end
	end 
	return  true

end

--计算label边缘
function CBarragePopView.CalculateLabelRightPos(self, oLabel)
	
	local labelWidth , labelHeight =  oLabel:GetSize()
	local wp = oLabel:GetPos()
	local sp = self:GetScreenPos(wp)
	return sp.x + labelWidth

end

function CBarragePopView.GetScreenPos(self, WorldPos)

	local oUICamera = g_CameraCtrl:GetUICamera()
	local screenPos = oUICamera:WorldToScreenPoint(WorldPos)
	return screenPos

end

function CBarragePopView.GetWorldPos(self, screenPos)

	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos

end

function CBarragePopView.StartToMove(self, oLabel)
	
	local lp = oLabel:GetPos()
	local sp = self:GetScreenPos(lp)
	local wp = self:GetWorldPos(Vector3.New(-UnityEngine.Screen.width/2, sp.y, 0))
	local endMove = function (la)
		local fun = function ( ... )
			la.isMoveEnd = true 
		end
		return fun
	end

	local tween = DOTween.DOMoveX(oLabel.m_Transform, wp.x, self.m_MovingTime)
	DOTween.SetEase(tween, 1)
	DOTween.OnComplete(tween, endMove(oLabel))

end

return CBarragePopView