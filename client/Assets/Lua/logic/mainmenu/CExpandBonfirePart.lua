local CExpandBonfirePart = class("CExpandBonfirePart", CPageBase)

function CExpandBonfirePart.ctor(self, obj)
    CPageBase.ctor(self, obj)
    self.m_AddExpCount = 0
    self.m_TeamAddExpXCount = 0
end

function CExpandBonfirePart.OnInitPage(self)
    self.m_ExpAddLabel = self:NewUI(2, CLabel)
    self.m_WineBtn = self:NewUI(3, CButton)
    self.m_GiveBtn = self:NewUI(4, CButton)
    self.m_AnswerBtn = self:NewUI(5, CButton)
    self.m_DesBtn = self:NewUI(6, CButton)
    self.m_TimeLbl = self:NewUI(7, CLabel, false)
    self:InitContent()
end

function CExpandBonfirePart.InitContent(self)
    --self.m_ExpAddLabel:SetText("0%")
    self.m_WineBtn:AddUIEvent("click", callback(self, "OnWineBtn"))
    self.m_GiveBtn:AddUIEvent("click", callback(self, "OnGiveBtn"))
    self.m_AnswerBtn:AddUIEvent("click", callback(self, "OnAnswerBtn"))
    self.m_DesBtn:AddUIEvent("click", callback(self, "OnDesBtn"))
    g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCampfireCtrl"))
    if g_BonfireCtrl.m_DrinkBuffAdds then
       self.m_AddExpCount = g_BonfireCtrl.m_DrinkBuffAdds
    end
    self:CalCulateTeamAddExp()
    -- if self.m_ExpAddLabel then
    --     local sum = self.m_AddExpCount + self.m_TeamAddExpXCount
    --     self.m_ExpAddLabel:SetText(sum.."%")
    -- end
    self.m_TimeLbl:SetActive(false)
    if g_BonfireCtrl.m_CampfireInfo then
        self:UpdateTimeLabel(g_BonfireCtrl.m_CampfireInfo)
    end
end

function CExpandBonfirePart.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Team.Event.MemberUpdate or oCtrl.m_EventID == define.Team.Event.AddTeam then
        self:CalCulateTeamAddExp()
    end
    if oCtrl.m_EventID == define.Team.Event.DelTeam then
        if self.m_ExpAddLabel then
            self.m_ExpAddLabel:SetText(self.m_AddExpCount.."%")
        end 
    end
end

function CExpandBonfirePart.CalCulateTeamAddExp(self)
    local list =  g_TeamCtrl:GetMemberList()
    table.print(list)
    local count = 0
    for k,v in pairs(list) do
        if g_TeamCtrl:IsOffline(v.pid) == false then
            count = count + 1
        end
    end
    printc("队伍数量:"..count)
    if count > 1 then
        self.m_TeamAddExpXCount = (count - 1)*data.bonfiredata.CONFIG.adds_per_member
    else
        self.m_TeamAddExpXCount = 0
    end
    local sum = self.m_AddExpCount + self.m_TeamAddExpXCount
    if self.m_ExpAddLabel then
        self.m_ExpAddLabel:SetText(sum.."%")
    end
end

function CExpandBonfirePart.OnCampfireCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.UpdateLeftTime then
        self:UpdateTimeLabel(oCtrl.m_EventData)
    end
end

--------------------篝火活动倒计时---------------------
function CExpandBonfirePart.UpdateTimeLabel(self, info)
    if not self.m_TimeLbl then
        return
    end
    if self.m_CDTimer then
        Utils.DelTimer(self.m_CDTimer)
        self.m_CDTimer = nil
    end
    self.m_TimeLbl:SetActive(true)
    self.m_CDTimer = Utils.AddTimer(function()
        info.lefttime = info.lefttime - 1
        if info.lefttime < 0 then
            return false     
        end

        local Timetext = ""

        if info.state == 1 then
            Timetext = "预计开始时间 "..g_TimeCtrl:GetLeftTime(info.lefttime, false)
        elseif info.state == 2 then
            Timetext = "活动剩余时间 "..g_TimeCtrl:GetLeftTime(info.lefttime, false)
        end
        self.m_TimeLbl:SetRichText("#G"..Timetext.."#n", nil, nil, true)     
        return true      
    end, 1, 0)
end

function CExpandBonfirePart.SetInfo(self, info)
    self.m_AddExpCount = info
    self:CalCulateTeamAddExp()
end

function CExpandBonfirePart.OnWineBtn(self)
    CBonfireWineView:ShowView()
end

function CExpandBonfirePart.OnGiveBtn(self)
    g_BonfireCtrl:C2GSCampfireQueryGiftables()
end

function CExpandBonfirePart.OnAnswerBtn(self)
    if g_BonfireCtrl.m_CurQuestionState == 0 or next(g_BonfireCtrl.m_CurTopicInfo) == nil then
        -- local sText = data.bonfiredata.TEXT[5001].content
        -- sText = string.gsub(sText, "#time", 1)
        -- g_NotifyCtrl:FloatMsg(sText)
        nethuodong.C2GSCampfireDesireQuestion()
        return
    elseif g_BonfireCtrl.m_CurQuestionState == 2 then
        g_NotifyCtrl:FloatMsg(data.bonfiredata.TEXT[5002].content)
        return
    elseif g_BonfireCtrl.m_CurQuestionState == 3 and next(g_BonfireCtrl.m_CurTopicInfo) == nil then
        g_NotifyCtrl:FloatMsg(data.bonfiredata.TEXT[5003].content)
        return
    end
    local view = CBonfireHintView:GetView()
    if view then
        view:ShowAnswerTopic()
        return
    else
        CBonfireHintView:ShowView(function (oView)
            oView:ShowAnswerTopic()
        end)
    end
end

function CExpandBonfirePart.OnDesBtn(self)
    local zContent = {title = "规则",desc = data.instructiondata.DESC[10002].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CExpandBonfirePart.Destroy(self)
    if self.m_CDTimer then
        Utils.DelTimer(self.m_CDTimer)
    end
    if self.m_TimeLbl then
        self.m_TimeLbl:SetActive(false)
    end
    CPageBase.Destroy(self)
end

return CExpandBonfirePart