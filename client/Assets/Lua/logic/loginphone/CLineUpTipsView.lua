local CLineUpTipsView = class("CLineUpTipsView", CViewBase)

function CLineUpTipsView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Login/LineUpTipsView.prefab", cb)
    --界面设置
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CLineUpTipsView.OnCreateView(self)
    self.m_ServerName = self:NewUI(1, CLabel)  --服务器名           
    self.m_LineCount = self:NewUI(2, CLabel)   --排队人数
    self.m_WaitTime = self:NewUI(3, CLabel)    --等待时间
    self.m_ExitBtn = self:NewUI(4, CButton)    --退出排队
    self.m_CloseBtn = self:NewUI(5, CButton)   --退出排队
    self.m_ServerState = self:NewUI(6, CSprite) --登陆状态
    self.m_ExitBtn:AddUIEvent("click", callback(self, "OnExitClick"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnExitClick"))
    g_LoginPhoneCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self.m_Timer = nil
end

function CLineUpTipsView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Login.Event.LineOver then
       self:CloseUI()
    end
    if oCtrl.m_EventID == define.Login.Event.UpdateWaitTime then
       self:Refresh(oCtrl.m_EventData)
    end
end

function CLineUpTipsView.Refresh(self, info)
    printc("刷新排队ui")
    self.m_ServerState:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(g_LoginPhoneCtrl:GetSelectdSeverState()))
    self.m_ServerName:SetText("[a64e00]服务器[-]       "..g_ServerPhoneCtrl:GetCurServerName())
    self.m_LineCount:SetText("[a64e00]当前排在您前面的人数[-][49666DFF] "..info.cnt.." [-][a64e00]人[-]")
    self.m_WaitTime:SetText("[a64e00]预计等待:[-][406168FF]"..self:GetLeftTime(info.time).."[-]")
    self:SetActive(true)
    self:SendGetLeftTime()
end

function CLineUpTipsView.OnExitClick(self)
    --通知服务器退出排队，关闭排队界面
    printc("取消排队")
    g_LoginPhoneCtrl:C2GSQuitLoginQueue()
    self:ShwoLineView()
end

function CLineUpTipsView.CloseUI(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    self:SetActive(false)
    self:CloseView()
end                             

function CLineUpTipsView.ShwoLineView(self)
    self:CloseUI()

    -- 重新打开登录界面 
    g_LoginPhoneCtrl:ResetAllData() 
    CLoginPhoneView:ShowView(function (oView)
        oView:RefreshUI()
        --这里是在有中心服的数据情况下
        if g_LoginPhoneCtrl.m_IsQrPC then
            g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
        end
    end)
end

--刷新等待时间
function CLineUpTipsView.RefreshWaitTime(self, times)
    self.m_WaitTime:SetText("预计等待："..self:GetLeftTime(times))       
end

function CLineUpTipsView.SendGetLeftTime(self)
    if self.m_Timer then
        return
    end
    local update = function() 
          if Utils.IsExist(self) then
             netlogin.C2GSGetLoginWaitInfo()
             return true
          end
    end
    self.m_Timer = Utils.AddTimer(update,10,10)
end


function CLineUpTipsView.GetLeftTime(self, iSec)
    iSec = math.floor(iSec)
    
    local hour = math.modf(iSec / 3600)
    local min = math.floor((iSec % 3600) / 60)
    local sec = iSec % 60
    if hour > 0 then
        return string.format("%d小时%d分", hour, min)
    else
        return string.format("%d分钟", min)
    end
end

return CLineUpTipsView