local CJieBaiWaitView = class("CJieBaiWaitView", CViewBase)

function CJieBaiWaitView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiWaitView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiWaitView.OnCreateView(self)

    self.m_Time = self:NewUI(1, CLabel)
    self.m_DescL = self:NewUI(2, CLabel)
    self.m_DescL:SetText(g_JieBaiCtrl:GetTextTip(1035))
end


function CJieBaiWaitView.SetTime(self, remainTime)
    
    local cb = function (time)
        if not time then 
            self.m_Time:SetText("操作倒计时:00:00")
            self:ForceClose()
        else
            self.m_Time:SetText("(操作倒计时:" .. time .. ")")
        end 
    end
    g_TimeCtrl:StartCountDown(self, remainTime, 4, cb)

end

function CJieBaiWaitView.OnClose(self)
    
    g_NotifyCtrl:FloatMsg(g_JieBaiCtrl:GetTextTip(1097))

end

function CJieBaiWaitView.ForceClose(self)
    
    CViewBase.OnClose(self)

end


return CJieBaiWaitView