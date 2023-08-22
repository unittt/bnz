local CScheduleWeekBox = class("CScheduleWeekBox", CBox)

function CScheduleWeekBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SaveSprList = {}
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_WeekBoxTabGrid = self:NewUI(2, CGrid)
	self.m_WeekBoxScroll = self:NewUI(3, CScrollView)
	self.m_WeekBoxGrid = self:NewUI(4, CGrid)
	self.m_WeekCellBoxGridClone = self:NewUI(5, CGrid)
	self.m_WeekCellBoxClone = self:NewUI(6, CScheduleWeekCellBox)
	self.m_SplitSprBox = self:NewUI(7, CBox)
	for i=1, 7 do
		table.insert(self.m_SaveSprList, self.m_SplitSprBox:NewUI(i, CSprite))
	end
	self.m_WeekCellBoxGridClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseWeedBox"))
	-- 保持oItem引用，否者local生命周期下New的对象被lua内存管理gc
	self.m_WeekCellBoxList = {}
end

function CScheduleWeekBox.OnCloseWeedBox(self)
	local oView = CScheduleMainView:GetView()
	if oView then
		oView.m_BaseContent:SetActive(true)
		oView.m_MainContent:SetActive(true)
	end
	self:SetActive(false)
end

-- 设置数据
function CScheduleWeekBox.SetScheduleWeekBox(self)
	--打开日程周历界面，隐藏其他的界面。
	local oView = CScheduleMainView:GetView()
	if oView then
		oView.m_BaseContent:SetActive(false)
		oView.m_MainContent:SetActive(false)
	end
	self:SetActive(true)
	self:SetWeekBoxTabSelect()
	self:InitWeekTimeBoxGrid()
end

function CScheduleWeekBox.SetWeekBoxTabSelect(self)
	local nowWeekIndex = tonumber(g_TimeCtrl:GetTimeWeek())
	nowWeekIndex = nowWeekIndex == 0 and 7 or nowWeekIndex
	-- 第一列是时间，因此下标需要-1
	local function InitBoxTab(obj, index)
		local oWeekCellBox = nil
		if index - 1 == nowWeekIndex then
			local oWeekCellBox = CSprite.New(obj)
			oWeekCellBox:SetSpriteName("h7_zhoulidi")

			if nowWeekIndex == 7 then
				self.m_SaveSprList[7]:SetActive(false)
			else
				self.m_SaveSprList[nowWeekIndex]:SetActive(false)
				self.m_SaveSprList[nowWeekIndex+1]:SetActive(false)
			end
		end
		
	end
	self.m_WeekBoxTabGrid:InitChild(InitBoxTab)
end

function CScheduleWeekBox.InitWeekTimeBoxGrid(self)
	local weekDataList = g_ScheduleCtrl:GetWeekDataInfoList()
	local nowWeekIndex = tonumber(g_TimeCtrl:GetTimeWeek())
	local nowTimeIndex = self:GetWeekTimeNodeIdx(weekDataList)
	local weekTimeBoxGridList = self.m_WeekBoxGrid:GetChildList()
	local oWeekTimeBoxGrid = nil
	for i,v in ipairs(weekDataList) do
		if i > #weekTimeBoxGridList then
			oWeekTimeBoxGrid = self.m_WeekCellBoxGridClone:Clone()
			self.m_WeekBoxGrid:AddChild(oWeekTimeBoxGrid)
			oWeekTimeBoxGrid:SetActive(true)
		else
			oWeekTimeBoxGrid = weekTimeBoxGridList[i]
		end

		local highlightTime = i == nowTimeIndex
		local function InitWeekCell(obj, index)
			local weekIndex = index - 1
			local oWeekCellBox = self.m_WeekCellBoxClone.New(obj, function ()
				if weekIndex > 0 and v.weekInfoList[weekIndex] then
					local scheduleID = v.weekInfoList[weekIndex][1]
					local scheduleInfo = g_ScheduleCtrl:GetScheduleInfo(scheduleID)
					if scheduleInfo then
						CScheduleInfoView:ShowView(function (oView)
							oView:SetScheduleInfo(scheduleInfo)
						end)
					end
				end
			end)
			local highlightWeek = weekIndex == nowWeekIndex
			oWeekCellBox:SetColRaw(i,index)
			oWeekCellBox:SetScheduleWeekCellBox(index, v, highlightTime, highlightWeek)
			table.insert(self.m_WeekCellBoxList, oWeekCellBox)
		end
		oWeekTimeBoxGrid:InitChild(InitWeekCell)
	end
	for i=#weekDataList+1,#weekTimeBoxGridList do
		weekTimeBoxGridList[i]:SetActive(false)
	end	
	self.m_WeekBoxGrid:Reposition()
	self.m_WeekBoxScroll:ResetPosition()
end

function CScheduleWeekBox.GetWeekTimeNodeIdx(self, weekDataList)
	local timeHM = g_TimeCtrl:GetTimeHM()
	local index = 1
	for i,v in ipairs(weekDataList) do
		if timeHM < v.time then
			index = i
			break
		end
	end
	return index
end



return CScheduleWeekBox