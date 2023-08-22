local CFightOutsideBuffBox = class("CFightOutsideBuffBox", CBox)

function CFightOutsideBuffBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_BuffAttr = self:NewUI(3, CLabel)
	self.m_SimpleDes = self:NewUI(4, CLabel)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_LeftTimeLbl = self:NewUI(6, CLabel)
	self.m_LeftTimeLbl:SetActive(false)

	self.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddBtn"))

	self.m_BuffAttr:SetActive(false)
	
	g_DancingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateDancingEvent"))
end

function CFightOutsideBuffBox.OnUpdateDancingEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Dancing.Event.DanceCount then
    	if not self.m_data then
    		return
    	end
    	if self.m_data.id ~= g_DancingCtrl.m_dancingStateId then
    		return
    	end        
        if g_DancingCtrl.m_DanceLeftTime <= 0 then
        	self.m_LeftTimeLbl:SetActive(false)
        else
        	self.m_LeftTimeLbl:SetActive(true)
        	self.m_LeftTimeLbl:SetText(g_TimeCtrl:GetLeftTime(g_DancingCtrl.m_DanceLeftTime))
        end
    end
end

function CFightOutsideBuffBox.SetData(self, data)

	self.m_data = data
	self.m_Name:SetText(data.name)
	self.m_SimpleDes:SetText(data.des)
	self.m_Icon:SetSpriteName(data.icon)

	local leftTime = data.time - g_TimeCtrl:GetTimeS()
	if leftTime > 0 then 
		g_TimeCtrl:StartCountDown(self, leftTime, 2, callback(self, "RefreshTime"))
	else
		self:HandleBuffLabel()
	end 
	
	self.m_AddBtn:SetActive(data.isNeedBtn == 1 and true or false)

	self.m_LeftTimeLbl:SetActive(false)
	if self.m_data.id == g_DancingCtrl.m_dancingStateId and g_DancingCtrl.m_DanceLeftTime > 0 then
		self.m_LeftTimeLbl:SetActive(true)
    	self.m_LeftTimeLbl:SetText(g_TimeCtrl:GetLeftTime(g_DancingCtrl.m_DanceLeftTime))
	end
end

function CFightOutsideBuffBox.RefreshTime(self, time)
	local s = "剩余:" .. time
	self.m_BuffAttr:SetText(s)
	self.m_BuffAttr:SetActive(true)
end

function CFightOutsideBuffBox.OnClickAddBtn(self)
	-- 这里需要对双点做特殊逻辑，因此判定搬到数据层
	g_FightOutsideBuffCtrl:C2GSClickState(self.m_data.id)
end

function CFightOutsideBuffBox.HandleBuffLabel(self)
	if not self.m_data.attrList[1] then 
		return
	end 

	local value = tostring(self.m_data.attrList[1].value)
	local info = nil

	local str = self.m_data.remainTime
	if str and string.find(str, "#") then 
		info = string.gsub(str, "#", value)
		self.m_BuffAttr:SetText(info)
		self.m_BuffAttr:SetActive(true)
	end
end

return CFightOutsideBuffBox