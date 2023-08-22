local COrgWelfareItemBox = class("COrgWelfareItemBox", CBox)

function COrgWelfareItemBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ActivityIcon = self:NewUI(1, CSprite)
    self.m_ActivityName = self:NewUI(2, CLabel)
    self.m_ActivityDes = self:NewUI(3, CLabel)
    self.m_ActivityAward = self:NewUI(4, CLabel)
    self.m_ActivityInput = self:NewUI(5, CInput)
    self.m_GetAwardBtn = self:NewUI(6, CButton)
    self.m_GetAwardOther = self:NewUI(7, CLabel)
    self.m_RewardGrid = self:NewUI(8, CGrid)
    self.m_RewardBox = self:NewUI(9, CBox)

    self.m_ItemDic = {sign = 1001, dividend = 1002, award = 1003, goal = 1004, activity = 1005, redpacket = 1006}
end

function COrgWelfareItemBox.InitContent(self, v, info)
    self.m_BaseInfo = v
    self.m_CurStatuInfo = info
    self.m_ActivityIcon:SetSpriteName(tostring(v.icon))
    self.m_ActivityName:SetText(v.name)
    self.m_ActivityAward:SetText(v.awardname)
    self.m_ActivityDes:SetText(v.des)
    self.m_GetAwardBtn:DelEffect("RedDot")
    if v.id == self.m_ItemDic.sign then
        self:SetSignItem(v)
    elseif v.id == self.m_ItemDic.dividend then
        self:SetDividendItem(v)
    elseif v.id == self.m_ItemDic.award then
        self:SetAwardItem(v) 
    elseif v.id == self.m_ItemDic.goal then
        self:SetGoalItem(v)      
    elseif v.id == self.m_ItemDic.activity then
        self:SetActivityItem(v)
    elseif v.id == self.m_ItemDic.redpacket then
        self:SetRedPacketItem(v)
    end
    self.m_GetAwardBtn:AddUIEvent("click", callback(self, "OnGetAward", v))
    self.m_ActivityInput:AddUIEvent("submit", callback(self, "OnInputSubmit"))
    self.m_ActivityInput:AddUIEvent("select", callback(self, "OnInputSubmit"))

    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function COrgWelfareItemBox.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Org.Event.UpdateOrgRedPoint then
        if self.m_BaseInfo.id == self.m_ItemDic.redpacket then
            self:CheckOrgRedPoint()
        end
    end
end

function COrgWelfareItemBox.OnInputSubmit(self)
    local iText = self.m_ActivityInput:GetText()

    local bStringWithBlock = self:IsStringWithAllBlock(iText)
    if bStringWithBlock then
        self.m_ShowMsg = self.m_BaseInfo.other
        self.m_ActivityInput:SetText(self.m_ShowMsg)
    end
end

function COrgWelfareItemBox.SetSignItem(self, v)
    self.m_GetAwardBtn:SetText("签到")
    self.m_ActivityInput:SetActive(true)

    self.bShowConfig = false
    local ConfigText = IOTools.GetClientData("org_sign_Config"..g_AttrCtrl.pid)
    if not ConfigText then
        ConfigText = v.other
        IOTools.SetClientData("org_sign_Config"..g_AttrCtrl.pid, ConfigText)
    elseif ConfigText ~= v.other then
        ConfigText = v.other
        self.bShowConfig = true
    end

    local sText = IOTools.GetClientData("org_sign_"..g_AttrCtrl.pid)
    if sText == nil or string.len(sText) == 0 then
        sText = ConfigText
    end

    if self.bShowConfig then
        self.m_ShowMsg = ConfigText
    else
        self.m_ShowMsg = sText
    end
    self.m_ActivityInput:SetText(self.m_ShowMsg)
   
    self.m_GetAwardOther:SetActive(false)
    if self.m_CurStatuInfo.sign_status == 1 then
        self.m_GetAwardBtn:SetGrey(true)
    else
        self.m_GetAwardBtn:AddEffect("RedDot", 20, Vector2.New(-15, -19))
        self.m_GetAwardBtn:SetGrey(false)
    end
end

function COrgWelfareItemBox.SetAwardItem(self, v)
    self.m_GetAwardBtn:SetText("领取")
    self.m_ActivityInput:SetActive(false)
    local position = data.orgdata.POSITIONID[g_OrgCtrl.m_Org.info.position]
    local poscoin = data.orgdata.OTHERS[1].pos_coin
    local other = v.other
    if position then
        other = string.gsub(other, "#position", position.name) 
    end
    local sReward = self:GetCoinReward(self.m_CurStatuInfo.pos_reward)
    sReward = sReward == "" and "#cur_2 0" or sReward
    self.m_GetAwardOther:SetText(other..sReward)--string.format(" %s %s ", poscoin, self.m_CurStatuInfo.pos_coin))

    if self.m_CurStatuInfo.pos_status ~= 1 then
        self.m_GetAwardBtn:SetGrey(true)
    else
        self.m_GetAwardBtn:AddEffect("RedDot", 20, Vector2.New(-15, -19))
        self.m_GetAwardBtn:SetGrey(false)
    end
end

function COrgWelfareItemBox.SetDividendItem(self, v)
    self.m_GetAwardBtn:SetText("领取")
    self.m_ActivityInput:SetActive(false)
    self.m_GetAwardOther:SetActive(true)

    -- local sAward = self:GetCoinReward(self.m_CurStatuInfo.bonus_reward)
    -- if self.m_CurStatuInfo.bonus_offer == 0 then
    --     sAward = string.format("#cur_3 %s  #cur_4 %s",
    --         self.m_CurStatuInfo.bonus_coin, self.m_CurStatuInfo.bonus_sliver)
    -- else
    --     sAward = string.format("#cur_3 %s  #cur_7 %s  #cur_4 %s",
    --         self.m_CurStatuInfo.bonus_coin, self.m_CurStatuInfo.bonus_offer, self.m_CurStatuInfo.bonus_sliver)
    -- end
    -- self.m_GetAwardOther:SetText(sAward)
    self.m_GetAwardOther:SetActive(false)
    self:RefreshRewardGrid(self.m_CurStatuInfo.bonus_reward)
    if self.m_CurStatuInfo.bonus_status ~= 1 then
        self.m_GetAwardBtn:SetGrey(true)
    else
        self.m_GetAwardBtn:AddEffect("RedDot", 20, Vector2.New(-15, -19))
        self.m_GetAwardBtn:SetGrey(false) 
    end 
end

function COrgWelfareItemBox.SetGoalItem(self, v)
    self.m_GetAwardBtn:SetText("查看")
    self.m_ActivityInput:SetActive(false)
    self.m_GetAwardOther:SetActive(false)

    if v.other == "" then
        local v3 =  self.m_ActivityDes:GetLocalPos()
        v3.y = 1
       self.m_ActivityDes:SetLocalPos(v3)
    end
end

function COrgWelfareItemBox.SetActivityItem(self, v)
    self.m_GetAwardBtn:SetText("查看")
    self.m_ActivityInput:SetActive(false)
    self.m_GetAwardOther:SetActive(false)
    if v.other == "" then
        local v3 =  self.m_ActivityDes:GetLocalPos()
        v3.y = 1
       self.m_ActivityDes:SetLocalPos(v3)
    end
    local activity = DataTools.GetNextOrgActivity(tonumber(g_TimeCtrl:GetTimeWeek()), g_TimeCtrl:GetTimeHM())
    if activity then
        local sActivity = string.format("[c][BD5733]【%s】%s开启", activity.name, activity.time)
        self.m_ActivityDes:SetText(v.des..sActivity)
        self.m_ActivityDes:AddUIEvent("click", function()
            CScheduleInfoView:ShowView(function (oView)
                oView:SetScheduleID(activity.id)
            end)
        end)
    else
        self.m_ActivityDes:SetText(v.des.." 敬请期待")
    end
    self.m_GetAwardBtn:SetGrey(false) 
end

function COrgWelfareItemBox.SetRedPacketItem(self, v)
    self.m_GetAwardBtn:SetText("查看")
    self.m_ActivityInput:SetActive(false)
    self.m_GetAwardOther:SetActive(false)
    if v.other == "" then
        local v3 =  self.m_ActivityDes:GetLocalPos()
        v3.y = 1
       self.m_ActivityDes:SetLocalPos(v3)
    end
    self.m_GetAwardBtn:SetGrey(false) 

    self:CheckOrgRedPoint()
end

function COrgWelfareItemBox.CheckOrgRedPoint(self)
    if g_RedPacketCtrl.m_ShowOrgRedPoint then
        self.m_GetAwardBtn.m_IgnoreCheckEffect = true
        self.m_GetAwardBtn:AddEffect("RedDot", 20, Vector2.New(-13, -17))
    else
        self.m_GetAwardBtn:DelEffect("RedDot")
    end
end

function COrgWelfareItemBox.GetCoinReward(self, coinlist)
    local str = ""
    local cointype = {"#cur_1", "#cur_2", "#cur_3", "#cur_4", "#cur_7"}
    for i,v in ipairs(coinlist) do
        if v > 0 then
            str = string.format("%s %s %d", str, cointype[i], v)
        end
    end
    return str
end

function COrgWelfareItemBox.RefreshRewardGrid(self, coinlist)
    self.m_RewardGrid:Clear()
    local cointype = {"10001", "10221", "10002", "10003", "10203"}
    for i,v in ipairs(coinlist) do
        if v > 0 then
            local oBox = self.m_RewardBox:Clone()
            oBox.m_RewardSpr = oBox:NewUI(1, CSprite)
            oBox.m_RewardL = oBox:NewUI(2, CLabel)
            oBox:SetActive(true)

            oBox.m_RewardSpr:SetSpriteName(cointype[i])
            oBox.m_RewardL:SetText(v)
            self.m_RewardGrid:AddChild(oBox)
        end
    end

    self.m_RewardGrid:Reposition()
end

function COrgWelfareItemBox.OnGetAward(self, v)
    if v.id == self.m_ItemDic.sign then  
        if self.m_CurStatuInfo.sign_status == 1 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1098].content)
            return
        end
        local msg = self.m_ActivityInput:GetText()
        --or string.isIllegal(msg) == false
        if g_MaskWordCtrl:IsContainMaskWord(msg) then 
		    g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
		    return
	    end

        if self.bShowConfig then
            IOTools.SetClientData("org_sign_Config"..g_AttrCtrl.pid, v.other)
        end

        IOTools.SetClientData("org_sign_"..g_AttrCtrl.pid, msg)

        netorg.C2GSOrgSign(msg)
    elseif v.id == self.m_ItemDic.dividend then
        if g_AttrCtrl.org_pos == 7 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1156].content)
            return
        elseif self.m_CurStatuInfo.bonus_status == 0 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1100].content)
            return
        elseif self.m_CurStatuInfo.bonus_status == 2 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1102].content)
            return
        end
        netorg.C2GSReceiveBonus()
    elseif v.id == self.m_ItemDic.award then
        if self.m_CurStatuInfo.pos_status == 0 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1100].content)
            return
        elseif self.m_CurStatuInfo.pos_status == 2 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1102].content)
            return
        end
        netorg.C2GSReceivePosBonus()
    elseif v.id == self.m_ItemDic.goal then
        netorg.C2GSGetAchieveInfo()
    elseif v.id == self.m_ItemDic.activity then
        local oView = COrgInfoView:GetView()
        local dViewDefine = data.viewdefinedata.DEFINE
        oView:ShowSubPageByIndex(dViewDefine.OrgInfo.tab.Building)
        COrgActivityView:ShowView()
    elseif v.id == self.m_ItemDic.redpacket then
        --TODO 红包逻辑
        CRedPacketMainView:ShowView(function (oView)
            oView:ShowOrgPart()
        end)
        g_RedPacketCtrl.m_ShowOrgRedPoint = false
        g_OrgCtrl:OnEvent(define.Org.Event.UpdateOrgRedPoint)
    end
end

function COrgWelfareItemBox.IsStringWithAllBlock(self, text)
    local len = 0
    for i=1, #text do
        local c = string.byte(text, i)
        if not c then break end
        if c == 32 then
            len = len + 1
        end
    end
    return len == #text
end

return COrgWelfareItemBox