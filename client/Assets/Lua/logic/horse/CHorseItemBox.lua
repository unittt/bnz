local CHorseItemBox = class("CHorseItemBox", CBox)

function CHorseItemBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Grade = self:NewUI(3, CLabel)
	self.m_Time = self:NewUI(4, CLabel)
	self.m_IsRide = self:NewUI(5, CBox)
	self.m_EmptyBox = self:NewUI(6, CWidget)
	self.m_ItemBox = self:NewUI(7, CWidget)
	self.m_Timer = nil
	self.m_LeftTime = nil
	self.m_ClickCb = nil

end

function CHorseItemBox.StartTimer(self)
	
	local cb = function (time, leftTime)
      
        if not time then 
            self.m_Time:SetText("剩余时间:过期")
            self.m_LeftTime = leftTime
        else
            self.m_Time:SetText("剩余时间:" .. time)
            self.m_LeftTime = leftTime
        end 

    end

    g_TimeCtrl:StartCountDown(self, self.m_Interval, 3, cb)

end

function CHorseItemBox.SetData(self, horseId, cb)

	local horseData = data.ridedata.RIDEINFO[horseId]
	if horseData then
		self.m_IsInit = true
		self.m_ClickCb = cb
		self.m_HorseId = horseId
		self.m_ItemBox:SetActive(true)
		self.m_EmptyBox:SetActive(false)
		local horse = g_HorseCtrl:GetHorseById(horseId)
		self.m_Icon:SetSpriteName(tostring(horseData.shape))
		self.m_Grade:SetText(g_HorseCtrl.grade.."级")
		self.m_Name:SetText(horseData.name)
		if horse.left_time == -1 then
			self.m_Time:SetText("剩余时间：永久")
			g_TimeCtrl:DelTimer(self)
		else
			self.m_Interval = horse.left_time
			self.m_LeftTime = horse.left_time
			self:StartTimer()
		end

		if g_HorseCtrl.use_ride == horseId then
			self.m_IsRide:SetActive(true)
		else
			self.m_IsRide:SetActive(false)
		end
		self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItem"))
	else 
		self.m_EmptyBox:SetActive(true)
		self.m_ItemBox:SetActive(false)
		self.m_ClickCb = cb
		self.m_EmptyBox:AddUIEvent("click", callback(self, "OnClickItem"))
	end 

end

function CHorseItemBox.ForceSelect(self)
	
	self.m_ItemBox:ForceSelected(true)

end

function CHorseItemBox.RefreshUseRideState(self)

	if not self.m_IsInit then 
		return
	end 
	
	if g_HorseCtrl.use_ride == self.m_HorseId then
		self.m_IsRide:SetActive(true)
	else
		self.m_IsRide:SetActive(false)
	end

end

function CHorseItemBox.OnClickItem(self)
	
	if self.m_ClickCb then 
		self.m_ClickCb(self)
	end

end

function CHorseItemBox.GetHorseId(self)
	
	return self.m_HorseId 

end

return CHorseItemBox