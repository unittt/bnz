local CJieBaiCountDownView = class("CJieBaiCountDownView", CViewBase)

function CJieBaiCountDownView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiCountDownView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"

end

function CJieBaiCountDownView.OnCreateView(self)

    self.m_Tips = self:NewUI(1, CSprite)
    self.m_Time = self:NewUI(2, CLabel)
    self.m_Text = self:NewUI(3, CLabel)

    self.m_Tips:AddUIEvent("click", callback(self, "OnClickTipBtn"))
     g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))

    self:RefreshTime()
    self:RefreshText()

end

function CJieBaiCountDownView.RefreshTime(self)
	
	local remainTime = g_JieBaiCtrl:GetYiShiStateTime()
	local cb = function (time)
	    if not time then 
	        self.m_Time:SetText("剩余时间:00:00")
	    else
	        self.m_Time:SetText("(剩余时间:" .. time .. ")")
	    end 
	end
	g_TimeCtrl:StartCountDown(self, remainTime, 1, cb)

end

function CJieBaiCountDownView.RefreshText(self)
	
	local state = g_JieBaiCtrl:GetCurYiShiState()
	if state == define.JieBai.YiShiState.Open then
		self.m_Text:SetText("举行仪式")
	elseif state == define.JieBai.YiShiState.Select then 
		self.m_Text:SetText("准备祭品")
	end 
	
end

function CJieBaiCountDownView.OnClickTipBtn(self)
    
    g_JieBaiCtrl:ShowIntruction(10067)

end

function CJieBaiCountDownView.OnJieBaiEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange then
        local state = g_JieBaiCtrl:GetCurYiShiState()
        if state == define.JieBai.YiShiState.Open or state == define.JieBai.YiShiState.Select then 
        	self:RefreshTime()
        	self:RefreshText()
        else
        	self:OnClose()
        end  
    end

end

return CJieBaiCountDownView