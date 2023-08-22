local CScheduleWeekCellBox = class("CScheduleWeekCellBox", CBox)

function CScheduleWeekCellBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_CallBack = cb
	self.m_Name = self:NewUI(1, CLabel)
	self.m_TagTip = self:NewUI(2, CSprite)
	self.m_CellBoxBtn = self:NewUI(3, CButton, true, false)
	self.m_CellBoxBtn:AddUIEvent("click", callback(self, "OnClickBox"))
end

function CScheduleWeekCellBox.OnClickBox(self)
	if self.m_CallBack then
		self.m_CallBack()
	end
end

function CScheduleWeekCellBox.SetScheduleWeekCellBox(self, index, weekInfo, highlightTime, highlightWeek)
	-- 第一列显示时间
	if index == 1 then
		self.m_TagTip:SetSpriteName("h7_naozhong")
		self.m_Name:SetText(weekInfo.time)
	elseif index > 1 then
		local weekIndex = index - 1
		local tagName = g_ScheduleCtrl:GetWeekDataInfoTagTip(weekInfo.time, weekIndex)
		local showTag = tagName and string.len(tagName) > 0
		self.m_TagTip:SetActive(showTag)
		-- if showTag then
		-- 	self.m_TagTip:SetSpriteName(tagName)
		-- end

		local nameStr = ""
		if weekInfo.weekInfoList[weekIndex] then
			local scheduleID = weekInfo.weekInfoList[weekIndex][1]
			local scheduleInfo = g_ScheduleCtrl:GetScheduleInfo(scheduleID)
			if scheduleInfo then
				nameStr = scheduleInfo.name or ""
			end
		end
		local showName = string.len(nameStr) > 0
		self.m_Name:SetActive(showName)
		if showName then
			self.m_Name:SetText(nameStr)
		end
	end
	self:SetBgStyle(index, highlightTime, highlightWeek)
end

function CScheduleWeekCellBox.SetBgStyle(self, index, highlightTime, highlightWeek)
	if index == 1 then
		
	else
		if highlightWeek  then
			--if not highlightTime then
				self.m_CellBoxBtn:SetSpriteName("h7_di_5")
			-- else
			-- 	self.m_CellBoxBtn:SetSpriteName("h7_di_25")
			--end
		end
	end
end

function CScheduleWeekCellBox.SetColRaw(self, raw, col)
	-- body
	local weekDataList = g_ScheduleCtrl:GetWeekDataInfoList()
	if raw > #weekDataList/2  then -- and col > 1
		self.m_CellBoxBtn:SetSpriteName("h7_di_4")
	end
end

return CScheduleWeekCellBox