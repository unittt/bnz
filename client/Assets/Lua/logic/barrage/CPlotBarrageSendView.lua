local CPlotBarrageSendView = class("CPlotBarrageSendView", CViewBase)

function CPlotBarrageSendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Barrage/PlotBarrageSendView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CPlotBarrageSendView.OnCreateView(self)

	self.m_SendNode = self:NewUI(1, CBox)
	self.m_BarrageOpen = self:NewUI(2, CBox)
	self.m_SendBox = self:NewUI(3, CBarrageSendBox)
	self.m_BarrageOpenSwitch = self.m_BarrageOpen:NewUI(1, CWidget)

	self.m_IsOpenBarrage = true

	self:OpenBarrageUI()

	self.m_BarrageOpenSwitch:AddUIEvent("click", callback(self, "OnClickBarrage"))

end

--开关弹幕界面
function CPlotBarrageSendView.OnClickBarrage(self)

    self.m_IsOpenBarrage = not self.m_IsOpenBarrage
    if self.m_IsOpenBarrage then 
        g_BarrageCtrl:ShowBarrageView(true)
    else
        g_BarrageCtrl:ShowBarrageView(false)
    end 
   
end

--打开弹幕相关组件
function CPlotBarrageSendView.OpenBarrageUI(self)

	-- g_BarrageCtrl:OpenBarrageView()
	
	-- self.m_SendBox:SetState(define.Barrage.State.Plot)

	-- self.m_SendNode:SetActive(true)
	
end


return CPlotBarrageSendView