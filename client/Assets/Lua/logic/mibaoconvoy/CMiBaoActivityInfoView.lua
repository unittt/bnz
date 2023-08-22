local CMiBaoActivityInfoView = class("CMiBaoActivityInfoView", CViewBase)

function CMiBaoActivityInfoView.ctor(self, cb)

	CViewBase.ctor(self, "UI/MiBao/MiBaoActivityInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
  --  self.m_ExtendClose = "Black"

end

function CMiBaoActivityInfoView.OnCreateView(self)

    self.m_Tip = self:NewUI(1, CSprite)
    self.m_ActivityTime = self:NewUI(2, CLabel)
    self.m_HideBtn = self:NewUI(3, CSprite)
    self.m_RobBtn = self:NewUI(4, CSprite)
    self.m_RobCnt = self:NewUI(5, CLabel)
    self.m_ConvoyTime = self:NewUI(6, CLabel)
    self.m_ConvoyProgress = self:NewUI(7, CLabel)
    self.m_ConvoyCnt = self:NewUI(8, CLabel)
    self.m_BeRobCnt = self:NewUI(9, CLabel)
    self.m_HuodongState = self:NewUI(10, CLabel)
    self:InitContent()

end

function CMiBaoActivityInfoView.InitContent(self)
    
    self.m_Tip:AddUIEvent("click", callback(self, "OnClickTip"))
    self.m_RobBtn:AddUIEvent("click", callback(self, "OnClickRobBtn"))
    g_MiBaoConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self:RefreshAll()

end

function CMiBaoActivityInfoView.RefreshAll(self)
    
    self:RefreshActivityTime()
    self:RefreshConvoyTime()
    self:RefreshConvoyProgress()
    self:RefreshConvoyCnt()
    self:RefreshBeRobCnt()
    self:RefreshRobCnt()
    self:RefreshRobBtn()

end

function CMiBaoActivityInfoView.RefreshActivityTime(self)
    
    if g_MiBaoConvoyCtrl:IsInPrepare() then
        self.m_HuodongState:SetText("活动开启时间:")
        self:ActivityTimeCountDown()
    elseif g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_HuodongState:SetText("活动结束时间:")
        self:ActivityTimeCountDown()
    else
         g_TimeCtrl:DelTimer(self.m_ActivityTime)
    end

end

function CMiBaoActivityInfoView.ActivityTimeCountDown(self)

    local refreshTime = function ( time )
        self.m_ActivityTime:SetText(time)
    end

    self.m_ActivityTime:SetActive(true)
    local endTime = g_MiBaoConvoyCtrl:GetAvtivityEndTime()
    local leftTime = endTime - g_TimeCtrl:GetTimeS()
    if leftTime > 0 then
        g_TimeCtrl:StartCountDown(self.m_ActivityTime, leftTime, 4, refreshTime)
    else
        self.m_ActivityTime:SetActive(false)
    end  

end 

function CMiBaoActivityInfoView.RefreshConvoyTime(self)
    
    local refreshTime = function ( time )
        self.m_ConvoyTime:SetText(time)
    end
    
    if not g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_ConvoyTime:SetActive(false)
    else
        self.m_ConvoyTime:SetActive(true)
        local endTime = g_MiBaoConvoyCtrl:GetConvoyTime()
        local leftTime = endTime - g_TimeCtrl:GetTimeS()
        if leftTime > 0 then 
            g_TimeCtrl:StartCountDown(self.m_ConvoyTime, leftTime, 4, refreshTime)
        else
            self.m_ConvoyTime:SetActive(false)
        end  
    end
    
end

function CMiBaoActivityInfoView.RefreshConvoyProgress(self)
    
    if not g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_ConvoyProgress:SetActive(false)
    else
        self.m_ConvoyProgress:SetActive(true)
        local curProgress = g_MiBaoConvoyCtrl:GetConvoyProgress()
        local totalProgress = g_MiBaoConvoyCtrl:GetConvoyTotalProgress()
        self.m_ConvoyProgress:SetText(tostring(curProgress) .. "/" .. tostring(totalProgress))
    end 

end

function CMiBaoActivityInfoView.RefreshConvoyCnt(self)
    
    if not g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_ConvoyCnt:SetActive(false)
    else
        self.m_ConvoyCnt:SetActive(true)
        local cur = g_MiBaoConvoyCtrl:GetConvoyCnt()
        local total = g_MiBaoConvoyCtrl:GetConvoyTotalCnt()
        self.m_ConvoyCnt:SetText(tostring(cur) .. "/" .. tostring(total))
    end 

end

function CMiBaoActivityInfoView.RefreshBeRobCnt(self)
    
    if not g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_BeRobCnt:SetActive(false)
    else
        self.m_BeRobCnt:SetActive(true)
        local cur = g_MiBaoConvoyCtrl:BeRobCnt()
        local total = g_MiBaoConvoyCtrl:BeRobTotalCnt()
        self.m_BeRobCnt:SetText(tostring(cur) .. "/" .. tostring(total))
    end 

end

function CMiBaoActivityInfoView.RefreshRobCnt(self)
    
    if not g_MiBaoConvoyCtrl:IsInProcess() then 
        self.m_RobCnt:SetActive(false)
    else
        self.m_RobCnt:SetActive(true)
        local cur = g_MiBaoConvoyCtrl:RobCnt()
        local total = g_MiBaoConvoyCtrl:RobTotalCnt()
        self.m_RobCnt:SetText(tostring(cur) .. "/" .. tostring(total))
    end 

end

function CMiBaoActivityInfoView.RefreshRobBtn(self)

    self.m_RobBtn:SetGrey(not g_MiBaoConvoyCtrl:IsInProcess())

end

function CMiBaoActivityInfoView.OnClickTip(self)

    local desInfo = data.instructiondata.DESC[10070]
    if desInfo then 
        local zContent = {title = desInfo.title, desc = desInfo.desc}
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end 

end

function CMiBaoActivityInfoView.OnClickRobBtn(self)
    
    if g_MiBaoConvoyCtrl:IsInProcess() then 
        g_MiBaoConvoyCtrl:C2GSTreasureConvoyMatchRob()
    end  

end

function CMiBaoActivityInfoView.OnCtrlEvent(self, oCtrl)

    if oCtrl.m_EventID == define.MiBaoConvoy.Event.StateChange or  oCtrl.m_EventID == define.MiBaoConvoy.Event.ConvoyInfo then
        self:RefreshAll()
    end

end

return CMiBaoActivityInfoView