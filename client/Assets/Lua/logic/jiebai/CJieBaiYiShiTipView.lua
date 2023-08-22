local CJieBaiYiShiTipView = class("CJieBaiYiShiTipView", CViewBase)

function CJieBaiYiShiTipView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiYiShiTipView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiYiShiTipView.OnCreateView(self)

    self.m_Tip = self:NewUI(1, CLabel)
    
end

function CJieBaiYiShiTipView.SetInfo(self, text, showTime, cb)
    
    self.m_Tip:SetText(text)
    self:RefreshShowTime(showTime)
    self.m_Cb = cb

end

function CJieBaiYiShiTipView.RefreshShowTime(self, showTime)
    
    showTime = showTime or 5
    self.m_Timer = Utils.AddTimer(function ()
        self:OnClose()
        return false
    end, 0, showTime)

end

function CJieBaiYiShiTipView.OnClose(self)
    
    if self.m_Timer then 
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end 

    CViewBase.OnClose(self)
    if self.m_Cb then 
        self.m_Cb()
        self.m_Cb = nil
    end 

end

return CJieBaiYiShiTipView